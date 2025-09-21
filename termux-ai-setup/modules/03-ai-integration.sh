#!/usr/bin/env bash
set -euo pipefail

# ====================================
# MÓDULO 03: Integración de CLIs de IA
# Instala CLIs nativos: OpenAI Codex, Google Gemini, Qwen Code
# Autenticación: cada CLI maneja su propio flujo (OAuth/API key)
# ====================================

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

ensure_prereqs() {
    note "Verificando requisitos (Node 22 LTS, npm, certificados SSL)…"
    if ! is_cmd node; then
        warn "Node.js no encontrado. Instalando LTS…"
        pkg install -y nodejs-lts >/dev/null
    fi
    if ! is_cmd npm; then
        warn "npm no encontrado. Instalando…"
        pkg install -y nodejs-lts >/dev/null || true
    fi

    # Comprobar versión mayor de Node (preferir 22)
    if is_cmd node; then
        NODE_VER=$(node -v 2>/dev/null || echo "v0.0.0")
        NODE_MAJOR=${NODE_VER#v}
        NODE_MAJOR=${NODE_MAJOR%%.*}
        if [[ "$NODE_MAJOR" != "22" ]]; then
            warn "Node actual ($NODE_VER) no es 22.x. Intentando asegurar LTS…"
            pkg install -y nodejs-lts >/dev/null || true
        else
            ok "Node ${NODE_VER} (22.x) detectado"
        fi
    fi

    # Certificados SSL comunes en Termux
    export SSL_CERT_FILE="${PREFIX:-/data/data/com.termux/files/usr}/etc/tls/cert.pem"
    export SSL_CERT_DIR="${PREFIX:-/data/data/com.termux/files/usr}/etc/tls/certs"
    export REQUESTS_CA_BUNDLE="$SSL_CERT_FILE"
    export NODE_EXTRA_CA_CERTS="$SSL_CERT_FILE"
    export CURL_CA_BUNDLE="$SSL_CERT_FILE"

    # Paquete 'expect' opcional
    if ! is_cmd expect; then
        pkg install -y expect >/dev/null || true
    fi

    ok "Requisitos verificados"
}

npm_install_global() {
    local pkg_name="$1"
    note "Instalando paquete global: $pkg_name"
    if npm list -g --depth=0 "$pkg_name" >/dev/null 2>&1; then
        ok "$pkg_name ya estaba instalado"
        return 0
    fi
    if npm i -g "$pkg_name" >/dev/null 2>&1; then
        ok "$pkg_name instalado"
        return 0
    else
        err "Fallo al instalar $pkg_name"
        return 1
    fi
}

install_codex() { note "Instalando OpenAI Codex CLI (@openai/codex)…"; npm_install_global "@openai/codex"; }
install_gemini() { note "Instalando Google Gemini CLI (@google/gemini-cli)…"; npm_install_global "@google/gemini-cli"; }
install_qwen() { note "Instalando Qwen Code CLI (@qwen-code/qwen-code)…"; npm_install_global "@qwen-code/qwen-code"; }

verify_binaries() {
    note "Verificando binarios instalados…"
    local ok_all=true
    command -v codex >/dev/null 2>&1 || ok_all=false
    command -v gemini >/dev/null 2>&1 || ok_all=false
    if ! command -v qwen >/dev/null 2>&1 && ! command -v qwen-code >/dev/null 2>&1; then ok_all=false; fi
    if [[ "$ok_all" == true ]]; then
        ok "CLIs verificados en PATH"
        return 0
    else
        warn "Algún CLI no se registró en PATH. Reinicia la sesión o añade '$(npm bin -g 2>/dev/null)' al PATH"
        return 1
    fi
}

main() {
    echo -e "${BLUE}🤖 Instalando CLIs nativos de IA…${NC}"
    ensure_prereqs

    install_codex || warn "@openai/codex no pudo instalarse ahora"
    install_gemini || warn "@google/gemini-cli no pudo instalarse ahora"
    install_qwen || warn "@qwen-code/qwen-code no pudo instalarse ahora"

    verify_binaries || true

    echo
    ok "Instalación de CLIs finalizada"
    echo -e "${CYAN}Siguientes pasos:${NC}"
    echo "  - codex        # Ejecuta 'codex login' (elige Sign in with ChatGPT - OAuth)"
    echo "  - gemini       # Ejecuta 'gemini' y completa el login de Google (OAuth)"
    echo "  - qwen         # o 'qwen-code', según el binario expuesto"
    echo
    echo -e "${YELLOW}Notas para Termux:${NC}"
    echo "  - Si se abre una URL para login, usa: termux-open-url <URL>"
    echo "  - Asegúrate de tener un navegador Android configurado"
}

main "$@"