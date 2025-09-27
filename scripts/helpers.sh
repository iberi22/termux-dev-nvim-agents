#!/bin/bash

# =================================================================
# HELPER FUNCTIONS FOR TERMUX AI SETUP
# =================================================================

set -euo pipefail

# --- Color Definitions ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# --- Logging Functions ---

# Generic log function, prints to STDERR to avoid capture.
_log() {
    local color="$1"
    local icon="$2"
    shift 2
    local message="$*"
    # Print to stderr to not interfere with command substitutions
    printf "%b%s %s%b\n" "${color}" "${icon}" "${message}" "${NC}" >&2
}

log_info() {
    _log "${CYAN}" "ℹ️" "$@"
}

log_success() {
    _log "${GREEN}" "✅" "$@"
}

log_warn() {
    _log "${YELLOW}" "⚠️" "$@"
}

log_error() {
    _log "${RED}" "❌" "$@"
}