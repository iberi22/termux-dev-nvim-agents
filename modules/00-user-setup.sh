#!/bin/bash

# ====================================
# MÓDULO: Configuración Inicial de Usuario
# Solicita y configura datos básicos del usuario
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

USER_CONFIG_FILE="$HOME/.termux_user_config"

show_user_setup_banner() {
    echo -e "${PURPLE}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                CONFIGURACIÓN INICIAL DE USUARIO              ║"
    echo "║         🔧 Configuremos tu entorno de desarrollo            ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}\n"
}

prompt_user_info() {
    echo -e "${BLUE}📝 Configuración de Usuario${NC}"
    echo -e "${CYAN}Necesitamos algunos datos para configurar tu entorno:${NC}\n"

    # Nombre de usuario del sistema
    while true; do
        read -p "$(echo -e ${YELLOW}👤 Ingresa tu nombre de usuario: ${NC})" USERNAME
        if [[ -n "$USERNAME" && "$USERNAME" =~ ^[a-zA-Z0-9._-]+$ ]]; then
            break
        else
            echo -e "${RED}❌ El nombre de usuario solo puede contener letras, números, puntos, guiones y guiones bajos${NC}"
        fi
    done

    # Contraseña del usuario
    while true; do
        read -s -p "$(echo -e ${YELLOW}🔐 Ingresa una contraseña para tu usuario: ${NC})" PASSWORD
        echo
        if [[ ${#PASSWORD} -ge 6 ]]; then
            read -s -p "$(echo -e ${YELLOW}🔐 Confirma la contraseña: ${NC})" PASSWORD_CONFIRM
            echo
            if [[ "$PASSWORD" == "$PASSWORD_CONFIRM" ]]; then
                break
            else
                echo -e "${RED}❌ Las contraseñas no coinciden. Intenta de nuevo.${NC}"
            fi
        else
            echo -e "${RED}❌ La contraseña debe tener al menos 6 caracteres${NC}"
        fi
    done

    # Configuración de Git
    echo -e "\n${BLUE}📝 Configuración de Git${NC}"

    while true; do
        read -p "$(echo -e ${YELLOW}📧 Ingresa tu email para Git: ${NC})" GIT_EMAIL
        if [[ "$GIT_EMAIL" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
            break
        else
            echo -e "${RED}❌ Por favor ingresa un email válido${NC}"
        fi
    done

    while true; do
        read -p "$(echo -e ${YELLOW}👤 Ingresa tu nombre completo para Git: ${NC})" GIT_NAME
        if [[ -n "$GIT_NAME" ]]; then
            break
        else
            echo -e "${RED}❌ El nombre no puede estar vacío${NC}"
        fi
    done

    # Confirmar información
    echo -e "\n${CYAN}📋 Resumen de configuración:${NC}"
    echo -e "Usuario: ${GREEN}$USERNAME${NC}"
    echo -e "Email Git: ${GREEN}$GIT_EMAIL${NC}"
    echo -e "Nombre Git: ${GREEN}$GIT_NAME${NC}"

    while true; do
        read -p "$(echo -e ${YELLOW}❓ ¿Es correcta esta información? (s/n): ${NC})" CONFIRM
        case $CONFIRM in
            [Ss]* ) break;;
            [Nn]* ) echo -e "${YELLOW}🔄 Reiniciando configuración...${NC}"; prompt_user_info; return;;
            * ) echo -e "${RED}Por favor responde 's' o 'n'${NC}";;
        esac
    done
}

save_user_config() {
    echo -e "${BLUE}💾 Guardando configuración...${NC}"

    cat > "$USER_CONFIG_FILE" << EOF
# Configuración de usuario de Termux AI Setup
# Generado automáticamente el $(date)

USERNAME="$USERNAME"
PASSWORD_HASH="$(echo -n "$PASSWORD" | sha256sum | cut -d' ' -f1)"
GIT_EMAIL="$GIT_EMAIL"
GIT_NAME="$GIT_NAME"
SETUP_DATE="$(date)"
EOF

    chmod 600 "$USER_CONFIG_FILE"
    echo -e "${GREEN}✅ Configuración guardada en $USER_CONFIG_FILE${NC}"
}

configure_system_user() {
    echo -e "${BLUE}👤 Configurando usuario del sistema...${NC}"

    # En Termux no se pueden crear usuarios tradicionales como en Linux
    # Pero podemos configurar el entorno para el usuario actual

    # Configurar Git globalmente
    echo -e "${CYAN}🔧 Configurando Git...${NC}"
    git config --global user.name "$GIT_NAME"
    git config --global user.email "$GIT_EMAIL"
    git config --global init.defaultBranch main
    git config --global pull.rebase false

    echo -e "${GREEN}✅ Git configurado correctamente${NC}"

    # Configurar variables de entorno
    echo -e "${CYAN}🔧 Configurando variables de entorno...${NC}"

    # Agregar al bashrc y zshrc si existen
    for shell_rc in "$HOME/.bashrc" "$HOME/.zshrc"; do
        if [[ -f "$shell_rc" ]]; then
            # Remover configuraciones anteriores si existen
            sed -i '/# Termux AI Setup User Config/,/# End Termux AI Setup User Config/d' "$shell_rc"

            cat >> "$shell_rc" << EOF

# Termux AI Setup User Config
export TERMUX_AI_USER="$USERNAME"
export GIT_AUTHOR_NAME="$GIT_NAME"
export GIT_AUTHOR_EMAIL="$GIT_EMAIL"
export GIT_COMMITTER_NAME="$GIT_NAME"
export GIT_COMMITTER_EMAIL="$GIT_EMAIL"
# End Termux AI Setup User Config
EOF
        fi
    done

    echo -e "${GREEN}✅ Variables de entorno configuradas${NC}"
}

load_user_config() {
    if [[ -f "$USER_CONFIG_FILE" ]]; then
        source "$USER_CONFIG_FILE"
        return 0
    fi
    return 1
}

check_existing_config() {
    if load_user_config; then
        echo -e "${CYAN}📋 Configuración existente encontrada:${NC}"
        echo -e "Usuario: ${GREEN}$USERNAME${NC}"
        echo -e "Email Git: ${GREEN}$GIT_EMAIL${NC}"
        echo -e "Nombre Git: ${GREEN}$GIT_NAME${NC}"
        echo -e "Configurado el: ${GREEN}$SETUP_DATE${NC}"

        while true; do
            read -p "$(echo -e ${YELLOW}❓ ¿Quieres usar esta configuración? (s/n): ${NC})" USE_EXISTING
            case $USE_EXISTING in
                [Ss]* )
                    echo -e "${GREEN}✅ Usando configuración existente${NC}"
                    return 0
                    ;;
                [Nn]* )
                    echo -e "${YELLOW}🔄 Configurando de nuevo...${NC}"
                    return 1
                    ;;
                * )
                    echo -e "${RED}Por favor responde 's' o 'n'${NC}"
                    ;;
            esac
        done
    fi
    return 1
}

main() {
    show_user_setup_banner

    echo -e "${BLUE}🔍 Verificando configuración existente...${NC}"

    if ! check_existing_config; then
        prompt_user_info
        save_user_config
    fi

    configure_system_user

    echo -e "\n${GREEN}🎉 Configuración de usuario completada exitosamente!${NC}"
    echo -e "${CYAN}📁 Los datos se guardaron en: $USER_CONFIG_FILE${NC}"
    echo -e "${CYAN}🔄 Las configuraciones se aplicarán en el próximo reinicio de terminal${NC}"
}

# Exportar funciones para uso en otros scripts
export_user_vars() {
    if load_user_config; then
        export TERMUX_AI_USERNAME="$USERNAME"
        export TERMUX_AI_GIT_EMAIL="$GIT_EMAIL"
        export TERMUX_AI_GIT_NAME="$GIT_NAME"
        echo -e "${GREEN}✅ Variables de usuario exportadas${NC}"
    else
        echo -e "${RED}❌ No se pudo cargar la configuración de usuario${NC}"
        return 1
    fi
}

# Si el script es ejecutado directamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi