#!/bin/bash

# =================================================================
# MODULE: 03-AI-INTEGRATION
#
# Installs the AI / developer CLIs supported by this project.
#
# Supported component keys:
#
#   claude    -> @anthropic-ai/claude-code    (binary: claude)
#   opencode  -> opencode-ai                  (binary: opencode)
#   codex     -> @openai/codex                (binary: codex)
#   wrangler  -> wrangler                     (binary: wrangler)
#   agy       -> Google Antigravity           (binary: agy, no npm package)
#
# Component selection is read from TERMUX_AI_COMPONENTS (comma or space
# separated). When unset, empty or 'all', every npm-based CLI is
# installed. The interactive menu in setup.sh exports this variable, so
# nothing is prompted for here.
#
# Every installer is idempotent: when the binary already exists it is
# reported with its version and left untouched.
# =================================================================

# --- Source Helper Functions ---
# shellcheck disable=SC1091
source "$(dirname "$0")/../scripts/helpers.sh"

# --- Component tables ---

# npm-backed CLIs, in install order.
ALL_NPM_COMPONENTS=("claude" "opencode" "codex" "wrangler")

# Components that cannot be installed through npm.
MANUAL_COMPONENTS=("agy")

# Every supported component, in the order shown in the summary table.
ALL_COMPONENTS=("claude" "opencode" "codex" "wrangler" "agy")

# Download page for components that require a manual install.
AGY_DOWNLOAD_URL="https://antigravity.google"

# Selection and reporting state.
SELECTED_COMPONENTS=()
declare -A COMPONENT_STATUS=()
declare -A COMPONENT_VERSION=()

# --- Component metadata ---

# Maps a component key to its npm package name.
npm_package_for() {
    case "$1" in
        claude) printf '%s\n' "@anthropic-ai/claude-code" ;;
        opencode) printf '%s\n' "opencode-ai" ;;
        codex) printf '%s\n' "@openai/codex" ;;
        wrangler) printf '%s\n' "wrangler" ;;
        *) return 1 ;;
    esac
}

# Maps a component key to the binary it exposes (the key is the binary).
binary_for() {
    case "$1" in
        claude | opencode | codex | wrangler | agy) printf '%s\n' "$1" ;;
        *) return 1 ;;
    esac
}

# Prints the first line of '<binary> --version', or '-' when unavailable.
capture_version() {
    local bin="$1"
    local out
    out="$("$bin" --version 2>/dev/null | head -n 1 || true)"
    printf '%s\n' "${out:--}"
}

# --- Selection handling ---

# Appends a component key to SELECTED_COMPONENTS unless already present.
add_component() {
    local candidate="$1"
    local existing
    for existing in "${SELECTED_COMPONENTS[@]}"; do
        if [[ "$existing" == "$candidate" ]]; then
            return 0
        fi
    done
    SELECTED_COMPONENTS+=("$candidate")
}

# Populates SELECTED_COMPONENTS from TERMUX_AI_COMPONENTS.
select_components() {
    local raw="${TERMUX_AI_COMPONENTS:-all}"
    raw="${raw//,/ }"

    if [[ -z "${raw// /}" || "${raw// /}" == "all" ]]; then
        log_info "Sin selección explícita: se instalarán todos los CLIs disponibles."
        local comp
        for comp in "${ALL_COMPONENTS[@]}"; do
            add_component "$comp"
        done
        return 0
    fi

    local -a requested=()
    # IFS is restricted for this read only; setup.sh sets a newline/tab IFS.
    IFS=' ,' read -r -a requested <<<"$raw" || true

    local item
    for item in "${requested[@]}"; do
        case "$item" in
            '')
                continue
                ;;
            all)
                local comp
                for comp in "${ALL_COMPONENTS[@]}"; do
                    add_component "$comp"
                done
                ;;
            claude | opencode | codex | wrangler | agy)
                add_component "$item"
                ;;
            *)
                log_warn "Componente desconocido '${item}': se ignora."
                log_warn "Valores válidos: ${ALL_COMPONENTS[*]// /, }."
                ;;
        esac
    done
}

# --- npm guard ---

# Verifies npm exists. Logs actionable guidance when it does not.
require_npm() {
    local comp="$1"
    if command -v npm >/dev/null 2>&1; then
        return 0
    fi
    log_error "npm no está disponible: no se puede instalar '${comp}'."
    log_error "Ejecuta primero el módulo '00-base-packages' (instala Node.js y npm)."
    return 1
}

