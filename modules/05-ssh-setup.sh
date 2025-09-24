#!/bin/bash

# ====================================
# MÓDULO: Configuración SSH para GitHub
# Genera claves SSH, configura ssh-agent y guía la configuración de GitHub
# MODO NO-INTERACTIVO cuando TERMUX_AI_AUTO está definido
# ====================================

set -euo pipefail

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${BLUE}🔐 Configurando SSH para GitHub...${NC}"

# Variables
SSH_DIR="$HOME/.ssh"
KEY_NAME="termux_github_ed25519"
KEY_PATH="$SSH_DIR/$KEY_NAME"
PUB_KEY_PATH="$KEY_PATH.pub"

# Crear directorio SSH si no existe
if [[ ! -d "$SSH_DIR" ]]; then
    echo -e "${YELLOW}📁 Creando directorio SSH...${NC}"
    mkdir -p "$SSH_DIR"
    chmod 700 "$SSH_DIR"
fi

# Función para cargar configuración de usuario existente
load_user_config() {
    local user_config_file="$HOME/.termux_user_config"
    if [[ -f "$user_config_file" ]]; then
        source "$user_config_file"
        if [[ -n "${GIT_NAME:-}" && -n "${GIT_EMAIL:-}" ]]; then
            USER_NAME="$GIT_NAME"
            USER_EMAIL="$GIT_EMAIL"
            echo -e "${GREEN}✅ Usando configuración de usuario existente:${NC}"
            echo -e "${WHITE}   Nombre: $USER_NAME${NC}"
            echo -e "${WHITE}   Email: $USER_EMAIL${NC}"
            return 0
        fi
    fi
    return 1
}

# Función para obtener información del usuario
get_user_info() {
    echo -e "${CYAN}📝 Configuración de identidad para GitHub${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    # Intentar cargar configuración de usuario del setup inicial
    if load_user_config; then
        echo -e "${CYAN}🔄 Configuración cargada del setup inicial${NC}"
        return 0
    fi

    # Intentar obtener configuración existente de Git
    local existing_name=$(git config --global user.name 2>/dev/null || echo "")
    local existing_email=$(git config --global user.email 2>/dev/null || echo "")

    if [[ -n "$existing_name" && -n "$existing_email" ]]; then
        echo -e "${GREEN}✅ Configuración Git existente encontrada:${NC}"
        echo -e "${WHITE}   Nombre: $existing_name${NC}"
        echo -e "${WHITE}   Email: $existing_email${NC}"
        echo -e ""

        # En modo automático, usar configuración existente sin preguntar
        if [[ -n "${TERMUX_AI_AUTO:-}" ]]; then
            USER_NAME="$existing_name"
            USER_EMAIL="$existing_email"
            echo -e "${GREEN}✅ Usando configuración Git existente automáticamente${NC}"
        else
            read -p "¿Usar esta configuración para SSH? (Y/n): " use_existing
            if [[ "$use_existing" =~ ^[Nn]$ ]]; then
                get_new_user_info
            else
                USER_NAME="$existing_name"
                USER_EMAIL="$existing_email"
            fi
        fi
    else
        get_new_user_info
    fi
}

get_new_user_info() {
    # En modo automático, usar valores por defecto que serán configurados al final
    if [[ -n "${TERMUX_AI_AUTO:-}" ]]; then
        USER_NAME="${TERMUX_AI_GIT_NAME:-Termux Developer}"
        USER_EMAIL="${TERMUX_AI_GIT_EMAIL:-developer@termux.local}"

        if [[ "${TERMUX_AI_SILENT:-}" == "1" ]]; then
            echo -e "${CYAN}🤖 Modo automático: configuración de usuario será solicitada al FINAL del proceso${NC}"
        else
            echo -e "${YELLOW}⚠️ Modo automático: usando valores temporales${NC}"
            echo -e "${WHITE}   Nombre: $USER_NAME${NC}"
            echo -e "${WHITE}   Email: $USER_EMAIL${NC}"
            echo -e "${CYAN}💡 La configuración final será solicitada al completar la instalación${NC}"
        fi
        return 0
    fi

    # Modo interactivo original (solo si no está en auto)
    echo -e "${CYAN}📝 Ingresa tu información de GitHub:${NC}"
    read -p "Ingresa tu nombre completo: " USER_NAME
    while [[ -z "$USER_NAME" ]]; do
        echo -e "${RED}❌ El nombre es obligatorio${NC}"
        read -p "Ingresa tu nombre completo: " USER_NAME
    done

    read -p "Ingresa tu email de GitHub: " USER_EMAIL
    while [[ -z "$USER_EMAIL" || ! "$USER_EMAIL" =~ ^[^@]+@[^@]+\.[^@]+$ ]]; do
        echo -e "${RED}❌ Email inválido${NC}"
        read -p "Ingresa tu email de GitHub: " USER_EMAIL
    done
}
    fi

    while [[ -z "${USER_NAME:-}" ]]; do
        read -p "Ingresa tu nombre completo: " USER_NAME
    done

    while [[ -z "${USER_EMAIL:-}" ]]; do
        read -p "Ingresa tu email de GitHub: " USER_EMAIL
        if [[ ! "$USER_EMAIL" =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$ ]]; then
            echo -e "${RED}❌ Email inválido. Intenta de nuevo.${NC}"
            USER_EMAIL=""
        fi
    done

    # Configurar Git con la información proporcionada
    echo -e "${BLUE}⚙️ Configurando Git globalmente...${NC}"
    git config --global user.name "$USER_NAME"
    git config --global user.email "$USER_EMAIL"
}

