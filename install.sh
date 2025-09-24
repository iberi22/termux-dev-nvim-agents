#!/bin/bash

# ====================================
# TERMUX AI SETUP - INSTALADOR RÁPIDO
# Script de instalación con un comando
SCRIPT_VERSION="2025-09-22.4"
SCRIPT_COMMIT="auto"
# ====================================

set -euo pipefail

# Flag de verbose (por defecto desactivado)
VERBOSE=false
FORCE_MODULES=false
RESET_STATE=false
CLEAN_INSTALL=false

# Parseo simple de flags (-v|--verbose antes de cualquier acción)
for arg in "$@"; do
    case "$arg" in
        -v|--verbose)
            VERBOSE=true
            ;;
        -f|--force)
            FORCE_MODULES=true
            ;;
        --reset-state)
            RESET_STATE=true
            ;;
        --clean|--fresh)
            CLEAN_INSTALL=true
            ;;
    esac
done

# Colores
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
    echo "║   TERMUX AI SETUP - INSTALADOR RÁPIDO  | v${SCRIPT_VERSION}        ║"
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
    # Configurar TMP seguro para Termux
    if [[ ! -w "/tmp" ]]; then
        export TMPDIR="$HOME/.cache/tmp"
        export TEMP="$TMPDIR"
        export TMP="$TMPDIR"
        mkdir -p "$TMPDIR"
    fi
}

install_basic_tools() {
    echo -e "${BLUE}📦 Instalando herramientas básicas...${NC}"

    # Actualizar paquetes
    if [[ "$VERBOSE" == true ]]; then
        pkg update -y || true
    else
        pkg update -y >/dev/null 2>&1 || true
    fi

    # Instalar herramientas esenciales
    local tools=("curl" "wget" "git" "unzip")
    for tool in "${tools[@]}"; do
        if ! command -v "$tool" >/dev/null 2>&1; then
            echo -e "${YELLOW}Instalando $tool...${NC}"
            if [[ "$VERBOSE" == true ]]; then
                pkg install -y "$tool" || true
            else
                pkg install -y "$tool" >/dev/null 2>&1 || true
            fi
        fi
    done

    echo -e "${GREEN}✅ Herramientas básicas instaladas${NC}"
}

# Descargar y ejecutar setup principal
run_main_setup() {
    echo -e "${BLUE}📥 Descargando instalador principal...${NC}"

    if [[ -d "$INSTALL_DIR/.git" ]]; then
        if [[ "$CLEAN_INSTALL" == true ]]; then
            echo -e "${YELLOW}🧹 Eliminando instalación previa (modo clean)...${NC}"
            rm -rf "$INSTALL_DIR"
        else
            echo -e "${CYAN}🔄 Repositorio existente detectado. Intentando actualizar...${NC}"
            if git -C "$INSTALL_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
                git -C "$INSTALL_DIR" fetch --all --tags >/dev/null 2>&1 || true
                if ! git -C "$INSTALL_DIR" pull --ff-only origin "$BRANCH" >/dev/null 2>&1; then
                    echo -e "${YELLOW}⚠️ No se pudo aplicar pull fast-forward (posibles cambios locales).${NC}"
                    echo -e "${YELLOW}   Conservando la versión actual. Usa --clean para reinstalar desde cero.${NC}"
                else
                    echo -e "${GREEN}✅ Repositorio actualizado${NC}"
                fi
            else
                echo -e "${YELLOW}⚠️ Directorio existente inválido. Eliminando para reinstalar...${NC}"
                rm -rf "$INSTALL_DIR"
            fi
        fi
    elif [[ -d "$INSTALL_DIR" ]]; then
        if [[ "$CLEAN_INSTALL" == true ]]; then
            echo -e "${YELLOW}🧹 Eliminando directorio previo para reinstalar...${NC}"
            rm -rf "$INSTALL_DIR"
        else
            local backup_dir
            backup_dir="${INSTALL_DIR}_backup_$(date '+%Y%m%d%H%M%S')"
            echo -e "${YELLOW}⚠️ Directorio existente sin repo. Moviendo a ${backup_dir}.${NC}"
            mv "$INSTALL_DIR" "$backup_dir"
        fi
    fi

    if [[ ! -d "$INSTALL_DIR/.git" ]]; then
        echo -e "${CYAN}📥 Clonando repositorio...${NC}"
        if ! git clone "https://github.com/${REPO_OWNER}/${REPO_NAME}.git" "$INSTALL_DIR"; then
            echo -e "${RED}❌ Error al clonar el repositorio${NC}"
            echo -e "${YELLOW}💡 Verifica tu conexión a internet${NC}"
            exit 1
        fi
        echo -e "${GREEN}✅ Repositorio clonado${NC}"
    fi

    cd "$INSTALL_DIR"
    chmod +x setup.sh 2>/dev/null || true

    echo -e "${CYAN}🚀 Iniciando instalación COMPLETAMENTE AUTOMÁTICA...${NC}"

    # Fast path: instalación ya completada previamente
    if [[ -f "$HOME/.termux-ai-setup/INSTALL_DONE" && "$FORCE_MODULES" == false && "$CLEAN_INSTALL" == false && "$RESET_STATE" == false ]]; then
        echo -e "${GREEN}✅ Instalación ya completada previamente (detectado INSTALL_DONE).${NC}"
        echo -e "${YELLOW}Use --force o --clean para reinstalar, o --reset-state para reintentar módulos fallidos.${NC}"
        echo -e "${BLUE}📄 Resumen rápido:${NC}"
        grep -E 'completed_at|version|script_commit' "$HOME/.termux-ai-setup/INSTALL_DONE" 2>/dev/null || true
        return 0
    fi

    # Ejecutar instalación automática SIN INTERVENCIÓN
    export TERMUX_AI_AUTO=1
    export TERMUX_AI_SILENT=1

    # Configurar valores por defecto para evitar prompts
    export TERMUX_AI_GIT_NAME="Termux Developer"
    export TERMUX_AI_GIT_EMAIL="developer@termux.local"
    export TERMUX_AI_SSH_USER="termux"
    export TERMUX_AI_SSH_PASS="termux123"
    export TERMUX_AI_SETUP_SSH="1"
    export TERMUX_AI_START_SERVICES="1"
    export TERMUX_AI_LAUNCH_WEB="1"

    local setup_args=("auto")
    if [[ "$FORCE_MODULES" == true ]]; then
        setup_args+=("--force")
    fi
    if [[ "$RESET_STATE" == true ]]; then
        setup_args+=("--reset-state")
    fi
    if [[ "$VERBOSE" == true ]]; then
        setup_args+=("--verbose")
    fi

    exec ./setup.sh "${setup_args[@]}"
}

# Función principal
main() {
    show_banner

    echo -e "${CYAN}� Iniciando Termux AI Setup (v${SCRIPT_VERSION})${NC}"
    if [[ "$VERBOSE" == true ]]; then
        echo -e "${YELLOW}Modo verbose activado${NC}"
        set -x
    fi
    echo -e "${YELLOW}Este script instalará automáticamente:${NC}"
    echo -e "  • Git, Node.js, Zsh con Oh My Zsh"
    echo -e "  • Configuración SSH y Git"
    echo -e "  • Gemini CLI con autenticación OAuth2"
    echo -e "  • Agente IA integrado (comando ':')'"
    echo ""

    check_termux
    install_basic_tools
    run_main_setup
}

# Ejecutar instalación
main "$@"
