#!/usr/bin/env bats

load test_helper

SCRIPT="$BIN_DIR/close-task"

@test "no args: exits 1 with usage" {
    run -1 bash "$SCRIPT"
    assert_output --partial "Usage:"
}

@test "unknown ticket: exits 1 with error" {
    run -1 bash "$SCRIPT" kit-9999
    assert_output --partial "no worktree found"
}

@test "ticket with slash treated same as sanitized form" {
    # release/1.74.0 sanitizes to release-1.74.0 for lookup
    # neither exists, so both should get "no worktree found"
    run -1 bash "$SCRIPT" "release/1.74.0"
    assert_output --partial "no worktree found"

    run -1 bash "$SCRIPT" "release-1.74.0"
    assert_output --partial "no worktree found"
}
