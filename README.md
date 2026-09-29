# wallsplash

A new AI-painted wallpaper on your desktop every day.

`generate.sh` asks `claude` to write a self-contained HTML canvas painting
(impressionist landscapes, seeded by the date), renders it headless in Chrome
at your primary display's native resolution, and sets it as the wallpaper on
every desktop.

## setup

```bash
./install.sh        # schedule daily run at 08:00 via launchd
./generate.sh       # or run one right now
```

## requirements

- `claude` CLI (authed, or set `ANTHROPIC_API_KEY` in a `.env` file here)
- Google Chrome at `/Applications/Google Chrome.app`
- macOS will ask once to let the script control System Events

## files

- `prompt.txt` — the painting brief sent to claude (`{{SEED}}`, `{{DATE}}` get substituted)
- `generate.sh` — the whole pipeline
- `install.sh` + `com.wallsplash.daily.plist` — the daily schedule
- `out/` — generated scenes and PNGs (gitignored)

## notes

- Renders for the primary display only. The other monitor gets the same image cropped.
- Logs go to `out/agent.log` when run by launchd.
- Uninstall: `launchctl unload ~/Library/LaunchAgents/com.wallsplash.daily.plist`
