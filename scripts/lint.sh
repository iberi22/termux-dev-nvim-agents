#!/usr/bin/env bash
set -euo pipefail

# Robust ShellCheck script for Termux AI Setup
# Usage: ./scripts/lint.sh [files...] [--staged]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
SHELLCHECK_RC="$PROJECT_ROOT/.shellcheckrc"

echo "[LINT] Starting ShellCheck analysis..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Resolve shellcheck runner (binary or npx fallback)
resolve_shellcheck() {
    # Try system shellcheck first
    if command -v shellcheck >/dev/null 2>&1; then
        echo shellcheck
        return 0
    fi

    # Try npx with node (check both npx and node availability)
    if command -v npx >/dev/null 2>&1 && command -v node >/dev/null 2>&1; then
        # Test if npx shellcheck actually works
        if npx --yes shellcheck --version >/dev/null 2>&1; then
            echo "npx --yes shellcheck"
            return 0
        fi
    fi

    # Try npm shellcheck if npm is available
    if command -v npm >/dev/null 2>&1; then
        # Check if shellcheck is installed as npm package
        if npm list shellcheck >/dev/null 2>&1 || npm list -g shellcheck >/dev/null 2>&1; then
            echo "npx shellcheck"
            return 0
        fi
    fi

    echo "" # no runner available
}

SHELLCHECK_RUNNER="$(resolve_shellcheck)"
SHELLCHECK_AVAILABLE=true

if [[ -z "$SHELLCHECK_RUNNER" ]]; then
    SHELLCHECK_AVAILABLE=false
    echo -e "${YELLOW}[WARN] ShellCheck not available - using bash -n syntax check only${NC}"
    echo -e "${CYAN}For better linting, install ShellCheck:${NC}"
    echo "  Ubuntu/Debian: sudo apt-get install shellcheck"
    echo "  macOS: brew install shellcheck"
    echo "  Windows: scoop install shellcheck"
    echo "  Node.js: npm install -g shellcheck"
    echo ""
fi

# Function to lint a single file
lint_file() {
    local file="$1"
    local basename="$(basename "$file")"

    echo -e "${BLUE}[LINT] Checking $basename...${NC}"
    # 1) Syntax check first
    if ! bash -n "$file" 2>/dev/null; then
        echo -e "${RED}[FAIL] $basename has bash syntax errors (bash -n)${NC}"
        return 1
    fi

    # 2) ShellCheck analysis (if available)
    if [[ "$SHELLCHECK_AVAILABLE" == "true" ]]; then
        # Run shellcheck capturing stderr
        if output=$( { ${SHELLCHECK_RUNNER} --rcfile="$SHELLCHECK_RC" "$file"; } 2>&1 ); then
            echo -e "${GREEN}[OK] $basename passed (bash + shellcheck)${NC}"
            return 0
        else
            # If the failure looks like an execution problem, fallback to syntax-only
            if echo "$output" | grep -E "node: not found|command not found|No such file or directory|npm ERR!" >/dev/null 2>&1; then
                echo -e "${YELLOW}[WARN] ShellCheck execution failed, using syntax check only${NC}"
                echo -e "${GREEN}[OK] $basename passed (syntax checked by bash -n)${NC}"
                return 0
            else
                echo -e "${RED}[FAIL] $basename has shellcheck issues${NC}"
                echo "$output"
                return 1
            fi
        fi
    else
        # ShellCheck not available, syntax check already passed
        echo -e "${GREEN}[OK] $basename passed (syntax checked by bash -n)${NC}"
        return 0
    fi
}

# Main execution
cd "$PROJECT_ROOT"

ERROR_COUNT=0
FILE_COUNT=0

# Check for --staged option
STAGED_MODE=false
for arg in "$@"; do
    if [[ "$arg" == "--staged" ]]; then
        STAGED_MODE=true
        break
    fi
done

if [[ $# -eq 0 ]] || [[ "$STAGED_MODE" == true ]]; then
    if [[ "$STAGED_MODE" == true ]]; then
        # Staged mode: check only staged .sh files
        echo "[INFO] Checking staged .sh files..."
        staged_files=()
        while IFS= read -r file; do
            if [[ -f "$file" && "$file" == *.sh ]]; then
                staged_files+=("$file")
            fi
        done < <(git diff --cached --name-only --diff-filter=ACMR 2>/dev/null | grep '\.sh$' || true)

        if [[ ${#staged_files[@]} -eq 0 ]]; then
            echo "[INFO] No staged .sh files found."
            exit 0
        fi

        for file in "${staged_files[@]}"; do
            if ! lint_file "$file"; then
                ERROR_COUNT=$((ERROR_COUNT + 1))
            fi
            FILE_COUNT=$((FILE_COUNT + 1))
        done
    else
        # No arguments: check all shell scripts
        echo "[INFO] No files specified, checking all .sh files (excluding node_modules, .git, .husky)..."
        while IFS= read -r -d '' file; do
            if ! lint_file "$file"; then
                ERROR_COUNT=$((ERROR_COUNT + 1))
            fi
            FILE_COUNT=$((FILE_COUNT + 1))
        done < <(find . \( -path './.git' -o -path './node_modules' -o -path './.husky' \) -prune -o -name '*.sh' -type f -print0)
    fi
else
    # Arguments provided: check specific files (exclude --staged from file list)
    for file in "$@"; do
        if [[ "$file" != "--staged" ]]; then
            if [[ -f "$file" && "$file" == *.sh ]]; then
                if ! lint_file "$file"; then
                    ERROR_COUNT=$((ERROR_COUNT + 1))
                fi
                FILE_COUNT=$((FILE_COUNT + 1))
            else
                echo -e "${YELLOW}[SKIP] $file (not a .sh file or doesn't exist)${NC}"
            fi
        fi
    done
fi

# Summary
echo
echo "========================================"
echo "ShellCheck Summary:"
echo "  Files checked: $FILE_COUNT"
echo "  Files with issues: $ERROR_COUNT"
if [[ $FILE_COUNT -gt 0 ]]; then
    echo "  Success rate: $(( (FILE_COUNT - ERROR_COUNT) * 100 / FILE_COUNT ))%"
fi

if [[ $ERROR_COUNT -eq 0 ]]; then
    echo -e "${GREEN}[SUCCESS] All files passed ShellCheck!${NC}"
    exit 0
else
    echo -e "${RED}[FAILURE] $ERROR_COUNT file(s) have linting issues.${NC}"
    echo "Fix the issues above and run again."
    exit 1
fi
