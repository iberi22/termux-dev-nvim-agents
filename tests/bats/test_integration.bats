#!/usr/bin/env bats
# Bats tests for CI/CD integration
# Run: bats tests/bats/test_integration.bats

load "test_helper"

@test "CI workflow has required jobs" {
    local ci_file="$BATS_TEST_DIRNAME/../../.github/workflows/ci.yml"
    
    # Check for lint job
    run grep -q "name: Shell Lint & Syntax" "$ci_file"
    [ "$status" -eq 0 ]
    
    # Check for meta job
    run grep -q "name: Metadata Sanity" "$ci_file"  
    [ "$status" -eq 0 ]
    
    # Check for failure notification job
    run grep -q "name: Create Issue on CI Failure" "$ci_file"
    [ "$status" -eq 0 ]
}

@test "CI workflow uses correct triggers" {
    local ci_file="$BATS_TEST_DIRNAME/../../.github/workflows/ci.yml"
    
    run grep -A5 "^on:" "$ci_file"
    [ "$status" -eq 0 ]
    [[ "$output" =~ push ]]
    [[ "$output" =~ pull_request ]]
}

@test "Auto-deploy workflow exists" {
    run test -f "$BATS_TEST_DIRNAME/../../.github/workflows/auto-deploy.yml"
    [ "$status" -eq 0 ]
}

@test "CodeRabbit config is properly formatted" {
    local config_file="$BATS_TEST_DIRNAME/../../.coderabbit.yml"
    
    if [[ -f "$config_file" ]]; then
        # Check for key sections
        run grep -q "reviews:" "$config_file"
        [ "$status" -eq 0 ]
        
        run grep -q "comments:" "$config_file"
        [ "$status" -eq 0 ]
    else
        skip "CodeRabbit config not found"
    fi
}

@test "ShellCheck config has proper exclusions" {
    local shellcheck_file="$BATS_TEST_DIRNAME/../../.shellcheckrc"
    
    if [[ -f "$shellcheck_file" ]]; then
        # Check for disable statements
        run grep -q "disable=" "$shellcheck_file"
        [ "$status" -eq 0 ]
        
        # Check for format specification
        run grep -q "format=" "$shellcheck_file"
        [ "$status" -eq 0 ]
    else
        skip "ShellCheck config not found"
    fi
}

@test "Smoke test covers essential checks" {
    local smoke_file="$BATS_TEST_DIRNAME/../smoke.sh"
    
    # Check that smoke test exists
    run test -f "$smoke_file"
    [ "$status" -eq 0 ]
    
    # Check for syntax validation
    run grep -q "bash -n" "$smoke_file"
    [ "$status" -eq 0 ]
    
    # Check for file existence validation  
    run grep -q "Missing:" "$smoke_file"
    [ "$status" -eq 0 ]
}

@test "Pre-commit hook is properly configured" {
    local precommit_file="$BATS_TEST_DIRNAME/../../scripts/pre-commit.sh"
    
    if [[ -f "$precommit_file" ]]; then
        # Check for git integration
        run grep -q "git diff --cached" "$precommit_file"
        [ "$status" -eq 0 ]
        
        # Check for shellcheck integration
        run grep -q "lint.sh" "$precommit_file"
        [ "$status" -eq 0 ]
    else
        skip "Pre-commit hook not found"
    fi
}

@test "All workflow files have valid YAML syntax" {
    local workflow_dir="$BATS_TEST_DIRNAME/../../.github/workflows"
    
    if [[ -d "$workflow_dir" ]]; then
        for file in "$workflow_dir"/*.yml; do
            if [[ -f "$file" ]]; then
                # Basic YAML syntax check (presence of key elements)
                run grep -q "name:" "$file"
                [ "$status" -eq 0 ]
                
                run grep -q "on:" "$file"
                [ "$status" -eq 0 ]
                
                run grep -q "jobs:" "$file"
                [ "$status" -eq 0 ]
            fi
        done
    fi
}

@test "Documentation includes CI badge" {
    local readme_file="$BATS_TEST_DIRNAME/../../README.md"
    
    # Check for CI badge
    run grep -q "actions/workflows/ci.yml/badge.svg" "$readme_file"
    [ "$status" -eq 0 ]
}

@test "Repository structure is complete" {
    local required_dirs=(
        ".github/workflows"
        "modules"
        "tests"
        "scripts"
    )
    
    for dir in "${required_dirs[@]}"; do
        run test -d "$BATS_TEST_DIRNAME/../../$dir"
        [ "$status" -eq 0 ]
    done
}
