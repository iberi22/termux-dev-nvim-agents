#!/bin/bash#!/bin/bash



# Módulo 03: Integración Nativa de IA - CLIs con OAuth2# ====================================

# Reemplaza sistema de recomendaciones con instalación nativa de CLIs# MÓDULO: Asistentes CLI Nativos + Auto-login

# Soporte: Gemini (OAuth), Qwen (OAuth), OpenAI (API Key)# Instala y configura CLIs nativos con autenticación mejorada

# ====================================

# Colores para output

RED='\033[0;31m'set -euo pipefail

GREEN='\033[0;32m'

YELLOW='\033[1;33m'# Colores

BLUE='\033[0;34m'RED='\033[0;31m'

PURPLE='\033[0;35m'GREEN='\033[0;32m'

CYAN='\033[0;36m'YELLOW='\033[1;33m'

WHITE='\033[1;37m'BLUE='\033[0;34m'

NC='\033[0m'PURPLE='\033[0;35m'

CYAN='\033[0;36m'

# DirectoriosNC='\033[0m'

TOOLS_DIR="$HOME/termux-ai-tools"

WRAP_DIR="$PREFIX/bin"echo -e "${BLUE}🤖 Configurando Asistentes CLI Nativos...${NC}"

SHIMS_DIR="$TOOLS_DIR/shims"

# Directorios de configuración

# Función para marcar progresoTERMUX_AI_DIR="$HOME/.termux-ai"

mark() {SHIMS_DIR="$TERMUX_AI_DIR/shims"

    echo -e "${GREEN}✅ $1${NC}"WRAP_DIR="$TERMUX_AI_DIR/bin"

}

# Crear directorios necesarios

# Verificar requisitos del sistemamkdir -p "$SHIMS_DIR" "$WRAP_DIR"

