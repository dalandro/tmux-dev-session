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

@test "no branch given: exits 1 with 'branch required'" {
    mkdir -p "$HOME/api"
    git -C "$HOME/api" init -q
    git -C "$HOME/api" -c user.email="test@test.com" -c user.name="Test" \
        commit --allow-empty -q -m "init"

    run -1 bash "$SCRIPT" api
    assert_output --partial "branch required"
    assert_output --partial "Usage:"
}

@test "new branch without --base or default: exits 1 with set-default-base hint" {
    mkdir -p "$HOME/api"
    git -C "$HOME/api" init -q
    git -C "$HOME/api" -c user.email="test@test.com" -c user.name="Test" \
        commit --allow-empty -q -m "init"

    run -1 bash "$SCRIPT" api new-feature
    assert_output --partial "set-default-base"
}

@test "--base ignored on locally-existing branch: warns" {
    mkdir -p "$HOME/api"
    git -C "$HOME/api" init -q -b main
    git -C "$HOME/api" -c user.email="test@test.com" -c user.name="Test" \
        commit --allow-empty -q -m "init"

    # main is checked out at $HOME/api so worktree-add will refuse anyway,
    # but the warning should appear before the refusal error.
    run -1 bash "$SCRIPT" api main --base anything
    assert_output --partial "Warning: --base ignored"
}

@test "usage line documents --detach" {
    run -1 bash "$SCRIPT"
    assert_output --partial "--detach"
}

@test "--detach with nonexistent branch: exits with helpful error" {
    mkdir -p "$HOME/api"
    git -C "$HOME/api" init -q
    git -C "$HOME/api" -c user.email="test@test.com" -c user.name="Test" \
        commit --allow-empty -q -m "init"

    run -1 bash "$SCRIPT" api no-such-branch --detach
    assert_output --partial "--detach requires existing branch"
}

@test "branch already checked out elsewhere: exits with hint pointing at --detach" {
    # Create a repo with a 'main' branch checked out at $HOME/api itself
    mkdir -p "$HOME/api"
    git -C "$HOME/api" init -q -b main
    git -C "$HOME/api" -c user.email="test@test.com" -c user.name="Test" \
        commit --allow-empty -q -m "init"

    run -1 bash "$SCRIPT" api main
    assert_output --partial "already checked out"
    assert_output --partial "--detach"
}
