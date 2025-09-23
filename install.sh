#!/bin/bash

# ====================================
# TERMUX AI SETUP - INSTALADOR RÁPIDO
# Script de instalación con un comando
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

# Información del repositorio
REPO_OWNER="iberi22"
REPO_NAME="termux-dev-nvim-agents"
BRANCH="main"
BASE_URL="https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/${BRANCH}"

# Directorio de instalación
INSTALL_DIR="$HOME/termux-ai-setup"

show_banner() {
    clear
    echo -e "${PURPLE}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║              TERMUX AI SETUP - INSTALADOR RÁPIDO            ║"
    echo "║         🚀 Instalación automática para Termux AI            ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}\n"
}

check_termux() {
    if [[ ! -d "/data/data/com.termux" ]]; then
        echo -e "${RED}❌ Este script debe ejecutarse en Termux${NC}"
        exit 1
    fi

    if ! command -v pkg >/dev/null 2>&1; then
        echo -e "${RED}❌ Gestor de paquetes de Termux no encontrado${NC}"
        exit 1
    fi

    # Crear directorio cache si no existe
    mkdir -p "$HOME/.cache"
}

install_basic_tools() {
    echo -e "${BLUE}📦 Instalando herramientas básicas...${NC}"

    # Actualizar paquetes
    pkg update -y >/dev/null 2>&1

    # Instalar herramientas esenciales
    local tools=("curl" "wget" "git" "unzip")
    for tool in "${tools[@]}"; do
        if ! command -v "$tool" >/dev/null 2>&1; then
            echo -e "${YELLOW}Instalando $tool...${NC}"
            pkg install -y "$tool" >/dev/null 2>&1
        fi
    done

    echo -e "${GREEN}✅ Herramientas básicas instaladas${NC}"
}

# Descargar y ejecutar quick-setup
run_quick_setup() {
    echo -e "${BLUE}📥 Descargando instalador principal...${NC}"

    # URL del quick-setup
    local setup_url="https://raw.githubusercontent.com/iberi22/termux-dev-nvim-agents/main/quick-setup.sh"

    # Crear directorio temporal en el espacio del usuario
    local temp_dir="$HOME/.cache/termux-ai-install-$$"
    mkdir -p "$temp_dir"

    # Descargar quick-setup.sh
    if ! wget -q "$setup_url" -O "$temp_dir/quick-setup.sh"; then
        echo -e "${RED}❌ Error al descargar el instalador${NC}"
        echo -e "${YELLOW}💡 Verifica tu conexión a internet${NC}"
        exit 1
    fi

    chmod +x "$temp_dir/quick-setup.sh"

    echo -e "${GREEN}✅ Instalador descargado${NC}"
    echo -e "${CYAN}🚀 Iniciando instalación automática...${NC}"

    # Ejecutar instalación automática
    exec "$temp_dir/quick-setup.sh" --auto
}

# Función principal
main() {
    show_banner

    echo -e "${CYAN}� Iniciando Termux AI Setup${NC}"
    echo -e "${YELLOW}Este script instalará automáticamente:${NC}"
    echo -e "  • Git, Node.js, Zsh con Oh My Zsh"
    echo -e "  • Configuración SSH y Git"
    echo -e "  • Gemini CLI con autenticación OAuth2"
    echo -e "  • Agente IA integrado (comando ':')'"
    echo ""

    check_termux
    install_basic_tools
    run_quick_setup
}

# Ejecutar instalación
main "$@"
