#!/usr/bin/env bats
# Bats tests for SSH module functionality
# Run: bats tests/bats/test_ssh_module.bats

setup() {
    load 'test_helper'
    mock_termux_env
    export TERMUX_AI_AUTO=1
    export BATS_SSH_MODULE="$(cd "$BATS_TEST_DIRNAME/../../modules" && pwd)/07-local-ssh-server.sh"
}

@test "SSH module has correct shebang" {
    run head -n 1 "$BATS_SSH_MODULE"
    [ "$status" -eq 0 ]
    [[ "$output" =~ ^\#!.*bash ]]
}

@test "SSH module uses safety flags" {
    run grep -q "set -euo pipefail" "$BATS_SSH_MODULE"
    [ "$status" -eq 0 ]
}

@test "SSH module defines required functions" {
    local required_functions=(
        "ensure_ssh_packages"
        "configure_sshd"
        "set_user_password"
        "enable_sshd_service"
        "display_summary"
        "main"
    )

    for func in "${required_functions[@]}"; do
        run grep -q "^${func}()" "$BATS_SSH_MODULE"
        [ "$status" -eq 0 ]
    done
}

@test "SSH module creates helper script templates" {
    # Check that the module configures SSH server properly
    run grep -q "configure_sshd" "$BATS_SSH_MODULE"
    [ "$status" -eq 0 ]

    run grep -q "sshd_config" "$BATS_SSH_MODULE"
    [ "$status" -eq 0 ]

    run grep -q "PasswordAuthentication" "$BATS_SSH_MODULE"
    [ "$status" -eq 0 ]
}

@test "SSH module handles PORT variable correctly" {
    # Check that the module uses TERMUX_AI_SSH_PORT variable with default 8022
    run grep -q 'TERMUX_AI_SSH_PORT' "$BATS_SSH_MODULE"
    [ "$status" -eq 0 ]

    # Check that it configures Port in sshd_config
    run grep -q 'Port.*port' "$BATS_SSH_MODULE"
    [ "$status" -eq 0 ]
}

@test "SSH module includes symlink creation" {
    run grep -q "enable_sshd_service" "$BATS_SSH_MODULE"
    [ "$status" -eq 0 ]

    run grep -q "sv-enable" "$BATS_SSH_MODULE"
    [ "$status" -eq 0 ]
}

@test "SSH module includes PATH persistence" {
    run grep -q "termux-services" "$BATS_SSH_MODULE"
    [ "$status" -eq 0 ]

    run grep -q "sv up" "$BATS_SSH_MODULE"
    [ "$status" -eq 0 ]
}

@test "SSH module has proper error handling" {
    # Check for logging functions
    run grep -q -E "(info|success|warn|error)" "$BATS_SSH_MODULE"
    [ "$status" -eq 0 ]

    # Check for color definitions
    run grep -q -E "(RED|GREEN|YELLOW|BLUE)" "$BATS_SSH_MODULE"
    [ "$status" -eq 0 ]
}

@test "SSH module syntax is valid" {
    run check_syntax "$BATS_SSH_MODULE"
    [ "$status" -eq 0 ]
}

@test "SSH module passes shellcheck" {
  run lint_check "$BATS_SSH_MODULE"
  if [ "$status" -ne 0 ]; then
    echo "--- Shellcheck output for $BATS_SSH_MODULE ---"
    echo "$output"
    echo "------------------------------------------"
  fi
  [ "$status" -eq 0 ]
}
