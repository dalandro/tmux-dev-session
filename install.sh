#!/usr/bin/env bash
# tmux-dev-session installer
# https://github.com/dalandro/tmux-dev-session
#
# Run from a clone of the repo:
#   git clone https://github.com/dalandro/tmux-dev-session ~/tmux-dev-session
#   bash ~/tmux-dev-session/install.sh
#
# For the curl one-liner, use curl-install.sh instead.
#
# Idempotent: safe to run multiple times.

set -euo pipefail

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

# ── Locate repo dir ───────────────────────────────────────────

if [[ -z "${BASH_SOURCE[0]:-}" || "${BASH_SOURCE[0]}" == "bash" ]]; then
    fail "install.sh must be run from a clone (not piped). Use curl-install.sh for the one-liner."
fi
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[[ -d "$REPO_DIR/bin" ]] || fail "Could not find bin/ next to install.sh — is this really a clone of the repo?"

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
set -g status-interval 60
set-hook -g pane-focus-in 'refresh-client -S'
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
printf "\n"
printf "Quick start:\n"
printf "  ${GREEN}dev${NC}                                   # start/attach session\n"
printf "  ${GREEN}new-task${NC} api kit-1234-my-feature      # open feature window\n"
printf "  ${GREEN}close-task${NC} kit-1234                   # clean up when done\n"
