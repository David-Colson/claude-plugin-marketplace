#!/usr/bin/env bash
# check-file-length.sh — modes:
#   --hook (stdin JSON): PostToolUse on Write|Edit — checks the file just
#     written. Exit 2 reports the violation back to the agent.
#   --scan: checks all tracked source files (gates / CI / manual). Exit 1 on
#     violation. Batched (two greps -> one wc -> one awk): a per-file loop
#     costs ~100ms per process spawn under Git Bash / MSYS.
#   --write-baseline: ADOPTION-TIME ONLY — records current over-limit files as
#     per-file ceilings (may shrink, never grow). Refuses to run when a
#     non-empty baseline exists: a re-run could RAISE ceilings and erases seam
#     flags; after adoption the baseline moves in one direction, via --tighten.
#   --tighten: lowers ceilings to current reality (run at milestone/round
#     close-out). Never raises; never adds a row; a row whose file fell
#     to/under MAX_LINES (or left the tree) drops. A row tagged `seam` (3rd
#     column: files that grow with every feature by design) keeps 10% headroom
#     over its CURRENT size instead of tightening to the exact count.
#   No args: DEPRECATED legacy dispatch (hook if stdin carries a file_path,
#     scan otherwise). Pass --hook / --scan explicitly.
# Requires gawk-compatible awk (/dev/stderr) — Git Bash, WSL, Linux all fine.
set -u

# ==== repo config (owned by this repo; survives kit re-sync) ==================
MAX_LINES={{MAX_FILE_LINES}}          # e.g. 300
BASELINE_FILE="scripts/checks/length-baseline.txt"   # <lines><TAB><path>[<TAB>seam]
EXT_REGEX='\.(py|ts|tsx|js|jsx|mjs|go|rs|rb|java|cs|sh)$'
# css is deliberately NOT governed: line-y, low-density markup the cap was
# never aimed at. Add it here only as a recorded decision.
EXEMPT_REGEX='(^|/)(node_modules|dist|build|vendor|\.git|migrations)(/|$)|(_test|\.test|\.spec)\.|lock'
# ==== end repo config =========================================================

# ==== kit code v{{KIT_VERSION}} (replaced wholesale on re-sync; do not hand-edit)
KIT_VERSION="{{KIT_VERSION}}"   # repo-governance kit version this file was synced from

warn() { echo "$*" >&2; }

