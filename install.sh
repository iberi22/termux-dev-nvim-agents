#!/bin/bash

# ====================================
# TERMUX AI SETUP - INSTALADOR RÁPIDO
# Script de instalación con un comando
# ====================================
SCRIPT_VERSION="2025-09-25.1b42acc"
SCRIPT_COMMIT="git-local"

# Force UTF-8 encoding to avoid visual artifacts
export LC_ALL=C.UTF-8
export LANG=C.UTF-8

set -Eeuo pipefail
IFS=$'\n\t'

readonly SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"
readonly SCRIPT_START_TS="$(date +%s)"

SCRIPT_EXIT_CODE=-1
SCRIPT_FAILURE_CMD=""
SCRIPT_STATUS="running"

declare -a SUMMARY_LINES=()

# Flag de verbose (por defecto desactivado)
VERBOSE=false
FORCE_MODULES=false
RESET_STATE=false
CLEAN_INSTALL=false

# Colores (ANSI standard)
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Directorio de instalación
INSTALL_DIR="$HOME/termux-ai-setup"
LOG_FILE="$INSTALL_DIR/setup.log"

log() {
    local color="$1"
    local icon="$2"
    shift 2
    # Print to stdout with color
    printf "%b%s%b %s\n" "$color" "$icon" "$NC" "$*"
    # Log to file without color (ensure dir exists first)
    if [[ -d "$INSTALL_DIR" ]]; then
        echo "[$(date +'%H:%M:%S')] $icon $*" >> "$LOG_FILE" 2>/dev/null || true
    fi
}

info() {
    log "$CYAN" "ℹ️" "$@"
}

success() {
    log "$GREEN" "✅" "$@"
}

warn() {
    log "$YELLOW" "⚠️" "$@" >&2
}

error() {
    log "$RED" "❌" "$@" >&2
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
    warn "Se detectó un fallo en: ${failed_command} (código ${exit_code})"
}

