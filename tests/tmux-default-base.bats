#!/usr/bin/env bats

load test_helper

SCRIPT="$BIN_DIR/tmux-default-base"

fake_tmux() {
    local pane_path="$1"
    cat > "$FAKE_BIN/tmux" <<EOF
#!/usr/bin/env bash
echo "$pane_path"
EOF
    chmod +x "$FAKE_BIN/tmux"
}

write_config() {
    local content="$1"
    mkdir -p "$HOME/.config/dev-sessions"
    printf "%s\n" "$content" > "$HOME/.config/dev-sessions/defaults"
}

@test "no config file: exits 0 silently" {
    fake_tmux "$HOME/worktrees/api/kit-1234"
    run -0 bash "$SCRIPT"
    assert_output ""
}

@test "worktree path: shows base for repo" {
    write_config "api=release/1.74.0"
    fake_tmux "$HOME/worktrees/api/kit-1234"

    run -0 bash "$SCRIPT"
    assert_output "base:release/1.74.0"
}

@test "direct repo path: shows base for repo" {
    write_config "api=main"
    fake_tmux "$HOME/api"

    run -0 bash "$SCRIPT"
    assert_output "base:main"
}

@test "unknown repo: outputs nothing" {
    write_config "api=main"
    fake_tmux "$HOME/worktrees/webui/kit-9999"

    run -0 bash "$SCRIPT"
    assert_output ""
}

@test "multiple repos in config: resolves correct one" {
    write_config "$(printf "api=release/1.74.0\nwebui=main")"
    fake_tmux "$HOME/worktrees/webui/kit-5678"

    run -0 bash "$SCRIPT"
    assert_output "base:main"
}
