#!/bin/bash

# =================================================================
# MODULE: 03-AI-INTEGRATION
#
# Installs the primary AI command-line tool for this project:
# Google's Gemini CLI.
#
# This script is idempotent and will skip installation if the
# 'gemini' command is already available.
# =================================================================

# --- Source Helper Functions ---
# shellcheck disable=SC1091
source "$(dirname "$0")/../scripts/helpers.sh"

# --- Functions ---

# Installs the Gemini CLI package from npm if not already installed.
install_gemini_cli() {
    log_info "Verificando la instalación de Gemini CLI..."

    # Idempotency Check: If the command exists, do nothing.
    if command -v gemini >/dev/null 2>&1; then
        log_success "Gemini CLI ya está instalado."
        # Optional: uncomment the line below to force update on every run.
        # log_info "Attempting to update Gemini CLI to the latest version..."
        # npm update -g @google/gemini-cli || log_warn "Could not update Gemini CLI."
        return
    fi

    # Check if npm is available
    if ! command -v npm >/dev/null 2>&1; then
        log_error "npm no está instalado. El módulo '00-base-packages.sh' debe ejecutarse primero."
        exit 1
    fi

    log_info "Instalando @google/gemini-cli desde npm..."

    if npm install -g @google/gemini-cli; then
        log_success "Gemini CLI instalado correctamente."
    else
        log_error "Falló la instalación de Gemini CLI."
        log_warn "Asegúrate de que Node.js y npm estén instalados y funcionando correctamente."
        exit 1
    fi
}

# Installs the GitHub Copilot CLI if not already installed.
install_copilot_cli() {
    log_info "Verificando la instalación de GitHub Copilot CLI..."

    if command -v copilot >/dev/null 2>&1; then
        log_success "GitHub Copilot CLI ya está instalado."
        return
    fi

    if ! command -v npm >/dev/null 2>&1; then
        log_error "npm no está instalado. No se puede instalar Copilot CLI."
        return
    fi

    log_info "Instalando @github/copilot desde npm..."

    # Fix for node-gyp build issues in Termux.
    # This creates a config file that defines the problematic 'android_ndk_path'
    # variable as empty, which prevents build failures for native modules.
    if [ -d "$PREFIX" ] && [ "$(uname -o)" = "Android" ]; then
      log_info "Applying node-gyp fix for Termux..."
      mkdir -p "$HOME/.gyp"
      echo "{'variables':{'android_ndk_path':''}}" > "$HOME/.gyp/include.gypi"
    fi

    # Install dependencies for native modules if on Termux
    if [ -d "$PREFIX" ] && [ "$(uname -o)" = "Android" ]; then
      log_info "Installing dependencies for Copilot CLI on Termux..."
      pkg install -y libsecret
    fi

    if npm install -g @github/copilot; then
        log_success "GitHub Copilot CLI instalado correctamente."
    else
        log_error "Falló la instalación de GitHub Copilot CLI."
    fi
}


# --- Main Function ---
main() {
    log_info "=== Iniciando Módulo: Integración de IA ==="

    install_gemini_cli
    install_copilot_cli

    log_info "=== Módulo de Integración de IA Completado ==="
}

# --- Execute Main Function ---
main