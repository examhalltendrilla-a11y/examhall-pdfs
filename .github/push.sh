#!/usr/bin/env bash
# Push the PDFs dropped into this folder and print their direct links.
# Usage: bash .github/push.sh
set -euo pipefail
cd /workspaces/examhall-pdfs
OWNER=examhalltendrilla-a11y
# Match GitHub exactly first (after a Flush this drops old files and history).
# New, not-yet-pushed PDFs are untracked, so they are kept.
git fetch -q origin main && git reset -q --hard origin/main
shopt -s nullglob nocaseglob
new=()
for f in *.pdf; do git ls-files --error-unmatch "$f" >/dev/null 2>&1 || new+=("$f"); done
if [ ${#new[@]} -eq 0 ]; then echo "No new PDFs. Drag them into the examhall-pdfs folder first."; exit 1; fi
for f in "${new[@]}"; do
  mb=$(( $(stat -c %s "$f") / 1048576 ))
  if [ "$mb" -gt 95 ]; then echo "Too large (${mb} MB, limit 95): $f"; exit 1; fi
done
git add -- "${new[@]}"
git commit -q -m "Add ${#new[@]} PDF(s) $(date -u +%Y-%m-%dT%H:%MZ)"
git push -q origin HEAD:main
echo "Pushed ${#new[@]} PDF(s). Direct links:"
for f in "${new[@]}"; do
  echo "https://raw.githubusercontent.com/${OWNER}/examhall-pdfs/main/$(python3 -c 'import sys,urllib.parse;print(urllib.parse.quote(sys.argv[1]))' "$f")"
done
