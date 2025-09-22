#!/usr/bin/env bash
# Bats test helper functions

# Setup function run before each test
setup() {
    # Set test environment variables
    export TERMUX_AI_AUTO=1
    export BATS_PROJECT_ROOT="$BATS_TEST_DIRNAME/../.."
    
    # Create temporary directory for tests
    export BATS_TMPDIR="$(mktemp -d)"
    
    # Mock Termux environment check for testing
    export MOCK_TERMUX=1
}

# Teardown function run after each test  
teardown() {
    # Clean up temporary directory safely
    if [[ -n "${BATS_TMPDIR:-}" && -d "$BATS_TMPDIR" ]]; then
        # Ensure we have permission and the directory is safe to remove
        if [[ "$BATS_TMPDIR" =~ ^/tmp/ ]] && [[ -w "$BATS_TMPDIR" ]]; then
            rm -rf "$BATS_TMPDIR" 2>/dev/null || true
        fi
    fi
}

# Helper function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Helper function to mock Termux environment
mock_termux_env() {
    export PREFIX="/data/data/com.termux/files/usr"
    export HOME="/data/data/com.termux/files/home"
}

# Helper function to test shell script syntax
check_syntax() {
    local file="$1"
    bash -n "$file"
}

# Helper function to extract function names from shell scripts
extract_functions() {
    local file="$1"
    grep -E "^[[:space:]]*[a-zA-Z_][a-zA-Z0-9_]*[[:space:]]*\(\)" "$file" | \
        sed 's/[[:space:]]*()[[:space:]]*{.*//' | \
        sed 's/^[[:space:]]*//'
}

# Helper function to check if script follows shellcheck rules
lint_check() {
    local file="$1"
    
    # Ensure we're in the project root
    local original_dir="$PWD"
    cd "$BATS_PROJECT_ROOT" || return 1
    
    # Use our project's lint script which handles all the fallback logic
    if [[ -f "scripts/lint.sh" ]]; then
        # Run our lint script on the specific file (with full path)
        local result
        if bash scripts/lint.sh "$file" >/dev/null 2>&1; then
            result=0
        else
            result=1
        fi
        cd "$original_dir"
        return $result
    else
        # Fallback to syntax check only (since shellcheck might not be available)
        local result
        if bash -n "$file"; then
            result=0
        else
            result=1
        fi
        cd "$original_dir"
        return $result
    fi
}
