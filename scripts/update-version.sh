#!/usr/bin/env bash

# ====================================
# VERSION UPDATE SCRIPT
# Automatically updates version in install.sh
# ====================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() {
    local color="$1"
    local icon="$2"
    shift 2
    printf "%b%s%b %s\n" "$color" "$icon" "$NC" "$*"
}

info() {
    log "$BLUE" "ℹ️" "$@"
}

success() {
    log "$GREEN" "✅" "$@"
}

error() {
    log "$RED" "❌" "$@"
}

warning() {
    log "$YELLOW" "⚠️" "$@"
}

# Check if we're in a git repository
if ! git rev-parse --git-dir >/dev/null 2>&1; then
    error "Not in a git repository"
    exit 1
fi

# Get current date in YYYY-MM-DD format
CURRENT_DATE=$(date +%Y-%m-%d)

# Get short commit hash
COMMIT_HASH=$(git rev-parse --short HEAD)

# Create version string (date.commit-hash)
VERSION_STRING="${CURRENT_DATE}.${COMMIT_HASH}"

# Path to install.sh
INSTALL_SCRIPT="${PROJECT_ROOT}/install.sh"

if [[ ! -f "$INSTALL_SCRIPT" ]]; then
    error "install.sh not found at $INSTALL_SCRIPT"
    exit 1
fi

info "Updating version in install.sh..."
info "New version: $VERSION_STRING"
info "Commit hash: $COMMIT_HASH"

# Update SCRIPT_VERSION
if sed -i.bak "s/SCRIPT_VERSION=\"[^\"]*\"/SCRIPT_VERSION=\"$VERSION_STRING\"/" "$INSTALL_SCRIPT"; then
    success "Updated SCRIPT_VERSION to $VERSION_STRING"
else
    error "Failed to update SCRIPT_VERSION"
    exit 1
fi

# Update SCRIPT_COMMIT
if sed -i.bak "s/SCRIPT_COMMIT=\"[^\"]*\"/SCRIPT_COMMIT=\"$COMMIT_HASH\"/" "$INSTALL_SCRIPT"; then
    success "Updated SCRIPT_COMMIT to $COMMIT_HASH"
else
    error "Failed to update SCRIPT_COMMIT"
    exit 1
fi

# Remove backup files created by sed
rm -f "${INSTALL_SCRIPT}.bak"

# Verify the changes
info "Verifying changes..."
if grep -q "SCRIPT_VERSION=\"$VERSION_STRING\"" "$INSTALL_SCRIPT" && \
   grep -q "SCRIPT_COMMIT=\"$COMMIT_HASH\"" "$INSTALL_SCRIPT"; then
    success "Version update completed successfully!"
    info "Version: $VERSION_STRING"
    info "Commit: $COMMIT_HASH"
else
    error "Version update verification failed"
    exit 1
fi