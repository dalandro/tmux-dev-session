#!/usr/bin/env bash
# tmux-dev-session installer
# https://github.com/dalandro/tmux-dev-session
#
# Usage (one-liner):
#   curl -fsSL https://raw.githubusercontent.com/dalandro/tmux-dev-session/main/install.sh | bash
#
# Or clone and run:
#   git clone https://github.com/dalandro/tmux-dev-session ~/tmux-dev-session
#   bash ~/tmux-dev-session/install.sh
#
# Idempotent: safe to run multiple times.

set -euo pipefail

REPO_URL="https://github.com/dalandro/tmux-dev-session.git"
CLONE_DIR="$HOME/tmux-dev-session"
INSTALL_DIR="$HOME/.local/bin"
CONFIG_DIR="$HOME/.config/dev-sessions"
TMUX_CONF="$HOME/.tmux.conf"

# ── Colors ────────────────────────────────────────────────────

if [ -t 1 ]; then
    GREEN='\033[0;32m'
    YELLOW='\033[0;33m'
    RED='\033[0;31m'
    BOLD='\033[1m'
    NC='\033[0m'
else
    GREEN='' YELLOW='' RED='' BOLD='' NC=''
fi

info() { printf "${GREEN}>${NC} %s\n" "$1"; }
warn() { printf "${YELLOW}!${NC} %s\n" "$1"; }
fail() { printf "${RED}x${NC} %s\n" "$1"; exit 1; }

# ── Curl-pipe detection ───────────────────────────────────────
# When piped via curl | bash, BASH_SOURCE[0] is empty or "bash".
# In that case, clone the repo and re-exec the real install.sh.

SCRIPT_DIR=""
if [[ -n "${BASH_SOURCE[0]:-}" && "${BASH_SOURCE[0]}" != "bash" ]]; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
fi

if [[ -z "$SCRIPT_DIR" || ! -d "$SCRIPT_DIR/bin" ]]; then
    info "Running via curl — cloning repo..."
    if [[ -d "$CLONE_DIR/.git" ]]; then
        info "Repo exists at $CLONE_DIR, pulling latest..."
        git -C "$CLONE_DIR" pull --ff-only
    else
        git clone "$REPO_URL" "$CLONE_DIR"
    fi
    exec bash "$CLONE_DIR/install.sh"
fi

REPO_DIR="$SCRIPT_DIR"

# ── Prerequisites ─────────────────────────────────────────────

command -v tmux &>/dev/null || fail "tmux not found. Install tmux first."
command -v git  &>/dev/null || fail "git not found. Install git first."
command -v claude &>/dev/null || warn "claude not found in PATH. Install Claude Code before using new-task."

# ── Install ───────────────────────────────────────────────────

mkdir -p "$INSTALL_DIR" "$CONFIG_DIR"

info "Installing scripts to $INSTALL_DIR..."
for script in "$REPO_DIR"/bin/*; do
    cp "$script" "$INSTALL_DIR/"
    chmod +x "$INSTALL_DIR/$(basename "$script")"
    printf "  %s\n" "$(basename "$script")"
done

TMUX_MARKER="# tmux-dev-session"
if ! grep -qF "$TMUX_MARKER" "$TMUX_CONF" 2>/dev/null; then
    echo "" >> "$TMUX_CONF"
    cat >> "$TMUX_CONF" <<'EOF'
# tmux-dev-session
set -g status-right '#(tmux-default-base) | %H:%M'
set -g status-interval 10
EOF
    info "Appended status bar config to $TMUX_CONF"
else
    warn "tmux config already present, skipping"
fi

# ── Done ──────────────────────────────────────────────────────

printf "\n${BOLD}Done.${NC}\n\n"

if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
    warn "$INSTALL_DIR is not in your PATH. Add it:"
    printf "  echo 'export PATH=\"\$HOME/.local/bin:\$PATH\"' >> ~/.bashrc\n\n"
fi

printf "Set your defaults (do this once per repo):\n"
printf "  ${GREEN}set-default-base${NC} <repo> <branch>      # e.g. set-default-base api release/1.0.0\n"
printf "\n"
printf "  More defaults coming — agent/model selector is planned.\n"
printf "  See TODO.md for details.\n"
printf "\n"
printf "Quick start:\n"
printf "  ${GREEN}dev${NC}                                   # start/attach session\n"
printf "  ${GREEN}new-task${NC} api kit-1234-my-feature      # open feature window\n"
printf "  ${GREEN}close-task${NC} kit-1234                   # clean up when done\n"
