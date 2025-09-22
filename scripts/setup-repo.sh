#!/usr/bin/env bash
set -euo pipefail

# 🚀 Termux AI Setup Repository Configuration Script
# This script configures the entire CI/CD pipeline, bots, and automation
# Usage: bash scripts/setup-repo.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${PURPLE}🚀 Termux AI Setup Repository Configuration${NC}"
echo "=========================================="

cd "$PROJECT_ROOT"

# Function to print section headers
section() {
    echo -e "\n${BLUE}�� $1${NC}"
    echo "----------------------------------------"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to run with status
run_with_status() {
    local cmd="$1"
    local desc="$2"
    
    echo -n "  $desc... "
    
    if eval "$cmd" >/dev/null 2>&1; then
        echo -e "${GREEN}✓${NC}"
        return 0
    else
        echo -e "${RED}✗${NC}"
        return 1
    fi
}

# 1. Validate repository structure
section "Validating Repository Structure"

required_files=(
    "setup.sh"
    "install.sh"
    "README.md"
    ".github/workflows/ci.yml"
    ".github/workflows/auto-deploy.yml"
    ".coderabbit.yml"
    ".shellcheckrc"
    "scripts/lint.sh"
    "scripts/pre-commit.sh"
)

for file in "${required_files[@]}"; do
    if [[ -f "$file" ]]; then
        echo -e "  ${GREEN}✓${NC} $file"
    else
        echo -e "  ${RED}✗${NC} $file (missing)"
    fi
done

# 2. Set file permissions
section "Setting File Permissions"

run_with_status "chmod +x setup.sh install.sh diagnose.sh" "Main scripts"
run_with_status "chmod +x modules/*.sh" "Module scripts"
run_with_status "chmod +x scripts/*.sh" "Utility scripts"
run_with_status "chmod +x tests/smoke.sh" "Test scripts"

# 3. Install pre-commit hooks (if git repo)
section "Git Configuration"

if [[ -d ".git" ]]; then
    if [[ -f "scripts/pre-commit.sh" ]]; then
        run_with_status "cp scripts/pre-commit.sh .git/hooks/pre-commit" "Install pre-commit hook"
        run_with_status "chmod +x .git/hooks/pre-commit" "Make hook executable"
    fi
    
    # Set git attributes for line endings
    cat > .gitattributes << 'EOF'
*.sh text eol=lf
*.bash text eol=lf
*.yml text eol=lf
*.yaml text eol=lf
*.md text eol=lf
*.json text eol=lf
EOF
    
    echo -e "  ${GREEN}✓${NC} Git attributes configured"
else
    echo -e "  ${YELLOW}⚠${NC} Not a git repository"
fi

# 4. Validate shell scripts
section "Shell Script Validation"

if command_exists shellcheck; then
    if bash scripts/lint.sh >/dev/null 2>&1; then
        echo -e "  ${GREEN}✓${NC} All scripts pass ShellCheck"
    else
        echo -e "  ${YELLOW}⚠${NC} Some scripts have linting issues"
        echo "    Run: bash scripts/lint.sh"
    fi
else
    echo -e "  ${YELLOW}⚠${NC} ShellCheck not installed"
    echo "    Install with: sudo apt-get install shellcheck"
fi

# 5. Test framework setup
section "Test Framework Setup"

if command_exists bats; then
    echo -e "  ${GREEN}✓${NC} Bats test framework available"
    
    if bats tests/bats/*.bats >/dev/null 2>&1; then
        echo -e "  ${GREEN}✓${NC} All Bats tests pass"
    else
        echo -e "  ${YELLOW}⚠${NC} Some Bats tests failing"
        echo "    Run: bats tests/bats/*.bats"
    fi
else
    echo -e "  ${YELLOW}⚠${NC} Bats not installed"
    echo "    Install with: git clone https://github.com/bats-core/bats-core.git && sudo bats-core/install.sh /usr/local"
fi

# 6. CodeRabbit setup instructions
section "CodeRabbit Integration"

echo -e "  ${CYAN}ℹ${NC} CodeRabbit Configuration Steps:"
echo "    1. Visit: https://app.coderabbit.ai/login"
echo "    2. Sign up with GitHub account"
echo "    3. Install CodeRabbit app for this repository"
echo "    4. Configuration is already in .coderabbit.yml"
echo "    5. For open source repos: Free Pro plan automatically applies"

# 7. GitHub Actions setup
section "GitHub Actions Configuration"

echo -e "  ${CYAN}ℹ${NC} GitHub Actions Setup:"
echo "    1. Push changes to trigger first CI run"
echo "    2. Go to repository Settings > Actions > General"
echo "    3. Set Workflow permissions to 'Read and write permissions'"
echo "    4. Enable 'Allow GitHub Actions to create and approve pull requests'"

# 8. Branch protection setup (instructions)
section "Branch Protection (Manual Setup Required)"

echo -e "  ${CYAN}ℹ${NC} Recommended Branch Protection Rules:"
echo "    1. Go to Settings > Branches"
echo "    2. Add rule for 'main' branch:"
echo "       - Require status checks: ✓"
echo "       - Require branches to be up to date: ✓"  
echo "       - Status checks: CI / Shell Lint & Syntax, CI / Metadata Sanity"
echo "       - Require review from code owners: ✓"
echo "       - Dismiss stale reviews: ✓"
echo "       - Allow auto-merge: ✓"

# 9. Repository labels setup
section "Repository Labels (GitHub)"

echo -e "  ${CYAN}ℹ${NC} Recommended Labels:"
cat << 'EOF'
    - auto-merge (color: #00ff00) - PRs eligible for auto-merge
    - ci-fix (color: #ff9900) - Automated CI fixes
    - coderabbit-created (color: #6f42c1) - Issues created by CodeRabbit
    - build failed (color: #ff0000) - CI build failure notifications
    - enhancement (color: #84b6eb) - Feature requests/improvements
    - bug (color: #fc2929) - Bug reports
EOF

# 10. Local development setup
section "Local Development Environment"

echo -e "  ${CYAN}ℹ${NC} Recommended Tools:"

tools=(
    "shellcheck:Shell script linting"
    "shfmt:Shell script formatting"
    "bats:Test framework for shell scripts"
    "gh:GitHub CLI for automation"
    "git:Version control (required)"
)

for tool_info in "${tools[@]}"; do
    tool="${tool_info%%:*}"
    desc="${tool_info#*:}"
    
    if command_exists "$tool"; then
        echo -e "    ${GREEN}✓${NC} $tool - $desc"
    else
        echo -e "    ${RED}✗${NC} $tool - $desc"
    fi
done

# 11. Final summary and next steps
section "Setup Summary & Next Steps"

echo -e "${GREEN}✅ Repository configuration complete!${NC}"
echo
echo -e "${YELLOW}Next Steps:${NC}"
echo "1. Commit and push all changes to trigger CI"
echo "2. Configure branch protection rules in GitHub"  
echo "3. Install CodeRabbit app for automated reviews"
echo "4. Set up recommended labels in repository settings"
echo "5. Install missing development tools locally"
echo
echo -e "${CYAN}Testing Commands:${NC}"
echo "• Lint all scripts: bash scripts/lint.sh"
echo "• Run smoke tests: bash tests/smoke.sh"
echo "• Run Bats tests: bats tests/bats/*.bats"
echo "• Manual setup test: bash setup.sh"
echo
echo -e "${PURPLE}🎉 Happy coding with automated CI/CD!${NC}"
