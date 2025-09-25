#!/bin/bash

# ====================================
# TERMUX AI DEVELOPMENT SETUP
# Modular system to configure Termux with AI
# Repository: https://github.com/iberi22/termux-dev-nvim-agents
# Quick install: wget -qO- https://raw.githubusercontent.com/iberi22/termux-dev-nvim-agents/main/install.sh | bash
# ====================================

set -Eeuo pipefail
IFS=$'\n\t'

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Determine script location with graceful fallbacks
DEFAULT_INSTALL_DIR="$HOME/termux-dev-nvim-agents"

resolve_script_dir() {
    local source="${BASH_SOURCE[0]}"

    if [[ -z "$source" || "$source" == "bash" || "$source" == "-" || "$source" =~ ^/dev/fd ]]; then
        printf '%s\n' "$PWD"
        return
    fi

    while [[ -h "$source" ]]; do
        local dir
        dir="$(cd -P "$(dirname "$source")" && pwd)"
        if command -v readlink >/dev/null 2>&1; then
            source="$(readlink "$source")"
        else
            break
        fi
        [[ "$source" != /* ]] && source="$dir/$source"
    done

    (cd -P "$(dirname "$source")" && pwd)
}

SCRIPT_DIR="$(resolve_script_dir)"
if [[ ! -d "$SCRIPT_DIR" && -d "$DEFAULT_INSTALL_DIR" ]]; then
    SCRIPT_DIR="$DEFAULT_INSTALL_DIR"
fi

if [[ -d "$DEFAULT_INSTALL_DIR/modules" && ! -d "$SCRIPT_DIR/modules" ]]; then
    SCRIPT_DIR="$DEFAULT_INSTALL_DIR"
fi

MODULES_DIR="${SCRIPT_DIR}/modules"
CONFIG_DIR="${SCRIPT_DIR}/config"
LOG_FILE="${SCRIPT_DIR}/setup.log"

readonly SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"
readonly SCRIPT_START_TS="$(date +%s)"

SCRIPT_EXIT_CODE=-1
SCRIPT_FAILURE_CMD=""
SCRIPT_STATUS="running"

declare -a SUMMARY_LINES=()

MODULE_STATE_SCRIPT="${SCRIPT_DIR}/scripts/module-state.sh"
# shellcheck disable=SC1090
if [[ -f "$MODULE_STATE_SCRIPT" ]]; then
    source "$MODULE_STATE_SCRIPT"
else
    termux_ai_state_init() { :; }
    termux_ai_module_completed() { return 1; }
    termux_ai_record_module_state() { :; }
    termux_ai_reset_all_state() { :; }
    termux_ai_reset_module_state() { :; }
fi

if [[ -d "$SCRIPT_DIR" ]]; then
    cd "$SCRIPT_DIR"
fi

# Function for logging
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

add_summary() {
    SUMMARY_LINES+=("$1")
}

on_error() {
    local exit_code=$1
    local failed_command=$2
    SCRIPT_EXIT_CODE=$exit_code
    SCRIPT_FAILURE_CMD="$failed_command"
    SCRIPT_STATUS="error"
    log "[ERROR] Command failed: ${failed_command} (exit ${exit_code})"
}

on_interrupt() {
    SCRIPT_EXIT_CODE=130
    SCRIPT_STATUS="interrupted"
    log "[WARN] Installation interrupted by user"
    echo -e "${RED}[ERROR] Installation interrupted by user${NC}"
    exit 130
}

cleanup() {
    trap - EXIT ERR INT TERM

    local captured=$?
    local exit_code=$captured

    if (( SCRIPT_EXIT_CODE >= 0 )); then
        exit_code=$SCRIPT_EXIT_CODE
    fi

    local elapsed=$(( $(date +%s) - SCRIPT_START_TS ))

    if [[ $exit_code -ne 0 ]]; then
        if [[ -n "$SCRIPT_FAILURE_CMD" ]]; then
            echo -e "${RED}[ERROR] Último comando fallido: ${SCRIPT_FAILURE_CMD}${NC}"
        fi
        echo -e "${YELLOW}[INFO] Consulta ${LOG_FILE} para más detalles.${NC}"
        echo -e "${RED}[ERROR] ${SCRIPT_NAME} abortado tras ${elapsed}s (código ${exit_code}).${NC}"
        log "[ERROR] Script aborted after ${elapsed}s (code ${exit_code})"
    else
        log "[INFO] Script completed successfully in ${elapsed}s"
        if ((${#SUMMARY_LINES[@]} > 0)); then
            echo -e "${CYAN}[INFO] Resumen rápido:${NC}"
            for line in "${SUMMARY_LINES[@]}"; do
                echo -e "  • ${line}"
            done
        fi
    fi

    exit "$exit_code"
}

# Function to show banner
show_banner() {
    clear
    echo -e "${PURPLE}"
    echo "=============================================="
    echo "           TERMUX AI SETUP v2.0"
    echo "   Automated System for AI Development in Termux"
    echo "=============================================="
    echo -e "${NC}
"
}


# Function to check prerequisites
check_prerequisites() {
    echo -e "${BLUE}[INFO] Checking prerequisites...${NC}"

    # Verify we're running in Termux
    if [[ ! -d "/data/data/com.termux" ]]; then
        echo -e "${RED}[ERROR] This script must be run in Termux${NC}"
        exit 1
    fi

    # Verify internet connection
    if ! ping -c 1 google.com &> /dev/null; then
        echo -e "${RED}[ERROR] Internet connection required${NC}"
        exit 1
    fi

    # Attempt to switch to the default install directory if modules are missing but the repo exists there
    if [[ ! -d "$MODULES_DIR" && -d "$DEFAULT_INSTALL_DIR/modules" ]]; then
        echo -e "${YELLOW}[!] Modules directory missing in current path.${NC}"
        echo -e "${YELLOW}[>] Switching to: $DEFAULT_INSTALL_DIR${NC}"
        SCRIPT_DIR="$DEFAULT_INSTALL_DIR"
        MODULES_DIR="${SCRIPT_DIR}/modules"
        CONFIG_DIR="${SCRIPT_DIR}/config"
        LOG_FILE="${SCRIPT_DIR}/setup.log"
        cd "$SCRIPT_DIR"
    fi

    # Verify we have the correct directory structure
    if [[ ! -d "$MODULES_DIR" ]]; then
        echo -e "${RED}[x] Modules directory not found: $MODULES_DIR${NC}"
        echo -e "${YELLOW}[!] Please ensure you're running this script from the correct location.${NC}"

        # Check if we're in the wrong directory but repository exists
        if [[ -d "$DEFAULT_INSTALL_DIR" && "$PWD" != "$DEFAULT_INSTALL_DIR" ]]; then
            echo -e "${CYAN}[i] Found installation at: $DEFAULT_INSTALL_DIR${NC}"
            echo -e "${CYAN}[i] Please run: cd ~/termux-dev-nvim-agents && ./setup.sh${NC}"
            exit 1
        fi

        echo -e "${YELLOW}[!] Try re-running the installer:${NC}"
        echo -e "${CYAN}   wget -qO- https://raw.githubusercontent.com/iberi22/termux-dev-nvim-agents/main/install.sh | bash${NC}"
        exit 1
    fi
    # Verify essential modules exist
    local essential_modules=("00-base-packages.sh" "test-installation.sh")
    for module in "${essential_modules[@]}"; do
        if [[ ! -f "$MODULES_DIR/$module" ]]; then
            echo -e "${RED}❌ Essential module missing: $module${NC}"
            echo -e "${YELLOW}💡 Please re-run the installer to restore missing files.${NC}"
            exit 1
        fi
    done

    echo -e "${GREEN}✅ Prerequisites verified${NC}"
}

# Function to show main menu
show_main_menu() {
    echo -e "${CYAN}┌─────────────────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│                  MAIN MENU                      │${NC}"
    echo -e "${CYAN}├─────────────────────────────────────────────────┤${NC}"
    echo -e "${WHITE}│  1. � Instalación Completa Automática         │${NC}"
    echo -e "${CYAN}├─────────────────────────────────────────────────┤${NC}"
    echo -e "${WHITE}│  2. 📦 Instalar Paquetes Base                  │${NC}"
    echo -e "${WHITE}│  3. � Configurar Zsh Rastafari + Oh My Zsh    │${NC}"
    echo -e "${WHITE}│  4. ⚡ Instalar y Configurar Neovim            │${NC}"
    echo -e "${WHITE}│  5. 🤖 Configurar Integración IA               │${NC}"
    echo -e "${WHITE}│  6. 🔐 Configurar SSH para GitHub              │${NC}"
    echo -e "${CYAN}├─────────────────────────────────────────────────┤${NC}"
    echo -e "${WHITE}│  7. 🧪 Ejecutar Pruebas de Instalación         │${NC}"
    echo -e "${WHITE}│  8. 🧹 Limpiar y Reinstalar desde Cero         │${NC}"
    echo -e "${GREEN}│  9. 🎛️  Panel de Control Post-Instalación      │${NC}"
    echo -e "${CYAN}├─────────────────────────────────────────────────┤${NC}"
    echo -e "${WHITE}│ 99. 🚪 Salir                                   │${NC}"
    echo -e "${CYAN}└─────────────────────────────────────────────────┘${NC}"
    echo -e "\n${YELLOW}Selecciona una opción [1-9, 99]:${NC} "
}

# Function to run module with error handling
run_module() {
    local module_name="$1"
    local module_path="${MODULES_DIR}/${module_name}.sh"

    termux_ai_state_init

    echo -e "${BLUE}[RUN] Preparing to run: ${module_name}${NC}"
    echo -e "${CYAN}[INFO] Looking for module at: ${module_path}${NC}"
    echo -e "${CYAN}[INFO] Current directory: ${PWD}${NC}"
    echo -e "${CYAN}[INFO] Script directory: ${SCRIPT_DIR}${NC}"
    echo -e "${CYAN}[INFO] Modules directory: ${MODULES_DIR}${NC}"

    if [[ "${TERMUX_AI_FORCE_MODULES:-0}" != "1" ]]; then
        if termux_ai_module_completed "$module_name" "$module_path"; then
            echo -e "${GREEN}[SKIP] ${module_name} ya completado. Usa --force para reejecutar.${NC}"
            log "Module skipped (cached): ${module_name}"
            return 0
        fi
    else
        echo -e "${YELLOW}[FORCE] Reejecutando módulo ${module_name} a petición.${NC}"
        termux_ai_reset_module_state "$module_name"
    fi

    if [[ ! -f "$module_path" ]]; then
        echo -e "${RED}[ERROR] Module not found: ${module_path}${NC}"

        if [[ -d "$MODULES_DIR" ]]; then
            echo -e "${CYAN}[INFO] Available modules in ${MODULES_DIR}:${NC}"
            ls -la "$MODULES_DIR"/*.sh 2>/dev/null || echo -e "${YELLOW}[WARN] No .sh files found${NC}"
        else
            echo -e "${RED}[ERROR] Modules directory does not exist: ${MODULES_DIR}${NC}"
        fi

        echo -e "${YELLOW}[HINT] Solutions:${NC}"
        echo -e "${CYAN}  1. Ensure you're in the right directory: cd ~/termux-dev-nvim-agents${NC}"
        echo -e "${CYAN}  2. Re-run the installer: wget -qO- https://raw.githubusercontent.com/iberi22/termux-dev-nvim-agents/main/install.sh | bash${NC}"
        return 1
    fi

    if [[ ! -x "$module_path" ]]; then
        echo -e "${YELLOW}[WARN] Making ${module_name} executable...${NC}"
        chmod +x "$module_path"
    fi

    local auto_flag="${TERMUX_AI_AUTO:-}"
    local exit_code=0

    if [[ -n "$auto_flag" ]]; then
        if ! TERMUX_AI_AUTO="$auto_flag" bash "$module_path"; then
            exit_code=$?
        fi
    else
        if ! bash "$module_path"; then
            exit_code=$?
        fi
    fi

    if [[ $exit_code -eq 0 ]]; then
        echo -e "${GREEN}[OK] ${module_name} completed successfully${NC}"
        log "Module completed: ${module_name}"
        termux_ai_record_module_state "$module_name" "$module_path" "completed" 0
        return 0
    else
        echo -e "${RED}[ERROR] Error in ${module_name} (exit code: ${exit_code})${NC}"
        log "Error in module: ${module_name} (exit code: ${exit_code})"
        termux_ai_record_module_state "$module_name" "$module_path" "failed" "$exit_code"
        SCRIPT_EXIT_CODE=$exit_code
        SCRIPT_FAILURE_CMD="module:${module_name}"
        return 1
    fi
}


# Function to setup Gemini CLI (original interactive)
setup_gemini_cli() {
    echo -e "${YELLOW}🤖 Configurando Gemini CLI...${NC}"

    # Verificar si Node.js está instalado
    if ! command -v node &>/dev/null; then
        echo -e "${YELLOW}📦 Node.js requerido para Gemini CLI, instalando...${NC}"
        if ! run_module "00-base-packages"; then
            echo -e "${RED}❌ Error instalando dependencias${NC}"
            return 1
        fi
    fi

    # Instalar Gemini CLI
    if ! command -v gemini &>/dev/null; then
        echo -e "${YELLOW}📦 Instalando Gemini CLI...${NC}"
        npm install -g @google/gemini-cli
    fi

    # Configurar autenticación (DESACTIVADO - solo instala CLI)
    # if ! gemini auth test &>/dev/null; then
    #     echo -e "${CYAN}🔐 Configura la autenticación OAuth2 con Google${NC}"
    #     gemini auth login
    # fi
    echo -e "${YELLOW}ℹ️ Autenticación OAuth2 omitida. Usar 'gemini auth login' manualmente si es necesario.${NC}"

    echo -e "${GREEN}✅ Gemini CLI configurado${NC}"
}

# Function to setup Gemini CLI (automatic mode)
prepare_npm_env_for_gemini() {
    if ! command -v npm &>/dev/null; then
        return 0
    fi

    local npm_prefix="${HOME}/.npm-global"
    local current_prefix
    current_prefix=$(npm config get prefix 2>/dev/null || echo "")

    if [[ -z "$current_prefix" || "$current_prefix" == "null" ]]; then
        current_prefix=""
    fi

    if [[ "$current_prefix" != "$npm_prefix" ]]; then
        npm config set prefix "$npm_prefix" >/dev/null 2>&1 || true
    fi

    if [[ ":$PATH:" != *":${npm_prefix}/bin:"* ]]; then
        export PATH="${npm_prefix}/bin:${PATH}"
    fi

    export NPM_CONFIG_PREFIX="$npm_prefix"
    export npm_config_prefix="$npm_prefix"
}

install_gemini_cli_with_retries() {
    local packages=("@google/gemini-cli@latest" "@google/gemini-cli")
    local max_attempts=3
    local attempt
    local pkg

    for pkg in "${packages[@]}"; do
        attempt=1
        while (( attempt <= max_attempts )); do
            log "[INFO] Installing ${pkg} (attempt ${attempt}/${max_attempts})"
            if npm install -g "$pkg" --unsafe-perm --no-progress >>"$LOG_FILE" 2>&1; then
                return 0
            fi

            log "[WARN] npm install for ${pkg} failed (attempt ${attempt})"
            echo -e "${YELLOW}[WARN] npm install ${pkg} failed (attempt ${attempt}). Retrying...${NC}"
            sleep $(( attempt * 5 ))
            attempt=$(( attempt + 1 ))
        done
    done

    log "[ERROR] Unable to install @google/gemini-cli after retries"
    return 1
}

setup_gemini_cli_auto() {
    if [[ "${TERMUX_AI_SILENT:-}" == "1" ]]; then
        echo -e "${BLUE}[AUTO] Configurando Gemini CLI automaticamente...${NC}"
    else
        echo -e "${YELLOW}[INFO] Configurando Gemini CLI...${NC}"
    fi

    if ! command -v node &>/dev/null; then
        if [[ "${TERMUX_AI_SILENT:-}" == "1" ]]; then
            echo -e "${CYAN}[INFO] Instalando Node.js antes de Gemini CLI...${NC}"
        else
            echo -e "${YELLOW}[INFO] Node.js requerido para Gemini CLI, instalando dependencias base...${NC}"
        fi

        if ! run_module "00-base-packages"; then
            echo -e "${RED}[ERROR] Error instalando dependencias previas para Gemini CLI${NC}"
            return 1
        fi
    fi

    if ! command -v npm &>/dev/null; then
        echo -e "${YELLOW}[INFO] npm no disponible; reintentando dependencias base...${NC}"
        if ! run_module "00-base-packages"; then
            echo -e "${RED}[ERROR] No se pudo asegurar npm para Gemini CLI${NC}"
            return 1
        fi
    fi

    prepare_npm_env_for_gemini

    if command -v gemini &>/dev/null; then
        local current_version
        current_version=$(gemini --version 2>/dev/null || echo "desconocida")
        echo -e "${GREEN}[OK] Gemini CLI ya disponible (v${current_version})${NC}"
    else
        echo -e "${CYAN}[INFO] Instalando @google/gemini-cli...${NC}"
        if ! install_gemini_cli_with_retries; then
            echo -e "${RED}[ERROR] Error instalando Gemini CLI. Revisa ${LOG_FILE}${NC}"
            add_summary "Gemini CLI no se pudo instalar automaticamente"
            return 1
        fi
    fi

    if command -v gemini &>/dev/null; then
        local version
        version=$(gemini --version 2>/dev/null || echo "desconocida")
        echo -e "${GREEN}[OK] Gemini CLI v${version} instalado${NC}"

        if [[ "${TERMUX_AI_AUTO:-}" == "1" ]]; then
            mkdir -p "$HOME/.gemini" 2>/dev/null || true
            cat > "$HOME/.gemini/settings.json" <<'EOF'
{
  "model": {
    "name": "gemini-2.5-flash"
  },
  "safety": {
    "threshold": "BLOCK_ONLY_HIGH"
  }
}
EOF
            echo -e "${GREEN}[OK] Modelo predeterminado configurado: gemini-2.5-flash${NC}"
        fi
    else
        echo -e "${RED}[ERROR] Gemini CLI no se detecta en el PATH tras la instalacion${NC}"
        add_summary "Gemini CLI no se detecta tras la instalacion"
        return 1
    fi

    if [[ "${TERMUX_AI_SILENT:-}" == "1" ]]; then
        echo -e "${CYAN}[INFO] Autenticacion OAuth2 se realizara mas tarde con 'gemini auth login'.${NC}"
    else
        echo -e "${YELLOW}[INFO] Autenticacion OAuth2 omitida. Ejecuta 'gemini auth login' cuando sea necesario.${NC}"
    fi

    echo -e "${GREEN}[OK] Gemini CLI configurado${NC}"
}

# Function for post-installation configuration (automatic mode)
detect_termux_shell() {
    local shell_path="${SHELL:-}"
    if [[ -n "$shell_path" && -x "$shell_path" ]]; then
        echo "$shell_path"
        return 0
    fi

    local prefix="${PREFIX:-/data/data/com.termux/files/usr}"
    local candidates=(
        "$prefix/bin/zsh"
        "$prefix/bin/bash"
        "$prefix/bin/sh"
    )

    for candidate in "${candidates[@]}"; do
        if [[ -x "$candidate" ]]; then
            echo "$candidate"
            return 0
        fi
    done

    echo "/bin/sh"
}

ensure_termux_user_entry() {
    local username=$1
    local prefix="${PREFIX:-/data/data/com.termux/files/usr}"
    local shell_path
    shell_path="$(detect_termux_shell)"

    if id "$username" >/dev/null 2>&1; then
        return 0
    fi

    if command -v useradd >/dev/null 2>&1; then
        if useradd -m -s "$shell_path" "$username" >/dev/null 2>&1; then
            echo -e "${GREEN}✅ Usuario ${username} creado con useradd${NC}"
            return 0
        fi
    fi

    if command -v adduser >/dev/null 2>&1; then
        if adduser --disabled-password --shell "$shell_path" --gecos "" "$username" >/dev/null 2>&1; then
            echo -e "${GREEN}✅ Usuario ${username} creado con adduser${NC}"
            return 0
        fi
    fi

    local passwd_file="${prefix}/etc/passwd"
    local shadow_file="${prefix}/etc/shadow"

    if [[ -w "$passwd_file" ]]; then
        if ! grep -q "^${username}:" "$passwd_file"; then
            local uid
            local gid
            uid="$(id -u)"
            gid="$(id -g)"
            printf '%s:%s:%s:%s:%s:%s:%s\n' "$username" "x" "$uid" "$gid" "$username" "$HOME" "$shell_path" >> "$passwd_file"
            if [[ -f "$shadow_file" && -w "$shadow_file" ]]; then
                if ! grep -q "^${username}:" "$shadow_file"; then
                    printf '%s:%s:%s:%s:%s:%s:%s:%s:%s\n' "$username" "*" "0" "0" "99999" "7" "" "" "" >> "$shadow_file"
                fi
            fi
            echo -e "${GREEN}✅ Usuario ${username} registrado en ${passwd_file}${NC}"
        fi
        return 0
    fi

    echo -e "${YELLOW}⚠️ No se pudo crear el usuario ${username}. Se usará el usuario actual para SSH.${NC}"
    return 1
}

set_termux_user_password() {
    local username=$1
    local password=$2

    if [[ "$username" != "$(whoami)" && "$EUID" -ne 0 ]]; then
        echo -e "${YELLOW}⚠️ Sin privilegios para establecer la contraseña de ${username}. Ejecuta 'passwd ${username}' manualmente.${NC}"
        return 1
    fi

    if command -v chpasswd >/dev/null 2>&1 && [[ "$username" == "$(whoami)" || "$EUID" -eq 0 ]]; then
        if echo "${username}:${password}" | chpasswd >/dev/null 2>&1; then
            echo -e "${GREEN}✅ Contraseña establecida para ${username}${NC}"
            return 0
        fi
    fi

    if command -v expect >/dev/null 2>&1; then
        local passwd_cmd="passwd"
        if [[ "$username" != "$(whoami)" ]]; then
            passwd_cmd="passwd ${username}"
        fi

        if expect <<EOF >/dev/null 2>&1
spawn ${passwd_cmd}
expect "New password:"
send "${password}\r"
expect "Retype new password:"
send "${password}\r"
expect eof
EOF
        then
            echo -e "${GREEN}✅ Contraseña establecida para ${username}${NC}"
            return 0
        fi
    fi

    echo -e "${YELLOW}⚠️ No se pudo establecer la contraseña automáticamente para ${username}. Ejecuta 'passwd ${username}' manualmente.${NC}"
    return 1
}

post_installation_setup_auto() {
    echo -e "${CYAN}=============================================${NC}"
    echo -e "${GREEN}🎉 ¡Instalación Automática Completada!${NC}"
    echo -e "${CYAN}=============================================${NC}"
    echo ""

    # Configuración automática de usuario SSH
    echo -e "${BLUE}🔐 Configurando usuario SSH automáticamente...${NC}"
    local requested_ssh_user="${TERMUX_AI_SSH_USER:-termux}"
    local ssh_pass="${TERMUX_AI_SSH_PASS:-termux}"
    local effective_ssh_user="$requested_ssh_user"

    echo -e "${CYAN}Usuario SSH preferido: ${requested_ssh_user}${NC}"

    if ! ensure_termux_user_entry "$requested_ssh_user"; then
        effective_ssh_user="$(whoami)"
        echo -e "${YELLOW}⚠️ Usaremos el usuario actual (${effective_ssh_user}) para el inicio de sesión SSH.${NC}"
    fi

    if set_termux_user_password "$effective_ssh_user" "$ssh_pass"; then
        echo -e "${GREEN}✅ Contraseña predeterminada establecida para ${effective_ssh_user}${NC}"
    fi

    # SSH keys automatizadas
    if [[ ! -f "$HOME/.ssh/id_ed25519" ]]; then
        echo -e "${CYAN}🔑 Generando claves SSH automáticamente...${NC}"
        local git_email="${TERMUX_AI_GIT_EMAIL:-termux@localhost}"
        ssh-keygen -t ed25519 -C "$git_email" -f "$HOME/.ssh/id_ed25519" -N "" >/dev/null 2>&1
        echo -e "${GREEN}✅ Claves SSH generadas${NC}"
    fi

    # Servidor SSH permanente automático
    if [[ "${TERMUX_AI_SETUP_SSH:-}" == "1" ]]; then
        echo -e "${CYAN}🌐 Habilitando servidor SSH permanente...${NC}"
        if command -v sv-enable >/dev/null 2>&1; then
            if sv-enable sshd >/dev/null 2>&1; then
                if command -v sv >/dev/null 2>&1; then
                    if ! sv up sshd >/dev/null 2>&1; then
                        echo -e "${YELLOW}⚠️ No se pudo iniciar el servicio SSH automáticamente (sv up).${NC}"
                    fi
                fi
                local ip=$(ifconfig wlan0 2>/dev/null | grep 'inet ' | awk '{print $2}' | head -1 || echo "IP_NO_DETECTADA")
                echo -e "${GREEN}✅ SSH habilitado en: ssh -p 8022 ${effective_ssh_user}@${ip}${NC}"
            else
                echo -e "${YELLOW}⚠️ No se pudo habilitar el arranque automático con sv-enable.${NC}"
            fi
        else
            echo -e "${YELLOW}⚠️ termux-services no está instalado; omitiendo habilitación automática de SSH.${NC}"
        fi
    fi

    # Instalar comando del panel automáticamente
    install_ai_panel_command

    # Lanzar panel web automáticamente si está configurado
    if [[ "${TERMUX_AI_LAUNCH_WEB:-}" == "1" && "${TERMUX_AI_START_SERVICES:-}" == "1" ]]; then
        echo -e "${CYAN}🌐 Iniciando Panel Web automáticamente...${NC}"
        local panel_launcher="${SCRIPT_DIR}/start-panel.sh"
        if [[ -f "$panel_launcher" ]]; then
            echo -e "${BLUE}🔧 Instalando dependencias del panel web...${NC}"
            if bash "$panel_launcher" install >/dev/null 2>&1; then
                echo -e "${GREEN}✅ Panel web configurado${NC}"
                echo -e "${CYAN}Frontend: http://localhost:3000${NC}"
                echo -e "${CYAN}Backend:  http://localhost:8000${NC}"

                # Iniciar en background
                nohup bash "$panel_launcher" dev >/dev/null 2>&1 &
                echo -e "${GREEN}✅ Panel web iniciado en background${NC}"
            fi
        fi
    fi

    echo -e "${CYAN}ℹ️ Para configurar Git y GitHub ejecuta luego:${NC} ${YELLOW}bash modules/05-ssh-setup.sh${NC}"

    echo -e "\n${GREEN}🎉 ¡Configuración Automática Completa!${NC}"
    echo -e "${CYAN}=============================================${NC}"
    echo -e "${WHITE}📋 RESUMEN DE CONFIGURACIÓN:${NC}"
    echo -e "${CYAN}  • Usuario SSH: ${effective_ssh_user}${NC}"
    echo -e "${CYAN}  • Puerto SSH: 8022${NC}"
    echo -e "${CYAN}  • Panel Web: http://localhost:3000${NC}"
    echo -e "${CYAN}  • Comando IA: : \"tu pregunta\"${NC}"
    echo -e "${CYAN}  • Panel Control: termux-ai-panel${NC}"
    echo -e "${CYAN}=============================================${NC}"

    if [[ -f "$HOME/.ssh/id_ed25519.pub" ]]; then
        echo -e "${YELLOW}📋 Tu Clave Pública SSH (para GitHub):${NC}"
        echo -e "${CYAN}=============================================${NC}"
        cat "$HOME/.ssh/id_ed25519.pub"
        echo -e "${CYAN}=============================================${NC}"
        echo -e "${BLUE}🔗 Agrégala a: https://github.com/settings/ssh${NC}"
        echo -e "${CYAN}=============================================${NC}"
    fi
}

# Configuración final de Git y SSH
configure_git_and_ssh_final() {
    echo -e "${BLUE}⚙️ Configuración final de Git y SSH...${NC}"

    # En modo automático, usar valores predeterminados
    if [[ "${TERMUX_AI_SILENT:-}" == "1" ]]; then
        configure_git_and_ssh_auto
        return 0
    fi

    # Solicitar información del usuario AHORA (al final)
    echo -e "${CYAN}┌─────────────────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│           CONFIGURACIÓN FINAL DE USUARIO        │${NC}"
    echo -e "${CYAN}└─────────────────────────────────────────────────┘${NC}"

    echo -e "${YELLOW}🔧 Para completar la configuración, necesitamos algunos datos:${NC}"
    echo ""

    # Configurar Git si no está configurado
    local git_name="${TERMUX_AI_GIT_NAME:-}"
    local git_email="${TERMUX_AI_GIT_EMAIL:-}"

    if [[ -z "$git_name" ]] && ! git config --global user.name >/dev/null 2>&1; then
        echo -e "${CYAN}📝 Configuración de Git:${NC}"
        read -p "Ingresa tu nombre completo: " git_name
        while [[ -z "$git_name" ]]; do
            echo -e "${RED}❌ El nombre es obligatorio${NC}"
            read -p "Ingresa tu nombre completo: " git_name
        done
        git config --global user.name "$git_name"
    elif [[ -n "$git_name" ]]; then
        git config --global user.name "$git_name"
    fi

    if [[ -z "$git_email" ]] && ! git config --global user.email >/dev/null 2>&1; then
        read -p "Ingresa tu email de GitHub: " git_email
        while [[ -z "$git_email" || ! "$git_email" =~ ^[^@]+@[^@]+\.[^@]+$ ]]; do
            echo -e "${RED}❌ Email inválido${NC}"
            read -p "Ingresa tu email de GitHub: " git_email
        done
        git config --global user.email "$git_email"
    elif [[ -n "$git_email" ]]; then
        git config --global user.email "$git_email"
    fi

    # Configurar SSH para GitHub si hay claves
    if [[ -f "$HOME/.ssh/id_ed25519" ]]; then
        echo ""
        echo -e "${CYAN}🔑 Configuración SSH para GitHub:${NC}"

        cat > "$HOME/.ssh/config" << 'EOF'
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519
    IdentitiesOnly yes

Host *
    ServerAliveInterval 60
    ServerAliveCountMax 3
EOF
        chmod 600 "$HOME/.ssh/config"

        # Agregar clave al ssh-agent
        eval "$(ssh-agent -s)" >/dev/null 2>&1
        ssh-add "$HOME/.ssh/id_ed25519" >/dev/null 2>&1

        echo -e "${GREEN}✅ Git y SSH configurados correctamente${NC}"

        # Mostrar la clave pública para que el usuario la agregue a GitHub
        echo -e "\n${YELLOW}📋 Copia esta clave pública SSH y agrégala a GitHub:${NC}"
        echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
        cat "$HOME/.ssh/id_ed25519.pub"
        echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
        echo -e "${BLUE}🔗 Agrégala en: https://github.com/settings/ssh${NC}"
        echo -e "${YELLOW}💡 Presiona Enter cuando hayas agregado la clave...${NC}"
        read -r

        # Probar la conexión SSH
        echo -e "${CYAN}🔍 Probando conexión SSH con GitHub...${NC}"
        if ssh -T git@github.com -o StrictHostKeyChecking=no 2>&1 | grep -q "successfully authenticated"; then
            echo -e "${GREEN}✅ Conexión SSH con GitHub establecida correctamente${NC}"
        else
            echo -e "${YELLOW}⚠️ Conexión SSH no confirmada. Verifica que agregaste la clave a GitHub.${NC}"
        fi
    fi

    # Configuración final de autenticación Gemini CLI
    configure_gemini_auth_final
}

# Configuración automática de Git y SSH
configure_git_and_ssh_auto() {
    # Configurar Git si no está configurado
    if ! git config --global user.name >/dev/null 2>&1; then
        git config --global user.name "${TERMUX_AI_GIT_NAME:-Termux Developer}"
    fi
    if ! git config --global user.email >/dev/null 2>&1; then
        git config --global user.email "${TERMUX_AI_GIT_EMAIL:-developer@termux.local}"
    fi

    # Configurar SSH para GitHub automáticamente
    if [[ -f "$HOME/.ssh/id_ed25519" ]]; then
        cat > "$HOME/.ssh/config" << 'EOF'
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519
    IdentitiesOnly yes

Host *
    ServerAliveInterval 60
    ServerAliveCountMax 3
EOF
        chmod 600 "$HOME/.ssh/config"

        # Agregar clave al ssh-agent
        eval "$(ssh-agent -s)" >/dev/null 2>&1
        ssh-add "$HOME/.ssh/id_ed25519" >/dev/null 2>&1

        echo -e "${GREEN}✅ Git y SSH configurados automáticamente${NC}"
    fi
}

# Configuración final de autenticación Gemini CLI
configure_gemini_auth_final() {
    if [[ "${TERMUX_AI_SILENT:-}" == "1" ]]; then
        echo -e "${CYAN}ℹ️ Gemini CLI instalado. Usa 'gemini auth login' para configurar OAuth2 cuando sea necesario${NC}"
        return 0
    fi

    echo -e "\n${CYAN}🤖 Configuración final de Gemini CLI:${NC}"

    if command -v gemini >/dev/null 2>&1; then
        echo -e "${BLUE}¿Deseas configurar la autenticación OAuth2 con Google ahora?${NC}"
        echo -e "${YELLOW}Esto te permitirá usar el comando ':' para consultas IA${NC}"
        read -p "Configurar autenticación Gemini ahora? (y/N): " setup_gemini_auth

        if [[ "$setup_gemini_auth" =~ ^[Yy]$ ]]; then
            echo -e "${CYAN}🔐 Iniciando proceso de autenticación OAuth2...${NC}"
            gemini auth login || echo -e "${YELLOW}⚠️ Autenticación no completada. Puedes configurarla más tarde con 'gemini auth login'${NC}"

            # Verificar autenticación
            if gemini auth test >/dev/null 2>&1; then
                echo -e "${GREEN}✅ Autenticación Gemini configurada correctamente${NC}"
                echo -e "${CYAN}💡 Ahora puedes usar: : \"tu pregunta aquí\"${NC}"
            else
                echo -e "${YELLOW}⚠️ Autenticación no verificada${NC}"
            fi
        else
            echo -e "${CYAN}ℹ️ Podrás configurar la autenticación más tarde con: gemini auth login${NC}"
        fi
    else
        echo -e "${RED}❌ Gemini CLI no encontrado${NC}"
    fi
}
post_installation_setup() {
    echo -e "${CYAN}=============================================${NC}"
    echo -e "${GREEN}🎉 ¡Instalación Completada con Éxito!${NC}"
    echo -e "${CYAN}=============================================${NC}"
    echo ""

    # User password setup
    echo -e "${YELLOW}🔐 Configuración de Seguridad del Usuario${NC}"
    echo -e "${CYAN}Para mayor seguridad, es recomendable establecer una contraseña de usuario.${NC}"
    read -p "¿Deseas establecer una contraseña para tu usuario? (y/N): " setup_passwd
    if [[ "$setup_passwd" =~ ^[Yy]$ ]]; then
        echo -e "${BLUE}[INFO] Configurando contraseña de usuario...${NC}"
        passwd
    fi
    echo ""

    # SSH user setup
    echo -e "${YELLOW}👤 Configuración de Usuario SSH${NC}"
    echo -e "${CYAN}Para configurar el acceso SSH remoto, necesitamos un usuario y contraseña.${NC}"
    echo -e "${BLUE}Nota: En Termux, el usuario SSH será tu usuario actual del sistema.${NC}"
    read -p "¿Deseas configurar un usuario SSH ahora? (y/N): " setup_ssh_user
    if [[ "$setup_ssh_user" =~ ^[Yy]$ ]]; then
        echo -e "${BLUE}[INFO] El usuario SSH será: $(whoami)${NC}"
        echo -e "${CYAN}Asegúrate de tener una contraseña configurada para este usuario.${NC}"
        if ! passwd -S $(whoami) >/dev/null 2>&1 || passwd -S $(whoami) | grep -q "NP"; then
            echo -e "${YELLOW}⚠️ No tienes contraseña configurada. Vamos a configurarla...${NC}"
            passwd
        else
            echo -e "${GREEN}✅ Contraseña ya configurada${NC}"
        fi
    fi
    echo ""

    # SSH keys setup (OPCIONAL - no interactivo)
    echo -e "${YELLOW}🔑 Configuración de Llaves SSH para GitHub (OPCIONAL)${NC}"
    echo -e "${CYAN}ℹ️ Para configurar SSH para GitHub, ejecuta: modules/05-ssh-setup.sh${NC}"
    if [[ ! -f "$HOME/.ssh/id_ed25519" ]]; then
        echo -e "${CYAN}No se encontraron llaves SSH. Generando nuevas llaves...${NC}"
        read -p "Introduce tu email para GitHub: " git_email
        if [[ -n "$git_email" ]]; then
            ssh-keygen -t ed25519 -C "$git_email" -f "$HOME/.ssh/id_ed25519" -N ""
            echo -e "${GREEN}✅ Llaves SSH generadas correctamente${NC}"
        fi
    fi

    if [[ -f "$HOME/.ssh/id_ed25519.pub" ]]; then
        echo -e "${CYAN}=============================================${NC}"
        echo -e "${YELLOW}📋 Tu Llave Pública SSH (cópiala en GitHub):${NC}"
        echo -e "${CYAN}=============================================${NC}"
        cat "$HOME/.ssh/id_ed25519.pub"
        echo -e "${CYAN}=============================================${NC}"
        echo -e "${BLUE}1. Ve a GitHub → Settings → SSH and GPG keys${NC}"
        echo -e "${BLUE}2. Click 'New SSH key'${NC}"
        echo -e "${BLUE}3. Copia y pega la llave de arriba${NC}"
        echo -e "${CYAN}=============================================${NC}"
        read -p "Presiona Enter cuando hayas agregado la llave a GitHub..."
    fi
    echo ""

    # SSH server persistent setup
    echo -e "${YELLOW}🌐 Servidor SSH Permanente${NC}"
    echo -e "${CYAN}¿Deseas habilitar el servidor SSH para que se inicie automáticamente?${NC}"
    echo -e "${BLUE}Esto te permitirá conectarte desde tu computadora usando SFTP/SSH.${NC}"
    read -p "¿Habilitar servidor SSH permanente? (y/N): " enable_sshd
    if [[ "$enable_sshd" =~ ^[Yy]$ ]]; then
        if command -v sv-enable >/dev/null 2>&1; then
            if sv-enable sshd >/dev/null 2>&1; then
                echo -e "${GREEN}✅ Servidor SSH habilitado permanentemente${NC}"
                local ssh_ip="$(ifconfig wlan0 2>/dev/null | grep 'inet ' | awk '{print $2}' | head -1)"
                echo -e "${CYAN}Conéctate usando: ssh -p 8022 $(whoami)@${ssh_ip}${NC}"

                # Preguntar si iniciar SSH ahora
                echo ""
                echo -e "${YELLOW}🚀 ¿Quieres iniciar el servidor SSH ahora?${NC}"
                read -p "¿Iniciar SSH inmediatamente? (y/N): " start_ssh_now
                if [[ "$start_ssh_now" =~ ^[Yy]$ ]]; then
                    if command -v sv >/dev/null 2>&1; then
                        if sv up sshd >/dev/null 2>&1; then
                            echo -e "${GREEN}✅ Servidor SSH iniciado${NC}"
                        else
                            echo -e "${YELLOW}⚠️ No se pudo iniciar SSH automáticamente (sv up).${NC}"
                        fi
                    else
                        echo -e "${YELLOW}⚠️ termux-services no provee el comando 'sv'; inicia sshd manualmente.${NC}"
                    fi
                fi
            else
                echo -e "${YELLOW}⚠️ No se pudo habilitar el arranque automático con sv-enable.${NC}"
            fi
        else
            echo -e "${YELLOW}⚠️ termux-services no disponible. Instala con: pkg install termux-services${NC}"
        fi
    fi
    echo ""

    # Install termux-ai-panel command
    echo -e "${YELLOW}🎛️ Instalando Panel de Control...${NC}"
    install_ai_panel_command

    echo -e "${GREEN}🎉 ¡Configuración completada!${NC}"
    echo -e "${CYAN}Usa el comando '${YELLOW}termux-ai-panel${CYAN}' para acceder al panel de control.${NC}"

    # Offer to launch the full web panel now
    echo ""
    echo -e "${YELLOW}🌐 ¿Quieres abrir ahora el Panel Web completo?${NC}"
    echo -e "${BLUE}Esto iniciará el backend (FastAPI) en 8000 y el frontend (Vite) en 3000.${NC}"
    read -p "Lanzar el Panel Web ahora? (y/N): " launch_web
    if [[ "$launch_web" =~ ^[Yy]$ ]]; then
        local panel_launcher="${SCRIPT_DIR}/start-panel.sh"
        if [[ -f "$panel_launcher" ]]; then
            echo -e "${BLUE}🔧 Preparando dependencias del panel web...${NC}"
            if bash "$panel_launcher" install; then
                echo -e "${GREEN}✅ Dependencias listas. Iniciando entorno de desarrollo...${NC}"
                echo -e "${CYAN}Frontend: http://localhost:3000${NC}"
                echo -e "${CYAN}Backend:  http://localhost:8000${NC}"
                echo -e "${YELLOW}💡 Mantén esta terminal abierta. Pulsa Ctrl+C para detener.${NC}"
                bash "$panel_launcher" dev
            else
                echo -e "${RED}❌ No se pudieron instalar dependencias del panel web.${NC}"
                echo -e "${YELLOW}💡 Puedes intentar más tarde con: ${CYAN}bash start-panel.sh install && bash start-panel.sh dev${NC}"
            fi
        else
            echo -e "${RED}❌ No se encontró el lanzador del panel web: ${panel_launcher}${NC}"
            echo -e "${YELLOW}💡 Asegúrate de haber clonado el repo completo y ejecutado la instalación completa.${NC}"
        fi
    else
        echo -e "${BLUE}Continuando en la terminal. Podrás iniciar el panel cuando quieras con:${NC} ${YELLOW}termux-ai-panel${NC}"
    fi
}

# Function to install the AI panel command
install_ai_panel_command() {
    local panel_script="$PREFIX/bin/termux-ai-panel"

    cat > "$panel_script" << 'EOF'
#!/bin/bash
# Termux AI Panel - Post-installation management tool

if [[ -f "$HOME/termux-dev-nvim-agents/scripts/termux-ai-panel.sh" ]]; then
    bash "$HOME/termux-dev-nvim-agents/scripts/termux-ai-panel.sh" "$@"
elif [[ -f "$HOME/termux-dev-nvim-agents/modules/termux-ai-panel.sh" ]]; then
    bash "$HOME/termux-dev-nvim-agents/modules/termux-ai-panel.sh" "$@"
else
    echo "❌ Panel script not found. Please reinstall the termux-ai setup."
    exit 1
fi
EOF

    chmod +x "$panel_script"
    echo -e "${GREEN}✅ Comando 'termux-ai-panel' instalado${NC}"
}

# Function for complete installation
full_installation() {
    echo -e "${BLUE}[AUTO] Starting COMPLETE SILENT installation...${NC}"

    termux_ai_state_init

    # Verificar modo completamente automático
    if [[ "${TERMUX_AI_AUTO:-}" == "1" && "${TERMUX_AI_SILENT:-}" == "1" ]]; then
        echo -e "${GREEN}🤖 Modo completamente automático activado${NC}"
        echo -e "${CYAN}⏰ Instalación sin intervención del usuario iniciada...${NC}"
    fi

    local modules=(
        "00-network-fixes"         # NUEVO: Arreglar problemas de red y timeouts
        "00-fix-conflicts"         # NUEVO: Arreglar conflictos de configuración
        "00-system-optimization"   # NUEVO: Permisos, servicios, optimizaciones
        "00-user-setup"           # Configuración inicial de usuario
        "00-base-packages"        # Paquetes base con configuración automática
        "01-zsh-setup"            # Zsh + Oh My Zsh
        "02-neovim-setup"         # Neovim con configuración completa
        "06-fonts-setup"          # FiraCode Nerd Font como predeterminado
        "03-ai-integration"       # Agentes IA con últimas versiones
        "07-local-ssh-server"     # Servidor SSH persistente
        "05-ssh-setup"            # Claves SSH para GitHub (al final)
    )
    # Configurar Gemini CLI automáticamente
    setup_gemini_cli_auto

    local previous_auto="${TERMUX_AI_AUTO:-}"
    export TERMUX_AI_AUTO=1
    export TERMUX_AI_SILENT=1
    local install_status=0

    for module in "${modules[@]}"; do
        echo -e "${PURPLE}🔧 Ejecutando módulo: ${module}${NC}"
        if ! run_module "$module"; then
            install_status=1
            echo -e "${RED}[ERROR] Error en módulo: ${module}${NC}"
            if [[ "${TERMUX_AI_SILENT:-}" != "1" ]]; then
                read -p "¿Continuar con el siguiente módulo? (y/N): " continue_install
                if [[ ! "$continue_install" =~ ^[Yy]$ ]]; then
                    install_status=1
                    break
                fi
            else
                echo -e "${YELLOW}[AUTO] Continuando automáticamente...${NC}"
                sleep 2
            fi
        else
            echo -e "${GREEN}✅ Módulo ${module} completado${NC}"
        fi
        echo -e "${CYAN}---------------------------------------------${NC}"
    done

    if [[ -n "$previous_auto" ]]; then
        export TERMUX_AI_AUTO="$previous_auto"
    else
        unset TERMUX_AI_AUTO
    fi

    if (( install_status != 0 )); then
        return "$install_status"
    fi

    echo -e "${GREEN}[DONE] Instalación completa finalizada!${NC}"
    # Crear marcador global de instalación completa
    mkdir -p "$HOME/.termux-ai-setup" 2>/dev/null || true
    {
        echo "completed_at=$(date '+%Y-%m-%dT%H:%M:%S%z')"
        echo "version=2.0"
        echo "script_commit=${SCRIPT_COMMIT:-local}"
    } > "$HOME/.termux-ai-setup/INSTALL_DONE" 2>/dev/null || true
    add_summary "Instalación automática completada"
    add_summary "Estado guardado en ~/.termux-ai-setup/INSTALL_DONE"
    add_summary "Módulos ejecutados: ${#modules[@]}"

    # Post-instalación automática
    post_installation_setup_auto

    echo -e "${CYAN}[INFO] Reiniciando terminal...${NC}"

    # Reload configuration (suave, sin exec forzado para no interrumpir pipeline remoto)
    source ~/.bashrc 2>/dev/null || true
    # No hacemos exec aquí para permitir que el caller continúe (especialmente install.sh)
}

# Main function
main() {
    local mode=""
    local force_modules=false
    local reset_state=false
    local show_help=false

    while (($#)); do
        case "$1" in
            auto)
                mode="auto"
                ;;
            -f|--force)
                force_modules=true
                ;;
            --reset-state)
                reset_state=true
                ;;
            --verbose)
                export TERMUX_AI_VERBOSE=1
                ;;
            -h|--help)
                show_help=true
                ;;
            *)
                echo -e "${RED}[ERROR] Opción desconocida: $1${NC}"
                show_help=true
                ;;
        esac
        shift
    done

    if $show_help; then
        cat <<'EOF'
Uso: ./setup.sh [auto] [opciones]

Opciones:
  auto             Ejecuta la instalación completa sin menú
  -f, --force      Reejecuta todos los módulos aunque ya estén completados
  --reset-state    Limpia el estado almacenado de módulos antes de iniciar
  -h, --help       Muestra esta ayuda y termina
EOF
        return 0
    fi

    if $reset_state; then
        echo -e "${YELLOW}[RESET] Limpiando estado previo de módulos...${NC}"
        termux_ai_reset_all_state
    fi

    if $force_modules; then
        export TERMUX_AI_FORCE_MODULES=1
    else
        export TERMUX_AI_FORCE_MODULES="${TERMUX_AI_FORCE_MODULES:-0}"
    fi

    show_banner
    check_prerequisites
    termux_ai_state_init

    # Create log file
    log "Starting Termux AI Setup"

    if [[ "$mode" == "auto" ]]; then
        echo -e "${BLUE}🤖 Running in automatic mode...${NC}"
        full_installation
        exit $?
    fi

    while true; do
        show_main_menu
        read -r choice

        case $choice in
            1)
                full_installation
                ;;
            2)
                run_module "00-base-packages"
                ;;
            3)
                run_module "01-zsh-setup"
                ;;
            4)
                run_module "02-neovim-setup"
                ;;
            5)
                run_module "03-ai-integration"
                ;;
            6)
                run_module "05-ssh-setup"
                ;;
            7)
                run_module "test-installation"
                ;;
            8)
                run_module "99-clean-reset"
                ;;
            9)
                if [[ -f "${SCRIPT_DIR}/scripts/termux-ai-panel.sh" ]]; then
                    echo -e "${BLUE}🎛️ Lanzando Panel de Control...${NC}"
                    bash "${SCRIPT_DIR}/scripts/termux-ai-panel.sh"
                else
                    echo -e "${RED}❌ Panel no encontrado${NC}"
                    echo -e "${YELLOW}💡 El panel se instala automáticamente tras la instalación completa${NC}"
                fi
                ;;
            99)
                echo -e "${GREEN}Thank you for using Termux AI Setup!${NC}"
                log "Setup terminated by user"
                exit 0
                ;;
            *)
                echo -e "${RED}[ERROR] Invalid option. Select a number from 0-12, R (Rastafari), or 99.${NC}"
                sleep 2
                ;;
        esac

        echo -e "\n${YELLOW}Press Enter to continue...${NC}"
        read -r
    done
}

trap 'on_error $? "$BASH_COMMAND"' ERR
trap 'on_interrupt' INT TERM
trap 'cleanup' EXIT

# Execute main function
main "$@"
