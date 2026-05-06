#!/usr/bin/env bats

load test_helper

SCRIPT="$BIN_DIR/set-default-base"

@test "no args: exits 1 with usage" {
    run -1 bash "$SCRIPT"
    assert_output --partial "Usage:"
}

@test "one arg: exits 1 with usage" {
    run -1 bash "$SCRIPT" api
    assert_output --partial "Usage:"
}

@test "writes new entry to config" {
    run -0 bash "$SCRIPT" api main

    CONFIG="$HOME/.config/dev-sessions/defaults"
    assert [ -f "$CONFIG" ]
    run grep -cxF "api=main" "$CONFIG"
    assert_output "1"
}

@test "updates existing entry without duplicating" {
    CONFIG_DIR="$HOME/.config/dev-sessions"
    CONFIG="$CONFIG_DIR/defaults"
    mkdir -p "$CONFIG_DIR"
    echo "api=main" > "$CONFIG"

    run -0 bash "$SCRIPT" api release/2.0.0

    run grep -c "^api=" "$CONFIG"
    assert_output "1"

    run grep -cxF "api=release/2.0.0" "$CONFIG"
    assert_output "1"
}

@test "preserves other entries when updating" {
    CONFIG_DIR="$HOME/.config/dev-sessions"
    CONFIG="$CONFIG_DIR/defaults"
    mkdir -p "$CONFIG_DIR"
    printf "api=main\nwebui=main\n" > "$CONFIG"

    run -0 bash "$SCRIPT" api release/2.0.0

    run grep -cxF "webui=main" "$CONFIG"
    assert_output "1"
}

@test "creates config dir if missing" {
    run -0 bash "$SCRIPT" api main
    assert [ -d "$HOME/.config/dev-sessions" ]
}
