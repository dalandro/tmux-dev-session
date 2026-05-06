# TODO

## Agent/model selector

Allow `new-task` to launch a configurable agent in the right pane instead of always running `claude --resume`.

**Planned behaviour**
- Global default agent stored in `~/.config/dev-sessions/agents` as named shortcuts, e.g.:
  ```
  claude=claude --resume
  qwen=qwen-vl chat
  ```
- `set-default-agent <name>` command to set the global default
- Per-repo override in the existing defaults config
- `new-task` flag `--agent <name>` to override per task
- `install.sh` quick-start updated to include `set-default-agent`

**Known unknowns**
- Whether non-Claude agents have a `--resume` equivalent for session persistence
- What other agentic wrappers will be supported beyond `qwen-vl` and Claude Code
