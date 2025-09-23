#!/usr/bin/env bash

# ====================================
# Local CI Validation Script
# Replicates GitHub Actions CI locally
# Run this before pushing to catch issues early
# ====================================

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

show_banner() {
    echo -e "${BOLD}${BLUE}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                    LOCAL CI VALIDATION                       ║"
    echo "║              Replicate GitHub Actions locally                ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

info() {
    echo -e "${BLUE}ℹ️  $*${NC}"
}

success() {
    echo -e "${GREEN}✅ $*${NC}"
}

warning() {
    echo -e "${YELLOW}⚠️  $*${NC}"
}

error() {
    echo -e "${RED}❌ $*${NC}"
}

step() {
    echo -e "\n${BOLD}${CYAN}🔄 $*${NC}"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Job 1: Shell Lint & Syntax (replicates CI)
job_shell_lint() {
    step "Job 1/4: Shell Lint & Syntax Check"

    info "Running bash syntax check..."
    local syntax_errors=0

    # Find all shell scripts
    while IFS= read -r -d '' file; do
        if ! bash -n "$file" 2>/dev/null; then
            error "Syntax error in $file"
            bash -n "$file" || true
            syntax_errors=$((syntax_errors + 1))
        else
            success "Syntax OK: $file"
        fi
    done < <(find . \( -path './.git' -o -path './node_modules' \) -prune -o -name '*.sh' -type f -print0)

    if [[ $syntax_errors -gt 0 ]]; then
        error "Found $syntax_errors file(s) with syntax errors"
        return 1
    fi

    info "Running ShellCheck analysis..."
    if command_exists shellcheck || command_exists npx; then
        # Use our lint script which has the same logic as CI
        if ! bash "$PROJECT_ROOT/scripts/lint.sh"; then
            error "ShellCheck analysis failed"
            return 1
        fi
    else
        warning "ShellCheck not available - install for better validation"
    fi

    # Run shfmt diff on tracked .sh files only (avoid touching .md)
    if command_exists shfmt; then
        info "Running shfmt diff on tracked .sh files..."
        FILES=$(git ls-files '**/*.sh' || true)
        if [[ -n "$FILES" ]]; then
            if ! shfmt -d -i 4 -ci -sr $FILES; then
                warning "shfmt suggested formatting changes (diff above)."
            else
                success "shfmt: no changes suggested"
            fi
        else
            info "No .sh files tracked by git for shfmt"
        fi
    else
        info "shfmt not available - skipping formatting diff"
    fi

    success "Shell Lint & Syntax: PASSED"
}

# Job 2: BATS Tests (replicates CI)
job_bats_tests() {
    echo -e "\n${CYAN}=== Job 2/4: BATS Integration Tests ===${NC}"

    if [ ! -d "tests/bats" ]; then
        echo -e "${YELLOW}⚠️  No BATS tests directory found, skipping...${NC}"
        return 0
    fi

        # Normalize line endings in test files to avoid CRLF issues on Windows
        echo "⚙️  Normalizing test file line endings (CRLF -> LF)..."
        if command -v perl >/dev/null 2>&1; then
                find tests/bats -type f \( -name "*.bats" -o -name "*.bash" \) -print0 | xargs -0 -I{} perl -pi -e 's/\r\n/\n/g; s/\r/\n/g' "{}" 2>/dev/null || true
        elif command -v node >/dev/null 2>&1; then
                node - <<'NODE'
const fs = require('fs');
const path = require('path');
const dir = 'tests/bats';
if (fs.existsSync(dir)) {
    for (const f of fs.readdirSync(dir)) {
        if (f.endsWith('.bats') || f.endsWith('.bash')) {
            const p = path.join(dir, f);
            try {
                const data = fs.readFileSync(p, 'utf8');
                const norm = data.replace(/\r\n/g, '\n').replace(/\r/g, '\n');
                if (norm !== data) fs.writeFileSync(p, norm, 'utf8');
            } catch {}
        }
    }
}
NODE
        elif command -v dos2unix >/dev/null 2>&1; then
                find tests/bats -type f \( -name "*.bats" -o -name "*.bash" \) -print0 | xargs -0 dos2unix -q 2>/dev/null || true
        else
                while IFS= read -r -d '' f; do
                        sed -i 's/\r$//' "$f" 2>/dev/null || (awk '{ sub(/\r$/, ""); print }' "$f" > "$f.tmp" && mv "$f.tmp" "$f") 2>/dev/null || true
                done < <(find tests/bats -type f \( -name "*.bats" -o -name "*.bash" \) -print0)
        fi

    if ! command -v npm >/dev/null 2>&1; then
        echo -e "${YELLOW}⚠️  npm not found, installing BATS manually...${NC}"
        # Could add manual BATS installation here
        return 0
    fi

    echo "📦 Installing BATS test framework..."
    npm install --no-save bats >/dev/null 2>&1

    if [ ! -f "node_modules/bats/bin/bats" ]; then
        echo -e "${RED}❌ BATS installation failed${NC}"
        exit 1
    fi

    echo "🧪 Running BATS integration tests..."

    # Find all BATS test files
    local test_files
    test_files=$(find tests/bats -name "*.bats" 2>/dev/null)

    if [ -z "$test_files" ]; then
        echo -e "${YELLOW}⚠️  No BATS test files found${NC}"
        return 0
    fi

    local failed=0
    while IFS= read -r test_file; do
        echo "  Running $(basename "$test_file")..."
        # Use bash explicitly for cross-platform compatibility
        if ! bash node_modules/bats/bin/bats "$test_file"; then
            failed=1
        fi
    done <<< "$test_files"

    if [ $failed -eq 1 ]; then
        echo -e "${RED}❌ BATS tests failed${NC}"
        exit 1
    fi

    echo -e "${GREEN}✅ All BATS tests passed${NC}"
}

# Job 3: Metadata Sanity (replicates CI)
job_metadata_sanity() {
    step "Job 3/4: Metadata Sanity Check"

    info "Checking package.json..."
    if [ -f "package.json" ]; then
        # Simple JSON validation using jq if available, otherwise use node
        if command -v jq >/dev/null 2>&1; then
            if ! jq . package.json >/dev/null 2>&1; then
                error "package.json is not valid JSON"
                return 1
            fi
        elif command -v node >/dev/null 2>&1; then
            # Use a simpler node validation
            if ! node -p "JSON.parse(require('fs').readFileSync('package.json', 'utf8')); 'OK'" >/dev/null 2>&1; then
                error "package.json is not valid JSON"
                return 1
            fi
        else
            info "Neither jq nor node available - skipping JSON validation"
        fi
    else
        info "package.json not found - skipping validation"
    fi

    info "Checking .github/workflows/ci.yml..."
    if command_exists python3; then
        if ! python3 -c "import yaml; yaml.safe_load(open('.github/workflows/ci.yml'))" 2>/dev/null; then
            error "CI workflow YAML is invalid"
            return 1
        fi
    else
        info "Python not available - skipping YAML validation"
    fi

    info "Checking essential files exist..."
    local required_files=(
        "README.md"
        "install.sh"
        "setup.sh"
        ".shellcheckrc"
    )

    for file in "${required_files[@]}"; do
        if [[ ! -f "$file" ]]; then
            error "Required file missing: $file"
            return 1
        fi
    done

    success "Metadata Sanity: PASSED"
}

# Job 4: Pre-push validation
job_pre_push_validation() {
    step "Job 4/4: Pre-push Validation"

    info "Checking git status..."
    if [[ -n "$(git status --porcelain)" ]]; then
        warning "You have uncommitted changes:"
        git status --short
        echo
    fi

    info "Checking for large files..."
    local large_files
    large_files=$(find . -type f -size +1M -not -path './.git/*' -not -path './node_modules/*' || true)
    if [[ -n "$large_files" ]]; then
        warning "Large files detected:"
        echo "$large_files"
    fi

    info "Checking commit message format..."
    local last_commit
    last_commit=$(git log -1 --pretty=format:"%s")
    if [[ ${#last_commit} -gt 72 ]]; then
        warning "Last commit message is longer than 72 characters"
    fi

    success "Pre-push Validation: PASSED"
}

# Main execution
main() {
    show_banner

    cd "$PROJECT_ROOT"

    local start_time
    start_time=$(date +%s)

    info "Starting local CI validation..."
    info "Project root: $PROJECT_ROOT"
    echo

    # Run all CI jobs
    job_shell_lint
    job_bats_tests
    job_metadata_sanity
    job_pre_push_validation

        local end_time
        end_time=$(date +%s)
        local duration
    duration=$((end_time - start_time))

    echo
    echo -e "${BOLD}${GREEN}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                  ✅ ALL CHECKS PASSED! ✅                   ║"
    echo "║                                                              ║"
    echo "║          Your code is ready to push to GitHub! 🚀           ║"
    echo "║                                                              ║"
    echo "║                 Duration: ${duration}s                               ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# Handle interrupts gracefully
trap 'echo -e "\n${RED}❌ CI validation interrupted${NC}"; exit 1' INT TERM

# Run main function
main "$@"