# Reusable installer for the npm-backed CLIs.
install_npm_cli() {
    local comp="$1"
    local bin pkg version

    bin="$(binary_for "$comp")"
    pkg="$(npm_package_for "$comp")"

    # Idempotency: an existing binary is never reinstalled.
    if command -v "$bin" >/dev/null 2>&1; then
        version="$(capture_version "$bin")"
        log_success "${comp} ya está instalado (${version}). Se omite la reinstalación."
        COMPONENT_STATUS["$comp"]="installed"
        COMPONENT_VERSION["$comp"]="$version"
        return 0
    fi

    if ! require_npm "$comp"; then
        COMPONENT_STATUS["$comp"]="skipped"
        COMPONENT_VERSION["$comp"]="-"
        return 1
    fi

    log_info "Instalando ${pkg} (${comp}) desde npm..."
    if ! npm install -g "$pkg"; then
        log_error "Falló la instalación de ${comp} (${pkg})."
        log_warn "Revisa la conexión a internet y vuelve a ejecutar el módulo."
        COMPONENT_STATUS["$comp"]="skipped"
        COMPONENT_VERSION["$comp"]="-"
        return 1
    fi

    if command -v "$bin" >/dev/null 2>&1; then
        version="$(capture_version "$bin")"
        log_success "${comp} instalado correctamente (${version})."
    else
        version="instalado (binario fuera del PATH)"
        log_warn "${comp} se instaló pero '${bin}' no aparece en el PATH actual."
        log_warn "Añade el prefijo global de npm al PATH y reinicia la shell."
    fi

    COMPONENT_STATUS["$comp"]="installed"
    COMPONENT_VERSION["$comp"]="$version"
    return 0
}

# --- One installer per CLI ---

# Anthropic Claude Code.
install_claude() {
    install_npm_cli "claude"
}

# OpenCode (provider-agnostic agent).
install_opencode() {
    install_npm_cli "opencode"
}

# OpenAI Codex.
install_codex() {
    install_npm_cli "codex"
}

# Cloudflare Wrangler (developer CLI, not an agent).
install_wrangler() {
    install_npm_cli "wrangler"
}

# Google Antigravity. Has no npm package, so it is reported as a manual
# install and never fails the module.
install_agy() {
    local version

    if command -v agy >/dev/null 2>&1; then
        version="$(capture_version "agy")"
        log_success "agy ya está instalado (${version})."
        COMPONENT_STATUS["agy"]="installed"
        COMPONENT_VERSION["agy"]="$version"
        return 0
    fi

    log_warn "agy (Google Antigravity) no se distribuye por npm."
    log_warn "Descárgalo e instálalo manualmente desde: ${AGY_DOWNLOAD_URL}"
    COMPONENT_STATUS["agy"]="manual"
    COMPONENT_VERSION["agy"]="requiere instalación manual"
    return 0
}

# --- Dispatcher ---

install_component() {
    local comp="$1"
    case "$comp" in
        claude) install_claude ;;
        opencode) install_opencode ;;
        codex) install_codex ;;
        wrangler) install_wrangler ;;
        agy) install_agy ;;
        *)
            log_warn "Componente no soportado: '${comp}'."
            return 0
            ;;
    esac
}

# --- Reporting ---

# Prints the component / status / version summary table.
print_summary() {
    local comp status version

    log_info "---------------------------------------------------------------"
    log_info " Resumen de CLIs de IA"
    log_info "---------------------------------------------------------------"
    printf '%-10s %-10s %s\n' "COMPONENTE" "ESTADO" "VERSIÓN" >&2
    printf '%-10s %-10s %s\n' "----------" "------" "-------" >&2
    for comp in "${ALL_COMPONENTS[@]}"; do
        status="${COMPONENT_STATUS[$comp]:-skipped}"
        version="${COMPONENT_VERSION[$comp]:--}"
        printf '%-10s %-10s %s\n' "$comp" "$status" "$version" >&2
    done
    log_info "---------------------------------------------------------------"
}

# --- Main Function ---
main() {
    log_info "=== Iniciando Módulo: Integración de CLIs de IA ==="

    select_components

    if ((${#SELECTED_COMPONENTS[@]} == 0)); then
        log_warn "No se seleccionó ningún CLI de IA. Nada que instalar."
        print_summary
        log_info "=== Módulo de Integración de IA Completado ==="
        return 0
    fi

    log_info "Componentes seleccionados: ${SELECTED_COMPONENTS[*]// /, }"

    # Termux guard for node-gyp based native builds.
    export GYP_DEFINES="android_ndk_path=/dev/null"
    export npm_config_build_from_source=true

    local comp
    local failures=0
    for comp in "${SELECTED_COMPONENTS[@]}"; do
        log_info "---------------------------------------------"
        log_info "Instalando componente: ${comp}"
        log_info "---------------------------------------------"
        if ! install_component "$comp"; then
            failures=$((failures + 1))
        fi
    done

    print_summary

    if ((failures > 0)); then
        log_error "${failures} componente(s) no se pudieron instalar."
        log_warn "'agy' no cuenta como fallo: requiere descarga manual."
        log_info "=== Módulo de Integración de IA completado con errores ==="
        return 1
    fi

    if ! command -v agy >/dev/null 2>&1; then
        log_warn "Recordatorio: instala 'agy' manualmente desde ${AGY_DOWNLOAD_URL}"
    fi

    log_info "=== Módulo de Integración de IA Completado ==="
    return 0
}

# --- Execute Main Function ---
main
