#!/bin/bash

# ====================================
# MÓDULO: Diagnóstico y Corrección de Problemas
# Identifica y corrige problemas comunes del setup
# ====================================

set -euo pipefail

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

show_diagnostic_banner() {
    echo -e "${PURPLE}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                    DIAGNÓSTICO Y CORRECCIÓN                  ║"
    echo "║         🔧 Solucionando problemas comunes del setup         ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}\n"
}

check_neovim_config() {
    echo -e "${BLUE}🔍 Verificando configuración de Neovim...${NC}"

    local nvim_config="$HOME/.config/nvim"
    local issues_found=0

    # Verificar si Neovim está instalado
    if ! command -v nvim >/dev/null 2>&1; then
        echo -e "${RED}❌ Neovim no está instalado${NC}"
        ((issues_found++))
    else
        echo -e "${GREEN}✅ Neovim instalado${NC}"
    fi

    # Verificar directorio de configuración
    if [[ ! -d "$nvim_config" ]]; then
        echo -e "${RED}❌ Directorio de configuración de Neovim no existe${NC}"
        ((issues_found++))
    else
        echo -e "${GREEN}✅ Directorio de configuración existe${NC}"
    fi

    # Verificar archivos de configuración críticos
    local critical_files=(
        "$nvim_config/init.lua"
        "$nvim_config/lua/config/lazy.lua"
        "$nvim_config/lua/config/options.lua"
    )

    for file in "${critical_files[@]}"; do
        if [[ ! -f "$file" ]]; then
            echo -e "${RED}❌ Archivo faltante: $file${NC}"
            ((issues_found++))
        else
            echo -e "${GREEN}✅ $(basename "$file") existe${NC}"
        fi
    done

    # Verificar problemas de encoding
    if [[ -f "$nvim_config/lua/config/options.lua" ]]; then
        if grep -q "fillchars.*[^[:print:]]" "$nvim_config/lua/config/options.lua" 2>/dev/null; then
            echo -e "${YELLOW}⚠️ Posibles caracteres problemáticos en options.lua${NC}"
            ((issues_found++))
        fi
    fi

    if [[ $issues_found -eq 0 ]]; then
        echo -e "${GREEN}✅ Configuración de Neovim parece estar bien${NC}"
    else
        echo -e "${YELLOW}⚠️ Se encontraron $issues_found problemas con Neovim${NC}"
    fi

    return $issues_found
}

fix_neovim_issues() {
    echo -e "${BLUE}🔧 Corrigiendo problemas de Neovim...${NC}"

    local nvim_config="$HOME/.config/nvim"

    # Crear directorios necesarios
    mkdir -p "$nvim_config"/{lua/config,lua/plugins}
    mkdir -p ~/.local/{share,state,cache}/nvim

    # Ejecutar script de corrección si existe
    if [[ -f "$nvim_config/fix-common-issues.sh" ]]; then
        echo -e "${CYAN}🔄 Ejecutando script de corrección...${NC}"
        bash "$nvim_config/fix-common-issues.sh"
    fi

    echo -e "${GREEN}✅ Correcciones de Neovim aplicadas${NC}"
}

check_zsh_config() {
    echo -e "${BLUE}🔍 Verificando configuración de Zsh...${NC}"

    local issues_found=0

    # Verificar si Zsh está instalado
    if ! command -v zsh >/dev/null 2>&1; then
        echo -e "${RED}❌ Zsh no está instalado${NC}"
        ((issues_found++))
    else
        echo -e "${GREEN}✅ Zsh instalado${NC}"
    fi

    # Verificar Oh My Zsh
    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        echo -e "${RED}❌ Oh My Zsh no está instalado${NC}"
        ((issues_found++))
    else
        echo -e "${GREEN}✅ Oh My Zsh instalado${NC}"
    fi

    # Verificar Powerlevel10k
    if [[ ! -d "$HOME/.oh-my-zsh/custom/themes/powerlevel10k" ]]; then
        echo -e "${RED}❌ Powerlevel10k no está instalado${NC}"
        ((issues_found++))
    else
        echo -e "${GREEN}✅ Powerlevel10k instalado${NC}"
    fi

    # Verificar archivo .p10k.zsh
    if [[ ! -f "$HOME/.p10k.zsh" ]]; then
        echo -e "${YELLOW}⚠️ Archivo .p10k.zsh no existe${NC}"
        ((issues_found++))
    else
        echo -e "${GREEN}✅ Configuración .p10k.zsh existe${NC}"
    fi

    if [[ $issues_found -eq 0 ]]; then
        echo -e "${GREEN}✅ Configuración de Zsh parece estar bien${NC}"
    else
        echo -e "${YELLOW}⚠️ Se encontraron $issues_found problemas con Zsh${NC}"
    fi

    return $issues_found
}

