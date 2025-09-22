#!/bin/bash

set -euo pipefail

BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

info() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[OK]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }

default_port="8022"
PORT="${TERMUX_LOCAL_SSH_PORT:-$default_port}"
PREFIX="${PREFIX:-/data/data/com.termux/files/usr}"
SSHD_CONFIG="${PREFIX}/etc/ssh/sshd_config"
SERVICE_DIR="$HOME/.termux/services/sshd"
BIN_DIR="$HOME/bin"
AUTO_MODE="${TERMUX_AI_AUTO:-}"

ensure_packages() {
    local packages=(openssh termux-services)
    for pkg in "${packages[@]}"; do
        if dpkg -s "$pkg" >/dev/null 2>&1; then
            info "Package $pkg already installed"
        else
            info "Installing $pkg..."
            pkg install -y "$pkg" >/dev/null 2>&1
        fi
    done
}

generate_host_keys() {
    local host_dir="$PREFIX/etc/ssh"
    if ls "$host_dir"/ssh_host_*_key >/dev/null 2>&1; then
        info "SSH host keys already present"
    else
        info "Generating SSH host keys..."
        ssh-keygen -A >/dev/null 2>&1
        success "Host keys generated"
    fi
}

backup_config() {
    local backup="${SSHD_CONFIG}.termux-ai.bak"
    if [[ -f "$backup" ]]; then
        info "Backup already exists at $backup"
    else
        cp "$SSHD_CONFIG" "$backup"
        success "Backup created at $backup"
    fi
}

update_config_line() {
    local pattern="$1"
    local replacement="$2"
    local tmp
    tmp=$(mktemp)
    awk -v pattern="$pattern" -v newline="$replacement" '
        BEGIN { found=0 }
        {
            if ($0 ~ "^[#[:space:]]*" pattern) {
                if (!found) {
                    print newline
                    found=1
                }
            } else {
                print $0
            }
        }
        END {
            if (!found) {
                print newline
            }
        }
    ' "$SSHD_CONFIG" > "$tmp"
    mv "$tmp" "$SSHD_CONFIG"
}

configure_sshd() {
    info "Updating sshd configuration..."
    update_config_line 'Port' "Port ${PORT}"
    update_config_line 'PasswordAuthentication' 'PasswordAuthentication yes'
    update_config_line 'PubkeyAuthentication' 'PubkeyAuthentication yes'
    update_config_line 'PermitRootLogin' 'PermitRootLogin no'
    update_config_line 'AuthorizedKeysFile' 'AuthorizedKeysFile .ssh/authorized_keys'
    update_config_line 'Subsystem[[:space:]]+sftp' "Subsystem sftp ${PREFIX}/libexec/sftp-server"
    success "sshd_config updated"
}

prepare_directories() {
    mkdir -p "$HOME/.ssh"
    chmod 700 "$HOME/.ssh"
    touch "$HOME/.ssh/authorized_keys"
    chmod 600 "$HOME/.ssh/authorized_keys"
    mkdir -p "$SERVICE_DIR"
    mkdir -p "$BIN_DIR"
}

write_service() {
    cat > "$SERVICE_DIR/run" <<EOF
#!/data/data/com.termux/files/usr/bin/sh
exec sshd -D -p ${PORT}
EOF
    chmod +x "$SERVICE_DIR/run"
    success "Termux service script created at $SERVICE_DIR"
}

