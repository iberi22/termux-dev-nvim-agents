#!/usr/bin/env bash
# Pre-commit hook for ShellCheck and Version Update
# Install: cp scripts/pre-commit.sh .git/hooks/pre-commit && chmod +x .git/hooks/pre-commit

set -euo pipefail

# Get the directory of this script
HOOK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$HOOK_DIR")"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}[PRE-COMMIT] Starting pre-commit checks...${NC}"

# Note: Version update script was removed in spec-kit refactoring
# Version management is now manual or via CI/CD pipeline
echo -e "${GREEN}[PRE-COMMIT] Version check skipped (manual versioning)${NC}"

echo -e "${YELLOW}[PRE-COMMIT] Running ShellCheck on staged .sh files...${NC}"

# Get staged .sh files
STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACM | grep '\.sh$' || true)

if [[ -z "$STAGED_FILES" ]]; then
    echo -e "${GREEN}[OK] No .sh files to check${NC}"
    exit 0
fi

# Run shellcheck on staged files
cd "$PROJECT_ROOT"
LINT_SCRIPT="$PROJECT_ROOT/scripts/lint.sh"

if [[ -f "$LINT_SCRIPT" ]]; then
    if bash "$LINT_SCRIPT" $STAGED_FILES; then
        echo -e "${GREEN}[PRE-COMMIT] ShellCheck passed!${NC}"
        exit 0
    else
        echo -e "${RED}[PRE-COMMIT] ShellCheck failed. Fix issues before committing.${NC}"
        echo "Run: bash scripts/lint.sh $STAGED_FILES"
        exit 1
    fi
else
    echo -e "${YELLOW}[WARNING] Lint script not found, skipping check${NC}"
    exit 0
fi
