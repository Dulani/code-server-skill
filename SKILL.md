---
name: code-server
description: >
  Spin up code-server (VS Code in browser) to view agent-generated files.
  Use when asked to: "spin up code-server", "open in browser", "view these files",
  "browse this directory", "show me what you created", "start a viewer",
  "launch VS Code in browser", "open a file browser", "preview these files",
  "show me the output", "open a code viewer".
  Provides file tree, syntax highlighting, markdown preview, and terminal.
---

# code-server Viewer Skill

## Overview

This skill spins up an ephemeral VS Code-in-browser instance (code-server) so users can
immediately browse agent-generated artifacts — markdown reports, code files, HTML output —
with a full file tree, syntax highlighting, and live markdown preview. The server runs
locally on `127.0.0.1` only, requires no authentication, and automatically shuts down
after 1 hour of idle time. Use it after generating files the user wants to explore
visually. A single `open` command launches the browser to the correct URL.

---

## Prerequisites

```bash
# Check if code-server is installed
which code-server || echo "NOT INSTALLED — run: brew install code-server"
```

If not installed:
```bash
brew install code-server
# Binary will be at: /opt/homebrew/bin/code-server
# Version tested: 4.112.0
```

---

## Quick Start

Open a directory in code-server with one block:

```bash
TARGET_DIR="$HOME/my-project"   # ← change this

PORT=13337
while lsof -i :$PORT &>/dev/null && [ $PORT -lt 13399 ]; do PORT=$((PORT + 1)); done
SESSION="cs-$PORT"
tmux new-session -d -s "$SESSION" \
  "code-server --auth none --bind-addr 127.0.0.1:$PORT \
   --disable-telemetry --disable-update-check \
   --idle-timeout-seconds 3600 '$TARGET_DIR'"
for i in $(seq 1 30); do
  curl -sf "http://127.0.0.1:$PORT/healthz" &>/dev/null && break
  sleep 1
done
open "http://127.0.0.1:$PORT"
echo "Opened: http://127.0.0.1:$PORT  (session: $SESSION)"
```

---

## Recipes

### Start

Full start recipe with port auto-selection, healthz polling, and browser auto-open:

```bash
TARGET_DIR="/path/to/directory"   # ← set this to the directory to open

# Find a free port in range 13337-13399
PORT=13337
while lsof -i :$PORT &>/dev/null && [ $PORT -lt 13399 ]; do
  PORT=$((PORT + 1))
done
if lsof -i :$PORT &>/dev/null; then
  echo "ERROR: No free ports in range 13337-13399" >&2
  exit 1
fi

SESSION="cs-$PORT"

# Start code-server in a detached tmux session
tmux new-session -d -s "$SESSION" \
  "code-server --auth none --bind-addr 127.0.0.1:$PORT \
   --disable-telemetry --disable-update-check \
   --idle-timeout-seconds 3600 '$TARGET_DIR'"

# Poll healthz until ready (up to 30s)
URL="http://127.0.0.1:$PORT"
READY=0
for i in $(seq 1 30); do
  if curl -sf "$URL/healthz" &>/dev/null; then
    READY=1
    break
  fi
  sleep 1
done

if [ $READY -eq 0 ]; then
  echo "ERROR: code-server did not start within 30s" >&2
  tmux kill-session -t "$SESSION" 2>/dev/null
  exit 1
fi

echo "code-server ready at $URL"
echo "Session: $SESSION  |  Directory: $TARGET_DIR"
open "$URL"
```

> **Note**: First launch may take 10–20s as code-server downloads assets. Subsequent
> starts on the same machine are faster.

---

### Status

Check all running code-server instances:

```bash
echo "=== Running code-server instances ==="
FOUND=0
tmux list-sessions 2>/dev/null | grep "^cs-" | while IFS=: read -r session rest; do
  PORT="${session#cs-}"
  if curl -sf "http://127.0.0.1:$PORT/healthz" &>/dev/null; then
    echo "  $session → http://127.0.0.1:$PORT  [healthy]"
  else
    echo "  $session → port $PORT  [ZOMBIE — tmux alive but healthz failed]"
  fi
  FOUND=1
done
tmux list-sessions 2>/dev/null | grep -q "^cs-" || echo "  No code-server instances running"
```

---

### Stop

Stop a specific instance by port, or stop all:

```bash
# Stop by port
PORT=13337
tmux kill-session -t "cs-$PORT" 2>/dev/null \
  && echo "Stopped cs-$PORT" \
  || echo "Session cs-$PORT not found"

# Stop all instances
tmux list-sessions 2>/dev/null | grep "^cs-" | cut -d: -f1 | while read -r session; do
  tmux kill-session -t "$session" && echo "Stopped $session"
done
tmux list-sessions 2>/dev/null | grep -q "^cs-" || echo "All code-server instances stopped"
```

---

### Cleanup

Kill all cs-* sessions and verify ports are freed:

```bash
echo "Cleaning up all code-server instances..."
tmux list-sessions 2>/dev/null | grep "^cs-" | cut -d: -f1 | while read -r session; do
  PORT="${session#cs-}"
  tmux kill-session -t "$session" 2>/dev/null
  # Wait for port to release (up to 5s)
  for i in $(seq 1 5); do
    lsof -i :$PORT &>/dev/null || break
    sleep 1
  done
  echo "  Cleaned: $session (port $PORT)"
done
REMAINING=$(tmux list-sessions 2>/dev/null | grep "^cs-" | wc -l | tr -d ' ')
echo "Cleanup complete. Remaining cs-* sessions: $REMAINING"
```

---

## Troubleshooting

| Issue | Cause | Fix |
|-------|-------|-----|
| Port already in use | Another process on 13337 | Start recipe auto-increments; `lsof -i :13337` to identify |
| First launch slow (10–20s) | Asset download on first run | Healthz loop handles this; subsequent starts are faster |
| High memory (~600MB) | VS Code runtime | Expected; stop when done: `tmux kill-session -t cs-PORT` |
| Zombie session (tmux alive, healthz fails) | code-server crashed inside tmux | Run cleanup recipe; `tmux attach -t cs-PORT` to see error |
| Port in TIME_WAIT state | Recent stop, OS holding port | Wait 30–60s or use next port in range |
| Browser didn't open | `open` command failed | Navigate manually to `http://127.0.0.1:PORT` |
| No free ports in range | All 13337–13399 occupied | Stop old instances with cleanup recipe |

---

## Tips

- **Markdown preview**: Open any `.md` file → `Cmd+Shift+V` (or click the preview icon top-right)
- **File tree**: Left sidebar shows the full directory structure
- **Terminal**: `` Ctrl+` `` opens the integrated terminal
- **Multiple directories**: Start separate instances — each gets its own port and tmux session
- **URL format**: Always `http://127.0.0.1:PORT` — no password, no HTTPS needed
- **Idle shutdown**: Server auto-exits after 1 hour of no browser activity (`--idle-timeout-seconds 3600`)

---

## Future Enhancements (Plugin Approach)

A future OpenCode plugin could provide dedicated tools: `start_code_server(directory, port?)`,
`stop_code_server(port)`, `list_code_servers()`. The plugin would track port state across
sessions, auto-cleanup on session end, and surface the URL directly in the OpenCode UI.
This would eliminate the need for agents to manage tmux sessions manually. Implementation
would follow the OpenCode plugin API (TypeScript, `opencode.json` registration).
