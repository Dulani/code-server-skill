#!/usr/bin/env bash
set -euo pipefail

TARGET_DIR="${1:-$PWD}"
START_PORT="${CODE_SERVER_START_PORT:-13337}"
END_PORT="${CODE_SERVER_END_PORT:-13399}"

if ! command -v code-server >/dev/null 2>&1; then
  echo "ERROR: code-server is not installed. macOS: brew install code-server; Arch: yay -S code-server" >&2
  exit 1
fi

if ! command -v tmux >/dev/null 2>&1; then
  echo "ERROR: tmux is not installed." >&2
  exit 1
fi

if ! command -v lsof >/dev/null 2>&1; then
  echo "ERROR: lsof is not installed (needed to find a free port)." >&2
  exit 1
fi

if [[ ! -d "$TARGET_DIR" ]]; then
  echo "ERROR: target directory does not exist: $TARGET_DIR" >&2
  exit 1
fi

TARGET_DIR="$(python3 - "$TARGET_DIR" <<'PY'
import os
import sys

print(os.path.realpath(sys.argv[1]))
PY
)"

DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
SETTINGS_FILE="$DATA_HOME/code-server/User/settings.json"
mkdir -p "$(dirname "$SETTINGS_FILE")"

python3 - "$SETTINGS_FILE" <<'PY'
import json
import os
import sys

path = sys.argv[1]
data = {}
if os.path.exists(path):
    try:
        with open(path, "r", encoding="utf-8") as f:
            data = json.load(f)
    except Exception:
        data = {}

data["workbench.startupEditor"] = "none"
# Default to a dark theme so every invocation (and every machine) looks consistent.
# Keep "Dark 2026" unless a user overrides it after launch.
if "workbench.colorTheme" not in data:
    data["workbench.colorTheme"] = "Dark 2026"

with open(path, "w", encoding="utf-8") as f:
    json.dump(data, f, indent=2)
    f.write("\n")
PY

PORT="$START_PORT"
while lsof -i :"$PORT" >/dev/null 2>&1 && [[ "$PORT" -lt "$END_PORT" ]]; do
  PORT=$((PORT + 1))
done

if lsof -i :"$PORT" >/dev/null 2>&1; then
  echo "ERROR: No free ports in range $START_PORT-$END_PORT" >&2
  exit 1
fi

SESSION="cs-$PORT"
URL="http://127.0.0.1:$PORT"
FOLDER_URL="$(python3 - "$URL" "$TARGET_DIR" <<'PY'
import sys
import urllib.parse

base_url, target_dir = sys.argv[1], sys.argv[2]
print(f"{base_url}/?folder={urllib.parse.quote(target_dir)}")
PY
)"

printf -v QUOTED_TARGET '%q' "$TARGET_DIR"

tmux new-session -d -s "$SESSION" \
  "code-server --auth none --bind-addr 127.0.0.1:$PORT \
   --disable-telemetry --disable-update-check \
   --disable-getting-started-override --disable-workspace-trust \
   --ignore-last-opened --idle-timeout-seconds 3600 $QUOTED_TARGET"

READY=0
for _ in $(seq 1 30); do
  if curl -sf "$URL/healthz" >/dev/null 2>&1; then
    READY=1
    break
  fi
  sleep 1
done

if [[ "$READY" -ne 1 ]]; then
  echo "ERROR: code-server did not start within 30 seconds" >&2
  tmux kill-session -t "$SESSION" 2>/dev/null || true
  exit 1
fi

# Launch the browser cross-platform (macOS: open, Linux: xdg-open)
# Fall back to just printing the URL if no browser launcher exists.
if command -v xdg-open >/dev/null 2>&1; then
  xdg-open "$FOLDER_URL" >/dev/null 2>&1 &
elif command -v open >/dev/null 2>&1; then
  open "$FOLDER_URL"
fi

echo "code-server ready at $URL"
echo "Folder URL: $FOLDER_URL"
echo "Session: $SESSION"
echo "Directory: $TARGET_DIR"
