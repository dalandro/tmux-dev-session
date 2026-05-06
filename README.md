# tmux-dev-session

Tmux workflow for parallel feature development with git worktrees. Each feature gets its own window with a console pane and a Claude Code pane, both inside an isolated git worktree.

## Requirements

- tmux
- git
- [Claude Code](https://claude.ai/code) (`claude` in PATH)
- `~/.local/bin` in your PATH

## Install

```bash
git clone https://github.com/dalandro/tmux-dev-session ~/tmux-dev-session
cd ~/tmux-dev-session
./install.sh
```

Reinstall after changes:

```bash
./install.sh
```

## Setup

Set the default base branch per repo (update when your release branch changes):

```bash
set-default-base api release/1.74.0
set-default-base webui main
```

## Usage

**Start session:**

```bash
dev
```

Creates (or attaches to) a tmux session named `dev` with a manager window.

---

**Open a feature window:**

```bash
new-task <repo> [branch] [--name <window-name>] [--base <base-branch>]
```

Examples:

```bash
new-task api                                     # worktree on default base branch
new-task api kit-1234-my-feature                 # new branch, prompts for base
new-task api kit-1234-my-feature --base main     # new branch from main, no prompt
new-task api existing-branch                     # existing local or remote branch
new-task api kit-1234-my-feature --name kit-1234 # custom window name
```

Each window:
- Left pane: console in the worktree
- Right pane: `claude --resume` in the worktree
- Window named by ticket ID (e.g. `kit-1234`) or branch name

Repos are expected at `~/<repo>`. Worktrees are created at `~/worktrees/<repo>/<branch>`.

Branch names containing `/` (e.g. `release/1.74.0`) are sanitized to `-` for directory and window names (`release-1.74.0`).

---

**Close a feature window:**

```bash
close-task <ticket-id-or-branch>
```

Checks for uncommitted changes and unpushed commits, removes the worktree, closes the tmux window. Does not delete the branch.

---

**Update default base branch:**

```bash
set-default-base <repo> <branch>
```

The current default is shown in the tmux status bar, updating as you switch panes.

## Layout

```
dev session
├── manager          ← window 0, your shell for running new-task / close-task
├── kit-1234         ← feature window
│   ├── console (35%)
│   └── claude (65%)
├── kit-5678
│   ├── console
│   └── claude
└── ...
```
