#!/bin/bash

# =================================================================
# MODULE: 00-USER-INPUT
#
# This script is responsible for gathering all necessary user
# information at the beginning of the installation process.
# This avoids interruptions and centralizes user interaction.
#
# It collects:
#   - Git user name and email.
#   - SSH password.
#
# The collected data is exported as environment variables for
# other modules to use.
# =================================================================

# --- Source Helper Functions ---
# shellcheck disable=SC1091
source "$(dirname "$0")/../scripts/helpers.sh"

# --- Main Function ---
main() {
    log_info "Iniciando la configuración inicial del usuario."

    # --- Check if running in automated mode ---
    if [[ "${TERMUX_AI_AUTO:-}" == "1" ]]; then
        log_warn "Omitiendo la entrada del usuario en modo automático."
        # Ensure default values are set for automated runs if not already present
        export TERMUX_AI_GIT_NAME="${TERMUX_AI_GIT_NAME:-TermuxDev}"
        export TERMUX_AI_GIT_EMAIL="${TERMUX_AI_GIT_EMAIL:-dev@termux.local}"
        export TERMUX_AI_SSH_USER="${TERMUX_AI_SSH_USER:-${TERMUX_AI_GIT_NAME}}"
        export TERMUX_AI_SSH_PASS="${TERMUX_AI_SSH_PASS:-termux-password}"
        log_success "Valores por defecto para el modo automático asegurados."
        return 0
    fi

    # --- Interactive User Input ---
    local git_name git_email ssh_pass confirm

    # Loop until user confirms the details
    while true; do
        # --- Collect Git Information ---
        log_info "Necesitamos configurar tus credenciales de Git."
        read -p "$(printf "%b📝 Ingresa tu nombre para Git: %b" "${YELLOW}" "${NC}")" git_name
        while [[ -z "$git_name" ]]; do
            log_error "El nombre de Git no puede estar vacío."
            read -p "$(printf "%b📝 Ingresa tu nombre para Git: %b" "${YELLOW}" "${NC}")" git_name
        done

        read -p "$(printf "%b📧 Ingresa tu email para Git (usado en GitHub): %b" "${YELLOW}" "${NC}")" git_email
        while [[ -z "$git_email" || ! "$git_email" =~ ^[^@]+@[^@]+\.[^@]+$ ]]; do
            log_error "Por favor, ingresa un formato de email válido."
            read -p "$(printf "%b📧 Ingresa tu email para Git (usado en GitHub): %b" "${YELLOW}" "${NC}")" git_email
        done

        # --- Collect SSH Password ---
        log_info "Ahora, configura la contraseña para el acceso SSH."
        log_warn "El usuario para SSH será el mismo que tu nombre de Git: '${git_name}'"

        # Use -s to hide password input
        read -s -p "$(printf "%b🔐 Ingresa una contraseña para SSH: %b" "${YELLOW}" "${NC}")" ssh_pass
        echo # Add a newline after the hidden input
        while [[ -z "$ssh_pass" ]]; do
            log_error "La contraseña de SSH no puede estar vacía."
            read -s -p "$(printf "%b🔐 Ingresa una contraseña para SSH: %b" "${YELLOW}" "${NC}")" ssh_pass
            echo
        done

        # --- Confirmation Step ---
        echo -e "${PURPLE}--------------------------------------------------${NC}"
        log_info "Por favor, confirma que la siguiente información es correcta:"
        echo -e "${WHITE}  - Nombre Git / Usuario SSH: ${NC}${git_name}"
        echo -e "${WHITE}  - Email Git:              ${NC}${git_email}"
        echo -e "${WHITE}  - Contraseña SSH:         ${NC}(oculta)"
        echo -e "${PURPLE}--------------------------------------------------${NC}"

        # Corrected 'read -p' syntax for confirmation
        read -p "$(printf "%b❓ ¿Es correcta esta información? (s/n): %b" "${YELLOW}" "${NC}")" confirm
        if [[ "$confirm" =~ ^[sS]$ ]]; then
            break # Exit loop if user confirms
        else
            log_warn "Entendido. Empecemos de nuevo."
        fi
    done

    # --- Export Variables for Other Modules ---
    export TERMUX_AI_GIT_NAME="$git_name"
    export TERMUX_AI_GIT_EMAIL="$git_email"
    export TERMUX_AI_SSH_USER="$git_name" # Use Git name for SSH user
    export TERMUX_AI_SSH_PASS="$ssh_pass"

    # Persist for downstream modules (loaded by setup.sh)
    local env_dir="$HOME/.termux-ai-setup"
    local env_file="${env_dir}/user.env"
    mkdir -p "$env_dir"
    cat > "$env_file" <<EOF
export TERMUX_AI_GIT_NAME=${git_name@Q}
export TERMUX_AI_GIT_EMAIL=${git_email@Q}
export TERMUX_AI_SSH_USER=${git_name@Q}
export TERMUX_AI_SSH_PASS=${ssh_pass@Q}
EOF
    chmod 600 "$env_file"

    log_success "Información del usuario guardada y exportada."
    log_info "La instalación continuará con estos datos."
}

# --- Execute Main Function ---
main