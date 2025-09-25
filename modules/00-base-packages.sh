#!/bin/bash

# ====================================
# MODULE: Base Packages Installation
# Instalación robusta e idempotente de herramientas esenciales para Termux AI
# ====================================

set -Eeuo pipefail
IFS=$'\n\t'

readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m'

MODULE_NAME="00-base-packages"
STATE_MARKER_DIR="$HOME/.termux-ai-setup/state"
MODULE_MARKER="$STATE_MARKER_DIR/${MODULE_NAME}.ok"

declare -ar ESSENTIAL_PACKAGES=(
    curl
    wget
    git
    unzip
    zip
    python
    python-pip
    make
    clang
    nano
    vim
    tree
    htop
    openssh
    jq
    ca-certificates
    termux-tools
    zsh
    nodejs-lts
)

declare -ar OPTIONAL_PACKAGES=(
    ripgrep
    fd
    fzf
    bat
    eza
    zoxide
)

declare -a INSTALLED_ESSENTIAL=()
declare -a FAILED_ESSENTIAL=()
declare -a INSTALLED_OPTIONAL=()
declare -a FAILED_OPTIONAL=()
declare -a MISSING_CRITICAL=()

record_module_state() {
    local state=$1
    local exit_code=${2:-0}

    if command -v termux_ai_record_module_state >/dev/null 2>&1; then
        termux_ai_record_module_state "$MODULE_NAME" "$0" "$state" "$exit_code" || true
    fi
}

# shellcheck disable=SC2329
handle_error() {
    local exit_code=$?
    local line=${BASH_LINENO[0]:-unknown}

    printf "%b❌ Error en %s (línea %s). Código %s%b\n" "$RED" "$MODULE_NAME" "$line" "$exit_code" "$NC"
    record_module_state "failed" "$exit_code"
    exit "$exit_code"
}

trap 'handle_error' ERR

log() {
    local color=$1
    shift
    printf "%b%s%b\n" "$color" "$*" "$NC"
}

log_section() { log "$BLUE" "$*"; }
log_info() { log "$CYAN" "$*"; }
log_warn() { log "$YELLOW" "$*"; }
log_success() { log "$GREEN" "$*"; }
log_error() { log "$RED" "$*"; }

ensure_state_dir() {
    mkdir -p "$STATE_MARKER_DIR"
}

check_previous_run() {
    if [[ -f "$MODULE_MARKER" && "${TERMUX_AI_FORCE_MODULES:-0}" != "1" ]]; then
        log_success "🔁 ${MODULE_NAME} ya completado anteriormente (marker). Usa --force para reejecutar."
        exit 0
    fi
}

assert_termux_environment() {
    if ! command -v pkg >/dev/null 2>&1; then
        log_error "❌ No se detectó pkg. Este módulo requiere ejecutarse dentro de Termux."
        exit 1
    fi
}

