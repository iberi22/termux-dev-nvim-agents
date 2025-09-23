#!/usr/bin/env bash
set -euo pipefail

# ====================================
# MÓDULO 03: Integración de CLIs de IA
# Instala CLIs nativos: OpenAI Codex, Google Gemini, Qwen Code
# Autenticación: cada CLI maneja su propio flujo (OAuth/API key)
# ====================================

# Source UI functions if available
if [[ -f "scripts/install-ui.sh" ]]; then
    source scripts/install-ui.sh
fi

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
    note "Verificando requisitos (Node 22 LTS, npm, Python, certificados SSL)…"

    # Instalar Python primero (necesario para node-gyp)
    if ! is_cmd python; then
        warn "Python no encontrado. Instalando…"
        pkg install -y python >/dev/null
    fi

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

    # Verificar si ya está instalado
    if npm list -g --depth=0 "$pkg_name" >/dev/null 2>&1; then
        ok "$pkg_name ya estaba instalado"
        return 0
    fi

    # Intentar instalación con manejo de conflictos
    if npm i -g "$pkg_name" --force >/dev/null 2>&1; then
        ok "$pkg_name instalado"
        return 0
    else
        err "Fallo al instalar $pkg_name"
        return 1
    fi
}

install_codex() {
    note "Instalando OpenAI Codex CLI (@openai/codex)…"
    # Intenta varios paquetes posibles para Codex
    if ! npm_install_global "@openai/codex"; then
        warn "Intentando con openai-codex..."
        npm_install_global "openai-codex" || warn "Codex CLI no disponible"
    fi
}

install_gemini() {
    note "Instalando Google Gemini CLI (@google/gemini-cli)…"

    # Remover instalación existente si hay conflictos
    if npm list -g --depth=0 "@google/gemini-cli" >/dev/null 2>&1; then
        warn "Removiendo instalación existente de Gemini CLI..."
        npm uninstall -g "@google/gemini-cli" >/dev/null 2>&1 || true
    fi

    if ! npm_install_global "@google/gemini-cli"; then
        warn "Intentando con @google/generative-ai-cli (legacy)..."
        npm_install_global "@google/generative-ai-cli" || warn "Gemini CLI no disponible"
    fi
}

install_qwen() {
    note "Instalando Qwen Code CLI…"
    # Usar el paquete correcto de Qwen
    if ! npm_install_global "@qwen-code/qwen-code@latest"; then
        warn "Intentando con qwen-code legacy..."
        npm_install_global "qwen-code" || warn "Qwen CLI no disponible"
    fi
}

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
    echo -e "${CYAN}Autenticación pendiente:${NC}"
    echo "  Los CLIs de IA requieren autenticación OAuth2"
    echo "  Esto se realizará al final de la instalación completa"
    echo
    echo -e "${YELLOW}Comandos disponibles después de autenticación:${NC}"
    echo "  - codex        # OpenAI Codex CLI"
    echo "  - gemini       # Google Gemini CLI"
    echo "  - qwen         # Qwen Code CLI"
    echo "  - :            # Comando rápido (wrapper de gemini)"
}

main "$@"