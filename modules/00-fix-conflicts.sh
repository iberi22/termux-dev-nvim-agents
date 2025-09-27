#!/bin/bash

# =================================================================
# MODULE: 00-FIX-CONFLICTS
#
# Configures dpkg and apt to run in a non-interactive mode,
# automatically handling configuration file conflicts by preferring
# the package maintainer's version. It also attempts to fix any
# broken package dependencies.
# =================================================================

# --- Source Helper Functions ---
# shellcheck disable=SC1091
source "$(dirname "$0")/../scripts/helpers.sh"

# --- Constants ---
readonly DPKG_CONFIG_FILE="$PREFIX/etc/dpkg/dpkg.cfg.d/01-termux-ai-defaults"
readonly CONFIG_MARKER="# --- Managed by Termux AI Setup ---"

# --- Functions ---

# Configures dpkg to be non-interactive.
configure_dpkg_noninteractive() {
    log_info "Configurando dpkg para evitar conflictos interactivos..."

    mkdir -p "$(dirname "$DPKG_CONFIG_FILE")"

    # Check if the configuration is already present.
    if [[ -f "$DPKG_CONFIG_FILE" ]] && grep -qF -- "$CONFIG_MARKER" "$DPKG_CONFIG_FILE"; then
        log_success "La configuración no interactiva de dpkg ya existe."
        return
    fi

    # This configuration tells dpkg to always install the new version of a
    # config file without prompting, which is essential for automated runs.
    cat > "$DPKG_CONFIG_FILE" <<EOF
${CONFIG_MARKER}
# Always install the package maintainer's version of configuration files.
force-confnew
# Overwrite existing files if they are in the way of a new package.
force-overwrite
EOF
    log_success "dpkg configurado para manejar conflictos automáticamente."
}

# Attempts to fix any broken package dependencies.
fix_broken_dependencies() {
    log_info "Intentando reparar dependencias de paquetes rotas..."
    # Set DEBIAN_FRONTEND to avoid any potential prompts from apt.
    if DEBIAN_FRONTEND=noninteractive apt-get --fix-broken install -y; then
        log_success "Dependencias de paquetes reparadas (si era necesario)."
    else
        log_warn "No se pudieron reparar las dependencias de paquetes. Esto podría causar problemas más adelante."
    fi
}

# --- Main Function ---
main() {
    log_info "=== Iniciando Módulo: Arreglo de Conflictos ==="

    configure_dpkg_noninteractive
    fix_broken_dependencies

    log_info "=== Módulo de Arreglo de Conflictos Completado ==="
}

# --- Execute Main Function ---
main