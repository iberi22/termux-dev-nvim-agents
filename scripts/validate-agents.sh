#!/bin/bash

# =================================================================
# SCRIPT: VALIDATE-AGENTS
#
# This script validates that all necessary dependencies for the AI
# agents are installed.
# =================================================================

# --- Source Helper Functions ---
# shellcheck disable=SC1091
source "$(dirname "$0")/helpers.sh"

# --- Functions ---

check_dependency() {
    local name="$1"
    local command="$2"

    log_info "Verificando la dependencia: ${name}..."
    if eval "${command}"; then
        log_success "${name} está instalado."
        return 0
    else
        log_error "${name} no está instalado o no se encuentra en el PATH."
        return 1
    fi
}

check_pkg_dependency() {
    local name="$1"
    local package="$2"

    log_info "Verificando el paquete de Termux: ${name}..."
    if pkg show "${package}" >/dev/null 2>&1; then
        log_success "${package} está instalado."
        return 0
    else
        log_error "${package} no está instalado."
        return 1
    fi
}

# --- Main Function ---
main() {
    log_info "=== Iniciando Validador de Dependencias de Agentes AI ==="

    local all_ok=true

    check_dependency "Node.js" "command -v node" || all_ok=false
    check_dependency "npm" "command -v npm" || all_ok=false
    check_dependency "Python" "command -v python" || all_ok=false
    check_dependency "node-gyp" "command -v node-gyp" || all_ok=false
    check_pkg_dependency "Android NDK" "ndk-multilib" || all_ok=false
    check_pkg_dependency "libsecret" "libsecret" || all_ok=false

    if [ "${all_ok}" = true ]; then
        log_success "Todas las dependencias están instaladas."
    else
        log_error "Faltan algunas dependencias. Por favor, instálalas antes de continuar."
        exit 1
    fi

    log_info "=== Validador de Dependencias de Agentes AI Completado ==="
}

# --- Execute Main Function ---
main