# Verificar si ya existe una clave SSH
check_existing_key() {
    if [[ -f "$KEY_PATH" ]]; then
        echo -e "${YELLOW}⚠️ Ya existe una clave SSH: $KEY_PATH${NC}"
        echo -e "${CYAN}Contenido de la clave pública:${NC}"
        echo -e "${WHITE}$(cat "$PUB_KEY_PATH" 2>/dev/null || echo "Archivo de clave pública no encontrado")${NC}"
        echo -e ""

        # En modo automático, mantener clave existente
        if [[ -n "${TERMUX_AI_AUTO:-}" ]]; then
            echo -e "${GREEN}✅ Manteniendo clave SSH existente (modo automático)${NC}"
            return 0
        else
            read -p "¿Deseas generar una nueva clave? (y/N): " generate_new
            if [[ "$generate_new" =~ ^[Yy]$ ]]; then
                echo -e "${YELLOW}🗑️ Eliminando clave existente...${NC}"
                rm -f "$KEY_PATH" "$PUB_KEY_PATH"
                return 1
            else
                return 0
            fi
        fi
    fi
    return 1
}

# Generar clave SSH Ed25519
generate_ssh_key() {
    echo -e "${BLUE}🔑 Generando nueva clave SSH Ed25519...${NC}"

    # Generar clave sin passphrase para facilidad de uso en Termux
    if ssh-keygen -t ed25519 -C "$USER_EMAIL" -f "$KEY_PATH" -N ""; then
        echo -e "${GREEN}✅ Clave SSH generada exitosamente${NC}"
        chmod 600 "$KEY_PATH"
        chmod 644 "$PUB_KEY_PATH"
    else
        echo -e "${RED}❌ Error generando clave SSH${NC}"
        exit 1
    fi
}

# Configurar SSH agent
setup_ssh_agent() {
    echo -e "${BLUE}🤖 Configurando SSH Agent...${NC}"

    # Agregar configuración al .zshrc para iniciar ssh-agent automáticamente
    local ssh_agent_config='
# ====================================
# SSH AGENT CONFIGURATION
# ====================================

# Función para iniciar ssh-agent
start_ssh_agent() {
    if [[ -z "${SSH_AUTH_SOCK:-}" ]] || ! ssh-add -l >/dev/null 2>&1; then
        eval "$(ssh-agent -s)" >/dev/null 2>&1
        ssh-add ~/.ssh/termux_github_ed25519 >/dev/null 2>&1
    fi
}

# Iniciar ssh-agent automáticamente
start_ssh_agent
'

    # Verificar si la configuración ya existe
    if ! grep -q "start_ssh_agent" "$HOME/.zshrc" 2>/dev/null; then
        echo "$ssh_agent_config" >> "$HOME/.zshrc"
        echo -e "${GREEN}✅ Configuración de SSH Agent agregada a .zshrc${NC}"
    else
        echo -e "${GREEN}✅ SSH Agent ya está configurado${NC}"
    fi

    # Iniciar ssh-agent en la sesión actual
    eval "$(ssh-agent -s)" >/dev/null 2>&1
    ssh-add "$KEY_PATH" >/dev/null 2>&1

    echo -e "${GREEN}✅ SSH Agent iniciado y clave agregada${NC}"
}

