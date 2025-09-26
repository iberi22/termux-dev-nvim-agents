#!/usr/bin/env bash
# Script simple para actualizar versión manualmente
# Uso: ./scripts/update-version-manual.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Obtener fecha y hash actual
CURRENT_DATE=$(date +%Y-%m-%d)
COMMIT_HASH=$(git log --format="%h" -n 1 2>/dev/null || echo "unknown")
NEW_VERSION="${CURRENT_DATE}.${COMMIT_HASH}"

echo "🔄 Actualizando versión a: v${NEW_VERSION}"

# Actualizar install.sh
sed -i.bak "s/SCRIPT_VERSION=\"[^\"]*\"/SCRIPT_VERSION=\"${NEW_VERSION}\"/" "$PROJECT_ROOT/install.sh"

# Actualizar README.md
sed -i.bak "s/v[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}\.[a-f0-9]\{7\}/v${NEW_VERSION}/" "$PROJECT_ROOT/README.md"

# Limpiar archivos backup
rm -f "$PROJECT_ROOT/install.sh.bak" "$PROJECT_ROOT/README.md.bak"

echo "✅ Versión actualizada exitosamente a v${NEW_VERSION}"
echo "📋 Archivos actualizados:"
echo "   - install.sh"
echo "   - README.md"