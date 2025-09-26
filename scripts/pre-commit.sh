#!/usr/bin/env bash
# =================================================================
# PRE-COMMIT HOOK MEJORADO
#
# Ejecuta verificaciones completas antes de commit para asegurar
# que el código pase el CI de GitHub Actions
#
# Install: cp scripts/pre-commit.sh .git/hooks/pre-commit && chmod +x .git/hooks/pre-commit
# =================================================================

set -euo pipefail

# Get the directory of this script
HOOK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$HOOK_DIR")"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[PRE-COMMIT]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

log_info "Iniciando verificaciones pre-commit..."

# Get staged .sh files
STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACM | grep '\.sh$' || true)

if [[ -z "$STAGED_FILES" ]]; then
    log_success "No hay archivos .sh para verificar"
    exit 0
fi

cd "$PROJECT_ROOT"

log_info "Archivos a verificar: $STAGED_FILES"

# 1. Verificación de sintaxis bash
log_info "Verificando sintaxis bash..."
for file in $STAGED_FILES; do
    if [[ -f "$file" ]]; then
        if ! bash -n "$file"; then
            log_error "Error de sintaxis en: $file"
            exit 1
        fi
    fi
done
log_success "Sintaxis bash verificada"

# 2. ShellCheck
if command -v shellcheck &> /dev/null; then
    log_info "Ejecutando shellcheck..."
    if ! shellcheck $STAGED_FILES; then
        log_error "Shellcheck falló. Usa 'bash scripts/lint.sh' para más detalles"
        exit 1
    fi
    log_success "Shellcheck completado"
else
    log_warn "Shellcheck no disponible, omitiendo verificación"
fi

# 3. Verificación de line endings (si dos2unix está disponible)
if command -v dos2unix &> /dev/null; then
    log_info "Verificando line endings..."
    for file in $STAGED_FILES; do
        if [[ -f "$file" ]]; then
            dos2unix "$file" 2>/dev/null || true
        fi
    done
    log_success "Line endings verificados"
fi

# 4. Ejecutar CI local completo si está disponible
if [[ -f "$PROJECT_ROOT/scripts/ci-local.sh" ]]; then
    log_info "Ejecutando CI local completo..."
    if ! bash "$PROJECT_ROOT/scripts/ci-local.sh"; then
        log_error "CI local falló. Ejecuta manualmente: bash scripts/ci-local.sh"
        exit 1
    fi
    log_success "CI local completado"
else
    log_warn "CI local no disponible, solo verificaciones básicas"
fi

log_success "Todas las verificaciones pre-commit pasaron!"
log_info "Listo para commit con confianza 🚀"
