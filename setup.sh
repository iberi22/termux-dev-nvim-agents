#!/bin/bash

# ====================================
# TERMUX AI DEVELOPMENT SETUP
# Modular system to configure Termux with AI
# Repository: https://github.com/iberi22/termux-dev-nvim-agents
# Quick install: wget -qO- https://raw.githubusercontent.com/iberi22/termux-dev-nvim-agents/main/install.sh | bash
# ====================================

# Enforce UTF-8 to fix font rendering issues
export LC_ALL=C.UTF-8
export LANG=C.UTF-8

set -euo pipefail
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

# --- Source Helper Functions ---
# shellcheck disable=SC1091
if [[ -f "${SCRIPT_DIR}/scripts/helpers.sh" ]]; then
    source "${SCRIPT_DIR}/scripts/helpers.sh"
else
    echo "Error: El archivo de ayuda 'scripts/helpers.sh' no se encontró." >&2
    exit 1
fi

# Function for logging to file (legacy, for compatibility)
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
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
    log_error "Comando fallido: ${failed_command} (código de salida: ${exit_code})"
    log "Command failed: ${failed_command} (exit ${exit_code})"
}

on_interrupt() {
    SCRIPT_EXIT_CODE=130
    SCRIPT_STATUS="interrupted"
    log_warn "Instalación interrumpida por el usuario."
    log "Installation interrupted by user"
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
        echo ""
        echo -e "${RED}==============================================${NC}"
        echo -e "${RED}   INSTALACIÓN FALLIDA (Código $exit_code)${NC}"
        echo -e "${RED}==============================================${NC}"

        if [[ -n "$SCRIPT_FAILURE_CMD" ]]; then
            echo -e "${RED}Comando fallido: ${SCRIPT_FAILURE_CMD}${NC}"
        fi

        if [[ -f "$LOG_FILE" ]]; then
            echo -e "\n${YELLOW}--- Últimas 20 líneas del log ($LOG_FILE) ---${NC}"
            tail -n 20 "$LOG_FILE" 2>/dev/null || true
            echo -e "${YELLOW}---------------------------------------------${NC}"
            echo -e "${YELLOW}>> Revisa el archivo ${LOG_FILE} para ver el error completo.${NC}"
        fi

        echo -e "${RED}Aborted after ${elapsed}s.${NC}"
        log "[ERROR] Script aborted after ${elapsed}s (code ${exit_code})"
    else
        log "[INFO] Script completed successfully in ${elapsed}s"
        if ((${#SUMMARY_LINES[@]} > 0)); then
            echo -e "\n${CYAN}[INFO] Resumen rápido:${NC}"
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
    echo "           TERMUX AI SETUP v0.2.0"
    echo "   Automated System for AI Development in Termux"
    echo "=============================================="
    echo -e "${NC}
"
}


# Function to check prerequisites
check_prerequisites() {
    log_info "Verificando los prerrequisitos..."

    # Verify we're running in Termux
    if [[ -z "${PREFIX-}" || ! -d "$PREFIX" ]]; then
        log_error "Este script debe ejecutarse en Termux."
        exit 1
    fi
    log_info "Verificación de Termux superada."

    # Verify internet connection
    if ! ping -c 1 google.com &> /dev/null; then
        log_error "Se requiere conexión a internet."
        exit 1
    fi
    log_info "Verificación de conexión a internet superada."

    # Attempt to switch to the default install directory
    if [[ ! -d "$MODULES_DIR" && -d "$DEFAULT_INSTALL_DIR/modules" ]]; then
        log_warn "El directorio de módulos no se encuentra en la ruta actual."
        log_info "Cambiando a: $DEFAULT_INSTALL_DIR"
        SCRIPT_DIR="$DEFAULT_INSTALL_DIR"
        MODULES_DIR="${SCRIPT_DIR}/modules"
        cd "$SCRIPT_DIR"
    fi

    # Verify we have the correct directory structure
    if [[ ! -d "$MODULES_DIR" ]]; then
        log_error "Directorio de módulos no encontrado: $MODULES_DIR"
        log_warn "Por favor, asegúrate de ejecutar el script desde la ubicación correcta."
        exit 1
    fi

    log_success "Prerrequisitos verificados."
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

    log_info "Preparando para ejecutar el módulo: ${module_name}"
    log "Preparing to run module: ${module_name}"

    if [[ "${TERMUX_AI_FORCE_MODULES:-0}" != "1" ]]; then
        if termux_ai_module_completed "$module_name" "$module_path"; then
            log_success "Módulo '${module_name}' ya completado. Omitiendo."
            log "Module skipped (cached): ${module_name}"
            return 0
        fi
    else
        log_warn "Forzando la reejecución del módulo '${module_name}'."
        termux_ai_reset_module_state "$module_name"
    fi

    if [[ ! -f "$module_path" ]]; then
        log_error "Módulo no encontrado: ${module_path}"
        log "Module not found: ${module_path}"
        return 1
    fi

    if [[ ! -x "$module_path" ]]; then
        log_warn "Haciendo ejecutable el módulo: ${module_name}"
        chmod +x "$module_path"
    fi

    local exit_code=0
    if ! bash "$module_path"; then
        exit_code=$?
    fi

    if [[ $exit_code -eq 0 ]]; then
        log_success "Módulo '${module_name}' completado exitosamente."
        log "Module completed: ${module_name}"
        termux_ai_record_module_state "$module_name" "$module_path" "completed" 0
        return 0
    else
        log_error "Error en el módulo '${module_name}' (código de salida: ${exit_code})."
        log "Error in module: ${module_name} (exit code: ${exit_code})"
        termux_ai_record_module_state "$module_name" "$module_path" "failed" "$exit_code"
        SCRIPT_EXIT_CODE=$exit_code
        SCRIPT_FAILURE_CMD="module:${module_name}"
        return 1
    fi
}


# Detects the user's shell in Termux (falls back to bash or sh).
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
    local requested_ssh_user="${TERMUX_AI_SSH_USER:-termux-dev}"
    local ssh_pass="${TERMUX_AI_SSH_PASS:-termux2025}"
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
        if ! passwd -S "$(whoami)" >/dev/null 2>&1 || passwd -S "$(whoami)" | grep -q "NP"; then
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

# ============================================================
# v0.2.0 - INTERACTIVE COMPONENT SELECTION
# ============================================================

# AI CLIs the installer knows about, in menu order.
AI_COMPONENT_KEYS=("claude" "opencode" "codex" "wrangler" "agy")
AI_SELECTED=()

# Group toggles. The base system is forced ON: every other group
# depends on the packages it installs.
SELECT_GROUP_BASE=1
SELECT_GROUP_SHELL=1
SELECT_GROUP_AI=1
SELECT_GROUP_SSH=1

# Trims leading and trailing whitespace.
trim() {
    local value="$1"
    value="${value#"${value%%[![:space:]]*}"}"
    value="${value%"${value##*[![:space:]]}"}"
    printf '%s' "$value"
}

# Reads a group toggle variable by name ("1" = on).
group_state() {
    local var_name="$1"
    if [[ "${!var_name}" == "1" ]]; then
        printf 'on'
    else
        printf 'off'
    fi
}

# Flips a group toggle variable by name.
toggle_group() {
    local var_name="$1"
    if [[ "${!var_name}" == "1" ]]; then
        printf -v "$var_name" '%s' "0"
    else
        printf -v "$var_name" '%s' "1"
    fi
}

# Human readable description for an AI CLI key.
ai_component_label() {
    case "$1" in
        claude) printf '%s' "Anthropic Claude Code" ;;
        opencode) printf '%s' "Provider-agnostic agent (DeepSeek, GLM, free models)" ;;
        codex) printf '%s' "OpenAI Codex" ;;
        wrangler) printf '%s' "Cloudflare developer CLI (not an agent)" ;;
        agy) printf '%s' "Google Antigravity - manual install required" ;;
        *) printf '%s' "unknown component" ;;
    esac
}

