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

# Check if shellcheck is installed
if ! command -v shellcheck >/dev/null 2>&1; then
    echo -e "${RED}[ERROR] ShellCheck not found. Please install it:${NC}"
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
    
    if shellcheck --rcfile="$SHELLCHECK_RC" "$file"; then
        echo -e "${GREEN}[OK] $basename passed${NC}"
        return 0
    else
        echo -e "${RED}[FAIL] $basename has issues${NC}"
        return 1
    fi
}

# Main execution
cd "$PROJECT_ROOT"

ERROR_COUNT=0
FILE_COUNT=0

if [[ $# -eq 0 ]]; then
    # No arguments: check all shell scripts
    echo "[INFO] No files specified, checking all .sh files..."
    while IFS= read -r -d '' file; do
        if ! lint_file "$file"; then
            ((ERROR_COUNT++))
        fi
        ((FILE_COUNT++))
    done < <(find . -name '*.sh' -type f -print0)
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
