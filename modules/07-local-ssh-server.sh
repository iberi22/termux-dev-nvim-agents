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
SSH_MEMORY_FILE="$HOME/.ssh/termux-ai-ssh-memory.conf"
STARTUP_SCRIPT="$HOME/.termux/boot/ssh-autostart.sh"

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
    mkdir -p "$HOME/.termux/boot"
}

create_memory_file() {
    info "Creating SSH configuration memory..."
    local user
    user="$(whoami)"
    local install_date
    install_date="$(date '+%Y-%m-%d %H:%M:%S')"

    cat > "$SSH_MEMORY_FILE" <<EOF
# Termux AI SSH/SFTP Configuration Memory
# Created: $install_date
# This file stores SSH configuration for standalone installations

SSH_PORT=$PORT
SSH_USER=$user
SSH_SERVICE_ENABLED=true
INSTALL_DATE=$install_date
STANDALONE_INSTALL=true
EOF
    chmod 600 "$SSH_MEMORY_FILE"
    success "SSH memory file created at $SSH_MEMORY_FILE"
}

create_boot_script() {
    info "Creating auto-start boot script..."
    cat > "$STARTUP_SCRIPT" <<EOF
#!/data/data/com.termux/files/usr/bin/bash
# Termux AI SSH Auto-start Script
# Automatically starts SSH service on Termux boot

set -euo pipefail

SSH_MEMORY_FILE="$HOME/.ssh/termux-ai-ssh-memory.conf"

# Load configuration from memory
if [[ -f "\$SSH_MEMORY_FILE" ]]; then
    source "\$SSH_MEMORY_FILE"

    # Wait for network to be available
    sleep 5

    # Start SSH service if configured
    if [[ "\${SSH_SERVICE_ENABLED:-false}" == "true" ]]; then
        if ! pgrep -x sshd >/dev/null 2>&1; then
            if command -v sv-enable >/dev/null 2>&1; then
                sv up sshd >/dev/null 2>&1 || sshd -p "\${SSH_PORT:-8022}" >/dev/null 2>&1
            else
                sshd -p "\${SSH_PORT:-8022}" >/dev/null 2>&1
            fi

            if pgrep -x sshd >/dev/null 2>&1; then
                echo "SSH service auto-started on port \${SSH_PORT:-8022}"
                # Show connection info if in interactive mode
                if [[ -t 1 ]]; then
                    "\$HOME/bin/ssh-local-info" 2>/dev/null || true
                fi
            fi
        fi
    fi
fi
EOF
    chmod +x "$STARTUP_SCRIPT"
    success "Boot auto-start script created at $STARTUP_SCRIPT"
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

SSH_MEMORY_FILE="$HOME/.ssh/termux-ai-ssh-memory.conf"

# Load SSH configuration from memory
if [[ -f "$SSH_MEMORY_FILE" ]]; then
    source "$SSH_MEMORY_FILE"
    PORT="${SSH_PORT:-8022}"
else
    PORT="8022"
fi

if pgrep -x sshd >/dev/null 2>&1; then
    echo "🟢 SSH server already running on port $PORT"
else
    echo "🚀 Starting SSH server..."

    # Try service manager first, then direct sshd
    if command -v sv-enable >/dev/null 2>&1; then
        sv up sshd >/dev/null 2>&1 || sshd -p "$PORT" >/dev/null 2>&1
    else
        sshd -p "$PORT" >/dev/null 2>&1
    fi

    if pgrep -x sshd >/dev/null 2>&1; then
        echo "✅ SSH server started successfully on port $PORT"
    else
        echo "❌ Failed to start SSH server"
        echo "💡 Try: sshd -d -p $PORT (for debug output)"
        exit 1
    fi
fi

# Show connection info automatically
echo
if command -v ssh-local-info >/dev/null 2>&1; then
    ssh-local-info
elif [[ -f "$HOME/scripts/ssh-memory-manager.sh" ]]; then
    bash "$HOME/scripts/ssh-memory-manager.sh"
else
    # Fallback info display
    echo "📡 SSH server ready - use: ssh -p $PORT $(whoami)@<device-ip>"
fi
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
# Enhanced SSH info with memory support

SSH_MEMORY_FILE="$HOME/.ssh/termux-ai-ssh-memory.conf"

# Load from memory if available
if [[ -f "\$SSH_MEMORY_FILE" ]]; then
    source "\$SSH_MEMORY_FILE"
    PORT="\${SSH_PORT:-${PORT}}"
    USER="\${SSH_USER:-\$(whoami)}"
    INSTALL_DATE="\${INSTALL_DATE:-Unknown}"
else
    PORT="${PORT}"
    USER="\$(whoami)"
    INSTALL_DATE="Unknown"
fi

get_ip() {
    local ip=""
    if command -v ip >/dev/null 2>&1; then
        ip="\$(ip route get 1.1.1.1 2>/dev/null | awk 'NR==1 {for(i=1;i<=NF;i++) if(\$i==\"src\") {print \$(i+1); exit}}')"
        if [ -z "\$ip" ]; then
            ip="\$(ip -4 addr show wlan0 2>/dev/null | awk '/inet / {print \$2}' | cut -d/ -f1 | head -n1)"
        fi
    fi
    if [ -z "\$ip" ] && command -v ifconfig >/dev/null 2>&1; then
        ip="\$(ifconfig 2>/dev/null | awk '/inet / && \$2 != \"127.0.0.1\" {print \$2; exit}')"
    fi
    echo "\$ip"
}

get_status() {
    if pgrep -x sshd >/dev/null 2>&1; then
        echo "🟢 RUNNING"
    else
        echo "🔴 STOPPED"
    fi
}

IP="\$(get_ip)"
STATUS="\$(get_status)"
[ -z "\$IP" ] && IP="(auto-detection failed)"

echo "═══════════════════════════════════════════════════════════"
echo "🔐 TERMUX SSH/SFTP CONNECTION INFO"
echo "═══════════════════════════════════════════════════════════"
echo "Status      : \$STATUS"
echo "Username    : \$USER"
echo "Port        : \$PORT"
echo "Device IP   : \$IP"
echo "Installed   : \$INSTALL_DATE"
echo
echo "📡 CONNECTION COMMANDS:"
echo "───────────────────────────────────────────────────────────"
echo "SSH from terminal:"
if [ "\$IP" != "(auto-detection failed)" ]; then
    echo "  ssh -p \$PORT \$USER@\$IP"
else
    echo "  ssh -p \$PORT \$USER@<device-ip>"
fi
echo
echo "SCP file transfer:"
if [ "\$IP" != "(auto-detection failed)" ]; then
    echo "  scp -P \$PORT file.txt \$USER@\$IP:~/"
    echo "  scp -P \$PORT \$USER@\$IP:~/file.txt ."
else
    echo "  scp -P \$PORT file.txt \$USER@<device-ip>:~/"
    echo "  scp -P \$PORT \$USER@<device-ip>:~/file.txt ."
fi
echo
echo "🗂️ SFTP CLIENT SETTINGS (WinSCP, FileZilla):"
echo "───────────────────────────────────────────────────────────"
echo "  Protocol: SFTP"
if [ "\$IP" != "(auto-detection failed)" ]; then
    echo "  Host    : \$IP"
else
    echo "  Host    : <device-ip>"
fi
echo "  Port    : \$PORT"
echo "  Username: \$USER"
echo "  Password: <your-termux-password>"
echo
echo "🛠️ MANAGEMENT COMMANDS:"
echo "───────────────────────────────────────────────────────────"
echo "  ssh-local-start  # Start SSH service"
echo "  ssh-local-stop   # Stop SSH service"
echo "  ssh-local-info   # Show this info (current command)"
echo "  passwd           # Change password"
echo "═══════════════════════════════════════════════════════════"
EOF
    chmod +x "$BIN_DIR/ssh-local-info"
    success "Helper scripts installed in $BIN_DIR"
}