fix_termux_mirrors() {
    log_section "🔧 Ajustando mirrors y fuentes de Termux…"

    # Limpiar caché problemático primero
    rm -rf "$PREFIX/var/lib/apt/lists"/* 2>/dev/null || true
    mkdir -p "$PREFIX/var/lib/apt/lists/partial" 2>/dev/null || true

    # Detectar si usamos mirrors antiguos o problemáticos
    if [[ -f "$PREFIX/etc/apt/sources.list" ]]; then
        if grep -q "bintray\|mirrors.tuna\|mirror.termux" "$PREFIX/etc/apt/sources.list" 2>/dev/null; then
            log_warn "⚠️ Detectados mirrors problemáticos, aplicando configuración actualizada."
            # Forzar configuración limpia
            cat > "$PREFIX/etc/apt/sources.list" <<'EOF'
deb https://packages-cf.termux.dev/apt/termux-main stable main
EOF
        fi
    fi

    # Instalar termux-tools primero (crítico)
    log_info "📦 Asegurando termux-tools actualizado..."
    pkg install -y termux-tools 2>/dev/null || {
        apt-get install -y termux-tools 2>/dev/null || true
    }

    # Intentar usar termux-change-repo si está disponible
    if command -v termux-change-repo >/dev/null 2>&1; then
        log_info "🔄 Configurando mirrors optimizados..."
        # Seleccionar mirror automático (opción 1) y main repo (opción 1)
        if ! printf '1\n1\n' | termux-change-repo >/dev/null 2>&1; then
            log_warn "⚠️ Fallback a configuración manual de mirrors."
            # Usar Cloudflare mirror como fallback (más confiable)
            cat > "$PREFIX/etc/apt/sources.list" <<'EOF'
deb https://packages-cf.termux.dev/apt/termux-main stable main
EOF
        fi
    else
        log_info "🔄 Configurando mirror Cloudflare (más confiable)..."
        cat > "$PREFIX/etc/apt/sources.list" <<'EOF'
deb https://packages-cf.termux.dev/apt/termux-main stable main
EOF
    fi

    # Configuración dpkg para evitar prompts
    mkdir -p "$PREFIX/etc/dpkg/dpkg.cfg.d"
    cat > "$PREFIX/etc/dpkg/dpkg.cfg.d/01_termux_ai" <<'EOF'
force-confnew
force-overwrite
force-confdef
EOF

    # Asegurar permisos correctos
    chmod 644 "$PREFIX/etc/apt/sources.list" 2>/dev/null || true
}

preconfigure_packages() {
    log_section "⚙️ Preconfigurando entorno para instalaciones no interactivas…"

    export DEBIAN_FRONTEND=noninteractive
    export APT_LISTCHANGES_FRONTEND=none
    export NEEDRESTART_MODE=a

    if [[ -f "$PREFIX/etc/ssl/openssl.cnf" && ! -f "$PREFIX/etc/ssl/openssl.cnf.termux-ai-backup" ]]; then
        cp "$PREFIX/etc/ssl/openssl.cnf" "$PREFIX/etc/ssl/openssl.cnf.termux-ai-backup" >/dev/null 2>&1 || true
    fi
}

update_repositories() {
    log_section "🔄 Actualizando repositorios con reintentos robustos…"

    local max_retries=5
    local retry=1
    local backoff=3

    while (( retry <= max_retries )); do
        log_info "🌐 Intento ${retry}/${max_retries} de actualización."

        # Limpiar caché en reintentos
        if (( retry > 1 )); then
            log_info "🧹 Limpiando caché para reintento..."
            rm -rf "$PREFIX/var/lib/apt/lists"/* 2>/dev/null || true
            mkdir -p "$PREFIX/var/lib/apt/lists/partial" 2>/dev/null || true

            # Verificar conectividad básica
            if ! ping -c 1 8.8.8.8 >/dev/null 2>&1; then
                log_warn "⚠️ Sin conectividad de red, esperando..."
                sleep 5
            fi
        fi

        # Intentar actualización con timeouts más largos
        if timeout 180 apt update -y \
            -o Acquire::Retries=3 \
            -o Acquire::http::Timeout=60 \
            -o Acquire::ftp::Timeout=60 \
            -o Acquire::https::Timeout=60 \
            -o Dpkg::Options::="--force-confnew" \
            -o Dpkg::Options::="--force-overwrite" \
            -o Dpkg::Options::="--force-confdef" 2>/dev/null; then
            log_success "✅ Repositorios actualizados exitosamente."
            return 0
        fi

        # Estrategias de recuperación por intento
        if (( retry < max_retries )); then
            case $retry in
                2)
                    log_info "🔄 Reintentando con mirrors alternativos..."
                    if command -v termux-change-repo >/dev/null 2>&1; then
                        printf '2\n1\n' | termux-change-repo >/dev/null 2>&1 || true
                    fi
                    ;;
                3)
                    log_info "� Usando mirror Cloudflare directo..."
                    cat > "$PREFIX/etc/apt/sources.list" <<'EOF'
deb https://packages-cf.termux.dev/apt/termux-main stable main
EOF
                    ;;
                4)
                    log_info "🔄 Fallback a mirror principal..."
                    cat > "$PREFIX/etc/apt/sources.list" <<'EOF'
deb https://packages.termux.dev/apt/termux-main stable main
EOF
                    ;;
            esac

            log_warn "⏳ Esperando ${backoff}s antes del siguiente intento..."
            sleep "$backoff"
            backoff=$(( backoff + 2 ))
        fi

        ((retry++))
    done

    # Diagnóstico final si todo falla
    log_warn "⚠️ No se pudieron actualizar repositorios tras ${max_retries} intentos."

    if command -v curl >/dev/null 2>&1; then
        log_info "🔍 Verificando conectividad..."
        local test_urls=(
            "https://packages.termux.dev/"
            "https://packages-cf.termux.dev/"
            "https://mirror.termux.dev/"
        )

        for url in "${test_urls[@]}"; do
            if curl -s --connect-timeout 10 --max-time 20 "$url" >/dev/null 2>&1; then
                log_info "✅ Conectividad OK con: $url"
                break
            else
                log_warn "❌ Sin acceso a: $url"
            fi
        done
    fi

    log_warn "� Continuando con caché existente..."
    return 0
}

upgrade_packages() {
    log_section "⬆️ Actualizando paquetes existentes…"

    if ! apt upgrade -y \
        -o Dpkg::Options::="--force-confnew" \
        -o Dpkg::Options::="--force-overwrite" \
        -o Dpkg::Options::="--force-confdef" \
        -o APT::Get::Assume-Yes=true >/dev/null 2>&1; then
        log_warn "⚠️ Algunas actualizaciones fallaron, se continuará con la instalación."
    fi
}

is_package_installed() {
    local package=$1

    # Verificar con dpkg primero
    if dpkg -s "$package" >/dev/null 2>&1; then
        return 0
    fi

    # Verificar si el comando está disponible (para algunos paquetes)
    case $package in
        "git"|"curl"|"wget"|"python"|"node"|"npm"|"zsh")
            if command -v "$package" >/dev/null 2>&1; then
                return 0
            fi
            ;;
        "nodejs-lts")
            if command -v "node" >/dev/null 2>&1; then
                return 0
            fi
            ;;
        "python-pip")
            if command -v "pip" >/dev/null 2>&1 || command -v "pip3" >/dev/null 2>&1; then
                return 0
            fi
            ;;
    esac

    return 1
}

package_available() {
    apt-cache show "$1" >/dev/null 2>&1 || apt show "$1" >/dev/null 2>&1
}

install_package_with_retry() {
    local package=$1
    local max_retries=3
    local attempt=1

    if is_package_installed "$package"; then
        log_success "✅ ${package} ya está instalado."
        return 0
    fi

    if ! package_available "$package"; then
        log_error "❌ ${package} no está disponible en el repositorio actual."
        return 1
    fi

    log_info "📦 Instalando ${package}…"
    while (( attempt <= max_retries )); do
        # Limpiar problemas de dependencias antes de cada intento
        apt --fix-broken install -y >/dev/null 2>&1 || true
        dpkg --configure -a >/dev/null 2>&1 || true

        # Instalación con configuración robusta
        if timeout 300 apt install -y \
            -o Dpkg::Options::="--force-confnew" \
            -o Dpkg::Options::="--force-overwrite" \
            -o Dpkg::Options::="--force-confdef" \
            -o APT::Get::Assume-Yes=true \
            -o APT::Get::Fix-Broken=true \
            -o APT::Get::Fix-Missing=true \
            -o Acquire::Retries=3 \
            -o Acquire::http::Timeout=90 \
            -o Acquire::https::Timeout=90 \
            "$package" >/dev/null 2>&1; then

            # Verificación post-instalación
            if is_package_installed "$package"; then
                log_success "✅ ${package} instalado correctamente."
                return 0
            else
                log_warn "⚠️ ${package} reportó éxito pero la verificación falló."
            fi
        fi

        # Estrategias de recuperación por intento
        if (( attempt < max_retries )); then
            local wait=$(( attempt * 3 ))
            log_warn "⏳ Reintento ${attempt}/${max_retries} para ${package} en ${wait}s."

            # Limpiezas más agresivas en reintentos
            case $attempt in
                1)
                    apt-get clean >/dev/null 2>&1 || true
                    ;;
                2)
                    apt-get autoclean >/dev/null 2>&1 || true
                    apt --fix-broken install -y >/dev/null 2>&1 || true
                    ;;
            esac

            sleep "$wait"
        fi

        ((attempt++))
    done

    log_error "❌ No se pudo instalar ${package} tras ${max_retries} intentos."
    return 1
}

install_critical_packages_first() {
    log_section "⚡ Instalando paquetes críticos fundamentales primero..."

    local critical_packages=(
        "apt"
        "dpkg"
        "termux-tools"
        "ca-certificates"
        "curl"
        "wget"
    )

    for package in "${critical_packages[@]}"; do
        if ! is_package_installed "$package"; then
            log_info "🔧 Instalando crítico: ${package}"
            # Instalación ultra-simple para paquetes críticos
            pkg install -y "$package" 2>/dev/null || {
                apt-get install -y "$package" 2>/dev/null || {
                    log_warn "⚠️ No se pudo instalar $package, continuando..."
                }
            }
        else
            log_success "✅ Crítico ya presente: ${package}"
        fi
    done
}

install_essential_packages() {
    log_section "📋 Instalando ${#ESSENTIAL_PACKAGES[@]} paquetes esenciales…"

    local total=${#ESSENTIAL_PACKAGES[@]}
    local index=0

    for package in "${ESSENTIAL_PACKAGES[@]}"; do
        index=$(( index + 1 ))
        log_info "[${index}/${total}] ${package}"

        if install_package_with_retry "$package"; then
            INSTALLED_ESSENTIAL+=("$package")
        else
            FAILED_ESSENTIAL+=("$package")

            # Para paquetes críticos fallidos, intentar método alternativo
            case $package in
                "git"|"python"|"zsh"|"nodejs-lts")
                    log_warn "⚡ Reintentando paquete crítico $package con método alternativo..."
                    if pkg install -y "$package" 2>/dev/null; then
                        if is_package_installed "$package"; then
                            log_success "✅ $package instalado con método alternativo."
                            INSTALLED_ESSENTIAL+=("$package")
                            # Remover de fallidos
                            for i in "${!FAILED_ESSENTIAL[@]}"; do
                                if [[ "${FAILED_ESSENTIAL[i]}" == "$package" ]]; then
                                    unset "FAILED_ESSENTIAL[i]"
                                fi
                            done
                            FAILED_ESSENTIAL=("${FAILED_ESSENTIAL[@]}")  # Reindexar array
                        fi
                    fi
                    ;;
            esac
        fi
    done
}

install_optional_packages() {
    log_section "🎯 Instalando ${#OPTIONAL_PACKAGES[@]} paquetes opcionales…"

    local total=${#OPTIONAL_PACKAGES[@]}
    local index=0

    for package in "${OPTIONAL_PACKAGES[@]}"; do
        index=$(( index + 1 ))
        log_info "[${index}/${total}] ${package}"

        if install_package_with_retry "$package"; then
            INSTALLED_OPTIONAL+=("$package")
        else
            FAILED_OPTIONAL+=("$package")
        fi
    done
}

configure_git_identity() {
    log_section "⚙️ Configurando identidad de Git si es necesario…"

    if [[ "${TERMUX_AI_AUTO:-}" == "1" || "${TERMUX_AI_SILENT:-}" == "1" ]]; then
        if ! git config --global user.name >/dev/null 2>&1; then
            git config --global user.name "${TERMUX_AI_GIT_NAME:-Termux Developer}" >/dev/null 2>&1 || true
        fi

        if ! git config --global user.email >/dev/null 2>&1; then
            git config --global user.email "${TERMUX_AI_GIT_EMAIL:-dev@termux.local}" >/dev/null 2>&1 || true
        fi
    fi
}

configure_aliases() {
    log_section "🔧 Configurando aliases de conveniencia…"

    local aliases_file="$HOME/.bash_aliases"

    cat > "$aliases_file" <<'EOF'
# Aliases de Termux AI
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline'
alias gd='git diff'
if command -v bat >/dev/null 2>&1; then alias cat='bat'; fi
if command -v eza >/dev/null 2>&1; then alias ls='eza --icons'; elif command -v exa >/dev/null 2>&1; then alias ls='exa --icons'; fi
if command -v eza >/dev/null 2>&1; then alias exa='eza'; fi
if command -v fd >/dev/null 2>&1; then alias find='fd'; fi
if command -v zoxide >/dev/null 2>&1; then alias cd='z'; fi
alias apt='pkg'
alias python='python3'
alias pip='pip3'
EOF

    if [[ -f "$HOME/.bashrc" ]]; then
        if ! grep -Fq 'source ~/.bash_aliases' "$HOME/.bashrc"; then
            echo "source ~/.bash_aliases" >> "$HOME/.bashrc"
        fi
    else
        echo "source ~/.bash_aliases" > "$HOME/.bashrc"
    fi
}

ensure_npm_prefix() {
    local expected_prefix="${HOME}/.npm-global"
    local current_prefix

    current_prefix=$(npm config get prefix 2>/dev/null || echo "")
    if [[ -z "$current_prefix" || "$current_prefix" == "null" ]]; then
        current_prefix=""
    fi

    if [[ "$current_prefix" != "$expected_prefix" ]]; then
        log_info "🛠️ Configurando prefix global de npm en ${expected_prefix}."
        mkdir -p "$expected_prefix"
        npm config set prefix "$expected_prefix" >/dev/null 2>&1 || log_warn "⚠️ No se pudo establecer el prefix global de npm."
    fi

    local path_entry="export PATH=\"$HOME/.npm-global/bin:$PATH\""

    if [[ -f "$HOME/.bashrc" ]]; then
        if ! grep -Fq "$path_entry" "$HOME/.bashrc"; then
            echo "$path_entry" >> "$HOME/.bashrc"
        fi
    else
        echo "$path_entry" > "$HOME/.bashrc"
    fi
}

ensure_directories_and_path() {
    log_section "📁 Asegurando estructura de directorios y PATH…"

    mkdir -p "$HOME/bin" "$HOME/dev" "$HOME/.config"

    if command -v npm >/dev/null 2>&1; then
        ensure_npm_prefix
    fi
}

generate_summary() {
    log_section "📊 Resumen de instalación"

    log_success "Esenciales ok: ${#INSTALLED_ESSENTIAL[@]} / ${#ESSENTIAL_PACKAGES[@]}"
    if (( ${#FAILED_ESSENTIAL[@]} )); then
        log_error "Esenciales fallidos: ${FAILED_ESSENTIAL[*]}"
    fi

    log_success "Opcionales ok: ${#INSTALLED_OPTIONAL[@]} / ${#OPTIONAL_PACKAGES[@]}"
    if (( ${#FAILED_OPTIONAL[@]} )); then
        log_warn "Opcionales omitidos: ${FAILED_OPTIONAL[*]}"
    fi
}

verify_critical_tools() {
    local tools=(git curl python node npm pkg)
    MISSING_CRITICAL=()

    for tool in "${tools[@]}"; do
        if ! command -v "$tool" >/dev/null 2>&1; then
            MISSING_CRITICAL+=("$tool")
        fi
    done
}

finalize() {
    generate_summary
    verify_critical_tools

    if (( ${#MISSING_CRITICAL[@]} == 0 )) && (( ${#FAILED_ESSENTIAL[@]} == 0 )); then
        log_success "🎉 Instalación completada correctamente. Todas las herramientas críticas disponibles."
        touch "$MODULE_MARKER" >/dev/null 2>&1 || true
        record_module_state "completed" 0
        trap - ERR
        exit 0
    elif (( ${#MISSING_CRITICAL[@]} == 0 )); then
        log_warn "⚠️ Instalación completada con fallos en paquetes opcionales."
        touch "$MODULE_MARKER" >/dev/null 2>&1 || true
        record_module_state "completed" 0
        trap - ERR
        exit 0
    else
        log_error "❌ Faltan herramientas críticas: ${MISSING_CRITICAL[*]}"
        log_warn "💡 Reejecuta el módulo para reintentar la instalación."
        record_module_state "partial" 1
        trap - ERR
        exit 1
    fi
}

main() {
    log_section "📦 Iniciando instalación robusta de paquetes base…"

    ensure_state_dir
    check_previous_run
    assert_termux_environment

    # Paso 1: Instalar críticos primero
    install_critical_packages_first

    # Paso 2: Configurar mirrors
    fix_termux_mirrors
    preconfigure_packages

    # Paso 3: Actualizar repos
    update_repositories
    upgrade_packages

    # Paso 4: Instalar paquetes principales
    install_essential_packages
    install_optional_packages

    # Paso 5: Configuraciones finales
    configure_git_identity
    configure_aliases
    ensure_directories_and_path

    finalize
}

main "$@"