create_helper_scripts() {
    cat > "$BIN_DIR/ssh-local-start" <<'EOF'
#!/data/data/com.termux/files/usr/bin/bash
if pgrep -x sshd >/dev/null 2>&1; then
    echo "sshd already running."
    exit 0
fi
sshd >/dev/null 2>&1 && echo "SSH server started." || echo "Failed to start sshd."
EOF
    chmod +x "$BIN_DIR/ssh-local-start"

    cat > "$BIN_DIR/ssh-local-stop" <<'EOF'
#!/data/data/com.termux/files/usr/bin/bash
if ! pgrep -x sshd >/dev/null 2>&1; then
    echo "sshd is not running."
    exit 0
fi
pkill -x sshd && echo "SSH server stopped."
EOF
    chmod +x "$BIN_DIR/ssh-local-stop"

    cat > "$BIN_DIR/ssh-local-info" <<EOF
#!/data/data/com.termux/files/usr/bin/bash
PORT=${PORT}
USER="\$(whoami)"
get_ip() {
    local ip=""
    if command -v ip >/dev/null 2>&1; then
        ip="\$(ip route get 1.1.1.1 2>/dev/null | awk 'NR==1 {for(i=1;i<=NF;i++) if($i==\"src\") {print $(i+1); exit}}')"
        if [ -z "\$ip" ]; then
            ip="\$(ip -4 addr show wlan0 2>/dev/null | awk '/inet / {print $2}' | cut -d/ -f1 | head -n1)"
        fi
    fi
    if [ -z "\$ip" ] && command -v ifconfig >/dev/null 2>&1; then
        ip="\$(ifconfig 2>/dev/null | awk '/inet / && $2 != \"127.0.0.1\" {print $2; exit}')"
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

SFTP (WinSCP):
  Host: <device-ip> | Port: \$PORT | Protocol: SFTP
INFO
EOF
    chmod +x "$BIN_DIR/ssh-local-info"
    success "Helper scripts installed in $BIN_DIR"
}

enable_service() {
    if command -v sv-enable >/dev/null 2>&1; then
        sv-enable sshd >/dev/null 2>&1 || true
        sv up sshd >/dev/null 2>&1 || true
        sleep 1
        if pgrep -x sshd >/dev/null 2>&1; then
            success "SSH service running on port ${PORT}"
            return 0
        fi
    else
        warn "termux-services not available; service not enabled"
        return 1
    fi
    warn "SSH service did not start automatically"
    return 1
}

start_sshd_once() {
    if pgrep -x sshd >/dev/null 2>&1; then
        warn "sshd already running"
        return 0
    fi
    if sshd >/dev/null 2>&1; then
        success "SSH server started on port ${PORT}"
        return 0
    fi
    warn "Failed to start sshd; run 'sshd -d' for debugging"
    return 1
}

prompt_password() {
    if ! command -v passwd >/dev/null 2>&1; then
        warn "passwd command not found; install termux-tools to set passwords"
        return
    fi

    if [[ -n "$AUTO_MODE" ]]; then
        warn "Auto mode: run 'passwd' later to set your login password or use SSH keys"
        return
    fi

    read -r -p "Set or update the Termux password now? (Y/n): " answer
    if [[ -z "$answer" || "$answer" =~ ^[Yy]$ ]]; then
        passwd || warn "Password change skipped or failed"
    else
        warn "Skipping password change. Ensure ~/.ssh/authorized_keys contains a valid key or run 'passwd' later."
    fi
}

detect_device_ip() {
    local ip=""
    if command -v ip >/dev/null 2>&1; then
        ip="$(ip route get 1.1.1.1 2>/dev/null | awk 'NR==1 {for(i=1;i<=NF;i++) if($i=="src") {print $(i+1); exit}}')"
        if [[ -z "$ip" ]]; then
            ip="$(ip -4 addr show wlan0 2>/dev/null | awk '/inet / {print $2}' | cut -d/ -f1 | head -n1)"
        fi
    fi
    if [[ -z "$ip" ]] && command -v ifconfig >/dev/null 2>&1; then
        ip="$(ifconfig 2>/dev/null | awk '/inet / && $2 != "127.0.0.1" {print $2; exit}')"
    fi
    echo "$ip"
}

show_summary() {
    local user="$(whoami)"
    local ip="$(detect_device_ip)"

    success "Local SSH/SFTP access configured"
    info "Username : ${user}"
    info "Port     : ${PORT}"
    if [[ -n "$ip" ]]; then
        info "Device IP: ${ip}"
    else
        warn "Could not detect device IP automatically"
    fi
    echo
    echo "From another machine:"
    echo "  ssh -p ${PORT} ${user}@${ip:-<device-ip>}"
    echo
    echo "WinSCP / SFTP settings:"
    echo "  Host: ${ip:-<device-ip>} | Port: ${PORT} | User: ${user}"
    echo
    echo "Helper commands:"
    echo "  ssh-local-info   # show connection details"
    echo "  ssh-local-start  # start the server manually"
    echo "  ssh-local-stop   # stop the server"
}

main() {
    info "Configuring local SSH/SFTP server (port ${PORT})"
    ensure_packages
    prepare_directories
    generate_host_keys
    backup_config
    configure_sshd
    write_service
    create_helper_scripts

    if [[ -n "$AUTO_MODE" ]]; then
        enable_service || start_sshd_once || true
    else
        read -r -p "Enable sshd as a background service now? (Y/n): " answer
        if [[ -z "$answer" || "$answer" =~ ^[Yy]$ ]]; then
            enable_service || start_sshd_once || true
        else
            warn "Service not enabled. Use 'ssh-local-start' to launch manually."
        fi
    fi

    prompt_password
    show_summary
}

main "$@"