# Create symlinks in $PREFIX/bin so helpers are available immediately without shell reload
link_helper_scripts() {
    mkdir -p "$PREFIX/bin"
    local tools=(ssh-local-start ssh-local-stop ssh-local-info)
    for t in "${tools[@]}"; do
        if [ -f "$BIN_DIR/$t" ]; then
            ln -sf "$BIN_DIR/$t" "$PREFIX/bin/$t"
        fi
    done
    success "Helper symlinks created in $PREFIX/bin"
}

# Persist $HOME/bin in PATH for future sessions (bash/zsh)
persist_path_update() {
    local export_line="export PATH=\"\$HOME/bin:\$PATH\""
    # bash
    if [ -f "$HOME/.bashrc" ]; then
        if ! grep -Fqs "$export_line" "$HOME/.bashrc"; then
            printf '\n# Added by termux-dev-nvim-agents (local SSH helpers)\n%s\n' "$export_line" >> "$HOME/.bashrc"
        fi
    else
        printf '#!/data/data/com.termux/files/usr/bin/bash\n%s\n' "$export_line" > "$HOME/.bashrc"
    fi
    chmod 644 "$HOME/.bashrc" 2>/dev/null || true

    # zsh
    if [ -f "$HOME/.zshrc" ]; then
        if ! grep -Fqs "$export_line" "$HOME/.zshrc"; then
            printf '\n# Added by termux-dev-nvim-agents (local SSH helpers)\n%s\n' "$export_line" >> "$HOME/.zshrc"
        fi
    fi

    info "Ensured \$HOME/bin is added to PATH for future shells"
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

enable_autostart() {
    info "Enabling SSH auto-start on boot..."

    # Create termux:boot directory structure
    mkdir -p "$HOME/.termux/boot"

    # Enable termux:boot if available
    if command -v termux-setup-storage >/dev/null 2>&1; then
        info "Termux:Boot support detected"
    fi

    success "SSH will auto-start on Termux boot"
}

show_enhanced_summary() {
    local user
    user="$(whoami)"
    local ip
    ip="$(detect_device_ip)"
    local status="🔴 STOPPED"

    if pgrep -x sshd >/dev/null 2>&1; then
        status="🟢 RUNNING"
    fi

    echo
    success "SSH/SFTP SERVER CONFIGURED SUCCESSFULLY!"
    echo "════════════════════════════════════════════════════════════════"
    echo "📊 Current Status: $status"
    echo "👤 Username: $user"
    echo "🔌 Port: $PORT"
    echo "🌐 Device IP: ${ip:-<auto-detection failed>}"
    echo "💾 Configuration saved to: $SSH_MEMORY_FILE"
    echo "🚀 Auto-start enabled: YES"
    echo
    echo "📡 QUICK CONNECTION (copy these commands):"
    echo "────────────────────────────────────────────────────────────────"
    if [[ -n "$ip" ]]; then
        echo "SSH:  ssh -p $PORT $user@$ip"
        echo "SCP:  scp -P $PORT file.txt $user@$ip:~/"
    else
        echo "SSH:  ssh -p $PORT $user@<device-ip>"
        echo "SCP:  scp -P $PORT file.txt $user@<device-ip>:~/"
        warn "⚠️  Replace <device-ip> with your actual device IP"
    fi
    echo
    echo "🗂️ SFTP CLIENTS (WinSCP, FileZilla, etc.):"
    echo "────────────────────────────────────────────────────────────────"
    echo "Protocol: SFTP | Host: ${ip:-<device-ip>} | Port: $PORT | User: $user"
    echo
    echo "🛠️ MANAGEMENT COMMANDS (always available):"
    echo "────────────────────────────────────────────────────────────────"
    echo "ssh-local-info    # Show detailed connection info"
    echo "ssh-local-start   # Start SSH service manually"
    echo "ssh-local-stop    # Stop SSH service"
    echo "passwd            # Change login password"
    echo "════════════════════════════════════════════════════════════════"
    echo
    info "💡 TIP: Run 'ssh-local-info' anytime to see connection details"

    if [[ "$status" == "🔴 STOPPED" ]]; then
        warn "⚠️  SSH service is not running. Use 'ssh-local-start' to start it."
    fi
}

main() {
    info "🔧 Configuring Termux SSH/SFTP server with persistent memory..."
    info "Port: $PORT | Auto-mode: ${AUTO_MODE:+YES}"

    ensure_packages
    prepare_directories
    generate_host_keys
    backup_config
    configure_sshd
    write_service
    create_memory_file
    create_boot_script
    create_helper_scripts
    link_helper_scripts
    persist_path_update
    enable_autostart

    # Always try to start the service for standalone installations
    local service_started=false

    if [[ -n "$AUTO_MODE" ]]; then
        enable_service || start_sshd_once || true
        service_started=true
    else
        read -r -p "🚀 Start SSH/SFTP service now? (Y/n): " answer
        if [[ -z "$answer" || "$answer" =~ ^[Yy]$ ]]; then
            enable_service || start_sshd_once || true
            service_started=true
        else
            warn "Service not started. Use 'ssh-local-start' to launch manually."
        fi
    fi

    # Update memory with service status
    if [[ "$service_started" == true ]] && pgrep -x sshd >/dev/null 2>&1; then
        sed -i 's/SSH_SERVICE_ENABLED=.*/SSH_SERVICE_ENABLED=true/' "$SSH_MEMORY_FILE" 2>/dev/null || true
    fi

    prompt_password
    show_enhanced_summary

    # Force show connection info after installation
    echo
    success "🎉 Installation complete! SSH/SFTP server ready for connections."
    info "💾 Configuration saved with persistent memory for standalone use."
    info "🔄 Service will auto-start on Termux boot."
}

main "$@"
