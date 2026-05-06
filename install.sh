#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="$HOME/.local/bin"
CONFIG_DIR="$HOME/.config/dev-sessions"
TMUX_CONF="$HOME/.tmux.conf"

mkdir -p "$INSTALL_DIR" "$CONFIG_DIR"

echo "Installing scripts to $INSTALL_DIR..."
for script in "$REPO_DIR"/bin/*; do
  cp "$script" "$INSTALL_DIR/"
  chmod +x "$INSTALL_DIR/$(basename "$script")"
  echo "  $(basename "$script")"
done

TMUX_MARKER="# tmux-dev-session"
if ! grep -qF "$TMUX_MARKER" "$TMUX_CONF" 2>/dev/null; then
  echo "" >> "$TMUX_CONF"
  cat >> "$TMUX_CONF" <<'EOF'
# tmux-dev-session
set -g status-right '#(tmux-default-base) | %H:%M'
set -g status-interval 10
EOF
  echo "Appended status bar config to $TMUX_CONF"
else
  echo "tmux config already present, skipping"
fi

echo ""
echo "Done. Make sure $INSTALL_DIR is in your PATH."
echo ""
echo "Quick start:"
echo "  set-default-base api release/1.0.0   # configure default base branch"
echo "  dev                                   # start/attach session"
echo "  new-task api kit-1234-my-feature      # open feature window"
echo "  close-task kit-1234                   # clean up when done"