# Adds an AI CLI key to AI_SELECTED, ignoring duplicates.
ai_add_selected() {
    local candidate="$1"
    local existing
    for existing in "${AI_SELECTED[@]}"; do
        if [[ "$existing" == "$candidate" ]]; then
            return 0
        fi
    done
    AI_SELECTED+=("$candidate")
    return 0
}

# Removes an AI CLI key from AI_SELECTED.
ai_remove_selected() {
    local needle="$1"
    local existing
    local -a remaining=()
    for existing in "${AI_SELECTED[@]}"; do
        if [[ "$existing" != "$needle" ]]; then
            remaining+=("$existing")
        fi
    done
    if ((${#remaining[@]} > 0)); then
        AI_SELECTED=("${remaining[@]}")
    else
        AI_SELECTED=()
    fi
}

# Returns 0 when the given AI CLI key is currently selected.
ai_is_selected() {
    local needle="$1"
    local existing
    for existing in "${AI_SELECTED[@]}"; do
        if [[ "$existing" == "$needle" ]]; then
            return 0
        fi
    done
    return 1
}

# Comma separated view of AI_SELECTED (for display).
selected_ai_summary() {
    local IFS=' '
    if ((${#AI_SELECTED[@]} == 0)); then
        printf 'no CLI selected'
        return 0
    fi
    printf '%s' "${AI_SELECTED[*]// /, }"
}

# Comma separated value exported as TERMUX_AI_COMPONENTS.
selected_ai_export_value() {
    local joined=""
    local key
    for key in "${AI_SELECTED[@]}"; do
        if [[ -z "$joined" ]]; then
            joined="$key"
        else
            joined="${joined},${key}"
        fi
    done
    printf '%s' "$joined"
}

# Populates AI_SELECTED from a comma/space separated list. 'all' or an
# empty value selects every CLI.
parse_ai_components() {
    local raw="${1:-all}"
    local -a requested=()
    local item
    local trimmed

    AI_SELECTED=()
    trimmed="$(trim "$raw")"

    if [[ -z "$trimmed" || "$trimmed" == "all" ]]; then
        AI_SELECTED=("${AI_COMPONENT_KEYS[@]}")
        return 0
    fi

    raw="${raw//,/ }"
    # IFS is scoped to this read: setup.sh runs with IFS=$'\n\t'.
    IFS=' ' read -r -a requested <<<"$raw" || true

    for item in "${requested[@]}"; do
        item="$(trim "$item")"
        case "$item" in
            '')
                continue
                ;;
            all)
                AI_SELECTED=("${AI_COMPONENT_KEYS[@]}")
                ;;
            claude | opencode | codex | wrangler | agy)
                ai_add_selected "$item"
                ;;
            *)
                log_warn "Unknown AI component: '${item}' (ignored)."
                ;;
        esac
    done
    return 0
}

# Prints one toggle line of the component menu.
print_group_line() {
    local number="$1"
    local label="$2"
    local state="$3"
    local detail="$4"
    local mark="${RED}[ ]${NC}"
    if [[ "$state" == "on" ]]; then
        mark="${GREEN}[x]${NC}"
    fi
    echo -e " ${mark} ${number}. ${WHITE}${label}${NC}  ${CYAN}${detail}${NC}"
}

# Renders the top level component menu.
show_component_menu() {
    echo ""
    echo -e "${CYAN}┌──────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│              SELECT WHAT TO INSTALL   (v0.2.0)               │${NC}"
    echo -e "${CYAN}└──────────────────────────────────────────────────────────────┘${NC}"
    print_group_line "1" "Base system" "on" "00-user-input, 00-network-fixes, 00-fix-conflicts, 00-system-optimization, 00-base-packages"
    print_group_line "2" "Shell + editor" "$(group_state SELECT_GROUP_SHELL)" "01-zsh-setup, 02-neovim-setup, 06-fonts-setup"
    print_group_line "3" "AI CLIs" "$(group_state SELECT_GROUP_AI)" "03-ai-integration -> $(selected_ai_summary)"
    print_group_line "4" "SSH" "$(group_state SELECT_GROUP_SSH)" "07-local-ssh-server, 05-ssh-setup"
    echo ""
    echo -e "${YELLOW}Base system is always installed: every other group depends on it.${NC}"
    echo -e "${BLUE}Commands: ${WHITE}1-4${BLUE} toggle group | ${WHITE}a${BLUE} all | ${WHITE}n${BLUE} none | ${WHITE}d${BLUE} done + install | ${WHITE}q${BLUE} quit${NC}"
    echo -ne "${YELLOW}Selection: ${NC}"
}

# Renders the per-CLI sub-menu for the AI group.
show_ai_submenu() {
    local index=1
    local key
    local state

    echo ""
    echo -e "${CYAN}┌──────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│                    AI CLIs TO INSTALL                        │${NC}"
    echo -e "${CYAN}└──────────────────────────────────────────────────────────────┘${NC}"
    for key in "${AI_COMPONENT_KEYS[@]}"; do
        state="off"
        if ai_is_selected "$key"; then
            state="on"
        fi
        print_group_line "$index" "$key" "$state" "$(ai_component_label "$key")"
        index=$((index + 1))
    done
    echo ""
    echo -e "${YELLOW}agy is not published on npm: it must be downloaded from https://antigravity.google${NC}"
    echo -e "${BLUE}Commands: ${WHITE}1-5${BLUE} toggle CLI | ${WHITE}a${BLUE} all | ${WHITE}n${BLUE} none | ${WHITE}d${BLUE} back${NC}"
    echo -ne "${YELLOW}Selection: ${NC}"
}

# Aborts the selection phase without installing anything.
abort_selection() {
    echo ""
    log_warn "Selection cancelled: nothing was installed."
    exit 0
}

# Sub-menu loop for the AI CLIs.
select_ai_components_menu() {
    local choice
    local key
    local index

    while true; do
        show_ai_submenu
        read -r choice || choice="d"
        choice="$(trim "$choice")"
        case "$choice" in
            1 | 2 | 3 | 4 | 5)
                index=1
                for key in "${AI_COMPONENT_KEYS[@]}"; do
                    if ((index == choice)); then
                        if ai_is_selected "$key"; then
                            ai_remove_selected "$key"
                        else
                            ai_add_selected "$key"
                        fi
                        break
                    fi
                    index=$((index + 1))
                done
                ;;
            a | A)
                AI_SELECTED=("${AI_COMPONENT_KEYS[@]}")
                ;;
            n | N)
                AI_SELECTED=()
                ;;
            d | D | "")
                break
                ;;
            q | Q)
                abort_selection
                ;;
            *)
                echo -e "${RED}Unknown command: '${choice}'.${NC}"
                ;;
        esac
    done
}