check_requirements() {

    mark "Verificando requisitos del sistema..."# Función para marcar progreso

    mark() {

    # Verificar Node.js    echo -e "${GREEN}[✓] $1${NC}"

    if ! command -v node >/dev/null 2>&1; then}

        echo -e "${YELLOW}📦 Instalando Node.js...${NC}"

        pkg install nodejs -y# Función para verificar si un comando existe

    fiis_cmd() {

        command -v "$1" >/dev/null 2>&1

    # Verificar npm}

    if ! command -v npm >/dev/null 2>&1; then

        echo -e "${YELLOW}📦 Instalando npm...${NC}"# Función para verificar requisitos

        pkg install npm -ycheck_requirements() {

    fi    echo -e "${BLUE}🔍 Verificando requisitos...${NC}"



    # Verificar expect para automatización    # Verificar Node.js

    if ! command -v expect >/dev/null 2>&1; then    if ! is_cmd node; then

        echo -e "${YELLOW}📦 Instalando expect...${NC}"        echo -e "${YELLOW}📦 Instalando Node.js...${NC}"

        pkg install expect -y        pkg install -y nodejs

    fi    fi



    # Crear directorios necesarios    # Verificar npm

    mkdir -p "$TOOLS_DIR" "$SHIMS_DIR"    if ! is_cmd npm; then

            echo -e "${YELLOW}📦 Instalando npm...${NC}"

    # Configurar variables de entorno SSL para Android        pkg install -y nodejs-lts

    export SSL_CERT_FILE="$PREFIX/etc/tls/cert.pem"    fi

    export SSL_CERT_DIR="$PREFIX/etc/tls/certs"

    export REQUESTS_CA_BUNDLE="$SSL_CERT_FILE"    # Verificar expect para scripts de auto-login

    export NODE_EXTRA_CA_CERTS="$SSL_CERT_FILE"    if ! is_cmd expect; then

    export CURL_CA_BUNDLE="$SSL_CERT_FILE"        echo -e "${YELLOW}📦 Instalando expect para auto-login...${NC}"

            pkg install -y expect

    # Variables para compilación en Android    fi

    export GYP_DEFINES="android_ndk_path=''"

    export npm_config_build_from_source=true    # Verificar certificados SSL

    export npm_config_python="$(command -v python3)"    if [[ ! -f "$PREFIX/etc/tls/cert.pem" ]]; then

    export CC=clang        echo -e "${YELLOW}📦 Instalando certificados SSL...${NC}"

    export CXX=clang++        pkg install -y ca-certificates

        fi

    mark "Requisitos verificados"

}    # Verificar ripgrep para evitar errores de plataforma

    if ! is_cmd rg; then

# Crear shims para dependencias problemáticas        echo -e "${YELLOW}📦 Instalando ripgrep...${NC}"

create_shims() {        pkg install -y ripgrep

    mark "Creando shims para compatibilidad Android..."    fi



    # Shim para ripgrep (requerido por algunos paquetes)    mark "Requisitos verificados y instalados"

    cat > "$SHIMS_DIR/rg-shim.js" <<'EOF'}

// Shim para ripgrep en Android/Termux

const fs = require('fs');# Función principal para instalar asistentes

const path = require('path');install_assistants() {

    mark "Preparando shims y entorno para CLIs…"

// Crear ejecutable dummy de ripgrep si no existe

#!/usr/bin/env bash
set -euo pipefail

# Module 03: Install native AI CLIs (without menus or auto-login)
# Objective: install OpenAI Codex CLI, Google Gemini CLI and Qwen Code CLI
# Authentication: each CLI handles its own flow (OAuth2 or API key) natively

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

note() { echo -e "${CYAN}➤${NC} $*"; }
ok() { echo -e "${GREEN}✓${NC} $*"; }
warn() { echo -e "${YELLOW}!${NC} $*"; }
err() { echo -e "${RED}✗${NC} $*"; }

is_cmd() { command -v "$1" >/dev/null 2>&1; }

ensure_basics() {
    note "Checking basic requirements (node, npm, certificates)…"
    if ! is_cmd node; then
        warn "Node.js not found. Installing…"
        pkg install -y nodejs >/dev/null
    fi
    if ! is_cmd npm; then
        warn "npm not found. Installing…"
        pkg install -y nodejs-lts >/dev/null || true
    fi
    # Common SSL certificates in Android/Termux
    export SSL_CERT_FILE="${PREFIX:-/data/data/com.termux/files/usr}/etc/tls/cert.pem"
    export SSL_CERT_DIR="${PREFIX:-/data/data/com.termux/files/usr}/etc/tls/certs"
    export REQUESTS_CA_BUNDLE="$SSL_CERT_FILE"
    export NODE_EXTRA_CA_CERTS="$SSL_CERT_FILE"
    export CURL_CA_BUNDLE="$SSL_CERT_FILE"
    ok "Basic requirements ready"
}

npm_install_global() {
    local pkg_name="$1"
    if npm list -g --depth=0 "$pkg_name" >/dev/null 2>&1; then
        ok "$pkg_name already installed"
    else
        note "Installing $pkg_name (global)…"
        if npm i -g "$pkg_name" >/dev/null 2>&1; then
            ok "$pkg_name installed"
        else
            err "Failed installing $pkg_name"
            return 1
        fi
    fi
}

install_codex() {
    note "Installing OpenAI Codex CLI (@openai/codex)…"
    # Official: npm i -g @openai/codex
    npm_install_global "@openai/codex" || return 1
    ok "Codex ready. Login with: 'codex login' and choose 'Sign in with ChatGPT' (OAuth)"
}

install_gemini_cli() {
    note "Installing Google Gemini CLI (@google/gemini-cli)…"
    npm_install_global "@google/gemini-cli" || return 1
    ok "Gemini CLI ready. First run: 'gemini' and sign in with your Google account (OAuth)"
}

install_qwen_cli() {
    note "Installing Qwen Code CLI (@qwen-code/qwen-code)…"
    npm_install_global "@qwen-code/qwen-code" || return 1
    ok "Qwen CLI ready. To use: 'qwen' or 'qwen-code' depending on exposed binary"
}

main() {
    echo -e "${BLUE}==> Installing native AI CLIs (simple)${NC}"
    ensure_basics

    # Install the 3 requested CLIs
    install_codex || warn "Codex could not be installed now; try again later"
    install_gemini_cli || warn "Gemini CLI could not be installed now"
    install_qwen_cli || warn "Qwen CLI could not be installed now"

    echo
    ok "Installation completed"
    echo -e "${CYAN}Next steps:${NC}"
    echo "  - codex        # run 'codex login' and choose ChatGPT (OAuth)"
    echo "  - gemini       # run 'gemini' and complete Google sign-in (OAuth)"
    echo "  - qwen         # or qwen-code, depending on exposed binary"
    echo
    echo -e "${YELLOW}Notes for Termux:${NC}"
    echo "  - If login opens a URL, use: termux-open-url <URL>"
    echo "  - Make sure you have an Android browser configured"
    echo "  - If you see SSL errors, restart the session and try again"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi