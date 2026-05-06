#!/usr/bin/env bats

load test_helper

SCRIPT="$BIN_DIR/new-task"

@test "no args: exits 1 with usage" {
    run -1 bash "$SCRIPT"
    assert_output --partial "Usage:"
}

@test "unknown option: exits 1 with usage" {
    run -1 bash "$SCRIPT" api kit-1234 --unknown
    assert_output --partial "Usage:"
}

@test "repo path not a git repo: exits 1 with error" {
    mkdir -p "$HOME/api"
    run -1 bash "$SCRIPT" api kit-1234-branch
    assert_output --partial "not a git repository"
}

@test "no branch and no default configured: exits 1 with hint" {
    mkdir -p "$HOME/api"
    git -C "$HOME/api" init -q
    # Set required git identity so commit works in any CI environment
    git -C "$HOME/api" -c user.email="test@test.com" -c user.name="Test" \
        commit --allow-empty -q -m "init"

    run -1 bash "$SCRIPT" api
    assert_output --partial "set-default-base"
}
