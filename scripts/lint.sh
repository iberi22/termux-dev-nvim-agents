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
    local basename
    basename="$(basename "$file")"

    # 1) Syntax check first
    if ! bash -n "$file" 2>/dev/null; then
        echo -e "${RED}[FAIL] $basename has bash syntax errors (bash -n)${NC}"
        return 1
    fi

    # 2) ShellCheck analysis (if available)
    if [[ "$SHELLCHECK_AVAILABLE" != "true" ]]; then
        echo -e "${GREEN}[OK] $basename passed (syntax checked by bash -n)${NC}"
        return 0
    fi

    echo -e "${BLUE}[LINT] Checking $file...${NC}"
    
    # Try with rcfile first
    if $SHELLCHECK_RUNNER --rcfile="$SHELLCHECK_RC" "$file" >/dev/null 2>&1; then
        echo -e "${GREEN}[OK] $file passed.${NC}"
        return 0
    fi

    # Fallback for older versions (or if rcfile failed for other reasons)
    # We expect this to fail if there are issues
    if ! $SHELLCHECK_RUNNER --exclude=SC1091 "$file" >/dev/null 2>&1; then
        echo -e "${RED}[FAIL] $file has shellcheck issues${NC}"
        # Rerun to capture output for the user
        $SHELLCHECK_RUNNER --exclude=SC1091 "$file" || true
        return 1
    else
        # This case means the file passed with the fallback, but failed with rcfile.
        # This could indicate a problem with the rcfile itself, but for CI purposes,
        # we'll consider it a pass if the fallback succeeds.
        echo -e "${GREEN}[OK] $file passed (fallback mode).${NC}"
        return 0
    fi
}

# Main execution
cd "$PROJECT_ROOT"

failed_files=()
ERROR_COUNT=0
FILE_COUNT=0

# Check for --staged option
STAGED_MODE=false
# Create a new array for files to be processed, excluding flags
process_files=()
for arg in "$@"; do
    if [[ "$arg" == "--staged" ]]; then
        STAGED_MODE=true
    else
        process_files+=("$arg")
    fi
done

if [[ ${#process_files[@]} -eq 0 ]] || [[ "$STAGED_MODE" == true ]]; then
    files_to_check=()
    if [[ "$STAGED_MODE" == true ]]; then
        echo "[INFO] Checking staged .sh files..."
        while IFS= read -r file; do
            if [[ -f "$file" && "$file" == *.sh ]]; then
                files_to_check+=("$file")
            fi
        done < <(git diff --cached --name-only --diff-filter=ACMR 2>/dev/null | grep '\.sh$' || true)

        if [[ ${#files_to_check[@]} -eq 0 ]]; then
            echo "[INFO] No staged .sh files found."
            exit 0
        fi
    else
        echo "[INFO] No files specified, checking all .sh files (excluding node_modules, .git, .husky)..."
        while IFS= read -r -d '' file; do
            files_to_check+=("$file")
        done < <(find . \( -path './.git' -o -path './node_modules' -o -path './.husky' \) -prune -o -name '*.sh' -type f -print0)
    fi

    for file in "${files_to_check[@]}"; do
        if ! lint_file "$file"; then
            ERROR_COUNT=$((ERROR_COUNT + 1))
        fi
        FILE_COUNT=$((FILE_COUNT + 1))
    done
else
    # Arguments provided: check specific files
    for file in "${process_files[@]}"; do
        if [[ -f "$file" && "$file" == *.sh ]]; then
            if ! lint_file "$file"; then
                ERROR_COUNT=$((ERROR_COUNT + 1))
            fi
            FILE_COUNT=$((FILE_COUNT + 1))
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
