# code-server Viewer Skill

An OpenCode skill that spins up [code-server](https://github.com/coder/code-server) — VS Code running in your browser — so you can instantly browse agent-generated files without leaving your workflow.

## What it does

When an agent generates files (reports, code, HTML, data), you can ask it to "show me what you created" and it will:

1. Find a free local port (13337–13399)
2. Start code-server in a background tmux session
3. Ignore stale "last opened" state and force the requested folder
4. Wait for it to be ready (healthz polling)
5. Auto-open your browser to the exact folder URL

You get a full VS Code experience — file tree, syntax highlighting, live markdown preview, and an integrated terminal — pointed at whatever directory the agent was working in.

## Recommended launcher

Use the bundled launcher instead of hand-writing the `code-server` command:

```bash
/Users/dwoods/skills/code-server/scripts/start-code-server.sh "$PWD"
```

That script fixes three recurring annoyances:

- opens the current workspace instead of stale `/Users/dwoods/code_server` state
- disables one-session workspace trust prompts for this local viewer workflow
- suppresses the Welcome tab by setting `workbench.startupEditor` to `none`

## Requirements

- macOS
- [code-server](https://github.com/coder/code-server) — `brew install code-server`
- tmux

## Trigger phrases

Ask the agent any of these:

- *"spin up code-server for this directory"*
- *"open these files in a browser"*
- *"show me what you created"*
- *"launch VS Code in browser"*
- *"browse this directory"*
- *"open a file viewer"*

## Lifecycle

| Command | What it does |
|---------|-------------|
| Start | Launches on next free port, opens browser |
| Status | Lists all running instances with health check |
| Stop | `tmux kill-session -t cs-PORT` |
| Cleanup | Kills all `cs-*` sessions at once |
| Idle timeout | Auto-shuts down after 1 hour of no browser activity |

## Security

Runs on `127.0.0.1` only — never `0.0.0.0`. No authentication required because it's local-only. No extensions installed. The launcher does make one minimal user-setting change: it sets `workbench.startupEditor` to `none` in code-server's user settings so the Welcome tab stops reappearing.

## User settings

code-server reads your global settings from `~/.local/share/code-server/User/settings.json` — configure it once (theme, font, etc.) and every future instance picks it up automatically.

The launcher preserves your existing settings and only ensures this one value:

```json
{
  "workbench.startupEditor": "none"
}
```

## Credit

Built on [code-server](https://github.com/coder/code-server) by [Coder](https://coder.com) — VS Code running on a remote server, accessible in the browser. This skill wraps it as a local ephemeral viewer managed via tmux.
