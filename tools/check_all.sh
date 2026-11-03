#!/bin/sh
# Checks before a commit: Lua syntax of every file, complete translations, no unused or missing keys.
# Install as a hook once with:  sh tools/install_hooks.sh
cd "$(dirname "$0")/.." || exit 1
fail=0
for f in $(git ls-files 'WoWForeverDiary/*.lua'); do
    luac -p "$f" || { echo "Syntax error in $f"; fail=1; }
done
PY=py
command -v py >/dev/null 2>&1 || PY=python
$PY tools/check_locales.py || fail=1
$PY tools/check_usage.py || fail=1
exit $fail
