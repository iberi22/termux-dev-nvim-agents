#!/bin/bash

# ====================================
# TERMUX AI DEVELOPMENT SETUP
# Sistema modular para configurar Termux con IA
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
NC='\033[0m' # No Color

# Configuración
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODULES_DIR="${SCRIPT_DIR}/modules"
CONFIG_DIR="${SCRIPT_DIR}/config"
LOG_FILE="${SCRIPT_DIR}/setup.log"

# Función para logging
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Función para mostrar banner
show_banner() {
    clear
    echo -e "${PURPLE}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                    TERMUX AI SETUP v2.0                     ║"
    echo "║           Sistema Automatizado para Desarrollo con IA       ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}\n"
}

# Función para verificar prerequisites
check_prerequisites() {
    echo -e "${BLUE}🔍 Verificando prerequisites...${NC}"

    # Verificar que estemos en Termux
    if [[ ! -d "/data/data/com.termux" ]]; then
        echo -e "${RED}❌ Este script debe ejecutarse en Termux${NC}"
        exit 1
    fi

    # Verificar conexión a internet
    if ! ping -c 1 google.com &> /dev/null; then
        echo -e "${RED}❌ Se requiere conexión a internet${NC}"
        exit 1
    fi

    echo -e "${GREEN}✅ Prerequisites verificados${NC}"
}

# Función para mostrar menú principal
show_main_menu() {
    echo -e "${CYAN}┌─────────────────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│                MENÚ PRINCIPAL                   │${NC}"
    echo -e "${CYAN}├─────────────────────────────────────────────────┤${NC}"
    echo -e "${WHITE}│  1. � Instalar Paquetes Base                  │${NC}"
    echo -e "${WHITE}│  2. � Configurar Zsh + Oh My Zsh              │${NC}"
    echo -e "${WHITE}│  3. ⚡ Instalar y Configurar Neovim            │${NC}"
    echo -e "${WHITE}│  4. 🔐 Configurar SSH para GitHub              │${NC}"
    echo -e "${WHITE}│  5. 🤖 Configurar Integración con IA           │${NC}"
    echo -e "${WHITE}│  6. 🔄 Configurar Workflows de IA              │${NC}"
    echo -e "${WHITE}│  7. 🌟 Instalación Completa (Automática)       │${NC}"
    echo -e "${WHITE}│  8. 🧪 Ejecutar Tests de Instalación           │${NC}"
    echo -e "${WHITE}│  0. 🚪 Salir                                    │${NC}"
    echo -e "${CYAN}└─────────────────────────────────────────────────┘${NC}"
    echo -e "\n${YELLOW}Selecciona una opción [0-9]:${NC} "
}

# Función para ejecutar módulo con manejo de errores
run_module() {
    local module_name="$1"
    local module_path="${MODULES_DIR}/${module_name}.sh"

    if [[ ! -f "$module_path" ]]; then
        echo -e "${RED}❌ Módulo no encontrado: ${module_name}${NC}"
        return 1
    fi

    echo -e "${BLUE}🔄 Ejecutando: ${module_name}${NC}"
    log "Iniciando módulo: ${module_name}"

    if bash "$module_path"; then
        echo -e "${GREEN}✅ ${module_name} completado exitosamente${NC}"
        log "Módulo completado: ${module_name}"
        return 0
    else
        echo -e "${RED}❌ Error en ${module_name}${NC}"
        log "Error en módulo: ${module_name}"
        return 1
    fi
}

# Función para solicitar API key de Gemini
setup_gemini_api() {
    if [[ -z "${GEMINI_API_KEY:-}" ]]; then
        echo -e "${YELLOW}🔑 Configuración de API Key de Gemini${NC}"
        echo -e "${CYAN}Para obtener recomendaciones personalizadas de IA durante la instalación${NC}"
        echo -e "${CYAN}necesitas una API key de Google Gemini.${NC}\n"
        echo -e "${CYAN}Obtén tu API key en: https://aistudio.google.com/app/apikey${NC}\n"

        read -p "Ingresa tu API key de Gemini (o presiona Enter para continuar sin IA): " api_key

        if [[ -n "$api_key" ]]; then
            echo "export GEMINI_API_KEY='$api_key'" >> ~/.bashrc
            echo "export GEMINI_API_KEY='$api_key'" >> ~/.zshrc 2>/dev/null || true
            export GEMINI_API_KEY="$api_key"
            echo -e "${GREEN}✅ API key configurada correctamente${NC}"
        else
            echo -e "${YELLOW}⚠️  Continuando sin integración de IA${NC}"
        fi
    else
        echo -e "${GREEN}✅ API key de Gemini ya configurada${NC}"
    fi
}

# Función para instalación completa
full_installation() {
    echo -e "${BLUE}🚀 Iniciando instalación completa...${NC}"

    local modules=(
        "00-base-packages"
        "01-zsh-setup"
        "02-neovim-setup"
        "05-ssh-setup"
        "03-ai-integration"
        "04-workflows-setup"
    )

    setup_gemini_api

    for module in "${modules[@]}"; do
        if ! run_module "$module"; then
            echo -e "${RED}❌ Instalación interrumpida en: ${module}${NC}"
            read -p "¿Deseas continuar con el siguiente módulo? (y/N): " continue_install
            if [[ ! "$continue_install" =~ ^[Yy]$ ]]; then
                return 1
            fi
        fi
        echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    done

    echo -e "${GREEN}🎉 ¡Instalación completa finalizada!${NC}"
    echo -e "${CYAN}🔄 Reiniciando terminal...${NC}"

    # Recargar configuración
    source ~/.bashrc 2>/dev/null || true
    exec "$SHELL" || true
}

# Función principal
main() {
    show_banner
    check_prerequisites

    # Crear log file
    log "Iniciando Termux AI Setup"

    while true; do
        show_main_menu
        read -r choice

        case $choice in
            1)
                run_module "00-base-packages"
                ;;
            2)
                run_module "01-zsh-setup"
                ;;
            3)
                run_module "02-neovim-setup"
                ;;
            4)
                run_module "05-ssh-setup"
                ;;
            5)
                setup_gemini_api
                run_module "03-ai-integration"
                ;;
            6)
                run_module "04-workflows-setup"
                ;;
            7)
                full_installation
                ;;
            8)
                run_module "test-installation"
                ;;
            0)
                echo -e "${GREEN}¡Gracias por usar Termux AI Setup!${NC}"
                log "Setup terminado por el usuario"
                exit 0
                ;;
            *)
                echo -e "${RED}❌ Opción inválida. Selecciona un número del 0-8.${NC}"
                sleep 2
                ;;
        esac

        echo -e "\n${YELLOW}Presiona Enter para continuar...${NC}"
        read -r
    done
}

# Manejo de señales
trap 'echo -e "\n${RED}⚠️ Instalación interrumpida${NC}"; exit 1' INT TERM

# Ejecutar función principal
main "$@"