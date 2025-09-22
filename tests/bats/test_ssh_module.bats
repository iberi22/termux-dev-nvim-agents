#!/usr/bin/env bats
# Bats tests for SSH module functionality
# Run: bats tests/bats/test_ssh_module.bats

load "test_helper"

setup() {
    mock_termux_env
    export TERMUX_AI_AUTO=1
    export BATS_SSH_MODULE="$BATS_TEST_DIRNAME/../../modules/07-local-ssh-server.sh"
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
        "ensure_packages"
        "generate_host_keys"
        "create_helper_scripts"
        "link_helper_scripts"
        "persist_path_update"
        "main"
    )
    
    for func in "${required_functions[@]}"; do
        run grep -q "^${func}()" "$BATS_SSH_MODULE"
        [ "$status" -eq 0 ]
    done
}

@test "SSH module creates helper script templates" {
    # Check that helper script templates are present in the module
    run grep -q "ssh-local-start" "$BATS_SSH_MODULE"
    [ "$status" -eq 0 ]
    
    run grep -q "ssh-local-stop" "$BATS_SSH_MODULE"
    [ "$status" -eq 0 ]
    
    run grep -q "ssh-local-info" "$BATS_SSH_MODULE"
    [ "$status" -eq 0 ]
}

@test "SSH module handles PORT variable correctly" {
    run grep -q 'PORT="${TERMUX_LOCAL_SSH_PORT:-$default_port}"' "$BATS_SSH_MODULE"
    [ "$status" -eq 0 ]
}

@test "SSH module includes symlink creation" {
    run grep -q "link_helper_scripts" "$BATS_SSH_MODULE"
    [ "$status" -eq 0 ]
    
    run grep -q "ln -sf" "$BATS_SSH_MODULE"
    [ "$status" -eq 0 ]
}

@test "SSH module includes PATH persistence" {
    run grep -q "persist_path_update" "$BATS_SSH_MODULE"
    [ "$status" -eq 0 ]
    
    run grep -q ".bashrc" "$BATS_SSH_MODULE"
    [ "$status" -eq 0 ]
    
    run grep -q ".zshrc" "$BATS_SSH_MODULE"
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
    if command_exists shellcheck; then
        run lint_check "$BATS_SSH_MODULE"
        [ "$status" -eq 0 ]
    else
        skip "shellcheck not available"
    fi
}
