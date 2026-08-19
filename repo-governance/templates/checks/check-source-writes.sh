#!/usr/bin/env bash
# check-source-writes.sh — PreToolUse hook (matcher: Write|Edit|MultiEdit)
# Blocks agent Write/Edit calls to protected paths. Exit 2 = block (stderr is
# shown to the agent); exit 0 = allow. Invoke with --hook (accepted for
# settings.json uniformity; this script is hook-only, so it also runs with no
# args for one version of backward compatibility).
#
# NOTE: guards the Write/Edit tools only. Bash can still write; that layer is
# covered by the CLAUDE.md invariant and, where possible, filesystem perms.
set -u

# ==== repo config (owned by this repo; survives kit re-sync) ==================
# Entries are matched against a LOWERCASED, forward-slashed path — write them
# in lowercase (matching is case-insensitive as a result).
PROTECTED_PATHS=(
  "{{PROTECTED_PATH_1}}"   # e.g. "data/source"
  # ".env"        # common: never authored by an agent
  # ".gitignore"  # common: "never weaken .gitignore" made mechanical
)
# Paths OUTSIDE the repo (live production data, etc.). Entries must be
# pre-normalized: lowercase, forward slashes, `x:/` drive form —
# e.g. "c:/users/me/appdata/roaming/my-app".
ABSOLUTE_PROTECTED=(
)
# ==== end repo config =========================================================

# ==== kit code v{{KIT_VERSION}} (replaced wholesale on re-sync; do not hand-edit)
KIT_VERSION="{{KIT_VERSION}}"   # repo-governance kit version this file was synced from

warn() { echo "$*" >&2; }

INPUT="$(cat)"

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

# Windows-safe: lowercased, forward-slashed, `x:/...` drive form (tool paths
# arrive as `D:\Dev\...` while Git Bash's $PWD is `/d/Dev/...`).
norm_path() {
  local p
  p="$(printf '%s' "$1" | tr '\\' '/' | tr 'A-Z' 'a-z')"
  case "$p" in
    /[a-z]/*) p="${p:1:1}:${p:2}" ;;  # MSYS /d/... -> d:/...
  esac
  printf '%s' "$p"
}

FILE_PATH="$(extract_path)"
if [ -z "$FILE_PATH" ]; then
  [ -n "$INPUT" ] && warn "check-source-writes: WARNING - no file_path extracted (no working jq/node/python, or field absent). Protection is FAILING OPEN."
  exit 0
fi

NORM="$(norm_path "$FILE_PATH")"

# Absolute protections first — they apply regardless of where the repo is.
for p in ${ABSOLUTE_PROTECTED[@]+"${ABSOLUTE_PROTECTED[@]}"}; do
  [ -z "$p" ] && continue
  case "$NORM" in
    "$p"|"$p"/*)
      warn "BLOCKED: '$FILE_PATH' is under the protected path '$p'."
      warn "That location is protected outside this repo (live/original data). Derive from it; never write to it. (CLAUDE.md invariant)"
      exit 2
      ;;
  esac
done

# Repo-relative protections (matched case-insensitively via normalization).
PROJ="$(norm_path "${CLAUDE_PROJECT_DIR:-$PWD}")"
REL="$NORM"
case "$NORM" in
  "$PROJ"/*) REL="${NORM#"$PROJ"/}" ;;
esac

for p in ${PROTECTED_PATHS[@]+"${PROTECTED_PATHS[@]}"}; do
  [ -z "$p" ] && continue
  case "$REL" in
    "$p"|"$p"/*)
      warn "BLOCKED: '$REL' is under protected source path '$p'."
      warn "Original data is read-only reference material. Derive from it; never overwrite it. (CLAUDE.md invariant)"
      exit 2
      ;;
  esac
done

exit 0
