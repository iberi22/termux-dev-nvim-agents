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

    # Configuración especial para node-gyp en Termux (evita error android_ndk_path)
    export GYP_DEFINES="android_ndk_path=/dev/null"
    export npm_config_build_from_source=true
    export npm_config_python="$(command -v python3)"
    export CC=clang
    export CXX=clang++

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

    # Configurar entorno para node-gyp antes de instalar
    export GYP_DEFINES="android_ndk_path=/dev/null"
    export npm_config_build_from_source=true
    export npm_config_python="$(command -v python3)"
    export CC=clang
    export CXX=clang++

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
    note "Instalando OpenAI Codex CLI - última versión disponible…"

    # Verificar si codex ya está disponible
    if command -v codex >/dev/null 2>&1; then
        note "OpenAI Codex CLI ya disponible"
        # Intentar actualizar
        npm update -g @openai/codex >/dev/null 2>&1 || true
        ok "OpenAI Codex CLI verificado/actualizado"
        return 0
    fi

    # Intenta varios paquetes posibles para Codex con versiones específicas
    local codex_packages=(
        "@openai/codex@latest"
        "openai-codex@latest"
        "@openai/cli@latest"
        "openai@latest"
    )

    for pkg in "${codex_packages[@]}"; do
        note "Intentando instalar: $pkg"
        if npm_install_global "$pkg"; then
            # Verificar si el comando está disponible después de la instalación
            if command -v codex >/dev/null 2>&1 || command -v openai >/dev/null 2>&1; then
                ok "CLI de OpenAI instalado: $pkg"
                return 0
            fi
        fi
    done

    warn "OpenAI Codex CLI no disponible - puede requerir acceso especial"
    return 1
}

install_gemini() {
    note "Instalando Google Gemini CLI (@google/gemini-cli) - última versión…"

    # Verificar si gemini ya está disponible como comando
    if command -v gemini >/dev/null 2>&1; then
        local current_version=$(gemini --version 2>/dev/null || echo "desconocida")
        note "Gemini CLI ya disponible (versión: $current_version)"

        # Actualizar a la última versión
        note "Actualizando a la última versión..."
        npm update -g @google/gemini-cli >/dev/null 2>&1 || true

        local new_version=$(gemini --version 2>/dev/null || echo "desconocida")
        ok "Gemini CLI actualizado (versión: $new_version)"
        return 0
    fi

    # Limpiar instalaciones previas
    npm uninstall -g "@google/gemini-cli" >/dev/null 2>&1 || true
    npm uninstall -g "@google/generative-ai-cli" >/dev/null 2>&1 || true

    # Instalar la última versión del paquete oficial
    note "Instalando la última versión de @google/gemini-cli..."
    if ! npm_install_global "@google/gemini-cli@latest"; then
        warn "Intentando con versión específica..."
        if ! npm_install_global "@google/gemini-cli"; then
            err "No se pudo instalar Gemini CLI"
            return 1
        fi
    fi

    # Verificar instalación
    if command -v gemini >/dev/null 2>&1; then
        local version=$(gemini --version 2>/dev/null || echo "desconocida")
        ok "Gemini CLI v$version instalado correctamente"
    else
        err "Gemini CLI instalado pero comando no disponible"
        return 1
    fi
}

install_qwen() {
    note "Instalando Qwen Code CLI - última versión disponible…"

    # Verificar si qwen ya está disponible
    if command -v qwen >/dev/null 2>&1 || command -v qwen-code >/dev/null 2>&1; then
        note "Qwen CLI ya disponible"
        ok "Qwen CLI verificado"
        return 0
    fi

    # Lista de paquetes Qwen que pueden estar disponibles
    local qwen_packages=(
        "qwen-code@latest"
        "@qwen/qwen-code@latest"
        "qwen@latest"
        "@qwen/cli@latest"
        "qwencode@latest"
    )

    for pkg in "${qwen_packages[@]}"; do
        note "Intentando instalar: $pkg"
        if npm_install_global "$pkg"; then
            # Verificar si el comando está disponible después de la instalación
            if command -v qwen >/dev/null 2>&1 || command -v qwen-code >/dev/null 2>&1; then
                ok "Qwen CLI instalado: $pkg"
                return 0
            fi
        fi
    done

    warn "Qwen Code CLI no disponible - puede requerir configuración especial"
    return 1
}

verify_binaries() {
    note "Verificando binarios instalados…"
    local missing_count=0

    echo -e "${CYAN}Verificando CLIs instalados:${NC}"

    if command -v codex >/dev/null 2>&1; then
        ok "✓ codex disponible"
    else
        warn "✗ codex no disponible"
        ((missing_count++))
    fi

    if command -v gemini >/dev/null 2>&1; then
        ok "✓ gemini disponible"
    else
        warn "✗ gemini no disponible"
        ((missing_count++))
    fi

    if command -v qwen >/dev/null 2>&1; then
        ok "✓ qwen disponible"
    elif command -v qwen-code >/dev/null 2>&1; then
        ok "✓ qwen-code disponible"
    else
        warn "✗ qwen/qwen-code no disponible"
        ((missing_count++))
    fi

    if [[ $missing_count -eq 0 ]]; then
        ok "Todos los CLIs están disponibles"
        return 0
    else
        warn "$missing_count CLI(s) no están disponibles. Reinicia la sesión o añade '$(npm bin -g 2>/dev/null)' al PATH"
        # Mostrar información de PATH para depuración
        echo -e "${YELLOW}PATH actual contiene:${NC}"
        echo "$PATH" | tr ':' '\n' | grep -E "(node|npm)" || echo -e "${RED}No se encontraron rutas de Node.js/npm${NC}"
        return 1
    fi
}

main() {
    echo -e "${BLUE}🤖 Instalando CLIs nativos de IA…${NC}"
    ensure_prereqs

    local install_failures=0

    if ! install_codex; then
        warn "@openai/codex no pudo instalarse"
        ((install_failures++))
    fi

    if ! install_gemini; then
        warn "@google/gemini-cli no pudo instalarse"
        ((install_failures++))
    fi

    if ! install_qwen; then
        warn "@qwen-code/qwen-code no pudo instalarse"
        ((install_failures++))
    fi

    verify_binaries || warn "Algunos CLIs pueden no estar disponibles inmediatamente"

    echo
    if [[ $install_failures -eq 0 ]]; then
        ok "✅ Instalación de CLIs completada exitosamente"
    else
        warn "⚠️ Instalación completada con $install_failures fallo(s)"
    fi

    echo -e "${CYAN}ℹ️ Autenticación manual requerida:${NC}"
    echo "  • gemini auth login    # Para Google Gemini"
    echo "  • codex login          # Para OpenAI Codex (si disponible)"
    echo "  • qwen setup           # Para Qwen Code (si disponible)"
    echo
    echo -e "${YELLOW}Comandos disponibles:${NC}"
    echo "  • gemini -p \"tu pregunta\"  # Gemini CLI directo"
    echo "  • : \"tu pregunta\"          # Comando rápido (alias de gemini)"
    echo "  • codex \"código a generar\" # Codex CLI (si está disponible)"
}

main "$@"