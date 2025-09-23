#!/bin/bash

# ====================================
# TERMUX AI SETUP - Sistema Simplificado
# Instalación automática con Gemini CLI
# Repository: https://github.com/iberi22/termux-dev-nvim-agents
# Quick install: curl -L https://raw.githubusercontent.com/iberi22/termux-dev-nvim-agents/main/quick-setup.sh | bash
# ====================================

set -euo pipefail

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

# Configuración
INSTALL_DIR="$HOME/termux-ai-setup"
LOG_FILE="$HOME/termux-setup.log"
SCRIPT_VERSION="2025-09-22.4"

# Verbose flag (default: false)
VERBOSE=false

# Parse flags for verbose
for arg in "$@"; do
    case "$arg" in
        -v|--verbose)
            VERBOSE=true
            ;;
    esac
done

# Asegurar TMPDIR usable en Termux
if [[ ! -w "/tmp" ]]; then
    export TMPDIR="$HOME/.cache/tmp"
    export TEMP="$TMPDIR"
    export TMP="$TMPDIR"
    mkdir -p "$TMPDIR"
fi

# Banner principal
show_banner() {
    clear
    echo -e "${PURPLE}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║                                                                              ║${NC}"
    echo -e "${PURPLE}║              🚀 TERMUX AI SETUP  |  v${SCRIPT_VERSION} 🚀                  ║${NC}"
    echo -e "${PURPLE}║                                                                              ║${NC}"
    echo -e "${PURPLE}║                    Sistema Automático de Desarrollo                         ║${NC}"
    echo -e "${PURPLE}║                                                                              ║${NC}"
    echo -e "${PURPLE}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# Función de logging
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Función para verificar y actualizar paquetes
update_packages() {
    mkdir -p "$HOME/.cache"
    : > "$LOG_FILE" || true
    echo -e "${CYAN}📦 Actualizando paquetes de Termux...${NC}"

    if [[ "$VERBOSE" == true ]]; then
        if ! pkg update -y 2>&1 | tee -a "$LOG_FILE"; then
            echo -e "${RED}❌ Error al actualizar paquetes${NC}"
            return 1
        fi
        if ! pkg upgrade -y 2>&1 | tee -a "$LOG_FILE"; then
            echo -e "${RED}❌ Error al actualizar paquetes${NC}"
            return 1
        fi
    else
        if ! pkg update -y &>> "$LOG_FILE"; then
            echo -e "${RED}❌ Error al actualizar paquetes${NC}"
            return 1
        fi
        if ! pkg upgrade -y &>> "$LOG_FILE"; then
            echo -e "${RED}❌ Error al actualizar paquetes${NC}"
            return 1
        fi
    fi

    echo -e "${GREEN}✅ Paquetes actualizados${NC}"
}

# Función para instalar paquetes base
install_base_packages() {
    echo -e "${CYAN}📦 Instalando paquetes base...${NC}"

    local packages=(
        "git" "curl" "wget" "openssh" "termux-services"
        "nodejs-lts" "zsh" "which" "tree" "htop"
        "jq" "unzip" "zip" "grep" "sed" "awk"
    )

    for package in "${packages[@]}"; do
        echo -e "${YELLOW}Instalando: $package${NC}"
        if [[ "$VERBOSE" == true ]]; then
            if ! pkg install -y "$package" 2>&1 | tee -a "$LOG_FILE"; then
                echo -e "${YELLOW}⚠️ Error instalando $package, continuando...${NC}"
            fi
        else
            if ! pkg install -y "$package" &>> "$LOG_FILE"; then
                echo -e "${YELLOW}⚠️ Error instalando $package, continuando...${NC}"
            fi
        fi
    done

    echo -e "${GREEN}✅ Paquetes base instalados${NC}"
}

# Función para configurar Zsh
setup_zsh() {
    echo -e "${CYAN}🐚 Configurando Zsh...${NC}"

    # Cambiar shell por defecto a zsh
    if command -v zsh &>/dev/null; then
        chsh -s zsh
        echo -e "${GREEN}✅ Shell cambiado a Zsh${NC}"
    fi

    # Instalar Oh My Zsh
    if [[ ! -d ~/.oh-my-zsh ]]; then
        echo -e "${YELLOW}📦 Instalando Oh My Zsh...${NC}"

        export RUNZSH=no
        export KEEP_ZSHRC=yes

        if [[ "$VERBOSE" == true ]]; then
            if sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" 2>&1 | tee -a "$LOG_FILE"; then
                echo -e "${GREEN}✅ Oh My Zsh instalado${NC}"
            else
                echo -e "${YELLOW}⚠️ Error instalando Oh My Zsh${NC}"
            fi
        else
            if sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" &>> "$LOG_FILE"; then
                echo -e "${GREEN}✅ Oh My Zsh instalado${NC}"
            else
                echo -e "${YELLOW}⚠️ Error instalando Oh My Zsh${NC}"
            fi
        fi
    fi

    # Configurar .zshrc
    cat > ~/.zshrc << 'EOF'
# Oh My Zsh configuration
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"

plugins=(
    git
    zsh-syntax-highlighting
    zsh-autosuggestions
)

source $ZSH/oh-my-zsh.sh

# Aliases útiles
alias ll='ls -la'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'

# Activar comando de IA
if [[ -f ~/bin/colon ]]; then
    alias :='~/bin/colon'
fi

# Variables de entorno
export EDITOR=nano
if command -v nvim &>/dev/null; then
    export EDITOR=nvim
fi

# Configuración específica de Termux
export USE_CCACHE=1
export TERMUX_PKG_CACHE_SIZE=512M

echo "🤖 Termux AI Setup - Usa ': \"pregunta\"' para activar el asistente IA"
EOF

    echo -e "${GREEN}✅ Zsh configurado${NC}"
}

# Función para configurar SSH
setup_ssh() {
    echo -e "${CYAN}🔐 Configurando SSH...${NC}"

    # Crear directorio SSH si no existe
    mkdir -p ~/.ssh
    chmod 700 ~/.ssh

    # Generar clave SSH si no existe
    if [[ ! -f ~/.ssh/id_ed25519 ]]; then
        echo -e "${YELLOW}🔑 Generando clave SSH...${NC}"

        read -p "Ingresa tu email para Git/GitHub: " user_email

        if [[ -n "$user_email" ]]; then
            if [[ "$VERBOSE" == true ]]; then
                ssh-keygen -t ed25519 -C "$user_email" -f ~/.ssh/id_ed25519 -N "" 2>&1 | tee -a "$LOG_FILE"
            else
                ssh-keygen -t ed25519 -C "$user_email" -f ~/.ssh/id_ed25519 -N "" &>> "$LOG_FILE"
            fi
            echo -e "${GREEN}✅ Clave SSH generada${NC}"

            # Mostrar clave pública
            echo -e "${CYAN}📋 Tu clave SSH pública (cópiala a GitHub):${NC}"
            echo ""
            cat ~/.ssh/id_ed25519.pub
            echo ""
            echo -e "${YELLOW}💡 Añade esta clave a GitHub en: https://github.com/settings/keys${NC}"
        fi
    fi

    # Configurar SSH config
    cat > ~/.ssh/config << 'EOF'
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519
    IdentitiesOnly yes
EOF

    chmod 600 ~/.ssh/config
    echo -e "${GREEN}✅ SSH configurado${NC}"
}

# Función para configurar Git
setup_git() {
    echo -e "${CYAN}🌐 Configurando Git...${NC}"

    # Solicitar información del usuario
    if ! git config --global user.name &>/dev/null; then
        read -p "Ingresa tu nombre para Git: " user_name
        if [[ -n "$user_name" ]]; then
            git config --global user.name "$user_name"
        fi
    fi

    if ! git config --global user.email &>/dev/null; then
        read -p "Ingresa tu email para Git: " user_email
        if [[ -n "$user_email" ]]; then
            git config --global user.email "$user_email"
        fi
    fi

    # Configuración adicional de Git
    git config --global init.defaultBranch main
    git config --global core.editor nano
    git config --global pull.rebase false

    if command -v nvim &>/dev/null; then
        git config --global core.editor nvim
    fi

    echo -e "${GREEN}✅ Git configurado${NC}"
}

# Función para instalar todos los agentes de IA
install_ai_agents() {
    echo -e "${CYAN}🤖 Instalando Agentes de IA (Gemini, Codex, Qwen)...${NC}"

    # Verificar que Node.js esté instalado (crítico)
    if ! command -v node &>/dev/null; then
        echo -e "${RED}❌ Node.js requerido para agentes IA${NC}"
        return 1
    fi

    echo -e "${BLUE}📦 Instalando Gemini CLI...${NC}"
    if [[ "$VERBOSE" == true ]]; then
        if npm install -g @google/gemini-cli 2>&1 | tee -a "$LOG_FILE"; then
            echo -e "${GREEN}✅ Gemini CLI instalado${NC}"
        else
            echo -e "${YELLOW}⚠️ Error con Gemini CLI, continuando...${NC}"
        fi
    else
        if npm install -g @google/gemini-cli &>> "$LOG_FILE"; then
            echo -e "${GREEN}✅ Gemini CLI instalado${NC}"
        else
            echo -e "${YELLOW}⚠️ Error con Gemini CLI, continuando...${NC}"
        fi
    fi

    echo -e "${BLUE}📦 Instalando OpenAI Codex...${NC}"
    if [[ "$VERBOSE" == true ]]; then
        if npm install -g @openai/codex 2>&1 | tee -a "$LOG_FILE"; then
            echo -e "${GREEN}✅ OpenAI Codex instalado${NC}"
        else
            # Intentar con nombres alternativos
            if npm install -g openai-codex 2>&1 | tee -a "$LOG_FILE"; then
                echo -e "${GREEN}✅ OpenAI Codex instalado (alternativo)${NC}"
            else
                echo -e "${YELLOW}⚠️ Codex CLI no disponible, continuando...${NC}"
            fi
        fi
    else
        if npm install -g @openai/codex &>> "$LOG_FILE"; then
            echo -e "${GREEN}✅ OpenAI Codex instalado${NC}"
        else
            # Intentar con nombres alternativos
            if npm install -g openai-codex &>> "$LOG_FILE"; then
                echo -e "${GREEN}✅ OpenAI Codex instalado (alternativo)${NC}"
            else
                echo -e "${YELLOW}⚠️ Codex CLI no disponible, continuando...${NC}"
            fi
        fi
    fi

    echo -e "${BLUE}📦 Instalando Qwen Code...${NC}"
    if [[ "$VERBOSE" == true ]]; then
        if npm install -g qwen-code 2>&1 | tee -a "$LOG_FILE"; then
            echo -e "${GREEN}✅ Qwen Code instalado${NC}"
        elif npm install -g @qwen/qwen-code 2>&1 | tee -a "$LOG_FILE"; then
            echo -e "${GREEN}✅ Qwen Code instalado (scoped)${NC}"
        else
            echo -e "${YELLOW}⚠️ Qwen CLI no disponible, continuando...${NC}"
        fi
    else
        if npm install -g qwen-code &>> "$LOG_FILE"; then
            echo -e "${GREEN}✅ Qwen Code instalado${NC}"
        elif npm install -g @qwen/qwen-code &>> "$LOG_FILE"; then
            echo -e "${GREEN}✅ Qwen Code instalado (scoped)${NC}"
        else
            echo -e "${YELLOW}⚠️ Qwen CLI no disponible, continuando...${NC}"
        fi
    fi

    echo -e "${GREEN}✅ Agentes de IA configurados${NC}"

    # Configuración automática de Gemini OAuth2
    if command -v gemini &>/dev/null; then
        echo -e "${YELLOW}🔐 Configurando autenticación OAuth2 para Gemini...${NC}"
        echo -e "${CYAN}Se abrirá el navegador para autenticarte con Google${NC}"

        if [[ "$VERBOSE" == true ]]; then
            if gemini auth login 2>&1 | tee -a "$LOG_FILE"; then
                echo -e "${GREEN}✅ Autenticación Gemini configurada${NC}"
            else
                echo -e "${YELLOW}⚠️ Autenticación pendiente - ejecuta 'gemini auth login' más tarde${NC}"
            fi
        else
            if gemini auth login; then
                echo -e "${GREEN}✅ Autenticación Gemini configurada${NC}"
            else
                echo -e "${YELLOW}⚠️ Autenticación pendiente - ejecuta 'gemini auth login' más tarde${NC}"
            fi
        fi
    fi

    # Mostrar información sobre otros agentes
    echo -e "${CYAN}💡 Para configurar otros agentes:${NC}"
    if command -v codex &>/dev/null; then
        echo -e "  ${YELLOW}codex login${NC}     # OpenAI OAuth2"
    fi
    if command -v qwen &>/dev/null || command -v qwen-code &>/dev/null; then
        echo -e "  ${YELLOW}qwen setup${NC}      # Qwen configuration"
    fi
}

# Función para instalar el agente IA
install_ai_agent() {
    echo -e "${CYAN}🤖 Instalando Agente IA...${NC}"

    # Crear directorio bin si no existe
    mkdir -p ~/bin

    # Descargar agente principal
    if ! curl -fsSL https://raw.githubusercontent.com/iberi22/termux-dev-nvim-agents/main/termux-ai-agent.sh -o ~/bin/termux-ai-agent; then
        echo -e "${RED}❌ Error descargando agente IA${NC}"
        return 1
    fi

    chmod +x ~/bin/termux-ai-agent

    # Crear comando ':' (dos puntos)
    cat > ~/bin/colon << 'EOF'
#!/bin/bash
exec ~/bin/termux-ai-agent "$@"
EOF

    chmod +x ~/bin/colon

    # Añadir ~/bin al PATH si no está
    if [[ ":$PATH:" != *":$HOME/bin:"* ]]; then
        echo 'export PATH="$HOME/bin:$PATH"' >> ~/.zshrc
        echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
        export PATH="$HOME/bin:$PATH"
    fi

    echo -e "${GREEN}✅ Agente IA instalado${NC}"
    echo -e "${CYAN}💡 Usa ': \"tu pregunta\"' para activar el asistente${NC}"
}

# Función para configurar servicios SSH (opcional)
setup_ssh_service() {
    echo -e "${CYAN}🌐 ¿Configurar acceso SSH remoto? (s/N):${NC}"
    read -r enable_ssh

    if [[ "${enable_ssh,,}" == "s" || "${enable_ssh,,}" == "y" ]]; then
        # Configurar contraseña
        echo -e "${YELLOW}🔐 Configurando contraseña para SSH...${NC}"
        passwd

        # Habilitar servicio SSH
        sv-enable sshd
        echo -e "${GREEN}✅ Servicio SSH habilitado${NC}"

        # Mostrar información de conexión
        echo -e "${CYAN}📱 Información de conexión SSH:${NC}"
        echo -e "${WHITE}IP: $(ip route get 1 | awk '{print $7}' | head -1)${NC}"
        echo -e "${WHITE}Puerto: 8022${NC}"
        echo -e "${WHITE}Usuario: $(whoami)${NC}"
        echo -e "${CYAN}Conecta con: ssh -p 8022 $(whoami)@IP${NC}"
    fi
}

# Función para mostrar resumen final
show_completion_summary() {
    echo -e "\n${GREEN}🎉 ¡INSTALACIÓN COMPLETADA!${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    echo -e "${WHITE}🛠️  Herramientas instaladas:${NC}"
    echo -e "  ✅ Git, SSH, Node.js, Zsh"
    echo -e "  ✅ Oh My Zsh con configuración personalizada"
    echo -e "  ✅ Gemini CLI con autenticación OAuth2"
    echo -e "  ✅ Agente IA integrado"

    echo -e "\n${WHITE}🤖 Cómo usar el Agente IA:${NC}"
    echo -e "  ${CYAN}: \"¿Cómo instalar Python?\"${NC}"
    echo -e "  ${CYAN}: \"Configurar GitHub SSH\"${NC}"
    echo -e "  ${CYAN}: \"Crear script de backup\"${NC}"

    echo -e "\n${WHITE}📚 Comandos útiles:${NC}"
    echo -e "  ${YELLOW}termux-ai-agent --help${NC}     - Ayuda del agente"
    echo -e "  ${YELLOW}termux-ai-agent --status${NC}   - Estado del sistema"
    echo -e "  ${YELLOW}pkg install nvim${NC}           - Instalar Neovim (opcional)"

    echo -e "\n${CYAN}💡 Reinicia Termux para aplicar todos los cambios${NC}"
    echo -e "${CYAN}💡 Después usa ': \"tu pregunta\"' para interactuar con IA${NC}"

    # Ofrecer instalar Neovim
    echo -e "\n${YELLOW}¿Instalar Neovim ahora? (s/N):${NC}"
    read -r install_nvim

    if [[ "${install_nvim,,}" == "s" || "${install_nvim,,}" == "y" ]]; then
        echo -e "${CYAN}📦 Instalando Neovim...${NC}"
        pkg install -y neovim
        echo -e "${GREEN}✅ Neovim instalado${NC}"
    fi
}

# Función principal de instalación automática
main() {
    show_banner

    echo -e "${CYAN}🚀 Iniciando instalación automática de Termux AI Setup${NC}"
    echo -e "${YELLOW}📝 Log: $LOG_FILE${NC}"

    if [[ "$VERBOSE" == true ]]; then
        echo -e "${YELLOW}Modo verbose activado${NC}"
        set -x
    fi

    log "Inicio de instalación automática"

    # Pasos de instalación
    update_packages || exit 1
    install_base_packages || exit 1
    setup_zsh || exit 1
    setup_git || exit 1
    setup_ssh || exit 1
    install_ai_agents || exit 1
    install_ai_agent || exit 1
    setup_ssh_service

    show_completion_summary

    log "Instalación completada exitosamente"
}

# Función para instalación interactiva
interactive_menu() {
    while true; do
        show_banner

        echo -e "${CYAN}┌─────────────────────────────────────────────────┐${NC}"
        echo -e "${CYAN}│                MENÚ DE INSTALACIÓN              │${NC}"
        echo -e "${CYAN}├─────────────────────────────────────────────────┤${NC}"
        echo -e "${WHITE}│  1. 🚀 Instalación Automática Completa         │${NC}"
        echo -e "${WHITE}│  2. 📦 Solo Actualizar Paquetes                │${NC}"
        echo -e "${WHITE}│  3. 🐚 Solo Configurar Zsh                     │${NC}"
        echo -e "${WHITE}│  4. 🔐 Solo Configurar SSH/Git                 │${NC}"
        echo -e "${WHITE}│  5. 🤖 Solo Instalar Gemini CLI               │${NC}"
        echo -e "${WHITE}│  6. 🛠️ Instalar Neovim                         │${NC}"
        echo -e "${WHITE}│  7. 📊 Ver Estado del Sistema                  │${NC}"
        echo -e "${WHITE}│  0. 🚪 Salir                                   │${NC}"
        echo -e "${CYAN}└─────────────────────────────────────────────────┘${NC}"

        read -p "Selecciona una opción [0-7]: " choice

        case $choice in
            1)
                main
                break
                ;;
            2)
                update_packages
                ;;
            3)
                setup_zsh
                ;;
            4)
                setup_git
                setup_ssh
                ;;
            5)
                install_ai_agents
                install_ai_agent
                ;;
            6)
                pkg install -y neovim
                echo -e "${GREEN}✅ Neovim instalado${NC}"
                ;;
            7)
                echo -e "${CYAN}📊 Estado del Sistema:${NC}"
                echo -e "${WHITE}Node.js:${NC} $(command -v node &>/dev/null && node --version || echo 'No instalado')"
                echo -e "${WHITE}Git:${NC} $(command -v git &>/dev/null && git --version | head -1 || echo 'No instalado')"
                echo -e "${WHITE}Zsh:${NC} $(command -v zsh &>/dev/null && zsh --version || echo 'No instalado')"
                echo -e "${WHITE}Gemini CLI:${NC} $(command -v gemini &>/dev/null && echo 'Instalado' || echo 'No instalado')"
                echo -e "${WHITE}Agente IA:${NC} $([[ -f ~/bin/termux-ai-agent ]] && echo 'Instalado' || echo 'No instalado')"
                read -p "Presiona Enter para continuar..."
                ;;
            0)
                echo -e "${GREEN}👋 ¡Hasta luego!${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}❌ Opción inválida${NC}"
                sleep 2
                ;;
        esac
    done
}

# Verificar argumentos
if [[ "${1:-}" == "--auto" ]]; then
    main
elif [[ "${1:-}" == "--help" ]]; then
    echo "Uso: $0 [--auto|--help]"
    echo "  --auto    Instalación automática completa"
    echo "  --help    Mostrar esta ayuda"
    echo "  (sin args) Menú interactivo"
else
    interactive_menu
fi