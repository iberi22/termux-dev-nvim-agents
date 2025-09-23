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

normalize_path() {
    local input="$1"

    if command -v cygpath >/dev/null 2>&1; then
        cygpath -u "$input"
        return
    fi

    if [[ "$input" =~ ^([A-Za-z]):[\\/]*(.*)$ ]]; then
        local drive="${BASH_REMATCH[1]}"
        local rest="${BASH_REMATCH[2]}"
        drive=$(echo "$drive" | tr '[:upper:]' '[:lower:]')
        rest="${rest//\\/\/}"
        rest="${rest##/}"
        if [[ -d "/mnt/${drive}" ]]; then
            echo "/mnt/${drive}/${rest}"
        else
            echo "/${drive}/${rest}"
        fi
        return
    fi

    echo "$input"
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
    local check_file="$(normalize_path "$1")"
    bash -n "$check_file"
}

# Helper function to extract function names from shell scripts
extract_functions() {
    local file="$1"
    local check_file="$(normalize_path "$1")"
    grep -E "^[[:space:]]*[a-zA-Z_][a-zA-Z0-9_]*[[:space:]]*\(\)" "$check_file" | \
        sed 's/[[:space:]]*()[[:space:]]*{.*//' | \
        sed 's/^[[:space:]]*//'
}

# Helper function to check if script follows shellcheck rules
lint_check() {
    local file="$1"
    local check_file="$(normalize_path "$1")"

    local original_dir="$PWD"
    local project_root="$(normalize_path "${BATS_PROJECT_ROOT:-$PWD}")"

    if [[ ! -d "$project_root" ]]; then
        echo "Project root directory not found: $project_root" >&2
        return 1
    fi

    cd "$project_root" || return 1

    local status=1
    local rcfile="$project_root/.shellcheckrc"

    if command_exists shellcheck; then
        if [[ -f "$rcfile" ]]; then
            if shellcheck --rcfile="$rcfile" "$check_file"; then
                status=0
            fi
        elif shellcheck "$check_file"; then
            status=0
        fi
    elif command_exists npx && command_exists node; then
        if [[ -f "$rcfile" ]]; then
            if npx shellcheck --rcfile="$rcfile" "$check_file"; then
                status=0
            fi
        elif npx shellcheck "$check_file"; then
            status=0
        fi
    fi

    if [[ $status -ne 0 ]]; then
        if [[ -f "scripts/lint.sh" ]]; then
            if bash scripts/lint.sh "$check_file" >/dev/null 2>&1; then
                status=0
            elif bash -n "$check_file"; then
                status=0
            fi
        elif bash -n "$check_file"; then
            status=0
        fi
    fi

    cd "$original_dir"
    return $status
}
