#!/bin/bash

# =================================================================
# MODULE: 01-ZSH-SETUP
#
# Configures Zsh as the default shell, installs Oh My Zsh,
# essential plugins (zsh-autosuggestions, zsh-syntax-highlighting),
# and the Powerlevel10k theme.
#
# The script is fully idempotent.
# =================================================================

# --- Source Helper Functions ---
# shellcheck disable=SC1091
source "$(dirname "$0")/../scripts/helpers.sh"

# --- Constants ---
readonly OH_MY_ZSH_DIR="$HOME/.oh-my-zsh"
readonly ZSH_CUSTOM_DIR="${OH_MY_ZSH_DIR}/custom"
readonly ZSHRC_FILE="$HOME/.zshrc"
readonly P10K_CONFIG_FILE="$HOME/.p10k.zsh"
readonly ZSH_CONFIG_MARKER="# --- TERMUX_AI_ZSH_CONFIG_BLOCK ---"

# --- Functions ---

# Ensures Oh My Zsh is installed.
ensure_oh_my_zsh() {
    if [[ -d "$OH_MY_ZSH_DIR" ]]; then
        log_success "Oh My Zsh ya está instalado."
        return
    fi

    log_info "Instalando Oh My Zsh..."
    # Use RUNZSH=no and KEEP_ZSHRC=yes to prevent the installer from taking over the shell
    # or overwriting a potentially existing .zshrc file.
    if RUNZSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"; then
        log_success "Oh My Zsh instalado correctamente."
    else
        log_error "Falló la instalación de Oh My Zsh."
        exit 1
    fi
}

# Ensures a specific Zsh plugin is cloned.
ensure_plugin() {
    local name="$1"
    local repo_url="$2"
    local target_dir="${ZSH_CUSTOM_DIR}/plugins/${name}"

    if [[ -d "$target_dir" ]]; then
        log_success "Plugin '${name}' ya existe."
        return
    fi

    log_info "Instalando el plugin de Zsh: ${name}..."
    if git clone --depth=1 "$repo_url" "$target_dir"; then
        log_success "Plugin '${name}' instalado."
    else
        log_error "Falló la clonación del plugin '${name}'."
    fi
}

# Ensures the Powerlevel10k theme is cloned.
ensure_p10k() {
    local target_dir="${ZSH_CUSTOM_DIR}/themes/powerlevel10k"
    if [[ -d "$target_dir" ]]; then
        log_success "El tema Powerlevel10k ya existe."
        return
    fi

    log_info "Instalando el tema Powerlevel10k..."
    if git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$target_dir"; then
        log_success "Powerlevel10k instalado."
    else
        log_error "Falló la clonación de Powerlevel10k."
    fi
}

# Appends a block of configuration to a file if a marker is not present.
append_config_block_if_missing() {
    local file_path="$1"
    local marker="$2"
    # Here Document containing the configuration to add.
    local config_block
    config_block="$(cat)"

    if grep -qF -- "$marker" "$file_path"; then
        log_success "La configuración de Zsh en '${file_path}' ya existe. Omitiendo."
    else
        log_info "Añadiendo configuración personalizada a '${file_path}'..."
        # Append a newline just in case the file doesn't end with one.
        echo -e "\n$config_block" >> "$file_path"
        log_success "Configuración añadida a '${file_path}'."
    fi
}

# Configures the .zshrc file with our defaults.
configure_zshrc() {
    log_info "Asegurando la configuración de .zshrc..."

    # This is the main configuration block we want to ensure is in .zshrc
    # It sets the theme, plugins, and other useful settings.
    append_config_block_if_missing "$ZSHRC_FILE" "$ZSH_CONFIG_MARKER" <<EOF
${ZSH_CONFIG_MARKER}
# This block is managed by the Termux AI Setup script.

# Set Zsh theme to Powerlevel10k
ZSH_THEME="powerlevel10k/powerlevel10k"

# Define plugins to load
plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
)

# Source Oh My Zsh
source \$ZSH/oh-my-zsh.sh

# Source Powerlevel10k configuration
[[ -f "${P10K_CONFIG_FILE}" ]] && source "${P10K_CONFIG_FILE}"

# Set default editor
export EDITOR='nvim'
export VISUAL='nvim'

# Useful Aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ...='cd ../..'
alias g='git'
alias py='python'
EOF
}

# Creates a default .p10k.zsh configuration if it doesn't exist.
configure_p10k() {
    if [[ -f "$P10K_CONFIG_FILE" ]]; then
        log_success "El archivo de configuración de Powerlevel10k ya existe."
        return
    fi

    log_info "Creando archivo de configuración por defecto para Powerlevel10k..."
    if (p10k configure -y > /dev/null 2>&1); then
         log_success "Archivo .p10k.zsh creado con la configuración por defecto."
    else
        log_warn "No se pudo crear la configuración por defecto de p10k. Es posible que necesites configurarlo manualmente ejecutando 'p10k configure'."
    fi
}

# Sets Zsh as the default login shell.
ensure_default_shell() {
    # Check if the default shell is already zsh
    if [[ "$SHELL" == *"/zsh" ]]; then
        log_success "Zsh ya es la shell por defecto."
        return
    fi

    log_info "Cambiando la shell por defecto a Zsh..."
    if chsh -s zsh; then
        log_success "Shell por defecto cambiada a Zsh."
        log_warn "Necesitarás reiniciar Termux para que el cambio de shell tenga efecto completo."
    else
        log_error "No se pudo cambiar la shell por defecto."
        log_warn "Puedes intentar cambiarla manualmente con: chsh -s zsh"
    fi
}

# --- Main Function ---
main() {
    log_info "=== Iniciando Módulo: Configuración de Zsh ==="

    ensure_oh_my_zsh

    # Ensure plugins are installed
    ensure_plugin "zsh-autosuggestions" "https://github.com/zsh-users/zsh-autosuggestions"
    ensure_plugin "zsh-syntax-highlighting" "https://github.com/zsh-users/zsh-syntax-highlighting"

    ensure_p10k

    configure_zshrc
    configure_p10k

    ensure_default_shell

    log_info "=== Módulo de Configuración de Zsh Completado ==="
}

# --- Execute Main Function ---
main