# Configurar SSH config
setup_ssh_config() {
    echo -e "${BLUE}⚙️ Configurando SSH config...${NC}"

    local ssh_config="$SSH_DIR/config"
    local github_config="
# GitHub configuration
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/termux_github_ed25519
    IdentitiesOnly yes
    PreferredAuthentications publickey

# GitHub CLI configuration
Host gist.github.com
    HostName gist.github.com
    User git
    IdentityFile ~/.ssh/termux_github_ed25519
    IdentitiesOnly yes
    PreferredAuthentications publickey
"

    # Crear o actualizar archivo config
    if [[ ! -f "$ssh_config" ]] || ! grep -q "Host github.com" "$ssh_config"; then
        echo "$github_config" >> "$ssh_config"
        chmod 600 "$ssh_config"
        echo -e "${GREEN}✅ Configuración SSH para GitHub agregada${NC}"
    else
        echo -e "${GREEN}✅ Configuración SSH para GitHub ya existe${NC}"
    fi
}

# Mostrar clave pública y copiar al portapapeles
show_and_copy_key() {
    echo -e "\n${CYAN}🔑 TU CLAVE PÚBLICA SSH${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    local public_key=$(cat "$PUB_KEY_PATH")
    echo -e "${WHITE}$public_key${NC}"

    # Intentar copiar al portapapeles usando termux-clipboard-set
    if command -v termux-clipboard-set >/dev/null 2>&1; then
        echo "$public_key" | termux-clipboard-set
        echo -e "\n${GREEN}✅ Clave pública copiada al portapapeles${NC}"
    else
        echo -e "\n${YELLOW}⚠️ termux-clipboard-set no disponible. Copia manualmente la clave de arriba.${NC}"
    fi
}

# Guía para agregar clave a GitHub
github_setup_guide() {
    echo -e "\n${PURPLE}📖 GUÍA PARA AGREGAR LA CLAVE A GITHUB${NC}"
    echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    echo -e "${CYAN}1. ${WHITE}Abre GitHub en tu navegador:${NC}"
    echo -e "   ${BLUE}https://github.com/settings/keys${NC}"

    echo -e "\n${CYAN}2. ${WHITE}Haz clic en 'New SSH key'${NC}"

    echo -e "\n${CYAN}3. ${WHITE}Completa los campos:${NC}"
    echo -e "   ${YELLOW}• Title:${NC} Termux $(date +'%Y-%m-%d')"
    echo -e "   ${YELLOW}• Key type:${NC} Authentication Key"
    echo -e "   ${YELLOW}• Key:${NC} $(cat "$PUB_KEY_PATH" | cut -d' ' -f1-2)..."

    echo -e "\n${CYAN}4. ${WHITE}Haz clic en 'Add SSH key'${NC}"

    echo -e "\n${CYAN}5. ${WHITE}Confirma tu contraseña de GitHub si es solicitada${NC}"

    echo -e "\n${GREEN}💡 CONSEJO:${NC} La clave ya está en tu portapapeles (si termux-clipboard-set está disponible)"

    # Ofrecer abrir GitHub automáticamente
    if command -v termux-open >/dev/null 2>&1; then
        echo -e "\n${YELLOW}¿Abrir GitHub SSH settings ahora? (Y/n):${NC} "
        read -r open_github
        if [[ ! "$open_github" =~ ^[Nn]$ ]]; then
            termux-open "https://github.com/settings/keys"
        fi
    fi
}

# Función para probar la conexión SSH
test_ssh_connection() {
    echo -e "\n${BLUE}🧪 Probando conexión SSH con GitHub...${NC}"

    echo -e "${YELLOW}Presiona Enter cuando hayas agregado la clave a GitHub:${NC}"
    read -r

    echo -e "${BLUE}Ejecutando: ssh -T git@github.com${NC}"

    # Probar conexión SSH
    if ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
        echo -e "${GREEN}✅ ¡Conexión SSH exitosa con GitHub!${NC}"
        return 0
    else
        echo -e "${YELLOW}⚠️ Conexión no exitosa. Verifica que:${NC}"
        echo -e "   ${CYAN}• La clave esté agregada correctamente en GitHub${NC}"
        echo -e "   ${CYAN}• La clave sea de tipo 'Authentication Key'${NC}"
        echo -e "   ${CYAN}• No haya espacios extra al copiar la clave${NC}"

        echo -e "\n${YELLOW}¿Intentar de nuevo? (Y/n):${NC} "
        read -r retry
        if [[ ! "$retry" =~ ^[Nn]$ ]]; then
            test_ssh_connection
        fi
        return 1
    fi
}

