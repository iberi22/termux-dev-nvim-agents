#!/usr/bin/env bash
set -euo pipefail

# 🔍 Repository Setup Verification Script
# Quick check to ensure all CI/CD components are working

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🔍 Termux AI Setup - Verification Check${NC}"
echo "========================================"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_ROOT"

# Counters
TOTAL=0
PASSED=0

check() {
    local test_name="$1"
    local test_cmd="$2"
    local optional="${3:-false}"
    
    ((TOTAL++))
    echo -n "  $test_name... "
    
    if eval "$test_cmd" >/dev/null 2>&1; then
        echo -e "${GREEN}✓${NC}"
        ((PASSED++))
    else
        if [[ "$optional" == "true" ]]; then
            echo -e "${YELLOW}⚠ (optional)${NC}"
        else
            echo -e "${RED}✗${NC}"
        fi
    fi
}

section() {
    echo -e "\n${BLUE}📋 $1${NC}"
    echo "----------------------------------------"
}

section "Core Files"
check "Main setup script exists" "[[ -f setup.sh ]]"
check "Installation script exists" "[[ -f install.sh ]]"
check "README.md exists" "[[ -f README.md ]]"
check "AGENTS.md exists" "[[ -f AGENTS.md ]]" 
check "GEMINI.md exists" "[[ -f GEMINI.md ]]"
check "CI workflow exists" "[[ -f .github/workflows/ci.yml ]]"
check "Auto-deploy workflow exists" "[[ -f .github/workflows/auto-deploy.yml ]]"
check "CodeRabbit config exists" "[[ -f .coderabbit.yml ]]"

section "Spec-Kit Documentation"
check "SPEC.md exists" "[[ -f specs/SPEC.md ]]"
check "ROADMAP.md exists" "[[ -f specs/ROADMAP.md ]]"
check "TASKS.md exists" "[[ -f specs/TASKS.md ]]"
check "PROGRESS.md exists" "[[ -f specs/PROGRESS.md ]]"

section "Quality Tools"  
check "ShellCheck config exists" "[[ -f .shellcheckrc ]]"
check "Local lint script exists" "[[ -f scripts/lint.sh ]]"
check "Pre-commit hook exists" "[[ -f scripts/pre-commit.sh ]]"
check "Lint script is executable" "[[ -x scripts/lint.sh ]]"

section "Test Framework"
check "Core tests exist" "[[ -f tests/bats/test_core.bats ]]"
check "SSH module tests exist" "[[ -f tests/bats/test_ssh_module.bats ]]"
check "Integration tests exist" "[[ -f tests/bats/test_integration.bats ]]"
check "Test helper exists" "[[ -f tests/bats/test_helper.bash ]]"

section "Configuration Validation"
check "CI workflow syntax" "grep -q 'failed-build-issue-action' .github/workflows/ci.yml"
check "Auto-deploy syntax" "grep -q 'auto-merge' .github/workflows/auto-deploy.yml"
check "CodeRabbit shell focus" "grep -q 'shell' .coderabbit.yml"
check "ShellCheck exclusions" "grep -q 'SC1091' .shellcheckrc"

section "Git Integration"
check "Git repository" "[[ -d .git ]]"
check "Pre-commit hook installed" "[[ -f .git/hooks/pre-commit ]]" "true"
check "Git attributes configured" "[[ -f .gitattributes ]]" "true"

section "Tool Availability"
check "ShellCheck available" "command -v shellcheck" "true"
check "Bats available" "command -v bats" "true" 
check "GitHub CLI available" "command -v gh" "true"

# Summary
echo -e "\n${BLUE}📊 Verification Summary${NC}"
echo "========================================"

if [[ $PASSED -eq $TOTAL ]]; then
    echo -e "${GREEN}🎉 Perfect! All checks passed ($PASSED/$TOTAL)${NC}"
    exit 0
elif [[ $PASSED -gt $((TOTAL * 3 / 4)) ]]; then
    echo -e "${YELLOW}✅ Good! Most checks passed ($PASSED/$TOTAL)${NC}"
    echo -e "${YELLOW}💡 Run 'bash scripts/setup-repo.sh' for detailed setup${NC}"
    exit 0
else
    echo -e "${RED}❌ Issues found. Only $PASSED/$TOTAL checks passed${NC}"
    echo -e "${RED}🛠️  Run 'bash scripts/setup-repo.sh' to fix issues${NC}"
    exit 1
fi
