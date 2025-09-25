#!/bin/bash

# ====================================
# Configuración Final de Zsh Rastafari
# Aplica la configuración completa modular
# ====================================

set -euo pipefail

# Colores para salida
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${BLUE}🔧 Aplicando configuración final de Zsh Rastafari...${NC}"

# Verificar que los archivos modulares existen
CONFIG_DIR="$HOME/.config/zsh"
REQUIRED_FILES=(
    "aliases.zsh"
    "functions.zsh"
    "yazi-integration.zsh"
    "p10k-config.zsh"
    "main-zshrc.template"
)

echo -e "${YELLOW}Verificando archivos de configuración modular...${NC}"
for file in "${REQUIRED_FILES[@]}"; do
    if [[ -f "$CONFIG_DIR/$file" ]]; then
        echo -e "${GREEN}✅ $file encontrado${NC}"
    else
        echo -e "${RED}❌ $file no encontrado en $CONFIG_DIR${NC}"
        exit 1
    fi
done

# Crear directorio de configuración si no existe
mkdir -p "$CONFIG_DIR"

# Aplicar configuración del .zshrc
echo -e "${YELLOW}Aplicando configuración del .zshrc...${NC}"

# Backup del .zshrc existente
if [[ -f "$HOME/.zshrc" ]]; then
    cp "$HOME/.zshrc" "$HOME/.zshrc.backup.$(date +%Y%m%d_%H%M%S)"
    echo -e "${BLUE}📄 Backup de .zshrc creado${NC}"
fi

# Copiar template como .zshrc
cp "$CONFIG_DIR/main-zshrc.template" "$HOME/.zshrc"
echo -e "${GREEN}✅ .zshrc configurado${NC}"

# Copiar configuración de Powerlevel10k
if [[ -f "$CONFIG_DIR/p10k-config.zsh" ]]; then
    cp "$CONFIG_DIR/p10k-config.zsh" "$HOME/.p10k.zsh"
    echo -e "${GREEN}✅ Powerlevel10k configurado${NC}"
fi

# Configurar fuentes para Powerlevel10k
echo -e "${YELLOW}Configurando fuentes para Powerlevel10k...${NC}"
mkdir -p "$HOME/.termux"

cat > "$HOME/.termux/termux.properties" << 'EOF'
# Termux properties for AI development
use-fullscreen=true
fullscreen=false

# Font configuration for Powerlevel10k
extra-keys = [['ESC','/','-','HOME','UP','END','PGUP'],['TAB','CTRL','ALT','LEFT','DOWN','RIGHT','PGDN']]

# Terminal colors and behavior
terminal-margin-left=0
terminal-margin-right=0
terminal-margin-top=0
terminal-margin-bottom=0
terminal-onclick-url-open=true
clipboard-autocopy=true

# Cursor
terminal-cursor-blink-rate=0
EOF

# Recargar configuración de Termux
termux-reload-settings 2>/dev/null || true

# Configurar Zsh como shell por defecto
echo -e "${YELLOW}Configurando Zsh como shell por defecto...${NC}"

if ! grep -q "exec zsh" "$HOME/.bashrc" 2>/dev/null; then
    {
        echo ""
        echo "# Auto-start Zsh"
        echo "if [ -x /data/data/com.termux/files/usr/bin/zsh ]; then"
        echo "    export SHELL=/data/data/com.termux/files/usr/bin/zsh"
        echo "    exec zsh"
        echo "fi"
    } >> "$HOME/.bashrc"
fi

echo -e "\n${GREEN}🎉 Configuración final aplicada exitosamente!${NC}"
echo -e "${YELLOW}Reinicia la terminal para ver los cambios.${NC}"
echo -e "${CYAN}El tema Rastafari con métricas de sistema estará activo.${NC}"