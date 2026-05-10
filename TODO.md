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

## README: tmux quick-tutorial section

Add a short section to the README covering native tmux commands users will reach for alongside this tool — especially for "open an arbitrary scratch window not tied to a repo." Examples to cover:

- `tmux new-window -t dev -n scratch -c ~` — new window in `dev` session at `$HOME`
- `tmux new-window -t dev -n notes -c ~/notes` — new window at any path
- `tmux rename-window <name>` — rename current window
- `Prefix + c` / `Prefix + ,` keybinds (default `Ctrl-b`)
- `Prefix + &` to kill the current window

Keep it short — pointers, not a tmux primer.

## Configurable repos directory

`new-task` and `tmux-default-base` hardcode `~/<repo>` as the repo location. Make this configurable so users with `~/code/<repo>` or `~/work/<repo>` layouts don't need symlinks.

**Planned behaviour**
- Add `repos_dir` key to `~/.config/dev-sessions/defaults` (e.g. `repos_dir=~/code`)
- Default to `$HOME` if unset (preserve current behavior)
- `tmux-default-base` updates regex/path-match accordingly

## tmux usage info
First window of session containing quick cheatsheet for using tmux 