# Returns 0 when the interactive menu must be shown.
selection_menu_enabled() {
    if [[ "${TERMUX_AI_NO_MENU:-0}" == "1" ]]; then
        return 1
    fi
    # An explicit CLI list is already a complete non-interactive answer.
    if [[ -n "${TERMUX_AI_COMPONENTS:-}" ]]; then
        return 1
    fi
    if [[ "${TERMUX_AI_AUTO:-0}" == "1" ]]; then
        return 1
    fi
    # Piped installs (curl ... | bash) have no TTY: install everything.
    if [[ ! -t 0 ]]; then
        return 1
    fi
    return 0
}

# Runs the selection phase and leaves the result in SELECT_GROUP_* and
# AI_SELECTED.
select_installation_components() {
    # Defaults preserve the pre-0.2.0 behaviour: everything installed.
    SELECT_GROUP_BASE=1
    SELECT_GROUP_SHELL=1
    SELECT_GROUP_AI=1
    SELECT_GROUP_SSH=1
    AI_SELECTED=("${AI_COMPONENT_KEYS[@]}")

    # --components=... wins over the menu and over the defaults.
    if [[ -n "${TERMUX_AI_COMPONENTS:-}" ]]; then
        parse_ai_components "$TERMUX_AI_COMPONENTS"
        log_info "AI CLIs requested via --components: $(selected_ai_summary)"
        return 0
    fi

    if ! selection_menu_enabled; then
        log_info "Component menu disabled (no TTY or --no-menu): installing everything."
        return 0
    fi

    local choice

    while true; do
        show_component_menu
        read -r choice || choice="d"
        choice="$(trim "$choice")"
        case "$choice" in
            1)
                echo -e "${YELLOW}Base system is mandatory and always selected.${NC}"
                ;;
            2)
                toggle_group SELECT_GROUP_SHELL
                ;;
            3)
                toggle_group SELECT_GROUP_AI
                if [[ "$SELECT_GROUP_AI" == "1" ]]; then
                    select_ai_components_menu
                fi
                ;;
            4)
                toggle_group SELECT_GROUP_SSH
                ;;
            a | A)
                SELECT_GROUP_SHELL=1
                SELECT_GROUP_AI=1
                SELECT_GROUP_SSH=1
                AI_SELECTED=("${AI_COMPONENT_KEYS[@]}")
                ;;
            n | N)
                SELECT_GROUP_SHELL=0
                SELECT_GROUP_AI=0
                SELECT_GROUP_SSH=0
                AI_SELECTED=()
                ;;
            d | D | "")
                break
                ;;
            q | Q)
                abort_selection
                ;;
            *)
                echo -e "${RED}Unknown command: '${choice}'.${NC}"
                ;;
        esac
    done

    log_info "Selection -> shell=$(group_state SELECT_GROUP_SHELL) ai=$(group_state SELECT_GROUP_AI) ssh=$(group_state SELECT_GROUP_SSH) clis=$(selected_ai_summary)"
}

