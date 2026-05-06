#!/usr/bin/env bash
# tmux-dev-session bootstrap (curl one-liner entry point)
# https://github.com/dalandro/tmux-dev-session
#
# Clones the repo to ~/tmux-dev-session (or pulls if it exists) and runs install.sh.
# Idempotent: safe to re-run to update.
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/dalandro/tmux-dev-session/main/curl-install.sh | bash

set -euo pipefail

REPO_URL="https://github.com/dalandro/tmux-dev-session.git"
CLONE_DIR="$HOME/tmux-dev-session"

if [[ -d "$CLONE_DIR/.git" ]]; then
    echo "> Repo exists at $CLONE_DIR, pulling latest..."
    git -C "$CLONE_DIR" pull --ff-only
elif [[ -d "$CLONE_DIR" ]]; then
    echo "x $CLONE_DIR exists but is not a git repo. Remove it and retry." >&2
    exit 1
else
    echo "> Cloning $REPO_URL to $CLONE_DIR..."
    git clone "$REPO_URL" "$CLONE_DIR"
fi

exec bash "$CLONE_DIR/install.sh"
