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
source "$(dirname "$0")/../scripts/helpers.sh"

# Variables defined in helpers.sh
: "${YELLOW:=${YELLOW:-}}"
: "${NC:=${NC:-}}"

# --- Constants ---
readonly SSHD_CONFIG_FILE="$PREFIX/etc/ssh/sshd_config"
readonly CONFIG_MARKER="# --- Managed by Termux AI Setup ---"
readonly SERVICE_DIR="$HOME/.termux/services/sshd"
readonly HELPER_DIR="$HOME/.local/share/termux-ai/ssh"
readonly BIN_DIR="$HOME/bin"

# --- Functions ---

# Backups config
backup_config() {
    local backup="${SSHD_CONFIG_FILE}.termux-ai.bak"
    if [[ -f "$backup" ]]; then
        log_info "Backup de configuración existente."
        return
    fi
    cp "$SSHD_CONFIG_FILE" "$backup"
    log_success "Backup guardado en $backup"
}

# Requests the SSH password interactively
prompt_for_ssh_password() {
    local password=""
    while true; do
        read -r -s -p "$(printf "%b🔐 Ingresa una contraseña para SSH: %b" "${YELLOW}" "${NC}")" password
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

# Verifies env variables
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

# Ensures packages installed
ensure_ssh_packages() {
    log_info "Verificando openssh y termux-services..."
    for pkg in openssh termux-services; do
        if ! dpkg -s "$pkg" &>/dev/null; then
            log_warn "Instalando paquete '${pkg}'..."
            pkg install -y "$pkg" || { log_error "No se pudo instalar '${pkg}'."; exit 1; }
        fi
    done
    log_success "Paquetes SSH necesarios están presentes."
}

generate_host_keys() {
    if ls "$PREFIX/etc/ssh"/ssh_host_*_key >/dev/null 2>&1; then
        return
    fi
    log_info "Generando host keys..."
    ssh-keygen -A >/dev/null 2>&1
    log_success "Host keys generadas."
}

# Configures sshd_config
configure_sshd() {
    log_info "Configurando el servidor SSH (sshd)..."

    backup_config

    # Add managed marker if not present
    if ! grep -qF -- "$CONFIG_MARKER" "$SSHD_CONFIG_FILE"; then
        sed -i "1i${CONFIG_MARKER}\n" "$SSHD_CONFIG_FILE"
    fi

    local port="${TERMUX_AI_SSH_PORT:-8022}"

    # Port
    if grep -Eq '^[[:space:]]*#?[[:space:]]*Port\b' "$SSHD_CONFIG_FILE"; then
        sed -i -E 's/^[[:space:]]*#?[[:space:]]*Port\b.*/Port '"$port"'/g' "$SSHD_CONFIG_FILE"
    else
        printf '\nPort %s\n' "$port" >> "$SSHD_CONFIG_FILE"
    fi

    # Auth settings
    for settings in "PasswordAuthentication yes" "PermitEmptyPasswords no" "PubkeyAuthentication yes" "PermitRootLogin no"; do
        key="${settings%% *}"
        val="${settings#* }"
        if grep -Eq "^[[:space:]]*#?[[:space:]]*${key}\b" "$SSHD_CONFIG_FILE"; then
            sed -i -E "s/^[[:space:]]*#?[[:space:]]*${key}\b.*/${key} ${val}/g" "$SSHD_CONFIG_FILE"
        else
            printf '%s %s\n' "$key" "$val" >> "$SSHD_CONFIG_FILE"
        fi
    done

    log_success "sshd_config actualizado (Puerto: $port)."
}

# Sets user password
set_user_password() {
    local password="${TERMUX_AI_SSH_PASS}"
    local current_user
    current_user=$(whoami)
    log_info "Estableciendo contraseña para $current_user..."

    if ! command -v expect >/dev/null 2>&1; then
        pkg install -y expect || { log_error "Fallo al instalar 'expect'."; exit 1; }
    fi

    if expect << EOF
spawn passwd
expect "New password:"
send "${password}\r"
expect "Retype new password:"
send "${password}\r"
expect eof
EOF
    then
        log_success "Contraseña establecida."
    else
        log_error "Falló el establecimiento de contraseña."
        exit 1
    fi
}

prepare_directories() {
    mkdir -p "$HELPER_DIR" "$BIN_DIR" "$SERVICE_DIR"
    mkdir -p "$HOME/.ssh"
    chmod 700 "$HOME/.ssh"
    touch "$HOME/.ssh/authorized_keys"
    chmod 600 "$HOME/.ssh/authorized_keys"
}

create_helper_scripts() {
    log_info "Creando scripts auxiliares en $HELPER_DIR..."

    cat <<'EOF_HELPER' > "$HELPER_DIR/ssh-local-start"
#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail
if pgrep -x sshd >/dev/null 2>&1; then
    echo "sshd already running."
    exit 0
fi
sshd >/dev/null 2>&1 && echo "SSH server started." || echo "Failed to start sshd."
EOF_HELPER

    cat <<'EOF_HELPER' > "$HELPER_DIR/ssh-local-stop"
#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail
if ! pgrep -x sshd >/dev/null 2>&1; then
    echo "sshd is not running."
    exit 0
fi
pkill -x sshd && echo "SSH server stopped."
EOF_HELPER

    cat <<EOF_HELPER > "$HELPER_DIR/ssh-local-info"
#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail
PORT="\${TERMUX_AI_SSH_PORT:-8022}"
USER="\$(whoami)"
get_ip() {
    local ip=""
    if command -v ip >/dev/null 2>&1; then
        ip="\$(ip route get 1.1.1.1 2>/dev/null | awk 'NR==1 {for(i=1;i<=NF;i++) if(\$i==\"src\") {print \$(i+1); exit}}')"
    fi
    if [ -z "\$ip" ] && command -v ifconfig >/dev/null 2>&1; then
        ip="\$(ifconfig 2>/dev/null | awk '/inet / && \$2 != \"127.0.0.1\" {print \$2; exit}')"
    fi
    echo "\$ip"
}
IP="\$(get_ip)"
[ -z "\$IP" ] && IP="(not detected)"
cat <<INFO
SSH user : \$USER
SSH port : \$PORT
Device IP: \$IP

SSH command:
  ssh -p \$PORT \$USER@<device-ip>
INFO
EOF_HELPER
    chmod +x "$HELPER_DIR"/ssh-local-*
}

link_helper_scripts() {
    ln -sf "$HELPER_DIR/ssh-local-start" "$BIN_DIR/ssh-local-start"
    ln -sf "$HELPER_DIR/ssh-local-stop" "$BIN_DIR/ssh-local-stop"
    ln -sf "$HELPER_DIR/ssh-local-info" "$BIN_DIR/ssh-local-info"

    # Add to PATH if needed
    local export_line='export PATH="$HOME/bin:$PATH"'
    for file in "$HOME/.bashrc" "$HOME/.zshrc"; do
        if [[ -f "$file" ]]; then
            if ! grep -F "ssh-local-start" "$file" >/dev/null 2>&1 && ! grep -F "$export_line" "$file" >/dev/null 2>&1; then
                echo "$export_line" >> "$file"
            fi
        fi
    done
}

write_service() {
    local port="${TERMUX_AI_SSH_PORT:-8022}"
    cat <<EOF > "$SERVICE_DIR/run"
#!/data/data/com.termux/files/usr/bin/sh
exec sshd -D -p ${port}
EOF
    chmod +x "$SERVICE_DIR/run"
}

enable_sshd_service() {
    log_info "Habilitando servicio sshd..."
    write_service
    sv-enable sshd || true
    if sv up sshd; then
        log_success "Servicio sshd arrancado."
    else
        log_warn "No se pudo arrancar el servicio automáticamente. Usa 'ssh-local-start'."
    fi
}

display_summary() {
    local ip
    if command -v ip >/dev/null 2>&1; then
        ip=$(ip route get 1.1.1.1 2>/dev/null | awk '{print $7}')
    fi
    local user=$(whoami)
    local port="${TERMUX_AI_SSH_PORT:-8022}"

    log_info "--------------------------------------------------"
    log_info "Servidor SSH Configurado"
    log_info "--------------------------------------------------"
    log_info "  Usuario: ${user}"
    log_info "  IP:      ${ip:-<IP>}"
    log_info "  Puerto:  ${port}"
    log_warn "  Comando: ssh -p ${port} ${user}@${ip:-<IP>}"
    log_info "--------------------------------------------------"
    log_info "Helpers: ssh-local-start, ssh-local-stop, ssh-local-info"
}

# --- Main Function ---
main() {
    log_info "=== Iniciando Módulo: Configuración del Servidor SSH Local ==="

    check_env_variables
    ensure_ssh_packages
    prepare_directories
    generate_host_keys
    configure_sshd
    set_user_password
    create_helper_scripts
    link_helper_scripts
    enable_sshd_service
    display_summary

    log_info "=== Módulo del Servidor SSH Local Completado ==="
}

main