# Function for complete installation
full_installation() {
    log_info "Iniciando la instalación completa y automática..."
    termux_ai_state_init

    if [[ "${TERMUX_AI_AUTO:-}" == "1" ]]; then
        log_info "Modo automático detectado. La instalación procederá sin menús."
    fi

    # --- Component Selection (v0.2.0) ---
    # Decides which groups run. Exits the script when the user quits.
    select_installation_components

    # Propagate the chosen CLI keys to 03-ai-integration. An empty list means
    # the AI group has to be skipped (nothing to install there).
    if ((${#AI_SELECTED[@]} > 0)); then
        TERMUX_AI_COMPONENTS="$(selected_ai_export_value)"
        export TERMUX_AI_COMPONENTS
    fi

    # --- Module Execution Order (built from the selection) ---
    local modules=(
        "00-user-input"            # NUEVO: Recolecta toda la información del usuario al principio.
        "00-network-fixes"         # Arregla problemas de red y timeouts.
        "00-fix-conflicts"         # Arregla conflictos de configuración.
        "00-system-optimization"   # Permisos, servicios, optimizaciones.
        "00-base-packages"         # Paquetes base con configuración automática.
    )

    if ((SELECT_GROUP_SHELL == 1)); then
        modules+=("01-zsh-setup")     # Zsh + Oh My Zsh.
        modules+=("02-neovim-setup")  # Neovim con configuración completa.
        modules+=("06-fonts-setup")   # FiraCode Nerd Font como predeterminado.
    fi

    if ((SELECT_GROUP_AI == 1)); then
        if ((${#AI_SELECTED[@]} > 0)); then
            modules+=("03-ai-integration") # CLIs de IA seleccionados.
        else
            log_warn "AI group enabled but no CLI selected: skipping 03-ai-integration."
        fi
    fi

    if ((SELECT_GROUP_SSH == 1)); then
        modules+=("07-local-ssh-server") # Servidor SSH persistente.
        modules+=("05-ssh-setup")        # Claves SSH para GitHub.
    fi

    if ((${#modules[@]} == 5)); then
        log_info "Only the base system was selected: running base modules only."
    fi

    local install_status=0
    for module in "${modules[@]}"; do
        log_info "---------------------------------------------"
        log_info "Ejecutando módulo: ${module}"
        log_info "---------------------------------------------"
        if ! run_module "$module"; then
            install_status=1
            log_error "El módulo '${module}' falló. La instalación no puede continuar."
            return 1 # Exit on first failure to prevent cascading errors
        fi
    done

    if (( install_status != 0 )); then
        log_error "La instalación falló durante la ejecución de los módulos."
        return "$install_status"
    fi

    log_success "Instalación de módulos completada."

    # --- Final Steps ---
    log_info "Creando marcador de instalación completada..."
    mkdir -p "$HOME/.termux-ai-setup" 2>/dev/null || true
    {
        echo "completed_at=$(date '+%Y-%m-%dT%H:%M:%S%z')"
        echo "version=3.0" # Version Bump
        echo "script_commit=${SCRIPT_COMMIT:-local}"
    } > "$HOME/.termux-ai-setup/INSTALL_DONE" 2>/dev/null || true

    add_summary "Instalación automática completada exitosamente."
    add_summary "Estado guardado en ~/.termux-ai-setup/INSTALL_DONE"
    add_summary "Total de módulos ejecutados: ${#modules[@]}"

    # Reload shell configuration to apply changes immediately
    log_info "Recargando la configuración de la shell para aplicar los cambios..."
    # shellcheck disable=SC1090
    source "$HOME/.zshrc" 2>/dev/null || source "$HOME/.bashrc" 2>/dev/null || log_warn "No se pudo recargar .zshrc o .bashrc."

    log_success "Instalación completa finalizada."

    # Ejecutar validación orquestada al final para detectar componentes faltantes
    if command -v bash >/dev/null 2>&1 && [[ -f "${SCRIPT_DIR}/scripts/validate-agents.sh" ]]; then
        log_info "Ejecutando validación de componentes (full)..."
        set +e
        VALID_JSON=$(bash "${SCRIPT_DIR}/scripts/validate-agents.sh" --full --json 2>&1 || true)
        VALID_EXIT=$?
        set -e

        # Registrar y añadir resumen legible
        echo "$VALID_JSON" >> "${LOG_FILE}" 2>/dev/null || true

        # Extraer número de fallos
        FAILS=$(printf '%s' "$VALID_JSON" | grep -o '"failures":[0-9]*' | head -n1 | sed 's/"failures"://') || true
        FAILS=${FAILS:-0}
        if [[ "$FAILS" -gt 0 ]]; then
            add_summary "Validación final: ${FAILS} componentes faltantes. Revisa ${LOG_FILE} para detalles."
            log_warn "Validación final detectó ${FAILS} fallos."
        else
            add_summary "Validación final: todos los componentes presentes."
            log_success "Validación final OK."
        fi
    fi
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
            --no-menu)
                export TERMUX_AI_NO_MENU=1
                ;;
            --components=*)
                export TERMUX_AI_COMPONENTS="${1#*=}"
                export TERMUX_AI_NO_MENU=1
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
  auto                     Ejecuta la instalación completa sin menú principal
  -f, --force              Reejecuta todos los módulos aunque ya estén completados
  --reset-state            Limpia el estado almacenado de módulos antes de iniciar
  --no-menu                Omite el menú interactivo de componentes (instala todo)
  --components=<lista>     CLIs de IA a instalar, separados por comas
                           (claude,opencode,codex,wrangler,agy | all)
  -h, --help               Muestra esta ayuda y termina

Ejemplos:
  ./setup.sh                                  # menú interactivo de componentes
  ./setup.sh --components=claude,opencode     # automatización, sin menú
  ./setup.sh auto --no-menu                   # instalación completa desatendida
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
        export TERMUX_AI_NO_MENU=1
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
