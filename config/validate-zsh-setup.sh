#!/bin/bash

# ====================================
# Validación de Configuración Zsh
# Verifica que todos los componentes estén correctamente instalados
# ====================================

set -euo pipefail

# Colores para salida
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${BLUE}🔍 Validando configuración de Zsh Rastafari...${NC}"

# Función para verificar comandos
check_command() {
    local cmd="$1"
    local desc="$2"
    if command -v "$cmd" >/dev/null 2>&1; then
        echo -e "${GREEN}✅ $desc instalado${NC}"
        return 0
    else
        echo -e "${RED}❌ $desc no encontrado${NC}"
        return 1
    fi
}

# Función para verificar archivos
check_file() {
    local file="$1"
    local desc="$2"
    if [[ -f "$file" ]]; then
        echo -e "${GREEN}✅ $desc encontrado${NC}"
        return 0
    else
        echo -e "${RED}❌ $desc no encontrado${NC}"
        return 1
    fi
}

# Función para verificar directorios
check_dir() {
    local dir="$1"
    local desc="$2"
    if [[ -d "$dir" ]]; then
        echo -e "${GREEN}✅ $desc encontrado${NC}"
        return 0
    else
        echo -e "${RED}❌ $desc no encontrado${NC}"
        return 1
    fi
}

echo -e "\n${YELLOW}Verificando componentes principales...${NC}"

# Verificar Zsh
check_command zsh "Zsh"

# Verificar Oh My Zsh
check_dir "$HOME/.oh-my-zsh" "Oh My Zsh"

# Verificar Powerlevel10k
check_dir "$HOME/.oh-my-zsh/custom/themes/powerlevel10k" "Powerlevel10k theme"

# Verificar Yazi
check_command yazi "Yazi file manager"

echo -e "\n${YELLOW}Verificando plugins de Zsh...${NC}"

# Plugins esenciales
PLUGINS=(
    "zsh-autosuggestions"
    "zsh-syntax-highlighting"
    "zsh-completions"
    "yazi"
)

for plugin in "${PLUGINS[@]}"; do
    check_dir "$HOME/.oh-my-zsh/custom/plugins/$plugin" "Plugin $plugin"
done

echo -e "\n${YELLOW}Verificando archivos de configuración...${NC}"

# Archivos de configuración
check_file "$HOME/.zshrc" ".zshrc"
check_file "$HOME/.p10k.zsh" ".p10k.zsh"

# Archivos modulares
CONFIG_DIR="$HOME/.config/zsh"
check_dir "$CONFIG_DIR" "Directorio de configuración modular"

MODULAR_FILES=(
    "aliases.zsh"
    "functions.zsh"
    "yazi-integration.zsh"
    "p10k-config.zsh"
    "main-zshrc.template"
)

for file in "${MODULAR_FILES[@]}"; do
    check_file "$CONFIG_DIR/$file" "Archivo modular $file"
done

echo -e "\n${YELLOW}Verificando herramientas opcionales...${NC}"

# Herramientas modernas (opcionales)
OPTIONAL_TOOLS=(
    "exa:exa"
    "bat:bat"
    "fd:fd"
    "rg:ripgrep"
    "fzf:fzf"
    "zoxide:zoxide"
    "dust:dust"
    "duf:duf"
    "procs:procs"
    "htop:htop"
)

for tool in "${OPTIONAL_TOOLS[@]}"; do
    IFS=':' read -r cmd desc <<< "$tool"
    check_command "$cmd" "$desc" || true  # No fallar si no están instaladas
done

echo -e "\n${YELLOW}Verificando configuración de IA...${NC}"

# Verificar configuración de IA
check_file "$HOME/.ai-env" "Archivo de configuración de IA (opcional)" || true

echo -e "\n${YELLOW}Probando funcionalidades...${NC}"

# Probar que Zsh puede cargar la configuración
if command -v zsh >/dev/null 2>&1; then
    echo -e "${BLUE}Probando carga de configuración Zsh...${NC}"
    if zsh -c "source ~/.zshrc && echo 'Configuración cargada correctamente'" 2>/dev/null; then
        echo -e "${GREEN}✅ Configuración Zsh carga correctamente${NC}"
    else
        echo -e "${RED}❌ Error al cargar configuración Zsh${NC}"
    fi
fi

# Verificar que el tema Rastafari funciona
if [[ -f "$HOME/.p10k.zsh" ]]; then
    echo -e "${BLUE}Verificando tema Powerlevel10k...${NC}"
    if grep -q "RASTAFARI RAINBOW STYLE" "$HOME/.p10k.zsh"; then
        echo -e "${GREEN}✅ Tema Rastafari configurado${NC}"
    else
        echo -e "${YELLOW}⚠️ Tema Powerlevel10k encontrado pero configuración Rastafari no verificada${NC}"
    fi
fi

echo -e "\n${PURPLE}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${PURPLE}║                🌈 VALIDACIÓN COMPLETADA 🌈                 ║${NC}"
echo -e "${PURPLE}╚══════════════════════════════════════════════════════════════╝${NC}"

echo -e "\n${CYAN}💡 Recomendaciones:${NC}"
echo -e "• Si faltan componentes, ejecuta: ./modules/01-zsh-setup.sh"
echo -e "• Para aplicar configuración final: ./config/configure-zsh-final.sh"
echo -e "• Reinicia la terminal para ver el tema Rastafari"
echo -e "• Usa 'sysinfo' para ver información del sistema"
echo -e "• Usa 'yy' para abrir Yazi con cambio de directorio automático"

echo -e "\n${GREEN}🎉 Validación completada!${NC}"