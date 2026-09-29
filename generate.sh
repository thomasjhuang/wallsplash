#!/bin/bash
# wallsplash: one-shot daily AI wallpaper generator.
# claude writes a canvas painting -> chrome renders it at native res -> set as wallpaper.
set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"
OUT="$DIR/out"
mkdir -p "$OUT"

# launchd runs without your shell env; load .env if it exists
if [ -f "$DIR/.env" ]; then set -a; . "$DIR/.env"; set +a; fi

CLAUDE="${CLAUDE_BIN:-$HOME/.local/bin/claude}"
CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
TODAY="$(date +%F)"
SEED="$(date +%Y%m%d)"

# primary display pixel size (falls back to first display listed)
RES="$(system_profiler SPDisplaysDataType | awk '
  /Resolution:/ { res=$2 " " $4; if (!first) first=res }
  /Main Display: Yes/ { print res; found=1; exit }
  END { if (!found) print first }
')"
W="${RES%% *}"; H="${RES##* }"
echo "[wallsplash] rendering ${W}x${H} for $TODAY (seed $SEED)"

# 1. claude writes a self-contained html painting
"$CLAUDE" -p "$(sed -e "s/{{SEED}}/$SEED/g" -e "s/{{DATE}}/$TODAY/g" "$DIR/prompt.txt")" \
  | awk '/<!DOCTYPE|<html/{f=1} f{print} /<\/html>/{exit}' > "$OUT/scene.html"

[ -s "$OUT/scene.html" ] || { echo "[wallsplash] claude produced no html" >&2; exit 1; }

# 2. chrome headless screenshot at native res
PNG="$OUT/wallpaper-$TODAY.png"
"$CHROME" --headless=new --disable-gpu --hide-scrollbars \
  --force-device-scale-factor=1 --virtual-time-budget=20000 \
  --window-size="$W,$H" --screenshot="$PNG" \
  "file://$OUT/scene.html" >/dev/null 2>&1

[ -s "$PNG" ] || { echo "[wallsplash] chrome produced no png" >&2; exit 1; }
ln -sf "$(basename "$PNG")" "$OUT/current.png"

# 3. set on all desktops
osascript -e "tell application \"System Events\" to tell every desktop to set picture to POSIX file \"$PNG\""

echo "[wallsplash] done: $PNG"
