#!/bin/bash
# Orquestador simple de validaciones de agentes
# Salida: líneas con formato <STATUS>|<COMPONENT>|<MSG?>
# Exit code: 0 si todo OK, >0 número de fallos

set -euo pipefail
IFS=$'\n\t'

# Load helpers if available for consistent logging
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -f "$SCRIPT_DIR/helpers.sh" ]]; then
    # shellcheck source=/dev/null
    source "$SCRIPT_DIR/helpers.sh"
fi

LOG_FILE="${SCRIPT_DIR}/../setup.log"

COMPONENTS=(git node npm zsh curl wget)

# Minimal checks flag
MINIMAL=false
FULL=false

for arg in "$@"; do
    case "$arg" in
        --minimal)
            MINIMAL=true
            ;;
        --full)
            FULL=true
            ;;
    esac
done

if [[ "$MINIMAL" == true ]]; then
    COMPONENTS=(git node npm)
elif [[ "$FULL" == true ]]; then
    COMPONENTS=(git node npm zsh curl wget gemini)
fi

failures=()

check_cmd(){
    local name="$1"

    if command -v "$name" >/dev/null 2>&1; then
        echo "OK|${name}"
        return 0
    else
        echo "FAIL|${name}|not found"
        failures+=("${name}")
        return 1
    fi
}

for comp in "${COMPONENTS[@]}"; do
    check_cmd "$comp"
done

# Record to log file if available
if [[ -n "${LOG_FILE:-}" ]]; then
    {
        echo "[validate-agents] $(date +'%Y-%m-%d %H:%M:%S') - Completed checks"
        for comp in "${COMPONENTS[@]}"; do :; done
        if ((${#failures[@]} > 0)); then
            printf "%s\n" "FAILED: ${failures[*]}"
        else
            printf "%s\n" "ALL OK"
        fi
    } >> "$LOG_FILE" 2>/dev/null || true
fi

if ((${#failures[@]} > 0)); then
    exit ${#failures[@]}
fi

exit 0
