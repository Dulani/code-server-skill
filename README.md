# code-server Viewer Skill

Spin up an ephemeral VS Code-in-browser instance (code-server) to view agent-generated files — markdown reports, code, HTML output — with a full file tree, syntax highlighting, and live markdown preview.

## Overview

This skill gives any OpenCode agent a reliable, zero-configuration recipe for spinning up code-server as a local file viewer. The server runs on `127.0.0.1` only (no network exposure), requires no authentication, and auto-shuts down after 1 hour of idle time.

## Features

- **Auto port selection**: Finds a free port in range 13337–13399
- **Healthz polling**: Waits for server ready before opening browser
- **Auto browser open**: macOS `open` command launches the correct URL
- **tmux lifecycle**: Named sessions (`cs-PORT`) for easy management
- **Idle timeout**: `--idle-timeout-seconds 3600` kills forgotten instances
- **Status/stop/cleanup**: Full lifecycle recipes included

## Requirements

- macOS (uses `open` command for browser)
- [code-server](https://github.com/coder/code-server) — install via `brew install code-server`
- tmux

## Installation

```bash
brew install code-server
# Binary: /opt/homebrew/bin/code-server
# Version tested: 4.112.0
```

## Usage

Load this skill in OpenCode and ask the agent to:
- "spin up code-server for this directory"
- "open these files in a browser viewer"
- "show me what you created"
- "launch VS Code in browser"

The agent will start code-server, wait for it to be ready, and auto-open your browser.

## Security

- **Always** `--auth none` paired with `--bind-addr 127.0.0.1:PORT` (never `0.0.0.0`)
- Local-only access — no network exposure
- No extension installation, no settings.json changes, no workspace files

## License

MIT
