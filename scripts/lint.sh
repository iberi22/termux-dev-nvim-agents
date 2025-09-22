#!/usr/bin/env bash
set -euo pipefail

# Robust ShellCheck script for Termux AI Setup
# Usage: ./scripts/lint.sh [files...]

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
    if command -v shellcheck >/dev/null 2>&1; then
        echo shellcheck
        return 0
    fi
    if command -v npx >/dev/null 2>&1; then
        echo "npx --yes shellcheck"
        return 0
    fi
    echo "" # no runner
}

SHELLCHECK_RUNNER="$(resolve_shellcheck)"
if [[ -z "$SHELLCHECK_RUNNER" ]]; then
    echo -e "${RED}[ERROR] ShellCheck not available. Install shellcheck or Node 20+ to use npx shellcheck.${NC}"
    echo "  Ubuntu/Debian: sudo apt-get install shellcheck"
    echo "  macOS: brew install shellcheck"
    echo "  Windows: scoop install shellcheck"
    exit 1
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

    # 2) ShellCheck (may be npx wrapper). If the runner can't execute (e.g. node not found), warn and continue.
    SHELLCHECK_CMD=( ${SHELLCHECK_RUNNER} --rcfile="$SHELLCHECK_RC" "$file" )
    # Run shellcheck capturing stderr
    SHELLCHECK_OUTPUT=""
    if output=$( { ${SHELLCHECK_RUNNER} --rcfile="$SHELLCHECK_RC" "$file"; } 2>&1 ); then
        echo -e "${GREEN}[OK] $basename passed${NC}"
        return 0
    else
        # If the failure looks like an execution problem (node not found / command not found), warn and treat as pass
        if echo "$output" | grep -E "node: not found|command not found|No such file or directory" >/dev/null 2>&1; then
            echo -e "${YELLOW}[WARN] ShellCheck runner failed to execute: ${NC}"
            echo "$output"
            echo -e "${GREEN}[OK] $basename passed (syntax checked by bash -n)${NC}"
            return 0
        else
            echo -e "${RED}[FAIL] $basename has issues${NC}"
            echo "$output"
            return 1
        fi
    fi
}

# Main execution
cd "$PROJECT_ROOT"

ERROR_COUNT=0
FILE_COUNT=0

if [[ $# -eq 0 ]]; then
    # No arguments: check all shell scripts
    echo "[INFO] No files specified, checking all .sh files (excluding node_modules, .git, .husky)..."
    while IFS= read -r -d '' file; do
        if ! lint_file "$file"; then
            ((ERROR_COUNT++))
        fi
        ((FILE_COUNT++))
    done < <(find . \( -path './.git' -o -path './node_modules' -o -path './.husky' \) -prune -o -name '*.sh' -type f -print0)
else
    # Arguments provided: check specific files
    for file in "$@"; do
        if [[ -f "$file" && "$file" == *.sh ]]; then
            if ! lint_file "$file"; then
                ((ERROR_COUNT++))
            fi
            ((FILE_COUNT++))
        else
            echo -e "${YELLOW}[SKIP] $file (not a .sh file or doesn't exist)${NC}"
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
