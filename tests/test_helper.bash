bats_require_minimum_version 1.5.0

load "libs/bats-support/load"
load "libs/bats-assert/load"

REPO_ROOT="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
BIN_DIR="$REPO_ROOT/bin"

setup() {
    TEST_HOME="$(mktemp -d)"
    export HOME="$TEST_HOME"

    # Prepend a fake-bin dir so tests can shadow real commands (e.g. tmux)
    export FAKE_BIN="$TEST_HOME/fake-bin"
    mkdir -p "$FAKE_BIN"
    export PATH="$FAKE_BIN:$PATH"
}

teardown() {
    rm -rf "$TEST_HOME"
}
