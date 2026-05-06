# code-server Viewer Skill

An OpenCode skill that spins up code-server — VS Code running in your browser — so you can instantly browse agent-generated files without leaving your workflow. The server runs locally on 127.0.0.1, requires no authentication, and automatically shuts down after one hour of idle time.

## When Would I Use This?

- **Viewing Generated Files**: An agent has created a report, code, or HTML output and you want to explore it visually with a full file tree, syntax highlighting, and live markdown preview. You ask the agent to "show me what you created" and it launches VS Code in your browser pointed at the working directory.

- **Quick Code Review**: You need to browse through multiple files, search for specific patterns, or use VS Code's integrated terminal to run commands against the agent's output. The full IDE experience helps you understand the structure and content quickly.

- **Browsing Any Directory**: You want to open a local directory in a browser-based VS Code instance without installing VS Code locally or configuring remote servers. The skill finds a free port and launches instantly.

## What You'll Need

- **macOS**: The skill uses macOS-specific commands for browser launching and port management.
- **code-server**: Install via `brew install code-server`. The binary should be available at `/opt/homebrew/bin/code-server`.
- **tmux**: Required for managing background code-server sessions.

## How to Invoke

Say things like:
> "spin up code-server for this directory"
> "open these files in a browser"
> "show me what you created"
> "launch VS Code in browser"
> "browse this directory"

## Related Skills

- **code-server**: This skill IS the code-server viewer — standalone, no strong related skills needed.

---
*For technical details and implementation guidance, see [SKILL.md](./SKILL.md).*
