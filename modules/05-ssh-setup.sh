#!/bin/bash

# =================================================================
# MODULE: 05-SSH-SETUP
#
# Configures SSH keys for GitHub authentication. This module is
# non-interactive and relies on environment variables set by
# 00-user-input.sh.
#
# It ensures:
#   - An ed25519 SSH key exists.
#   - An SSH config file is set up for GitHub.
#   - The public key is displayed to the user for setup.
# =================================================================

# --- Source Helper Functions ---
# shellcheck disable=SC1091
source "$(dirname "$0")/../scripts/helpers.sh"

# --- Constants ---
readonly SSH_DIR="$HOME/.ssh"
readonly KEY_PATH="${SSH_DIR}/id_ed25519"
readonly CONFIG_PATH="${SSH_DIR}/config"
readonly CONFIG_MARKER="# --- GITHUB_SSH_CONFIG_BLOCK ---"

# --- Functions ---

# Verifies that the required environment variables are set.
check_env_variables() {
    if [[ -z "${TERMUX_AI_GIT_EMAIL:-}" ]]; then
        log_error "La variable de entorno TERMUX_AI_GIT_EMAIL no está definida."
        log_error "Este script depende de '00-user-input.sh' para ser ejecutado primero."
        exit 1
    fi
}

# Ensures that an SSH key is present, generating one if not.
ensure_ssh_key() {
    if [[ -f "$KEY_PATH" ]]; then
        log_success "La clave SSH en '${KEY_PATH}' ya existe. Omitiendo la creación."
        return
    fi

    log_info "No se encontró ninguna clave SSH. Generando una nueva..."
    mkdir -p "$SSH_DIR"
    chmod 700 "$SSH_DIR"

    # Generate a new ed25519 key without a passphrase.
    if ssh-keygen -t ed25519 -C "$TERMUX_AI_GIT_EMAIL" -f "$KEY_PATH" -N ""; then
        log_success "Nueva clave SSH generada en '${KEY_PATH}'."
        chmod 600 "$KEY_PATH"
    else
        log_error "Falló la generación de la clave SSH."
        exit 1
    fi
}

# Ensures the SSH config file has the correct settings for GitHub.
ensure_ssh_config() {
    if [[ -f "$CONFIG_PATH" ]] && grep -qF -- "$CONFIG_MARKER" "$CONFIG_PATH"; then
        log_success "La configuración de SSH para GitHub ya existe en '${CONFIG_PATH}'. Omitiendo."
        return
    fi

    log_info "Añadiendo configuración de GitHub a '${CONFIG_PATH}'..."

    # Create the config block to be appended.
    local config_block
    config_block="
${CONFIG_MARKER}
# Configuration for GitHub SSH access, managed by Termux AI setup.
Host github.com
    HostName github.com
    User git
    IdentityFile ${KEY_PATH}
    IdentitiesOnly yes
"
    # Append a newline and the block to the config file.
    echo -e "\n$config_block" >> "$CONFIG_PATH"
    chmod 600 "$CONFIG_PATH"
    log_success "Configuración de SSH para GitHub añadida."
}

# Displays the public key and instructions for the user.
display_public_key_instructions() {
    if [[ ! -f "${KEY_PATH}.pub" ]]; then
        log_error "No se encontró el archivo de la clave pública. No se puede continuar."
        return
    fi

    log_info "--------------------------------------------------"
    log_info "PASO FINAL: Añade tu clave pública a GitHub"
    log_info "--------------------------------------------------"
    log_warn "Copia la siguiente clave pública (el texto completo):"

    # Print the public key in a distinct color
    printf "\n%b%s%b\n\n" "${WHITE}" "$(cat "${KEY_PATH}.pub")" "${NC}" >&2

    log_info "1. Ve a GitHub en tu navegador:"
    log_info "   https://github.com/settings/keys"
    log_info "2. Haz clic en 'New SSH key'."
    log_info "3. Pega la clave en el campo 'Key' y dale un título (ej. 'Termux')."
    log_info "4. Haz clic en 'Add SSH key'."
    log_warn "Después de añadir la clave, puedes probar la conexión con: ssh -T git@github.com"
    log_info "--------------------------------------------------"
}

# --- Main Function ---
main() {
    log_info "=== Iniciando Módulo: Configuración de SSH para GitHub ==="

    check_env_variables
    ensure_ssh_key
    ensure_ssh_config

    display_public_key_instructions

    log_info "=== Módulo de Configuración de SSH Completado ==="
}

# --- Execute Main Function ---
main