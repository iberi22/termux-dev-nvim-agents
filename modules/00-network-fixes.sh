#!/bin/bash

# =================================================================
# MODULE: 00-NETWORK-FIXES
#
# Configures network settings for robustness, including timeouts
# for various tools and setting reliable DNS servers. This module
# is idempotent and safe to re-run.
# =================================================================

# --- Source Helper Functions ---
# shellcheck disable=SC1091
source "$(dirname "$0")/../scripts/helpers.sh"

# --- Constants ---
readonly CONFIG_MARKER="# --- Managed by Termux AI Setup ---"

# --- Functions ---

# Appends a configuration block to a file if the marker is not present.
append_config_if_missing() {
    local file_path="$1"
    local config_block
    config_block="$(cat)" # Reads from stdin (heredoc)

    # Create parent directory if it doesn't exist
    mkdir -p "$(dirname "$file_path")"

    if [[ -f "$file_path" ]] && grep -qF -- "$CONFIG_MARKER" "$file_path"; then
        log_success "La configuración en '${file_path}' ya existe. Omitiendo."
    else
        log_info "Aplicando configuración a '${file_path}'..."
        # Append a newline and the config block
        echo -e "\n$config_block" >> "$file_path"
        log_success "Configuración aplicada a '${file_path}'."
    fi
}

# Configures network timeouts for apt, wget, and curl.
configure_network_timeouts() {
    log_info "Configurando timeouts de red para apt, wget y curl..."

    append_config_if_missing "$PREFIX/etc/apt/apt.conf.d/99-termux-ai-timeouts" <<EOF
${CONFIG_MARKER}
Acquire::http::Timeout "60";
Acquire::https::Timeout "60";
Acquire::Retries "3";
EOF

    append_config_if_missing "$HOME/.wgetrc" <<EOF
${CONFIG_MARKER}
timeout = 60
tries = 3
retry_connrefused = on
EOF

    append_config_if_missing "$HOME/.curlrc" <<EOF
${CONFIG_MARKER}
connect-timeout = 60
max-time = 120
retry = 3
EOF
}

# Sets reliable DNS servers in resolv.conf.
configure_dns() {
    log_info "Configurando servidores DNS de confianza..."

    # Check if the file is a symlink and writable, which might indicate a non-standard setup.
    if [[ -L "$PREFIX/etc/resolv.conf" || ! -w "$PREFIX/etc/resolv.conf" ]]; then
         log_warn "El archivo 'resolv.conf' es un enlace simbólico o no tiene permisos de escritura. Omitiendo la configuración de DNS."
         log_warn "Esto puede ocurrir en algunos dispositivos. Si tienes problemas de red, configúralo manualmente."
         return
    fi

    append_config_if_missing "$PREFIX/etc/resolv.conf" <<EOF
${CONFIG_MARKER}
nameserver 8.8.8.8
nameserver 8.8.4.4
nameserver 1.1.1.1
EOF
}

# Tests basic internet connectivity.
test_connectivity() {
    log_info "Probando la conectividad de red básica..."
    if ping -c 1 -W 5 google.com >/dev/null 2>&1; then
        log_success "La conectividad a google.com funciona."
    else
        log_warn "No se pudo hacer ping a google.com. Puede haber problemas de conexión."
    fi
}

# --- Main Function ---
main() {
    log_info "=== Iniciando Módulo: Arreglos de Red ==="

    configure_network_timeouts
    configure_dns
    test_connectivity

    log_info "=== Módulo de Arreglos de Red Completado ==="
}

# --- Execute Main Function ---
main