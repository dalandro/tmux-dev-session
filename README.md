# tmux-dev-session

Tmux workflow for parallel feature development with git worktrees. Each feature gets its own window with a console pane and a Claude Code pane, both inside an isolated git worktree.

## Requirements

- tmux
- git
- [Claude Code](https://claude.ai/code) (`claude` in PATH)
- `~/.local/bin` in your PATH

## Install

One-liner (clones the repo to `~/tmux-dev-session` and runs the installer):

```bash
curl -fsSL https://raw.githubusercontent.com/dalandro/tmux-dev-session/main/curl-install.sh | bash
```

Or inspect the bootstrap script before running it:

```bash
curl -fsSL https://raw.githubusercontent.com/dalandro/tmux-dev-session/main/curl-install.sh
```

Or clone manually and run the installer directly:

```bash
git clone https://github.com/dalandro/tmux-dev-session ~/tmux-dev-session
bash ~/tmux-dev-session/install.sh
```

To update, re-run the one-liner — it pulls latest and reinstalls automatically.

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
new-task <repo> <branch> [--name <window-name>] [--base <base-branch>] [--detach]
```

Examples:

```bash
new-task api kit-1234-my-feature                 # new branch from configured default base
new-task api kit-1234-my-feature --base main     # new branch from explicit base
new-task api existing-branch                     # checkout existing local or remote branch
new-task api kit-1234-my-feature --name kit-1234 # custom window name
new-task api main --detach                       # parallel detached-HEAD worktree on main
```

`<branch>` is required. If it doesn't exist, it's created from `--base` (or the configured default base — see [Setup](#setup)). If it already exists locally or remotely, `--base` is ignored with a warning.

If a branch is already checked out (e.g. `main` is the active branch in `~/api`), git refuses a second checkout. Use `--detach` to create a detached-HEAD worktree at the same commit — useful for a separate working tree without disturbing the active checkout.

Each window:
- Left pane: console in the worktree
- Right pane: `claude --resume` in the worktree
- Window named by sanitized branch name (use `--name` for a shorter alias, e.g. `--name kit-1234`)

Repos are expected at `~/<repo>` — this layout is currently hardcoded. If you keep code under `~/code/` or `~/work/`, symlink or `cd` workarounds are needed until this is configurable (see TODO). Worktrees are created at `~/worktrees/<repo>/<branch>`.

Branch names containing `/` (e.g. `release/1.74.0`) are sanitized to `-` for directory and window names (`release-1.74.0`).

---

**Close a feature window:**

```bash
close-task                   # infer from $PWD (must be inside a worktree)
close-task <branch>          # match a worktree directory by name across repos
close-task <repo> <branch>   # explicit
```

Checks for uncommitted changes (including untracked files) and unpushed commits, removes the worktree, closes the tmux window. Does not delete the branch.

---

**Update default base branch:**

```bash
set-default-base <repo> <branch>
```

The current default is shown in the tmux status bar, updating as you switch panes.

## Development

### Running tests

Tests use [bats-core](https://github.com/bats-core/bats-core), [bats-assert](https://github.com/bats-core/bats-assert), and [bats-support](https://github.com/bats-core/bats-support). These are bundled as git submodules under `tests/libs/` — no separate install needed. If you cloned without `--recurse-submodules`, fetch them with:

```bash
git submodule update --init --recursive
```

Then run the full suite:

```bash
./tests/libs/bats-core/bin/bats tests/
```

Tests are isolated — each one gets a fresh temporary `$HOME` and a fake `$PATH` for mocking commands like `tmux`. Nothing writes outside that temp directory.

### What's covered

| Test file | What it tests |
|---|---|
| `set-default-base.bats` | Config writes, updates, dir creation |
| `tmux-default-base.bats` | Repo detection from pane path, config lookup |
| `new-task-args.bats` | Arg parsing, missing-branch error, invalid repo |
| `close-task-args.bats` | Missing-arg and unknown-ticket errors |

Integration tests (worktree creation, tmux window lifecycle) are not covered — those require a live tmux session and git remote.

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