# Configurar Git para usar SSH
configure_git_ssh() {
    echo -e "\n${BLUE}⚙️ Configurando Git para usar SSH...${NC}"

    # Configurar Git para usar SSH en lugar de HTTPS para GitHub
    git config --global url."git@github.com:".insteadOf "https://github.com/"

    echo -e "${GREEN}✅ Git configurado para usar SSH con GitHub${NC}"
}

# Crear aliases útiles
create_ssh_aliases() {
    echo -e "\n${BLUE}🔗 Creando aliases útiles...${NC}"

    local aliases='
# ====================================
# SSH AND GIT ALIASES
# ====================================

# SSH shortcuts
alias ssh-test="ssh -T git@github.com"
alias ssh-add-github="ssh-add ~/.ssh/termux_github_ed25519"
alias ssh-list="ssh-add -l"

# Git shortcuts con SSH
alias git-clone-ssh="git clone --config core.sshCommand=\"ssh -i ~/.ssh/termux_github_ed25519\""
alias git-remote-ssh="git remote set-url origin"

# Mostrar clave pública
alias show-ssh-key="cat ~/.ssh/termux_github_ed25519.pub"
alias copy-ssh-key="cat ~/.ssh/termux_github_ed25519.pub | termux-clipboard-set"
'

    # Agregar aliases al .zshrc si no existen
    if ! grep -q "SSH AND GIT ALIASES" "$HOME/.zshrc" 2>/dev/null; then
        echo "$aliases" >> "$HOME/.zshrc"
        echo -e "${GREEN}✅ Aliases SSH agregados a .zshrc${NC}"
    else
        echo -e "${GREEN}✅ Aliases SSH ya existen${NC}"
    fi
}

# Mostrar resumen final
show_summary() {
    echo -e "\n${GREEN}📊 RESUMEN DE CONFIGURACIÓN SSH${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    echo -e "${GREEN}✅ Clave SSH Ed25519 generada: $KEY_NAME${NC}"
    echo -e "${GREEN}✅ SSH Agent configurado automáticamente${NC}"
    echo -e "${GREEN}✅ SSH config para GitHub creado${NC}"
    echo -e "${GREEN}✅ Git configurado para usar SSH${NC}"
    echo -e "${GREEN}✅ Aliases útiles agregados${NC}"

    echo -e "\n${CYAN}📁 ARCHIVOS CREADOS:${NC}"
    echo -e "${WHITE}   • $KEY_PATH (clave privada)${NC}"
    echo -e "${WHITE}   • $PUB_KEY_PATH (clave pública)${NC}"
    echo -e "${WHITE}   • $SSH_DIR/config (configuración SSH)${NC}"

    echo -e "\n${CYAN}🔧 COMANDOS ÚTILES:${NC}"
    echo -e "${WHITE}   • ssh-test          ${CYAN}→ Probar conexión con GitHub${NC}"
    echo -e "${WHITE}   • show-ssh-key      ${CYAN}→ Mostrar clave pública${NC}"
    echo -e "${WHITE}   • copy-ssh-key      ${CYAN}→ Copiar clave al portapapeles${NC}"
    echo -e "${WHITE}   • ssh-add-github    ${CYAN}→ Agregar clave al SSH agent${NC}"

    echo -e "\n${PURPLE}🎉 ¡SSH configurado para GitHub!${NC}"
    echo -e "${CYAN}💡 Reinicia el terminal para que los aliases tomen efecto${NC}"
}

# Función principal
main() {
    echo -e "${PURPLE}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║                   🔐 SSH SETUP FOR GITHUB 🔐                ║${NC}"
    echo -e "${PURPLE}╚══════════════════════════════════════════════════════════════╝${NC}"

    # Obtener información del usuario
    get_user_info

    # Verificar si existe clave SSH
    if ! check_existing_key; then
        generate_ssh_key
    fi

    # Configurar SSH
    setup_ssh_agent
    setup_ssh_config

    # Mostrar clave y guía de configuración
    show_and_copy_key
    github_setup_guide

    # Probar conexión
    if test_ssh_connection; then
        configure_git_ssh
        create_ssh_aliases
        show_summary
    else
        echo -e "\n${YELLOW}⚠️ Configuración completada, pero la conexión SSH falló.${NC}"
        echo -e "${CYAN}Puedes probar más tarde con: ssh-test${NC}"
    fi
}

# Ejecutar función principal
main "$@"