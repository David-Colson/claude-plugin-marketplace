#!/usr/bin/env bash
# selftest.sh — proof harness for the installed governance checks. Run at
# ADOPTION and RE-SYNC only; never wired into hooks or gates (a proof tool,
# not a recurring gate). It drives the real scripts with simulated hook stdin
# so enforcement is proven, not improvised — hand-rolled probes have twice
# produced false results (echo-mangled JSON; inline traces through the tool's
# escaping layer). It also replays the hook command lines from
# .claude/settings.json, catching script/settings drift (e.g. a missing
# --hook after re-sync). Probe values are parsed from the sibling scripts'
# config regions, so this file needs no per-repo config to stay honest.
# Assumes the hook payload shape `.tool_input.file_path` (Claude Code docs).
set -u
cd "$(dirname "$0")/../.." || exit 1
CHECKS="scripts/checks"

# ==== repo config (owned by this repo; survives kit re-sync) ==================
SCRATCH_PREFIX="selftest-scratch"   # temp probe files created in repo root
# ==== end repo config =========================================================

# ==== kit code v{{KIT_VERSION}} (replaced wholesale on re-sync; do not hand-edit)
KIT_VERSION="{{KIT_VERSION}}"   # repo-governance kit version this file was synced from

PASS=0; FAIL=0; SKIP=0
ok()   { PASS=$((PASS+1)); echo "PASS  $1"; }
bad()  { FAIL=$((FAIL+1)); echo "FAIL  $1"; [ -n "${2:-}" ] && printf '%s\n' "$2" | sed 's/^/      /'; }
skip() { SKIP=$((SKIP+1)); echo "SKIP  $1 ($2)"; }