fix_zsh_issues() {
    echo -e "${BLUE}🔧 Corrigiendo problemas de Zsh...${NC}"

    # Crear archivo .p10k.zsh básico si no existe
    if [[ ! -f "$HOME/.p10k.zsh" ]]; then
        echo -e "${CYAN}📄 Creando configuración básica de .p10k.zsh...${NC}"
        cat > "$HOME/.p10k.zsh" << 'EOF'
# Configuración básica de Powerlevel10k
# Ejecuta 'p10k configure' para personalizar

# Enable instant prompt
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Configuración básica
typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir vcs)
typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status command_execution_time)
typeset -g POWERLEVEL9K_MODE='ascii'  # Usar modo ASCII para mejor compatibilidad
EOF
        echo -e "${GREEN}✅ Archivo .p10k.zsh creado${NC}"
    fi

    # Asegurar que el shell esté configurado
    if command -v zsh >/dev/null 2>&1; then
        export SHELL=$(which zsh)
        echo -e "${GREEN}✅ Shell configurado a Zsh${NC}"
    fi

    echo -e "${GREEN}✅ Correcciones de Zsh aplicadas${NC}"
}

check_user_config() {
    echo -e "${BLUE}🔍 Verificando configuración de usuario...${NC}"

    local user_config="$HOME/.termux_user_config"
    local issues_found=0

    if [[ ! -f "$user_config" ]]; then
        echo -e "${YELLOW}⚠️ Configuración de usuario no encontrada${NC}"
        ((issues_found++))
    else
        echo -e "${GREEN}✅ Configuración de usuario existe${NC}"

        # Verificar Git
        if ! git config --global user.name >/dev/null 2>&1; then
            echo -e "${YELLOW}⚠️ Git user.name no configurado${NC}"
            ((issues_found++))
        else
            echo -e "${GREEN}✅ Git user.name configurado${NC}"
        fi

        if ! git config --global user.email >/dev/null 2>&1; then
            echo -e "${YELLOW}⚠️ Git user.email no configurado${NC}"
            ((issues_found++))
        else
            echo -e "${GREEN}✅ Git user.email configurado${NC}"
        fi
    fi

    return $issues_found
}

check_ssh_config() {
    echo -e "${BLUE}🔍 Verificando configuración SSH...${NC}"

    local issues_found=0

    if [[ ! -d "$HOME/.ssh" ]]; then
        echo -e "${YELLOW}⚠️ Directorio SSH no existe${NC}"
        ((issues_found++))
    else
        echo -e "${GREEN}✅ Directorio SSH existe${NC}"

        # Verificar permisos
        if [[ $(stat -c "%a" "$HOME/.ssh") != "700" ]]; then
            echo -e "${YELLOW}⚠️ Permisos incorrectos en directorio SSH${NC}"
            chmod 700 "$HOME/.ssh"
            echo -e "${GREEN}✅ Permisos SSH corregidos${NC}"
        fi

        # Verificar claves SSH
        local key_count=$(find "$HOME/.ssh" -name "*.pub" 2>/dev/null | wc -l)
        if [[ $key_count -eq 0 ]]; then
            echo -e "${YELLOW}⚠️ No se encontraron claves SSH públicas${NC}"
            ((issues_found++))
        else
            echo -e "${GREEN}✅ Encontradas $key_count clave(s) SSH${NC}"
        fi
    fi

    return $issues_found
}

