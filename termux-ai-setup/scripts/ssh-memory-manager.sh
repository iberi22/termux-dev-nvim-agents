#!/data/data/com.termux/files/usr/bin/bash

# 🔐 Termux SSH/SFTP Enhanced Memory Manager
# Manages SSH installations, provides persistent memory, and auto-connection display

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

# Configuration
SSH_MEMORY_FILE="$HOME/.ssh/termux-ai-ssh-memory.conf"
BIN_DIR="$HOME/bin"
PREFIX="${PREFIX:-/data/data/com.termux/files/usr}"

info() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[OK]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }

load_ssh_memory() {
    if [[ -f "$SSH_MEMORY_FILE" ]]; then
        source "$SSH_MEMORY_FILE"
        return 0
    fi
    return 1
}

get_device_ip() {
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
    echo "${ip:-unknown}"
}

show_connection_banner() {
    local ip="$(get_device_ip)"
    local status="🔴 STOPPED"
    
    if pgrep -x sshd >/dev/null 2>&1; then
        status="🟢 RUNNING"
    fi
    
    # Load configuration
    if load_ssh_memory; then
        local port="${SSH_PORT:-8022}"
        local user="${SSH_USER:-$(whoami)}"
    else
        local port="8022"
        local user="$(whoami)"
    fi
    
    echo -e "${PURPLE}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║${NC}  🔐 ${CYAN}TERMUX SSH/SFTP CONNECTION READY${NC}                        ${PURPLE}║${NC}"
    echo -e "${PURPLE}╠════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${PURPLE}║${NC}  Status: $status                                          ${PURPLE}║${NC}"
    echo -e "${PURPLE}║${NC}  User  : ${YELLOW}$user${NC}                                              ${PURPLE}║${NC}"
    echo -e "${PURPLE}║${NC}  Port  : ${YELLOW}$port${NC}                                                  ${PURPLE}║${NC}"
    echo -e "${PURPLE}║${NC}  IP    : ${YELLOW}$ip${NC}                                    ${PURPLE}║${NC}"
    echo -e "${PURPLE}╠════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${PURPLE}║${NC}  ${CYAN}📡 QUICK CONNECT COMMANDS:${NC}                                ${PURPLE}║${NC}"
    echo -e "${PURPLE}║${NC}                                                                ${PURPLE}║${NC}"
    
    if [[ "$ip" != "unknown" ]]; then
        echo -e "${PURPLE}║${NC}  ${WHITE}SSH:${NC}  ssh -p $port $user@$ip                          ${PURPLE}║${NC}"
        echo -e "${PURPLE}║${NC}  ${WHITE}SCP:${NC}  scp -P $port file.txt $user@$ip:~/             ${PURPLE}║${NC}"
    else
        echo -e "${PURPLE}║${NC}  ${WHITE}SSH:${NC}  ssh -p $port $user@<device-ip>                  ${PURPLE}║${NC}"
        echo -e "${PURPLE}║${NC}  ${WHITE}SCP:${NC}  scp -P $port file.txt $user@<device-ip>:~/     ${PURPLE}║${NC}"
    fi
    
    echo -e "${PURPLE}║${NC}                                                                ${PURPLE}║${NC}"
    echo -e "${PURPLE}║${NC}  ${CYAN}🗂️ SFTP CLIENT SETTINGS:${NC}                               ${PURPLE}║${NC}"
    
    if [[ "$ip" != "unknown" ]]; then
        echo -e "${PURPLE}║${NC}  Host: $ip | Port: $port | Protocol: SFTP           ${PURPLE}║${NC}"
    else
        echo -e "${PURPLE}║${NC}  Host: <device-ip> | Port: $port | Protocol: SFTP        ${PURPLE}║${NC}"
    fi
    
    echo -e "${PURPLE}╠════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${PURPLE}║${NC}  ${CYAN}🛠️ MANAGEMENT:${NC} ssh-local-start │ ssh-local-stop │ ssh-local-info ${PURPLE}║${NC}"
    echo -e "${PURPLE}╚════════════════════════════════════════════════════════════════╝${NC}"
    
    if [[ "$status" == "🔴 STOPPED" ]]; then
        echo -e "\n${YELLOW}⚠️  SSH service is stopped. Run ${CYAN}'ssh-local-start'${YELLOW} to start it.${NC}"
    else
        echo -e "\n${GREEN}✅ SSH/SFTP server is ready for connections!${NC}"
    fi
}

main() {
    show_connection_banner
}

main "$@"