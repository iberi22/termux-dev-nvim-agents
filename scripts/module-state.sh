#!/bin/bash

# Module state management helpers for Termux AI setup.
#
# The setup orchestrator sources this file to keep track of which modules
# have already been executed successfully. Each module completion is recorded
# with a checksum of the module file so that changes to the script will
# automatically invalidate a previous completion record. This mechanism allows
# the installer to skip work that was already done, while still enabling users
# to rerun modules with the --force flag when needed.

# shellcheck disable=SC2034 # this file is sourced; some vars/functions used elsewhere

: "${TERMUX_AI_STATE_HOME:=$HOME/.termux-ai-setup}"
: "${TERMUX_AI_STATE_DIR:=$TERMUX_AI_STATE_HOME/state}"

termux_ai_state_init() {
    mkdir -p "$TERMUX_AI_STATE_DIR" 2>/dev/null || true
}

termux_ai_state_path() {
    local module_name="$1"
    printf '%s/%s.state' "$TERMUX_AI_STATE_DIR" "$module_name"
}

termux_ai_module_hash() {
    local module_path="$1"
    if command -v sha256sum >/dev/null 2>&1; then
        sha256sum "$module_path" 2>/dev/null | awk '{print $1}'
    elif command -v shasum >/dev/null 2>&1; then
        shasum -a 256 "$module_path" 2>/dev/null | awk '{print $1}'
    elif command -v md5sum >/dev/null 2>&1; then
        md5sum "$module_path" 2>/dev/null | awk '{print $1}'
    else
        # Fallback to mtime if no checksum utilities are available
        if command -v stat >/dev/null 2>&1; then
            stat -c %Y "$module_path" 2>/dev/null || date +%s
        else
            date +%s
        fi
    fi
}

termux_ai_record_module_state() {
    local module_name="$1"
    local module_path="$2"
    local status="${3:-completed}"
    local exit_code="${4:-0}"

    termux_ai_state_init

    local state_file
    state_file="$(termux_ai_state_path "$module_name")"
    local checksum
    checksum="$(termux_ai_module_hash "$module_path")"

    cat > "$state_file" <<EOF
module=$module_name
hash=$checksum
status=$status
exit_code=$exit_code
updated_at=$(date '+%Y-%m-%dT%H:%M:%S%z')
EOF
}

termux_ai_module_completed() {
    local module_name="$1"
    local module_path="$2"

    local state_file
    state_file="$(termux_ai_state_path "$module_name")"
    [[ -f "$state_file" ]] || return 1

    local recorded_hash recorded_status
    recorded_hash=$(awk -F= '/^hash=/{print $2}' "$state_file" 2>/dev/null)
    recorded_status=$(awk -F= '/^status=/{print $2}' "$state_file" 2>/dev/null)

    [[ "$recorded_status" == "completed" ]] || return 1

    local current_hash
    current_hash="$(termux_ai_module_hash "$module_path")"

    [[ -n "$recorded_hash" && "$recorded_hash" == "$current_hash" ]]
}

termux_ai_reset_module_state() {
    local module_name="$1"
    local state_file
    state_file="$(termux_ai_state_path "$module_name")"
    rm -f "$state_file" 2>/dev/null || true
}

termux_ai_reset_all_state() {
    rm -rf "$TERMUX_AI_STATE_DIR" 2>/dev/null || true
    mkdir -p "$TERMUX_AI_STATE_DIR" 2>/dev/null || true
}

