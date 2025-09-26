#!/bin/bash

# =================================================================
# MODULE: 00-BASE-PACKAGES
#
# Ensures all essential and optional base packages are installed.
# It is fully idempotent, checking if a package is already
# installed before attempting to install it.
# =================================================================

# --- Source Helper Functions ---
# shellcheck disable=SC1091
source "$(dirname "$0")/../scripts/helpers.sh"

# --- Package Lists ---
declare -ar ESSENTIAL_PACKAGES=(
    apt
    dpkg
    bash
    curl
    git
    grep
    gzip
    make
    openssh
    python
    python-pip
    coreutils
    termux-tools
    unzip
    wget
    zsh
    nodejs-lts
)

declare -ar NICE_TO_HAVE_PACKAGES=(
    bat
    eza
    fd
    fzf
    htop
    jq
    nano
    neovim
    ripgrep
    tree
    zoxide
)

# --- Idempotent Package Installation ---

# Checks if a package is already installed using dpkg.
is_package_installed() {
    dpkg -s "$1" &> /dev/null
}

# Installs a single package if it's not already installed.
install_package() {
    local pkg_name="$1"
    if is_package_installed "$pkg_name"; then
        log_success "${pkg_name} ya está instalado. Omitiendo."
    else
        log_info "Instalando ${pkg_name}..."
        if pkg install -y "$pkg_name"; then
            log_success "${pkg_name} instalado correctamente."
        else
            log_error "Falló la instalación de ${pkg_name}."
            # We don't exit here to allow other packages to be installed
            return 1
        fi
    fi
    return 0
}

# --- Main Function ---
main() {
    log_info "=== Iniciando Módulo: Instalación de Paquetes Base ==="

    # --- Initial System Update ---
    log_info "Actualizando los índices de paquetes de Termux..."
    pkg update -y || log_warn "No se pudieron actualizar los índices de paquetes. Se continuará con la caché local."

    log_info "Actualizando los paquetes base instalados..."
    pkg upgrade -y || log_warn "No se pudieron actualizar todos los paquetes. Puede que necesites ejecutar 'pkg upgrade' manualmente más tarde."

    # --- Install Essential Packages ---
    log_info "Instalando paquetes esenciales..."
    local failed_essential=0
    for pkg in "${ESSENTIAL_PACKAGES[@]}"; do
        install_package "$pkg" || failed_essential=$((failed_essential + 1))
    done

    if [ "$failed_essential" -gt 0 ]; then
        log_error "Fallaron ${failed_essential} paquetes esenciales. Revisa el log."
        # Decide if we should exit. For now, we continue.
    else
        log_success "Todos los paquetes esenciales están instalados."
    fi

    # --- Install Nice-to-Have Packages ---
    log_info "Instalando paquetes opcionales (nice-to-have)..."
    for pkg in "${NICE_TO_HAVE_PACKAGES[@]}"; do
        install_package "$pkg"
    done
    log_success "Paquetes opcionales procesados."

    log_info "=== Módulo de Paquetes Base Completado ==="
}

# --- Execute Main Function ---
main