on_interrupt() {
    SCRIPT_EXIT_CODE=130
    SCRIPT_STATUS="interrupted"
    warn "Ejecución interrumpida por el usuario."
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

    if [[ $exit_code -eq 0 ]]; then
        SCRIPT_STATUS="success"
        if ((${#SUMMARY_LINES[@]} > 0)); then
            printf "\n%b📋 Resumen:%b\n" "$BLUE" "$NC"
            for line in "${SUMMARY_LINES[@]}"; do
                printf "  • %s\n" "$line"
            done
        fi
        success "${SCRIPT_NAME} finalizado en ${elapsed}s."
    else
        echo ""
        error "=========================================="
        error "   LA INSTALACIÓN FALLÓ (Code $exit_code)"
        error "=========================================="
        if [[ -n "$SCRIPT_FAILURE_CMD" ]]; then
            error "Comando fallido: ${SCRIPT_FAILURE_CMD}"
        fi

        if [[ -f "$LOG_FILE" ]]; then
            echo -e "\n${YELLOW}--- Últimas 15 líneas del log ($LOG_FILE) ---${NC}"
            tail -n 15 "$LOG_FILE" 2>/dev/null || true
            echo -e "${YELLOW}---------------------------------------------${NC}"
            warn "Por favor revisa el archivo $LOG_FILE para más detalles."
        else
            warn "No se pudo leer el archivo de log."
        fi

        error "${SCRIPT_NAME} abortado tras ${elapsed}s."
    fi

    exit "$exit_code"
}

trap 'on_error $? "$BASH_COMMAND"' ERR
trap 'on_interrupt' INT TERM
trap 'cleanup' EXIT

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

# Información del repositorio
REPO_OWNER="iberi22"
REPO_NAME="termux-dev-nvim-agents"
BRANCH="main"
BASE_URL="https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/${BRANCH}"

run_with_retry() {
    local description="$1"
    shift

    local attempt=1
    local max_attempts=3

    while (( attempt <= max_attempts )); do
        if [[ "$VERBOSE" == true ]]; then
            if "$@"; then
                return 0
            fi
        else
            if "$@" >/dev/null 2>&1; then
                return 0
            fi
        fi

        warn "Intento ${attempt}/${max_attempts} fallido: ${description}"
        sleep $(( attempt ))
        ((attempt++))
    done

    error "No se pudo completar: ${description}"
    return 1
}

# Banner simplificado (ASCII safe)
show_banner() {
    clear
    echo -e "${PURPLE}"
    echo "=========================================================="
    echo "  TERMUX AI SETUP - INSTALADOR RAPIDO | v${SCRIPT_VERSION}"
    echo "         > Instalacion automatica para Termux AI"
    echo "=========================================================="
    echo -e "${NC}\n"
}

check_termux() {
    if [[ ! -d "/data/data/com.termux" ]]; then
        error "Este script debe ejecutarse en Termux."
        exit 1
    fi

    if ! command -v pkg >/dev/null 2>&1; then
        error "Gestor de paquetes de Termux no encontrado."
        exit 1
    fi

    # Crear directorio cache si no existe
    mkdir -p "$HOME/.cache"
    # Configurar TMP seguro para Termux
    if [[ ! -w "/tmp" ]]; then
        info "Configurando directorio temporal en cache local."
        export TMPDIR="$HOME/.cache/tmp"
        export TEMP="$TMPDIR"
        export TMP="$TMPDIR"
        mkdir -p "$TMPDIR"
    fi
}

install_basic_tools() {
    info "Preparando herramientas básicas de Termux..."

    if ! run_with_retry "Actualizar índices de paquetes" pkg update -y; then
        exit 1
    fi

    local tools=("curl" "wget" "git" "unzip")
    for tool in "${tools[@]}"; do
        if ! command -v "$tool" >/dev/null 2>&1; then
            info "Instalando ${tool}..."
            if ! run_with_retry "Instalar ${tool}" pkg install -y "$tool"; then
                exit 1
            fi
        fi
    done

    success "Herramientas básicas listas."
}

# Descargar y ejecutar setup principal
run_main_setup() {
    info "Preparando instalador principal..."

    if [[ -d "$INSTALL_DIR/.git" ]]; then
        if [[ "$CLEAN_INSTALL" == true ]]; then
            warn "Eliminando instalación previa (modo clean)."
            rm -rf "$INSTALL_DIR"
        else
            info "Repositorio existente detectado. Intentando actualizar..."
            if git -C "$INSTALL_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
                if [[ "$VERBOSE" == true ]]; then
                    git -C "$INSTALL_DIR" fetch --all --tags || warn "No se pudo sincronizar con el remoto."
                else
                    git -C "$INSTALL_DIR" fetch --all --tags >/dev/null 2>&1 || warn "No se pudo sincronizar con el remoto."
                fi

                if [[ "$VERBOSE" == true ]]; then
                    if ! git -C "$INSTALL_DIR" pull --ff-only origin "$BRANCH"; then
                        warn "No se pudo aplicar pull fast-forward (posibles cambios locales)."
                        warn "Conservando la versión actual. Usa --clean para reinstalar desde cero."
                    else
                        success "Repositorio actualizado."
                    fi
                else
                    if ! git -C "$INSTALL_DIR" pull --ff-only origin "$BRANCH" >/dev/null 2>&1; then
                        warn "No se pudo aplicar pull fast-forward (posibles cambios locales)."
                        warn "Conservando la versión actual. Usa --clean para reinstalar desde cero."
                    else
                        success "Repositorio actualizado."
                    fi
                fi
            else
                warn "Directorio existente inválido. Eliminando para reinstalar..."
                rm -rf "$INSTALL_DIR"
            fi
        fi
    elif [[ -d "$INSTALL_DIR" ]]; then
        if [[ "$CLEAN_INSTALL" == true ]]; then
            warn "Eliminando directorio previo para reinstalar..."
            rm -rf "$INSTALL_DIR"
        else
            local backup_dir
            backup_dir="${INSTALL_DIR}_backup_$(date '+%Y%m%d%H%M%S')"
            warn "Directorio existente sin repo. Moviendo a ${backup_dir}."
            mv "$INSTALL_DIR" "$backup_dir"
        fi
    fi

    if [[ ! -d "$INSTALL_DIR/.git" ]]; then
        info "Clonando repositorio..."
        if ! run_with_retry "Clonar repositorio principal" git clone "https://github.com/${REPO_OWNER}/${REPO_NAME}.git" "$INSTALL_DIR"; then
            warn "Verifica tu conexión a internet o usa --clean para reinstalar."
            exit 1
        fi
        success "Repositorio clonado."
    fi

    cd "$INSTALL_DIR"

    # Inicializar log file en instalación limpia
    touch "$LOG_FILE"

    chmod +x setup.sh 2>/dev/null || true

    info "Iniciando instalación completamente automática..."

    # Fast path: instalación ya completada previamente
    if [[ -f "$HOME/.termux-ai-setup/INSTALL_DONE" && "$FORCE_MODULES" == false && "$CLEAN_INSTALL" == false && "$RESET_STATE" == false ]]; then
        success "Instalación ya completada previamente (detectado INSTALL_DONE)."
        warn "Use --force o --clean para reinstalar, o --reset-state para reintentar módulos fallidos."
        grep -E 'completed_at|version|script_commit' "$HOME/.termux-ai-setup/INSTALL_DONE" 2>/dev/null || true
        add_summary "Instalación previa detectada: se omitió la ejecución de módulos."
        return 0
    fi

    # Ejecutar instalación automática.
    # El nuevo módulo 00-user-input.sh se encargará de pedir los datos al usuario.
    export TERMUX_AI_AUTO=1 # Mantiene el modo "auto" para el flujo de setup.sh
    export TERMUX_AI_SILENT=1 # Mantiene el modo silencioso para evitar menús

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

    info "Ejecutando setup principal (${setup_args[*]})..."

    # Capturar salida para debug si falla
    if ./setup.sh "${setup_args[@]}"; then
        add_summary "Instalación automática completada exitosamente."
        success "Setup principal finalizado."
    else
        local exit_code=$?
        SCRIPT_EXIT_CODE=$exit_code
        SCRIPT_FAILURE_CMD="./setup.sh ${setup_args[*]}"
        error "El setup principal devolvió código ${exit_code}."
        exit "$exit_code"
    fi
}

# Función principal
main() {
    show_banner

    info "Iniciando Termux AI Setup (v${SCRIPT_VERSION})."
    if [[ "$VERBOSE" == true ]]; then
        warn "Modo verbose activado."
        set -x
    fi
    printf "%bEste script instalará automáticamente:%b\n" "$YELLOW" "$NC"
    printf "  • Git, Node.js, Zsh con Oh My Zsh\n"
    printf "  • Configuración SSH y Git\n"
    printf "  • Gemini CLI con autenticación OAuth2\n"
    printf "  • Agente IA integrado (comando ':')\n\n"

    check_termux
    install_basic_tools

    # Validation delegated to setup.sh after cloning


    run_main_setup
}

# Ejecutar instalación
main "$@"