# Windows-safe path normalization: tool paths arrive as `D:\Dev\...` while Git
# Bash's $PWD is `/d/Dev/...`. Convert backslashes, normalize the MSYS drive
# form, and strip the project prefix case-insensitively (NTFS is
# case-insensitive; on case-sensitive filesystems a differently-cased prefix
# could in principle mis-strip — accepted, vanishingly rare).
norm() {
  local p proj lp lproj
  p="$(printf '%s' "$1" | tr '\\' '/')"
  proj="$(printf '%s' "${CLAUDE_PROJECT_DIR:-$PWD}" | tr '\\' '/')"
  case "$proj" in
    /[a-zA-Z]/*) proj="${proj:1:1}:${proj:2}" ;;  # MSYS /d/... -> d:/...
  esac
  case "$p" in
    /[a-zA-Z]/*) p="${p:1:1}:${p:2}" ;;
  esac
  lp="$(printf '%s' "$p" | tr 'A-Z' 'a-z')"
  lproj="$(printf '%s' "$proj" | tr 'A-Z' 'a-z')"
  case "$lp" in
    "$lproj"/*) p="${p:$(( ${#proj} + 1 ))}" ;;
  esac
  p="${p#./}"
  printf '%s' "$p"
}

baseline_ceiling() {  # $1 = normalized path -> prints recorded ceiling, if any
  [ -f "$BASELINE_FILE" ] || return 0
  awk -F'\t' -v p="$1" '$2==p{print $1; exit}' "$BASELINE_FILE"
}

check_one() {
  local f; f="$(norm "$1")"
  case "$f" in
    [a-zA-Z]:/*|//*) return 0 ;;  # outside the repo — not governed
  esac
  [ -f "$f" ] || return 0
  printf '%s\n' "$f" | grep -Eq "$EXT_REGEX" || return 0
  printf '%s\n' "$f" | grep -Eq "$EXEMPT_REGEX" && return 0
  local n limit ceil
  n=$(wc -l < "$f")
  limit="$MAX_LINES"
  ceil="$(baseline_ceiling "$f")"
  if [ -n "${ceil:-}" ] && [ "$ceil" -gt "$MAX_LINES" ]; then
    limit="$ceil"
    if [ "$n" -gt "$limit" ]; then
      warn "RATCHET VIOLATION: $f is $n lines; its recorded ceiling is $ceil. Legacy files may shrink, never grow. (CLAUDE.md invariant)"
      return 1
    fi
    return 0
  fi
  if [ "$n" -gt "$limit" ]; then
    warn "OVER LIMIT: $f is $n lines (max $MAX_LINES). Split before adding to it. (CLAUDE.md invariant)"
    return 1
  fi
  return 0
}

list_files() {
  if command -v git >/dev/null 2>&1 && git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    git ls-files
  else
    find . -type f
  fi
}

# Filtered `wc -l` over every governed file, one line per file. Paths with
# spaces are reassembled downstream; paths with tabs are unsupported.
counted() {
  list_files | grep -E "$EXT_REGEX" | grep -Ev "$EXEMPT_REGEX" \
    | tr '\n' '\0' | xargs -0 wc -l 2>/dev/null
}

scan_all() {
  counted | awk -v max="$MAX_LINES" -v bf="$BASELINE_FILE" '
    BEGIN {
      while ((getline line < bf) > 0) {
        split(line, a, "\t"); ceil[a[2]] = a[1] + 0
      }
    }
    $2 == "total" { next }
    {
      n = $1 + 0; f = $2
      for (i = 3; i <= NF; i++) f = f " " $i   # paths with spaces
      limit = (f in ceil && ceil[f] > max) ? ceil[f] : max
      if (n > limit) {
        if (f in ceil)
          printf "RATCHET VIOLATION: %s is %d lines; its recorded ceiling is %d. Legacy files may shrink, never grow.\n", f, n, ceil[f] > "/dev/stderr"
        else
          printf "OVER LIMIT: %s is %d lines (max %d). Split before adding to it.\n", f, n, max > "/dev/stderr"
        bad = 1
      }
    }
    END { exit bad ? 1 : 0 }
  '
}

# Unified JSON extraction: first candidate producing NON-EMPTY output wins —
# `command -v` alone is not enough (the Microsoft Store python3 shim exists on
# PATH but emits nothing, so enforcement failed open silently). CR-stripped
# per candidate (Windows python emits \r\n).
extract_path() {  # reads $INPUT
  local out c
  if command -v jq >/dev/null 2>&1; then
    out="$(printf '%s' "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null)"
    out="${out%$'\r'}"; [ -n "$out" ] && { printf '%s' "$out"; return; }
  fi
  if command -v node >/dev/null 2>&1; then
    out="$(printf '%s' "$INPUT" | node -e 'let s="";process.stdin.on("data",d=>s+=d).on("end",()=>{try{process.stdout.write(JSON.parse(s).tool_input?.file_path??"")}catch{}})' 2>/dev/null)"
    out="${out%$'\r'}"; [ -n "$out" ] && { printf '%s' "$out"; return; }
  fi
  for c in python3 python py; do
    command -v "$c" >/dev/null 2>&1 || continue
    out="$(printf '%s' "$INPUT" | "$c" -c 'import sys,json
try:
    print(json.load(sys.stdin).get("tool_input",{}).get("file_path",""))
except Exception:
    print("")' 2>/dev/null)"
    out="${out%$'\r'}"; [ -n "$out" ] && { printf '%s' "$out"; return; }
  done
  printf ''
}

run_hook() {  # expects $INPUT already read
  local fp
  fp="$(extract_path)"
  if [ -z "$fp" ]; then
    [ -n "$INPUT" ] && warn "check-file-length: WARNING - no file_path extracted (no working jq/node/python, or field absent). Enforcement is FAILING OPEN."
    exit 0
  fi
  check_one "$fp" || exit 2
  exit 0
}

case "${1:-}" in
  --hook)
    INPUT="$(cat)"
    run_hook
    ;;
  --scan)
    scan_all; exit $?
    ;;
  --write-baseline)
    if [ -s "$BASELINE_FILE" ]; then
      warn "check-file-length: baseline exists ($BASELINE_FILE); ceilings only move down via --tighten."
      warn "Delete the baseline first ONLY if deliberately re-adopting (this erases seam flags)."
      exit 1
    fi
    mkdir -p "$(dirname "$BASELINE_FILE")"
    counted | awk -v max="$MAX_LINES" '
      $2 == "total" { next }
      {
        n = $1 + 0; f = $2
        for (i = 3; i <= NF; i++) f = f " " $i
        if (n > max) printf "%d\t%s\n", n, f
      }
    ' | sort -t "$(printf '\t')" -k2 > "$BASELINE_FILE"
    echo "Baseline written: $(wc -l < "$BASELINE_FILE") legacy over-limit file(s) in $BASELINE_FILE (ceiling = current count)."
    exit 0
    ;;
  --tighten)
    [ -f "$BASELINE_FILE" ] || { echo "check-file-length: no baseline to tighten (nothing to do)."; exit 0; }
    tmp="$(mktemp)"
    counted | awk -v max="$MAX_LINES" -v bf="$BASELINE_FILE" '
      BEGIN {
        while ((getline line < bf) > 0) {
          split(line, a, "\t"); ceil[a[2]] = a[1] + 0; seam[a[2]] = a[3]
        }
      }
      $2 == "total" { next }
      {
        n = $1 + 0; f = $2
        for (i = 3; i <= NF; i++) f = f " " $i   # paths with spaces
        if (!(f in ceil)) next                    # tighten never ADDS a row
        want = (seam[f] == "seam") ? int(n * 1.1 + 0.5) : n
        new = (want < ceil[f]) ? want : ceil[f]   # never raise
        if (new > max)
          printf "%d\t%s%s\n", new, f, (seam[f] == "seam" ? "\tseam" : "")
        # else: at/under the cap now — the row drops, the standard cap rules.
        # Rows for files no longer in the tree drop the same way (no wc line).
      }
    ' | sort -t "$(printf '\t')" -k2 > "$tmp"
    mv "$tmp" "$BASELINE_FILE"
    echo "Baseline tightened: $(wc -l < "$BASELINE_FILE") ceiling(s) remain in $BASELINE_FILE."
    exit 0
    ;;
  "")
    # Legacy dispatch, kept for one version so a partially re-synced repo
    # (script updated, settings.json not) degrades to working old behavior.
    if [ ! -t 0 ]; then
      INPUT="$(cat)"
      if [ -n "$INPUT" ]; then
        warn "check-file-length: DEPRECATED no-args hook invocation; pass --hook in .claude/settings.json."
        run_hook
      fi
    fi
    scan_all; exit $?
    ;;
  *)
    warn "check-file-length: unknown argument '$1' (expected --hook | --scan | --write-baseline | --tighten)."
    exit 1
    ;;
esac
