#!/usr/bin/env bash
# Orquestador de validaciones de agentes con salida estructurada (plain + JSON)
# Uso: validate-agents.sh [--minimal|--full] [--json] [--pretty]

set -euo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="${SCRIPT_DIR}/../setup.log"

# shellcheck disable=SC1090
if [[ -f "$SCRIPT_DIR/helpers.sh" ]]; then
    source "$SCRIPT_DIR/helpers.sh"
fi

MINIMAL=false
FULL=false
JSON_OUT=false
PRETTY=false

for arg in "$@"; do
    case "$arg" in
        --minimal) MINIMAL=true ;;
        --full) FULL=true ;;
        --json) JSON_OUT=true ;;
        --pretty) PRETTY=true ;;
    esac
done

if [[ "$MINIMAL" == true ]]; then
    COMPONENTS=(git node npm)
elif [[ "$FULL" == true ]]; then
    COMPONENTS=(git node npm zsh curl wget gemini)
else
    COMPONENTS=(git node npm)
fi

results=()
failures=()

probe_version(){
    local cmd="$1"
    local ver="unknown"
    case "$cmd" in
        git) ver=$(git --version 2>/dev/null || true) ;;
        node) ver=$(node --version 2>/dev/null || true) ;;
        npm) ver=$(npm --version 2>/dev/null || true) ;;
        zsh) ver=$(zsh --version 2>/dev/null || true) ;;
        curl) ver=$(curl --version 2>/dev/null | head -n1 || true) ;;
        wget) ver=$(wget --version 2>/dev/null | head -n1 || true) ;;
        gemini) ver=$(gemini --version 2>/dev/null || true) ;;
        *) ver="" ;;
    esac
    echo "$ver"
}

for comp in "${COMPONENTS[@]}"; do
    if command -v "$comp" >/dev/null 2>&1; then
        local_path=$(command -v "$comp" 2>/dev/null || echo "")
        version=$(probe_version "$comp" || true)
        results+=("OK|${comp}|${local_path}|${version}")
    else
        results+=("FAIL|${comp}|not found")
        failures+=("${comp}")
    fi
done

# Print plain output
for r in "${results[@]}"; do
    echo "$r"
done

# Build JSON summary if requested
if [[ "$JSON_OUT" == true ]]; then
    total=${#results[@]}
    failures_count=${#failures[@]}

    # Build JSON array (simple, avoids jq dependency)
    json_items=""
    for r in "${results[@]}"; do
        # r format: OK|name|path|version OR FAIL|name|not found
        IFS='|' read -r status name path_or_msg ver <<< "$r" || true
        # Escape quotes
        path_or_msg_esc=$(printf '%s' "$path_or_msg" | sed 's/"/\\\"/g')
        ver_esc=$(printf '%s' "$ver" | sed 's/"/\\\"/g')
        json_items+="{\"name\":\"${name}\",\"status\":\"${status}\",\"path\":\"${path_or_msg_esc}\",\"version\":\"${ver_esc}\"},"
    done
    # Remove trailing comma
    json_items="${json_items%,}"

    json_out="{\"timestamp\":\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\",\"total\":${total},\"failures\":${failures_count},\"results\":[${json_items}] }"

    if [[ "$PRETTY" == true ]]; then
        # Pretty print using python if available
        if command -v python >/dev/null 2>&1; then
            printf '%s' "$json_out" | python -m json.tool
        else
            echo "$json_out"
        fi
    else
        echo "$json_out"
    fi
fi

# Log the run
{
    echo "[validate-agents] $(date +'%Y-%m-%d %H:%M:%S') - checked ${#COMPONENTS[@]} components - failures=${#failures[@]}"
    for line in "${results[@]}"; do
        echo "    $line"
    done
} >> "$LOG_FILE" 2>/dev/null || true

if ((${#failures[@]} > 0)); then
    exit ${#failures[@]}
fi

exit 0

