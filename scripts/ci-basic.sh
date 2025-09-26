#!/bin/bash

# =================================================================
# CI BÁSICO - Verificaciones esenciales sin herramientas externas
#
# Ejecuta solo las verificaciones que no requieren herramientas
# especiales, ideal para entornos con permisos limitados (WSL)
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

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; ERRORS=$((ERRORS + 1)); }

# Convertir line endings a LF
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

# Verificar bits ejecutables
check_executable_bits() {
    log_info "Verificando bits ejecutables en scripts..."
    find "$PROJECT_ROOT" -name "*.sh" -type f -not -executable 2>/dev/null | while read -r file; do
        log_warn "Archivo sin bit ejecutable: $file"
    done
    log_success "Verificación de bits ejecutables completada"
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
    done < <(find "$PROJECT_ROOT" -name "*.sh" -type f -print0)

    if [[ $failed -eq 0 ]]; then
        log_success "Todas las verificaciones de sintaxis bash pasaron"
    else
        log_error "Algunas verificaciones de sintaxis bash fallaron"
    fi

    return $failed
}

# Ejecutar pruebas smoke
run_smoke_tests() {
    log_info "Ejecutando pruebas smoke..."
    if [[ -f "$PROJECT_ROOT/tests/smoke.sh" ]]; then
        if bash "$PROJECT_ROOT/tests/smoke.sh"; then
            log_success "Pruebas smoke pasaron"
        else
            log_error "Pruebas smoke fallaron"
            return 1
        fi
    else
        log_warn "Archivo smoke.sh no encontrado"
        return 1
    fi
}

# Función principal
main() {
    log_info "=== CI BÁSICO para termux-dev-nvim-agents ==="
    log_info "Directorio del proyecto: $PROJECT_ROOT"
    log_info "Solo ejecutando verificaciones esenciales (sin herramientas externas)"

    cd "$PROJECT_ROOT"

    # Ejecutar verificaciones básicas
    convert_line_endings
    check_executable_bits
    bash_syntax_check
    run_smoke_tests

    # Resumen final
    if [[ $ERRORS -eq 0 ]]; then
        log_success "=== ✅ VERIFICACIONES BÁSICAS COMPLETADAS ✅ ==="
        log_info "🚀 Tu código está listo para commit!"
        log_info "💡 Para verificaciones completas instala: shellcheck, shfmt, bats"
        exit 0
    else
        log_error "=== ❌ $ERRORS ERRORES ENCONTRADOS ❌ ==="
        log_info "🔍 Revisa los errores y corrígelos antes del commit"
        exit 1
    fi
}

# Ejecutar función principal
main "$@"