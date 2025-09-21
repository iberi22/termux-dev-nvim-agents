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

# Módulo 03: Instalar CLIs nativos de IA (sin menús ni auto-login)
# Objetivo: instalar OpenAI Codex CLI, Google Gemini CLI y Qwen Code CLI
# Autenticación: cada CLI maneja su propio flujo (OAuth2 o API key) de forma nativa

# Colores
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
    note "Verificando requisitos básicos (node, npm, certificados)…"
    if ! is_cmd node; then
        warn "Node.js no encontrado. Instalando…"
        pkg install -y nodejs >/dev/null
    fi
    if ! is_cmd npm; then
        warn "npm no encontrado. Instalando…"
        pkg install -y nodejs-lts >/dev/null || true
    fi
    # Certificados SSL comunes en Android/Termux
    export SSL_CERT_FILE="${PREFIX:-/data/data/com.termux/files/usr}/etc/tls/cert.pem"
    export SSL_CERT_DIR="${PREFIX:-/data/data/com.termux/files/usr}/etc/tls/certs"
    export REQUESTS_CA_BUNDLE="$SSL_CERT_FILE"
    export NODE_EXTRA_CA_CERTS="$SSL_CERT_FILE"
    export CURL_CA_BUNDLE="$SSL_CERT_FILE"
    ok "Requisitos básicos listos"
}

npm_install_global() {
    local pkg_name="$1"
    if npm list -g --depth=0 "$pkg_name" >/dev/null 2>&1; then
        ok "$pkg_name ya instalado"
    else
        note "Instalando $pkg_name (global)…"
        if npm i -g "$pkg_name" >/dev/null 2>&1; then
            ok "$pkg_name instalado"
        else
            err "Fallo instalando $pkg_name"
            return 1
        fi
    fi
}

install_codex() {
    note "Instalando OpenAI Codex CLI (@openai/codex)…"
    # Fuente oficial: https://github.com/openai/codex (npm i -g @openai/codex)
    npm_install_global "@openai/codex" || return 1
    ok "Codex listo. Para usar: ejecuta 'codex' y sigue el login (ChatGPT recomendado)"
}

install_gemini_cli() {
    note "Instalando Google Gemini CLI (@google/gemini-cli)…"
    npm_install_global "@google/gemini-cli" || return 1
    ok "Gemini CLI listo. Para usar: 'gemini' y sigue su flujo nativo"
}

install_qwen_cli() {
    note "Instalando Qwen Code CLI (@qwen-code/qwen-code)…"
    npm_install_global "@qwen-code/qwen-code" || return 1
    ok "Qwen CLI listo. Para usar: 'qwen' o 'qwen-code' según exponga el binario"
}

main() {
    echo -e "${BLUE}==> Instalación de CLIs nativos de IA (simple)${NC}"
    ensure_basics

    # Instalar los 3 CLIs solicitados
    install_codex || warn "Codex no pudo instalarse ahora; reintenta más tarde"
    install_gemini_cli || warn "Gemini CLI no pudo instalarse ahora"
    install_qwen_cli || warn "Qwen CLI no pudo instalarse ahora"

    echo
    ok "Instalación finalizada"
    echo -e "${CYAN}Siguientes pasos:${NC}"
    echo "  - codex        # inicia el login y configuración (ChatGPT/Key)"
    echo "  - gemini       # usa OAuth/Key según su flujo nativo"
    echo "  - qwen         # o qwen-code, según el bin expuesto"
    echo
    echo -e "${YELLOW}Notas para Termux:${NC}"
    echo "  - Si el login abre una URL, usa 'termux-open-url <URL>' si no se abre solo"
    echo "  - Asegúrate de tener un navegador Android configurado"
    echo "  - Si ves errores SSL, reinicia la sesión e intenta de nuevo"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi