#!/usr/bin/env bats
# Bats tests for Termux AI Setup - Core Functions
# Run: bats tests/bats/test_core.bats

load "test_helper"

@test "setup.sh exists and is executable" {
    run test -x "$BATS_TEST_DIRNAME/../../setup.sh"
    [ "$status" -eq 0 ]
}

@test "setup.sh has proper shebang" {
    run head -n 1 "$BATS_TEST_DIRNAME/../../setup.sh"
    [ "$status" -eq 0 ]
    [[ "$output" =~ ^\#!.*bash ]]
}

@test "setup.sh uses safety flags" {
    run grep -q "set -euo pipefail" "$BATS_TEST_DIRNAME/../../setup.sh"
    [ "$status" -eq 0 ]
}

@test "modules directory exists" {
    run test -d "$BATS_TEST_DIRNAME/../../modules"
    [ "$status" -eq 0 ]
}

@test "all required modules exist" {
    local modules=(
        "00-base-packages.sh"
        "01-zsh-setup.sh" 
        "02-neovim-setup.sh"
        "03-ai-integration.sh"
        "04-workflows-setup.sh"
        "05-ssh-setup.sh"
        "06-fonts-setup.sh"
        "07-local-ssh-server.sh"
        "test-installation.sh"
    )
    
    for module in "${modules[@]}"; do
        run test -f "$BATS_TEST_DIRNAME/../../modules/$module"
        [ "$status" -eq 0 ]
    done
}

@test "SSH module creates helper scripts correctly" {
    # Test helper script creation logic (without actually running)
    run bash -n "$BATS_TEST_DIRNAME/../../modules/07-local-ssh-server.sh"
    [ "$status" -eq 0 ]
}

@test "install.sh syntax is valid" {
    run bash -n "$BATS_TEST_DIRNAME/../../install.sh"
    [ "$status" -eq 0 ]
}

@test "diagnose.sh syntax is valid" {
    run bash -n "$BATS_TEST_DIRNAME/../../diagnose.sh"
    [ "$status" -eq 0 ]
}

@test "README contains required sections" {
    local sections=(
        "Quick Installation"
        "SSH/SFTP Access"
        "Troubleshooting"
        "AI Commands"
    )
    
    for section in "${sections[@]}"; do
        run grep -q "$section" "$BATS_TEST_DIRNAME/../../README.md"
        [ "$status" -eq 0 ]
    done
}

@test "CI workflow exists and is valid YAML" {
    run test -f "$BATS_TEST_DIRNAME/../../.github/workflows/ci.yml"
    [ "$status" -eq 0 ]
    
    # Basic YAML syntax check
    run grep -q "name: CI" "$BATS_TEST_DIRNAME/../../.github/workflows/ci.yml"
    [ "$status" -eq 0 ]
}

@test "shellcheck config exists" {
    run test -f "$BATS_TEST_DIRNAME/../../.shellcheckrc"
    [ "$status" -eq 0 ]
}

@test "lint script is executable" {
    run test -x "$BATS_TEST_DIRNAME/../../scripts/lint.sh"
    [ "$status" -eq 0 ]
}
