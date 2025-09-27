#!/bin/bash

# =================================================================
# MODULE: 06-FONTS-SETUP
#
# Installs the FiraCode Nerd Font to ensure proper rendering of
# icons and symbols in the terminal.
#
# This script is idempotent and will not run if a custom font
# is already configured, to avoid overwriting user preferences.
# =================================================================

# --- Source Helper Functions ---
# shellcheck disable=SC1091
source "$(dirname "$0")/../scripts/helpers.sh"

# --- Constants ---
readonly TERMUX_CONFIG_DIR="$HOME/.termux"
readonly FONT_FILE_PATH="${TERMUX_CONFIG_DIR}/font.ttf"
readonly FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FiraCode.zip"
readonly TMP_DIR=$(mktemp -d)

# --- Cleanup Function ---
# Ensures the temporary directory is removed on exit.
cleanup() {
    rm -rf "$TMP_DIR"
}
trap cleanup EXIT INT TERM

# --- Functions ---

# Downloads and installs the FiraCode Nerd Font.
install_firacode_font() {
    log_info "Instalando FiraCode Nerd Font..."

    local zip_path="${TMP_DIR}/FiraCode.zip"

    log_info "Descargando la fuente desde ${FONT_URL}..."
    if ! curl -L -o "$zip_path" "$FONT_URL"; then
        log_error "Falló la descarga de FiraCode Nerd Font."
        return 1
    fi

    log_info "Extrayendo el archivo de la fuente..."
    # We extract only the Regular Mono font, which is ideal for terminals.
    if ! unzip -j "$zip_path" "*FiraCodeNerdFontMono-Regular.ttf" -d "$TMP_DIR"; then
        log_error "No se pudo extraer el archivo TTF del ZIP."
        return 1
    fi

    local ttf_path
    ttf_path=$(find "$TMP_DIR" -name "*FiraCodeNerdFontMono-Regular.ttf" | head -n 1)

    if [[ -z "$ttf_path" ]]; then
        log_error "No se encontró el archivo de fuente esperado en el archivo descargado."
        return 1
    fi

    log_info "Instalando la fuente en '${FONT_FILE_PATH}'..."
    mv "$ttf_path" "$FONT_FILE_PATH"

    # Reload Termux settings to apply the font immediately.
    termux-reload-settings

    log_success "FiraCode Nerd Font instalada y aplicada."
}

# --- Main Function ---
main() {
    log_info "=== Iniciando Módulo: Configuración de Fuentes ==="

    # Idempotency Check: If a font is already configured, do nothing.
    if [[ -f "$FONT_FILE_PATH" ]]; then
        log_warn "Ya existe una fuente personalizada en '${FONT_FILE_PATH}'. Omitiendo la instalación para no sobreescribir."
        log_info "=== Módulo de Configuración de Fuentes Omitido ==="
        return
    fi

    mkdir -p "$TERMUX_CONFIG_DIR"

    install_firacode_font

    log_info "=== Módulo de Configuración de Fuentes Completado ==="
}

# --- Execute Main Function ---
main