#!/bin/bash

# ====================================
# MÓDULO: Instalación y Configuración de Zsh
# Instala Zsh, Oh My Zsh, plugins y métricas de sistema con tema Rastafari
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

echo -e "${BLUE}🏗️ Configurando Zsh + Oh My Zsh con tema Rastafari...${NC}"

# Verificar si Zsh ya está instalado
if command -v zsh >/dev/null 2>&1; then
    echo -e "${GREEN}✅ Zsh ya está instalado${NC}"
else
    echo -e "${YELLOW}📦 Instalando Zsh...${NC}"
    if ! pkg install -y zsh; then
        echo -e "${RED}❌ Error instalando Zsh${NC}"
        exit 1
    fi
    echo -e "${GREEN}✅ Zsh instalado correctamente${NC}"
fi

# Verificar si Oh My Zsh ya está instalado
if [[ -d "$HOME/.oh-my-zsh" ]]; then
    echo -e "${GREEN}✅ Oh My Zsh ya está instalado${NC}"
else
    echo -e "${YELLOW}🎭 Instalando Oh My Zsh...${NC}"

    # Descargar e instalar Oh My Zsh de forma no interactiva
    export RUNZSH=no
    export KEEP_ZSHRC=yes

    if curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh | sh; then
        echo -e "${GREEN}✅ Oh My Zsh instalado correctamente${NC}"
    else
        echo -e "${RED}❌ Error instalando Oh My Zsh${NC}"
        exit 1
    fi
fi

# Instalar plugins populares
echo -e "${YELLOW}🔌 Instalando plugins de Zsh...${NC}"

# zsh-autosuggestions
if [[ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" ]]; then
    echo -e "${BLUE}🔧 Instalando zsh-autosuggestions...${NC}"
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    echo -e "${GREEN}✅ zsh-autosuggestions instalado${NC}"
fi

# zsh-syntax-highlighting
if [[ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" ]]; then
    echo -e "${BLUE}🔧 Instalando zsh-syntax-highlighting...${NC}"
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
    echo -e "${GREEN}✅ zsh-syntax-highlighting instalado${NC}"
fi

# zsh-completions
if [[ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-completions" ]]; then
    echo -e "${BLUE}🔧 Instalando zsh-completions...${NC}"
    git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-completions
    echo -e "${GREEN}✅ zsh-completions instalado${NC}"
fi

# Detectar potencial conflicto entre Yazi y Powerlevel10k
echo -e "${YELLOW}🗂️ Instalando Yazi (explorador de archivos)...${NC}"

# Función para detectar si hay conflictos de compatibilidad
check_yazi_p10k_compatibility() {
    local has_yazi_plugin=false
    local has_p10k=false
    
    if [[ -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/yazi" ]]; then
        has_yazi_plugin=true
    fi
    
    if [[ -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]]; then
        has_p10k=true
    fi
    
    # Si ambos están presentes, informar al usuario
    if [[ $has_yazi_plugin == true && $has_p10k == true ]]; then
        echo -e "${YELLOW}⚠️ Detectado: Yazi y Powerlevel10k pueden tener conflictos menores${NC}"
        echo -e "${CYAN}   Esto no debería afectar la funcionalidad básica${NC}"
        echo -e "${CYAN}   Si experimentas problemas, puedes desactivar uno temporalmente${NC}"
    fi
}

# Instalar Yazi
if ! command -v yazi >/dev/null 2>&1; then
    # Intentar instalar desde cargo (Rust package manager) ya que pkg no incluye yazi aún
    if ! command -v cargo >/dev/null 2>&1; then
        echo -e "${BLUE}📦 Instalando Rust para Yazi...${NC}"
        pkg install -y rust
    fi

    if command -v cargo >/dev/null 2>&1; then
        echo -e "${BLUE}🔧 Compilando Yazi desde fuente...${NC}"
        if cargo install --locked yazi-fm yazi-cli; then
            echo -e "${GREEN}✅ Yazi instalado${NC}"
        else
            echo -e "${YELLOW}⚠️ No se pudo instalar Yazi, continuando...${NC}"
        fi
    else
        echo -e "${YELLOW}⚠️ No se pudo instalar Yazi, continuando...${NC}"
    fi
else
    echo -e "${GREEN}✅ Yazi ya está instalado${NC}"
fi

# Instalar plugin de Yazi para Oh My Zsh
if [[ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/yazi" ]]; then
    echo -e "${BLUE}🔧 Instalando plugin de Yazi para Zsh...${NC}"
    if git clone https://github.com/DreamMaoMao/yazi.zsh ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/yazi; then
        echo -e "${GREEN}✅ Plugin de Yazi instalado${NC}"
    else
        echo -e "${YELLOW}⚠️ No se pudo instalar plugin de Yazi${NC}"
    fi
fi

# Instalar tema Powerlevel10k
if [[ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]]; then
    echo -e "${BLUE}🎭 Instalando tema Powerlevel10k...${NC}"
    if git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k; then
        echo -e "${GREEN}✅ Powerlevel10k instalado${NC}"
    else
        echo -e "${RED}❌ Error instalando Powerlevel10k${NC}"
        exit 1
    fi
fi

# Ejecutar verificación de compatibilidad
check_yazi_p10k_compatibility

echo -e "${GREEN}✅ Zsh y componentes instalados. Configurando archivos...${NC}"
exit 0