json_for() { printf '{"tool_input":{"file_path":"%s"}}' "$1"; }
winjson()  {  # drive-form path with doubled backslashes, JSON-escaped
  local p="$1"
  case "$p" in /[a-zA-Z]/*) p="${p:1:1}:${p:2}" ;; esac
  json_for "$(printf '%s' "$p" | sed 's|/|\\\\|g')"
}
run() {  # name expected_exit script json  -> also fails on FAILING OPEN text
  local name="$1" want="$2" script="$3" json="$4" out rc
  out="$(printf '%s' "$json" | bash "$CHECKS/$script" --hook 2>&1)"; rc=$?
  if [ "$rc" -ne "$want" ]; then bad "$name (exit $rc, wanted $want)" "$out"
  elif printf '%s' "$out" | grep -q "FAILING OPEN"; then bad "$name (failing open)" "$out"
  else ok "$name"; fi
}

cfg() { sed -n "s/^$2=\"\{0,1\}\([^\"#]*[^\"# ]\).*/\1/p" "$CHECKS/$1" | head -1; }
arr() {  # $1=file $2=array-name -> uncommented quoted entries, one per line
  awk -v a="$2" 'index($0, a"=(")==1 {f=1; next} f && /^\)/ {f=0} f' "$CHECKS/$1" \
    | sed -n 's/^[[:space:]]*"\([^"]*\)".*/\1/p'
}

MAX_LINES="$(cfg check-file-length.sh MAX_LINES)"
BASELINE_FILE="$(cfg check-file-length.sh BASELINE_FILE)"
EXT="$(sed -n '/^EXT_REGEX=/{s/.*(\([a-z0-9]*\)|.*/\1/p;}' "$CHECKS/check-file-length.sh" | head -1)"
[ -n "$EXT" ] || EXT="sh"
SCRATCH="$SCRATCH_PREFIX-overcap.$EXT"
TMP_A="$(mktemp)"; TMP_B="$(mktemp)"; TMP_C="$(mktemp)"
trap 'rm -f "$SCRATCH" "$TMP_A" "$TMP_B" "$TMP_C"' EXIT

echo "governance selftest — kit v$KIT_VERSION — $(pwd)"

# T0: no CR anywhere in the check scripts (autocrlf corruption).
if grep -l $'\r' "$CHECKS"/*.sh >/dev/null 2>&1; then
  bad "T0 scripts are LF-only" "$(grep -l $'\r' "$CHECKS"/*.sh)"
else ok "T0 scripts are LF-only"; fi

# T1/T2: every repo-relative protected path blocks; first also in D:\ form.
i=0
while IFS= read -r p; do
  [ -n "$p" ] || continue
  i=$((i+1))
  run "T1.$i protected '$p' blocked" 2 check-source-writes.sh "$(json_for "$PWD/$p/probe.txt")"
  [ "$i" -eq 1 ] && run "T2 protected '$p' blocked (backslash form)" 2 check-source-writes.sh "$(winjson "$PWD/$p/probe.txt")"
done <<EOF
$(arr check-source-writes.sh PROTECTED_PATHS)
EOF
[ "$i" -eq 0 ] && skip "T1/T2 protected paths" "none configured"

# T3: absolute protections (entries are pre-normalized; nothing is written).
j=0
while IFS= read -r p; do
  [ -n "$p" ] || continue
  j=$((j+1))
  run "T3.$j absolute '$p' blocked" 2 check-source-writes.sh "$(json_for "$p/probe.txt")"
done <<EOF
$(arr check-source-writes.sh ABSOLUTE_PROTECTED)
EOF
[ "$j" -eq 0 ] && skip "T3 absolute protected" "none configured"

# T4: benign write allowed AND the extractor actually worked (the case that
# turns the Store-shim silent fail-open red).
run "T4 benign path allowed, extractor live" 0 check-source-writes.sh "$(json_for "$PWD/$SCRATCH_PREFIX-benign.txt")"

# T5: an over-cap new file trips the length hook.
if [ -n "$MAX_LINES" ]; then
  awk -v n="$((MAX_LINES+1))" 'BEGIN{for(i=0;i<n;i++)print "x"}' > "$SCRATCH"
  run "T5 over-cap new file ($((MAX_LINES+1)) lines) trips" 2 check-file-length.sh "$(json_for "$PWD/$SCRATCH")"
  rm -f "$SCRATCH"
else skip "T5 over-cap trip" "could not parse MAX_LINES"; fi

# T6: full scan is clean.
if out="$(bash "$CHECKS/check-file-length.sh" --scan 2>&1)"; then ok "T6 clean scan"
else bad "T6 clean scan" "$out"; fi

# T7/T8: ratchet + tighten (only when a baseline exists).
if [ -n "$BASELINE_FILE" ] && [ -s "$BASELINE_FILE" ]; then
  cp "$BASELINE_FILE" "$TMP_A"                       # original baseline
  bfile="$(head -1 "$BASELINE_FILE" | cut -f2)"
  bceil="$(head -1 "$BASELINE_FILE" | cut -f1)"
  if [ -f "$bfile" ]; then
    cp "$bfile" "$TMP_B"
    n="$(wc -l < "$bfile")"
    awk -v k="$((bceil - n + 1))" 'BEGIN{for(i=0;i<k;i++)print "// selftest"}' >> "$bfile"
    run "T7 ratchet trip on '$bfile'" 2 check-file-length.sh "$(json_for "$PWD/$bfile")"
    cp "$TMP_B" "$bfile"
    if cmp -s "$TMP_B" "$bfile"; then ok "T7b probe file restored byte-identical"
    else bad "T7b probe file restored byte-identical"; fi
  else skip "T7 ratchet trip" "baselined file '$bfile' missing"; fi
  bash "$CHECKS/check-file-length.sh" --tighten >/dev/null 2>&1
  cp "$BASELINE_FILE" "$TMP_C"
  bash "$CHECKS/check-file-length.sh" --tighten >/dev/null 2>&1
  if cmp -s "$TMP_C" "$BASELINE_FILE"; then ok "T8 tighten is idempotent"
  else bad "T8 tighten is idempotent"; fi
  cp "$TMP_A" "$BASELINE_FILE"                       # net side-effect-free
  if cmp -s "$TMP_A" "$BASELINE_FILE"; then ok "T8b baseline restored byte-identical"
  else bad "T8b baseline restored byte-identical"; fi
else skip "T7/T8 ratchet+tighten" "no baseline"; fi

# T9: deps count runs and does not fail open (if instantiated).
if [ -f "$CHECKS/check-deps.sh" ]; then
  out="$(bash "$CHECKS/check-deps.sh" 2>&1)"; rc=$?
  if [ $rc -ne 0 ]; then bad "T9 check-deps green (exit $rc)" "$out"
  elif printf '%s' "$out" | grep -q "FAILING OPEN"; then bad "T9 check-deps green (failing open)" "$out"
  else ok "T9 check-deps green"; fi
else skip "T9 check-deps" "not instantiated"; fi

# T10: replay the ACTUAL hook command lines from .claude/settings.json —
# catches script/settings drift the direct calls above cannot see.
if [ -f .claude/settings.json ]; then
  k=0
  for script in check-source-writes check-file-length; do
    cmd="$(grep "$script" .claude/settings.json | sed -n 's/^[[:space:]]*"command": "\(.*\)",\{0,1\}[[:space:]]*$/\1/p' | head -1 | sed 's/\\"/"/g')"
    if [ -z "$cmd" ]; then skip "T10 settings dispatch ($script)" "no command found"; continue; fi
    k=$((k+1))
    if [ "$script" = "check-source-writes" ] && [ "$i" -gt 0 ]; then
      pfirst="$(arr check-source-writes.sh PROTECTED_PATHS | head -1)"
      out="$(printf '%s' "$(json_for "$PWD/$pfirst/probe.txt")" | CLAUDE_PROJECT_DIR="$PWD" bash -c "$cmd" 2>&1)"; rc=$?
      [ $rc -eq 2 ] && ok "T10.$k settings dispatch blocks ($script)" || bad "T10.$k settings dispatch blocks ($script, exit $rc)" "$out"
    else
      out="$(printf '%s' "$(json_for "$PWD/$SCRATCH_PREFIX-benign.txt")" | CLAUDE_PROJECT_DIR="$PWD" bash -c "$cmd" 2>&1)"; rc=$?
      if [ $rc -eq 0 ] && ! printf '%s' "$out" | grep -q "FAILING OPEN"; then ok "T10.$k settings dispatch allows ($script)"
      else bad "T10.$k settings dispatch allows ($script, exit $rc)" "$out"; fi
    fi
  done
else skip "T10 settings dispatch" ".claude/settings.json absent"; fi

echo "----"
echo "selftest: $PASS passed, $FAIL failed, $SKIP skipped."
[ "$FAIL" -eq 0 ] && { echo "SELFTEST GREEN"; exit 0; }
echo "SELFTEST RED"; exit 1
