#!/usr/bin/env bash
# check-deps.sh — scan mode only (gates / CI / manual). Counts direct
# dependencies and fails if over the cap. The "ask first" rule lives in
# CLAUDE.md; this makes drift visible with a number.
set -u

# ==== repo config (owned by this repo; survives kit re-sync) ==================
MAX_DEPS={{MAX_DEPS}}   # direct deps cap, e.g. 12
# First existing manifest in this order wins. requirements.txt deliberately
# precedes pyproject.toml: a skeleton pyproject with dependencies=[] would
# false-PASS silently, while a freeze-dump requirements.txt false-FAILS
# loudly — fail-visible beats fail-silent. Reorder here if pyproject is the
# real manifest in this repo.
MANIFEST_ORDER="package.json requirements.txt pyproject.toml"
# ==== end repo config =========================================================

# ==== kit code v{{KIT_VERSION}} (replaced wholesale on re-sync; do not hand-edit)
KIT_VERSION="{{KIT_VERSION}}"   # repo-governance kit version this file was synced from

warn() { echo "$*" >&2; }

# Execution-probed interpreter: `command -v` alone is not enough (the
# Microsoft Store python3 shim exists on PATH but cannot run).
find_py() {
  local c
  for c in python3 python py; do
    if "$c" -c 'pass' >/dev/null 2>&1; then printf '%s' "$c"; return; fi
  done
  printf ''
}

found=""
for m in $MANIFEST_ORDER; do
  [ -f "$m" ] && { found="$m"; break; }
done

if [ -z "$found" ]; then
  echo "check-deps: no manifest found; skipping." >&2
  exit 0
fi

count=""
case "$found" in
  package.json)
    if command -v jq >/dev/null 2>&1; then
      count="$(jq '[(.dependencies//{}),(.devDependencies//{})] | map(keys) | add | length' package.json 2>/dev/null)"
    fi
    if [ -z "$count" ] && command -v node >/dev/null 2>&1; then
      count="$(node -e 'const d=require("./package.json");process.stdout.write(String(Object.keys(d.dependencies||{}).length+Object.keys(d.devDependencies||{}).length))' 2>/dev/null)"
    fi
    if [ -z "$count" ]; then
      PYBIN="$(find_py)"
      [ -n "$PYBIN" ] && count="$("$PYBIN" -c 'import json;d=json.load(open("package.json"));print(len(d.get("dependencies",{}))+len(d.get("devDependencies",{})))' 2>/dev/null)"
    fi
    ;;
  requirements.txt)
    count="$(grep -cvE '^\s*(#|$|-r|-e)' requirements.txt || true)"
    ;;
  pyproject.toml)
    PYBIN="$(find_py)"
    if [ -n "$PYBIN" ]; then
      count="$("$PYBIN" - << 'PY' 2>/dev/null
import sys
try:
    import tomllib
    d = tomllib.load(open("pyproject.toml","rb"))
except Exception:
    print(""); sys.exit()
n = len(d.get("project",{}).get("dependencies",[]))
for extra in d.get("project",{}).get("optional-dependencies",{}).values():
    n += len(extra)
print(n)
PY
)"
    fi
    ;;
esac
count="${count%$'\r'}"

if [ -z "$count" ]; then
  warn "check-deps: WARNING - cannot count deps in $found (no jq/node/working python). FAILING OPEN."
  exit 0
fi

if [ "$count" -gt "$MAX_DEPS" ]; then
  warn "OVER LIMIT: $count direct dependencies in $found (max $MAX_DEPS)."
  warn "New dependencies require asking first. (CLAUDE.md invariant)"
  exit 1
fi
echo "check-deps: $count/$MAX_DEPS direct dependencies ($found)."
exit 0
