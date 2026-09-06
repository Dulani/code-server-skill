# code-server Viewer Skill

An OpenCode skill that spins up code-server — VS Code running in your browser — so you can instantly browse agent-generated files without leaving your workflow. The server runs locally on 127.0.0.1, requires no authentication, and automatically shuts down after one hour of idle time.

## When Would I Use This?

- **Viewing Generated Files**: An agent has created a report, code, or HTML output and you want to explore it visually with a full file tree, syntax highlighting, and live markdown preview. You ask the agent to "show me what you created" and it launches VS Code in your browser pointed at the working directory.

- **Quick Code Review**: You need to browse through multiple files, search for specific patterns, or use VS Code's integrated terminal to run commands against the agent's output. The full IDE experience helps you understand the structure and content quickly.

- **Browsing Any Directory**: You want to open a local directory in a browser-based VS Code instance without installing VS Code locally or configuring remote servers. The skill finds a free port and launches instantly.

## What You'll Need

- **macOS or Linux**: Launch is cross-platform — on macOS the bundled launcher uses `open`, on Linux it falls back to `xdg-open` for browser launch.
- **code-server**: macOS: `brew install code-server`. Linux: see [coder/code-server installation](https://github.com/coder/code-server#getting-started) (Arch: `yay -S code-server`; Fedora/RHEL: `sudo dnf install code-server`; Debian/Ubuntu: download the deb from coder/code-server releases).
- **tmux**: Required for managing background code-server sessions.
- **lsof**: Used to find the next free port in the 13337–13399 range.

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
