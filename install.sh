#!/bin/bash
# installs the daily LaunchAgent (runs generate.sh every day at 08:00)
set -euo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"
PLIST="$HOME/Library/LaunchAgents/com.wallsplash.daily.plist"

mkdir -p "$DIR/out"
sed "s|__DIR__|$DIR|g" "$DIR/com.wallsplash.daily.plist" > "$PLIST"
chmod +x "$DIR/generate.sh"

launchctl unload "$PLIST" 2>/dev/null || true
launchctl load "$PLIST"

echo "installed com.wallsplash.daily (daily 08:00)"
echo "logs: $DIR/out/agent.log"
echo "run now with: $DIR/generate.sh"
