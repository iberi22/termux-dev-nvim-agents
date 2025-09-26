#!/bin/bash

# =================================================================
# MODULE: 07-LOCAL-SSH-SERVER
#
# Configures and enables the OpenSSH server (sshd) on Termux,
# allowing remote access. It sets the user's password based on
# input from the '00-user-input.sh' module.
# =================================================================

set -euo pipefail
IFS=$'\n\t'

# --- Source Helper Functions ---
# shellcheck disable=SC1091
# shellcheck source=../scripts/helpers.sh
source "$(dirname "$0")/../scripts/helpers.sh"

# --- Constants ---
# shellcheck disable=SC2154
readonly SSHD_CONFIG_FILE="$PREFIX/etc/ssh/sshd_config"
readonly CONFIG_MARKER="# --- Managed by Termux AI Setup ---"

# --- Functions ---

# Requests the SSH password if it's not available via environment variables.
prompt_for_ssh_password() {
    local password=""

    while true; do
        read -s -p "$(printf "%b🔐 Ingresa una contraseña para SSH: %b" "${YELLOW}" "${NC}")" password
        echo

        if [[ -n "$password" ]]; then
            TERMUX_AI_SSH_PASS="$password"
            export TERMUX_AI_SSH_PASS
            log_success "Contraseña SSH registrada."
            break
        fi

        log_error "La contraseña de SSH no puede estar vacía."
    done
}

# Verifies that the required environment variables are set, gathering them
# interactively when running in modo manual.
check_env_variables() {
    if [[ -z "${TERMUX_AI_SSH_PASS:-}" ]]; then
        if [[ "${TERMUX_AI_AUTO:-}" == "1" || "${TERMUX_AI_SILENT:-}" == "1" ]]; then
            TERMUX_AI_SSH_PASS="${TERMUX_AI_SSH_PASS:-termux-password}"
            export TERMUX_AI_SSH_PASS
            log_warn "TERMUX_AI_SSH_PASS no definido. Usando valor predeterminado para modo automático."
            return
        fi

        log_warn "No se detectó TERMUX_AI_SSH_PASS. Recopilando datos ahora..."
        prompt_for_ssh_password
    fi
}

# Ensures that openssh and termux-services are installed.
ensure_ssh_packages() {
    log_info "Asegurando que openssh y termux-services estén instalados..."
    # These should be installed by 00-base-packages, but we check just in case.
    for pkg in openssh termux-services; do
        if ! dpkg -s "$pkg" &>/dev/null; then
            log_warn "El paquete '${pkg}' no está instalado. Intentando instalar ahora..."
            pkg install -y "$pkg" || { log_error "No se pudo instalar '${pkg}'."; exit 1; }
        fi
    done
    log_success "Paquetes SSH necesarios están presentes."
}

# Configures the sshd_config file for password authentication.
configure_sshd() {
    log_info "Configurando el servidor SSH (sshd)..."

    # Idempotency Check
    if [[ -f "$SSHD_CONFIG_FILE" ]] && grep -qF -- "$CONFIG_MARKER" "$SSHD_CONFIG_FILE"; then
        log_success "La configuración de sshd ya ha sido aplicada. Omitiendo."
        return
    fi

    # Backup the original config file just in case.
    cp "$SSHD_CONFIG_FILE" "${SSHD_CONFIG_FILE}.bak"

    # Add a marker to the top of the file to indicate it's managed.
    sed -i "1i${CONFIG_MARKER}\n" "$SSHD_CONFIG_FILE"

    # Set key parameters for secure password-based login.
    # Use robust match-or-append logic for configuration.
    local port="${TERMUX_AI_SSH_PORT:-8022}"
    
    # Port configuration
    if grep -Eq '^[[:space:]]*#?[[:space:]]*Port\b' "$SSHD_CONFIG_FILE"; then
        sed -i -E 's/^[[:space:]]*#?[[:space:]]*Port\b.*/Port '"$port"'/g' "$SSHD_CONFIG_FILE"
    else
        printf '\nPort %s\n' "$port" >> "$SSHD_CONFIG_FILE"
    fi
    
    # PasswordAuthentication configuration
    if grep -Eq '^[[:space:]]*#?[[:space:]]*PasswordAuthentication\b' "$SSHD_CONFIG_FILE"; then
        sed -i -E 's/^[[:space:]]*#?[[:space:]]*PasswordAuthentication\b.*/PasswordAuthentication yes/g' "$SSHD_CONFIG_FILE"
    else
        printf 'PasswordAuthentication yes\n' >> "$SSHD_CONFIG_FILE"
    fi
    
    # PermitEmptyPasswords configuration
    if grep -Eq '^[[:space:]]*#?[[:space:]]*PermitEmptyPasswords\b' "$SSHD_CONFIG_FILE"; then
        sed -i -E 's/^[[:space:]]*#?[[:space:]]*PermitEmptyPasswords\b.*/PermitEmptyPasswords no/g' "$SSHD_CONFIG_FILE"
    else
        printf 'PermitEmptyPasswords no\n' >> "$SSHD_CONFIG_FILE"
    fi

    log_success "sshd_config actualizado para permitir acceso con contraseña en el puerto 8022."
}

# Sets the current user's password non-interactively.
set_user_password() {
    local password="${TERMUX_AI_SSH_PASS}"
    log_info "Estableciendo la contraseña para el usuario actual ($(whoami))..."

    # Use 'expect' to automate the 'passwd' command.
    if ! command -v expect >/dev/null 2>&1; then
        log_warn "El comando 'expect' no está instalado. Intentando instalarlo..."
        pkg install -y expect || { log_error "No se pudo instalar 'expect'."; exit 1; }
    fi

    expect << EOF
spawn passwd
expect "New password:"
send "${password}\r"
expect "Retype new password:"
send "${password}\r"
expect eof
EOF

    if [ $? -eq 0 ]; then
        log_success "Contraseña establecida correctamente."
    else
        log_error "Falló el establecimiento de la contraseña."
        exit 1
    fi
}

# Enables and starts the sshd service using termux-services.
enable_sshd_service() {
    log_info "Habilitando y arrancando el servicio sshd..."

    # Enable the service to start on boot.
    sv-enable sshd

    # Start the service now.
    if sv up sshd; then
        log_success "Servicio sshd arrancado y habilitado para el inicio."
    else
        log_error "Falló el arranque del servicio sshd."
        log_warn "Puedes intentar arrancarlo manualmente con 'sv up sshd'."
    fi
}

# Displays a summary with connection instructions.
display_summary() {
    local ip
    ip=$(ip route get 1.1.1.1 | awk '{print $7}')
    local user
    user=$(whoami)

    log_info "--------------------------------------------------"
    log_info "Servidor SSH Configurado"
    log_info "--------------------------------------------------"
    log_info "Puedes conectarte a tu dispositivo usando:"
    log_info "  Usuario: ${user}"
    log_info "  IP:      ${ip} (o la IP de tu dispositivo en la red local)"
    log_info "  Puerto:  8022"
    log_warn "  Comando: ssh -p 8022 ${user}@${ip}"
    log_info "--------------------------------------------------"
}


# --- Main Function ---
main() {
    log_info "=== Iniciando Módulo: Configuración del Servidor SSH Local ==="

    check_env_variables
    ensure_ssh_packages
    configure_sshd
    set_user_password
    enable_sshd_service
    display_summary

    log_info "=== Módulo del Servidor SSH Local Completado ==="
}

# --- Execute Main Function ---
main
