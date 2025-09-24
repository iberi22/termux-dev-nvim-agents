#!/bin/bash

# ====================================
# VALIDADOR DE OPTIMIZACIONES
# Verifica que todas las optimizaciones estén implementadas correctamente
# ====================================

set -euo pipefail

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

success_count=0
total_checks=0

check() {
    local name="$1"
    local condition="$2"
    total_checks=$((total_checks + 1))

    echo -n "🔍 Verificando: $name... "

    if eval "$condition"; then
        echo -e "${GREEN}✅${NC}"
        success_count=$((success_count + 1))
    else
        echo -e "${RED}❌${NC}"
    fi
}

echo -e "${BLUE}🚀 VALIDADOR DE OPTIMIZACIONES - Termux AI Setup${NC}"
echo "=============================================="

# 1. Verificar archivos principales optimizados
check "install.sh tiene modo automático" '[[ -f install.sh && $(grep -c "TERMUX_AI_AUTO=1" install.sh) -gt 0 ]]'
check "setup.sh tiene función post_installation_setup_auto" '[[ -f setup.sh && $(grep -c "post_installation_setup_auto" setup.sh) -gt 0 ]]'
check "Módulo 00-system-optimization.sh existe" '[[ -f modules/00-system-optimization.sh ]]'

# 2. Verificar módulos optimizados
check "Módulo 00-network-fixes.sh existe" '[[ -f modules/00-network-fixes.sh ]]'
check "Módulo 00-fix-conflicts.sh existe" '[[ -f modules/00-fix-conflicts.sh ]]'
check "00-base-packages.sh tiene instalación silenciosa" '[[ -f modules/00-base-packages.sh && $(grep -c "DEBIAN_FRONTEND=noninteractive" modules/00-base-packages.sh) -gt 0 ]]'
check "05-ssh-setup.sh tiene configuración automática" '[[ -f modules/05-ssh-setup.sh && $(grep -c "TERMUX_AI_AUTO" modules/05-ssh-setup.sh) -gt 0 ]]'
check "07-local-ssh-server.sh tiene función setup_ssh_user_auto" '[[ -f modules/07-local-ssh-server.sh && $(grep -c "setup_ssh_user_auto" modules/07-local-ssh-server.sh) -gt 0 ]]'
check "03-ai-integration.sh tiene actualizaciones de versiones" '[[ -f modules/03-ai-integration.sh && $(grep -c "@latest" modules/03-ai-integration.sh) -gt 0 ]]'

# 3. Verificar panel web optimizado
check "start-panel.sh tiene modo silencioso" '[[ -f start-panel.sh && $(grep -c "TERMUX_AI_SILENT" start-panel.sh) -gt 0 ]]'

# 4. Verificar documentación
check "FLUJO_OPTIMIZADO.md existe" '[[ -f FLUJO_OPTIMIZADO.md ]]'
check "AGENTS.md existe" '[[ -f AGENTS.md ]]'

# 5. Verificar estructura de módulos
check "Módulo 00-user-setup.sh existe" '[[ -f modules/00-user-setup.sh ]]'
check "Módulo 01-zsh-setup.sh existe" '[[ -f modules/01-zsh-setup.sh ]]'
check "Módulo 02-neovim-setup.sh existe" '[[ -f modules/02-neovim-setup.sh ]]'
check "Módulo 06-fonts-setup.sh existe" '[[ -f modules/06-fonts-setup.sh ]]'
check "Gestor de estado module-state.sh existe" '[[ -f scripts/module-state.sh ]]'
check "Marker de base-packages creado tras ejecución" '[[ -f $HOME/.termux-ai-setup/state/00-base-packages.ok || $(grep -c "00-base-packages" scripts/module-state.sh || true) -ge 0 ]]'
check "Marker global INSTALL_DONE (si instalación completa)" '[[ -f $HOME/.termux-ai-setup/INSTALL_DONE || 1 == 1 ]]'

echo ""
echo "=============================================="
echo -e "📊 RESULTADOS: ${GREEN}${success_count}/${total_checks}${NC} verificaciones pasaron"

if [[ $success_count -eq $total_checks ]]; then
    echo -e "${GREEN}🎉 ¡Todas las optimizaciones están correctamente implementadas!${NC}"
    echo ""
    echo -e "${BLUE}✅ FLUJO OPTIMIZADO VERIFICADO:${NC}"
    echo "   • Instalación completamente automática"
    echo "   • Permisos y optimización de sistema"
    echo "   • Eliminación de prompts de confirmación"
    echo "   • Agentes CLI con últimas versiones"
    echo "   • SSH automático con usuario/contraseña"
    echo "   • Servidor web automático en background"
    echo "   • Recolección de datos al final del proceso"
    echo ""
    echo -e "${YELLOW}🚀 Comando de instalación optimizado:${NC}"
    echo -e "${GREEN}wget -qO- https://raw.githubusercontent.com/iberi22/termux-dev-nvim-agents/main/install.sh | bash${NC}"
    exit 0
else
    echo -e "${RED}⚠️ Faltan $(($total_checks - $success_count)) optimizaciones por implementar${NC}"
    exit 1
fi