run_comprehensive_check() {
    echo -e "${CYAN}🔍 Ejecutando diagnóstico completo...${NC}\n"

    local total_issues=0

    echo -e "${YELLOW}=== VERIFICACIÓN DE NEOVIM ===${NC}"
    if ! check_neovim_config; then
        ((total_issues += $?))
    fi

    echo -e "\n${YELLOW}=== VERIFICACIÓN DE ZSH ===${NC}"
    if ! check_zsh_config; then
        ((total_issues += $?))
    fi

    echo -e "\n${YELLOW}=== VERIFICACIÓN DE USUARIO ===${NC}"
    if ! check_user_config; then
        ((total_issues += $?))
    fi

    echo -e "\n${YELLOW}=== VERIFICACIÓN DE SSH ===${NC}"
    if ! check_ssh_config; then
        ((total_issues += $?))
    fi

    echo -e "\n${CYAN}=== RESUMEN DEL DIAGNÓSTICO ===${NC}"

    if [[ $total_issues -eq 0 ]]; then
        echo -e "${GREEN}🎉 ¡Todo parece estar configurado correctamente!${NC}"
    else
        echo -e "${YELLOW}⚠️ Se encontraron $total_issues problemas potenciales${NC}"
        echo -e "${CYAN}💡 Ejecuta las opciones de corrección para solucionarlos${NC}"
    fi

    return $total_issues
}

run_comprehensive_fix() {
    echo -e "${CYAN}🔧 Ejecutando correcciones automáticas...${NC}\n"

    echo -e "${YELLOW}=== CORRIGIENDO NEOVIM ===${NC}"
    fix_neovim_issues

    echo -e "\n${YELLOW}=== CORRIGIENDO ZSH ===${NC}"
    fix_zsh_issues

    echo -e "\n${GREEN}🎉 Correcciones completadas${NC}"
    echo -e "${CYAN}💡 Ejecuta el diagnóstico nuevamente para verificar${NC}"
}

show_menu() {
    echo -e "${CYAN}┌─────────────────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│              DIAGNÓSTICO Y CORRECCIÓN           │${NC}"
    echo -e "${CYAN}├─────────────────────────────────────────────────┤${NC}"
    echo -e "${WHITE}│  1. 🔍 Ejecutar diagnóstico completo           │${NC}"
    echo -e "${WHITE}│  2. 🔧 Ejecutar correcciones automáticas       │${NC}"
    echo -e "${WHITE}│  3. ⚡ Verificar solo Neovim                   │${NC}"
    echo -e "${WHITE}│  4. 🐚 Verificar solo Zsh                      │${NC}"
    echo -e "${WHITE}│  5. 👤 Verificar configuración de usuario      │${NC}"
    echo -e "${WHITE}│  6. 🔐 Verificar configuración SSH             │${NC}"
    echo -e "${WHITE}│  0. 🚪 Salir                                   │${NC}"
    echo -e "${CYAN}└─────────────────────────────────────────────────┘${NC}"
    echo -e "\n${YELLOW}Selecciona una opción [0-6]:${NC} "
}

main() {
    show_diagnostic_banner

    while true; do
        show_menu
        read -r choice

        case $choice in
            1)
                run_comprehensive_check
                ;;
            2)
                run_comprehensive_fix
                ;;
            3)
                check_neovim_config
                ;;
            4)
                check_zsh_config
                ;;
            5)
                check_user_config
                ;;
            6)
                check_ssh_config
                ;;
            0)
                echo -e "${GREEN}¡Gracias por usar el diagnóstico!${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}❌ Opción inválida. Selecciona un número del 0-6.${NC}"
                sleep 2
                ;;
        esac

        echo -e "\n${YELLOW}Presiona Enter para continuar...${NC}"
        read -r
    done
}

# Si el script es ejecutado directamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi