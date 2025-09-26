#!/bin/bash

# =================================================================
# CI LOCAL SCRIPT - Replica GitHub Actions CI localmente
#
# Este script ejecuta las mismas verificaciones que GitHub Actions:
# - Verificación de sintaxis bash
# - Shellcheck
# - Pruebas Bats
# - Verificaciones de formato con shfmt
# - Validaciones de metadatos
# =================================================================

set -euo pipefail

# Colores para output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

# Variables
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
ERRORS=0

# Modo básico si no se pueden instalar herramientas (WSL con permisos limitados)
BASIC_MODE="${CI_LOCAL_BASIC_MODE:-false}"

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; ERRORS=$((ERRORS + 1)); }

# Función para verificar que una herramienta esté disponible
check_tool() {
    local tool="$1"
    local install_cmd="${2:-}"
    
    if ! command -v "$tool" &> /dev/null; then
        if [[ -n "$install_cmd" ]]; then
            log_warn "$tool no encontrado. Intentando instalar..."
            if eval "$install_cmd"; then
                log_success "$tool instalado exitosamente"
            else
                log_error "Falló la instalación de $tool"
                return 1
            fi
        else
            log_error "$tool no está disponible. Por favor instálalo manualmente."
            return 1
        fi
    else
        log_info "$tool está disponible"
    fi
}

# Instalar herramientas necesarias
install_tools() {
    log_info "Verificando e instalando herramientas necesarias..."
    
    # Detectar el sistema operativo y gestor de paquetes
    if command -v apt &> /dev/null; then
        # Debian/Ubuntu/Termux
        check_tool "shellcheck" "apt update && apt install -y shellcheck"
        check_tool "shfmt" "apt install -y shfmt || { log_warn 'shfmt no disponible via apt, continuando...'; }"
        check_tool "bats" "apt install -y bats || { log_warn 'Instalando bats manualmente...'; install_bats_manual; }"
    elif command -v brew &> /dev/null; then
        # macOS
        check_tool "shellcheck" "brew install shellcheck"
        check_tool "shfmt" "brew install shfmt"
        check_tool "bats-core" "brew install bats-core"
    elif command -v chocolatey &> /dev/null || command -v choco &> /dev/null; then
        # Windows con Chocolatey
        check_tool "shellcheck" "choco install shellcheck"
        check_tool "shfmt" "{ log_warn 'shfmt no disponible via choco'; }"
        install_bats_manual
    else
        log_warn "Gestor de paquetes no detectado. Por favor instala manualmente:"
        log_warn "- shellcheck: https://github.com/koalaman/shellcheck"
        log_warn "- shfmt: https://github.com/mvdan/sh"
        log_warn "- bats: https://github.com/bats-core/bats-core"
    fi
}

# Instalar bats manualmente si no está disponible
install_bats_manual() {
    if ! command -v bats &> /dev/null; then
        log_info "Instalando bats manualmente..."
        local bats_dir="/tmp/bats-core"
        if [[ -d "$bats_dir" ]]; then
            rm -rf "$bats_dir"
        fi
        git clone https://github.com/bats-core/bats-core.git "$bats_dir"
        cd "$bats_dir"
        ./install.sh /usr/local
        cd "$PROJECT_ROOT"
        rm -rf "$bats_dir"
        log_success "bats instalado manualmente"
    fi
}

# Convertir line endings a LF (como hace el CI)
convert_line_endings() {
    log_info "Convirtiendo line endings a LF..."
    find "$PROJECT_ROOT" -type f \( -name "*.sh" -o -name "*.bats" \) -print0 | while IFS= read -r -d '' file; do
        if command -v dos2unix &> /dev/null; then
            dos2unix "$file" 2>/dev/null || true
        elif command -v sed &> /dev/null; then
            sed -i 's/\r$//' "$file" 2>/dev/null || true
        fi
    done
    log_success "Line endings convertidos"
}

# Verificación de sintaxis bash
bash_syntax_check() {
    log_info "Ejecutando verificación de sintaxis bash..."
    local failed=0
    
    while IFS= read -r -d '' file; do
        if ! bash -n "$file"; then
            log_error "Error de sintaxis en: $file"
            failed=1
        fi
    done < <(find "$PROJECT_ROOT" -name "*.sh" -print0)
    
    if [[ $failed -eq 0 ]]; then
        log_success "Todas las verificaciones de sintaxis bash pasaron"
    else
        log_error "Algunas verificaciones de sintaxis bash fallaron"
        return 1
    fi
}

# Ejecutar shellcheck
run_shellcheck() {
    log_info "Ejecutando shellcheck..."
    
    if ! command -v shellcheck &> /dev/null; then
        log_error "shellcheck no está disponible"
        return 1
    fi
    
    local failed=0
    while IFS= read -r -d '' file; do
        if ! shellcheck "$file"; then
            log_error "Shellcheck falló en: $file"
            failed=1
        fi
    done < <(find "$PROJECT_ROOT" -name "*.sh" -print0)
    
    if [[ $failed -eq 0 ]]; then
        log_success "Todas las verificaciones de shellcheck pasaron"
    else
        log_error "Algunas verificaciones de shellcheck fallaron"
        return 1
    fi
}

# Verificar formato con shfmt
check_format() {
    log_info "Verificando formato con shfmt..."
    
    if ! command -v shfmt &> /dev/null; then
        log_warn "shfmt no está disponible, omitiendo verificación de formato"
        return 0
    fi
    
    local failed=0
    while IFS= read -r -d '' file; do
        if ! shfmt -d -i 4 "$file"; then
            log_error "Formato incorrecto en: $file"
            failed=1
        fi
    done < <(find "$PROJECT_ROOT" -name "*.sh" -print0)
    
    if [[ $failed -eq 0 ]]; then
        log_success "Todas las verificaciones de formato pasaron"
    else
        log_error "Algunas verificaciones de formato fallaron"
        return 1
    fi
}

# Ejecutar pruebas smoke
run_smoke_tests() {
    log_info "Ejecutando pruebas smoke..."
    
    local smoke_script="$PROJECT_ROOT/tests/smoke.sh"
    if [[ -f "$smoke_script" ]]; then
        if bash "$smoke_script"; then
            log_success "Pruebas smoke pasaron"
        else
            log_error "Pruebas smoke fallaron"
            return 1
        fi
    else
        log_warn "Archivo de pruebas smoke no encontrado: $smoke_script"
    fi
}

# Ejecutar pruebas bats
run_bats_tests() {
    log_info "Ejecutando pruebas bats..."
    
    if ! command -v bats &> /dev/null; then
        log_error "bats no está disponible"
        return 1
    fi
    
    local bats_dir="$PROJECT_ROOT/tests/bats"
    if [[ -d "$bats_dir" ]]; then
        if bats "$bats_dir"/*.bats; then
            log_success "Todas las pruebas bats pasaron"
        else
            log_error "Algunas pruebas bats fallaron"
            return 1
        fi
    else
        log_warn "Directorio de pruebas bats no encontrado: $bats_dir"
    fi
}

# Verificar permisos ejecutables
check_executable_bits() {
    log_info "Verificando bits ejecutables en scripts..."
    
    local failed=0
    while IFS= read -r -d '' file; do
        if [[ ! -x "$file" ]]; then
            log_warn "Agregando bit ejecutable a: $file"
            chmod +x "$file"
        fi
    done < <(find "$PROJECT_ROOT" -name "*.sh" -print0)
    
    log_success "Verificación de bits ejecutables completada"
}

# Función principal
main() {
    log_info "=== Iniciando CI Local para termux-dev-nvim-agents ==="
    log_info "Directorio del proyecto: $PROJECT_ROOT"
    
    cd "$PROJECT_ROOT"
    
    # Detectar automáticamente si necesitamos modo básico
    if [[ "$BASIC_MODE" == "false" ]]; then
        if ! command -v shellcheck &> /dev/null && ! command -v apt &> /dev/null && ! command -v yum &> /dev/null; then
            BASIC_MODE=true
            log_warn "Herramientas de análisis no disponibles. Ejecutando en modo básico."
        fi
    fi
    
    # Si no estamos en modo básico, instalar herramientas
    if [[ "$BASIC_MODE" == "false" ]]; then
        log_info "Verificando e instalando herramientas necesarias..."
        if ! install_tools; then
            log_warn "Falló la instalación de herramientas. Cambiando a modo básico."
            BASIC_MODE=true
        fi
    else
        log_info "Modo básico activado: solo verificaciones esenciales"
    fi
    
    # Ejecutar verificaciones
    convert_line_endings
    check_executable_bits
    
    # Verificaciones principales
    bash_syntax_check
    
    if [[ "$BASIC_MODE" == "false" ]]; then
        log_info "Ejecutando verificaciones completas..."
        run_shellcheck || true
        check_format || true
        run_bats_tests || true
    else
        log_info "Modo básico: solo sintaxis bash y pruebas smoke"
    fi
    
    # Las pruebas smoke siempre se ejecutan (no requieren herramientas especiales)
    run_smoke_tests
    
    # Resumen final
    if [[ $ERRORS -eq 0 ]]; then
        if [[ "$BASIC_MODE" == "true" ]]; then
            log_success "=== VERIFICACIONES BÁSICAS PASARON - LISTO PARA COMMIT ==="
            log_info "Para verificaciones completas, instala: shellcheck, shfmt, bats"
        else
            log_success "=== TODOS LOS CHECKS PASARON - CI LOCAL EXITOSO ==="
        fi
        exit 0
    else
        log_error "=== $ERRORS ERRORES ENCONTRADOS - CI LOCAL FALLÓ ==="
        log_info "Revisa los errores anteriores y corrígelos antes de hacer push"
        exit 1
    fi
}

# Manejo de argumentos
case "${1:-all}" in
    "install"|"setup")
        install_tools
        ;;
    "syntax")
        bash_syntax_check
        ;;
    "shellcheck")
        run_shellcheck
        ;;
    "format")
        check_format
        ;;
    "smoke")
        run_smoke_tests
        ;;
    "bats")
        run_bats_tests
        ;;
    "all"|*)
        main
        ;;
esac