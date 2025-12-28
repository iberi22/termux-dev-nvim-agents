#!/bin/bash

# =================================================================
# MODULE: 00-SYSTEM-OPTIMIZATION
#
# Performs essential system optimizations for Termux, including:
#   - Requesting storage permissions.
#   - Setting up local cache directories for package managers.
#   - Configuring performance-related environment variables.
# =================================================================

# --- Source Helper Functions ---
# shellcheck disable=SC1091
source "$(dirname "$0")/../scripts/helpers.sh"

# --- Constants ---
readonly CONFIG_MARKER="# --- Termux AI Performance Optimizations ---"

# --- Functions ---

# Requests storage access for Termux.
request_storage_permission() {
    log_info "Solicitando permisos de almacenamiento..."
    if [[ -d "$HOME/storage" ]]; then
        log_success "Los permisos de almacenamiento ya están concedidos."
        return
    fi

    log_warn "Se necesitan permisos de almacenamiento para acceder a archivos fuera del directorio de Termux."
    termux-setup-storage
    # Give it a moment for the directory to be created.
    sleep 3

    if [[ -d "$HOME/storage" ]]; then
        log_success "Permisos de almacenamiento concedidos exitosamente."
    else
        log_error "No se pudieron obtener los permisos de almacenamiento. Algunas funciones pueden no funcionar."
        log_warn "Por favor, intenta ejecutar 'termux-setup-storage' manualmente."
    fi
}

# Creates optimized cache directories for pip and npm.
configure_local_caches() {
    log_info "Configurando directorios de caché locales para pip y npm..."

    # Pip cache configuration
    local pip_config_file="$HOME/.config/pip/pip.conf"
    mkdir -p "$(dirname "$pip_config_file")"
    if [[ ! -f "$pip_config_file" ]]; then
        cat > "$pip_config_file" <<EOF
[global]
cache-dir = $HOME/.cache/pip
EOF
        log_success "Configuración de caché para pip creada."
    else
        log_success "La configuración de caché para pip ya existe."
    fi

    # Npm cache configuration
    if command -v npm >/dev/null 2>&1; then
        npm config set cache "$HOME/.cache/npm" --global
        log_success "Configuración de caché para npm establecida."
    else
        log_info "npm no encontrado, omitiendo configuración de caché de npm."
    fi
}

# Appends performance-related environment variables to shell profiles.
configure_shell_performance() {
    log_info "Aplicando optimizaciones de rendimiento a los perfiles de la shell..."

    local perf_block
    perf_block="
${CONFIG_MARKER}
# Set a dedicated temporary directory.
export TMPDIR=\"\$HOME/.cache/tmp\"
mkdir -p \"\$TMPDIR\"

# Performance tweaks for Node.js and Python.
export NODE_OPTIONS=\"--max-old-space-size=4096\"
export PYTHONDONTWRITEBYTECODE=1
${CONFIG_MARKER}
"
    # Apply to .bashrc
    local bashrc="$HOME/.bashrc"
    if [[ ! -f "$bashrc" ]]; then
        touch "$bashrc"
        log_info "Creando $bashrc para aplicar optimizaciones."
    fi
    if ! grep -qF -- "$CONFIG_MARKER" "$bashrc"; then
        echo "$perf_block" >> "$bashrc"
        log_success "Optimizaciones añadidas a .bashrc."
    else
        log_info "Las optimizaciones ya existen en .bashrc."
    fi

    # Apply to .zshrc
    if command -v zsh > /dev/null 2>&1; then
        local zshrc="$HOME/.zshrc"
        if [[ ! -f "$zshrc" ]]; then
            touch "$zshrc"
            log_info "Creando $zshrc para aplicar optimizaciones."
        fi
        if ! grep -qF -- "$CONFIG_MARKER" "$zshrc"; then
            echo "$perf_block" >> "$zshrc"
            log_success "Optimizaciones añadidas a .zshrc."
        else
            log_info "Las optimizaciones ya existen en .zshrc."
        fi
    else
        log_info "zsh no está instalado, omitiendo optimizaciones para .zshrc."
    fi
}

# --- Main Function ---
main() {
    log_info "=== Iniciando Módulo: Optimización del Sistema ==="

    request_storage_permission
    configure_local_caches
    configure_shell_performance

    log_info "=== Módulo de Optimización del Sistema Completado ==="
}

# --- Execute Main Function ---
main