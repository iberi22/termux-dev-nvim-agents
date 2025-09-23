#!/bin/bash

# ====================================
# DEMO Y VALIDACIÓN DEL TEMA RASTAFARI
# Script para mostrar y verificar el tema Powerlevel10k Rastafari
# ====================================

set -euo pipefail

# Colores rastafari para el script
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

show_rastafari_banner() {
    clear
    echo -e "${RED}██████${YELLOW}██████${GREEN}██████${NC}"
    echo -e "${RED}██████${YELLOW}██████${GREEN}██████${NC}"
    echo -e "${RED}██████${YELLOW}██████${GREEN}██████${NC}"
    echo -e ""
    echo -e "${RED}🇯🇲 ${YELLOW}TERMUX AI SETUP - TEMA RASTAFARI ${GREEN}🇯🇲${NC}"
    echo -e "${RED}${YELLOW}${GREEN} Rainbow Style Powerlevel10k Configuration ${NC}"
    echo -e ""
    echo -e "${RED}██████${YELLOW}██████${GREEN}██████${NC}"
    echo -e "${RED}██████${YELLOW}██████${GREEN}██████${NC}"
    echo -e "${RED}██████${YELLOW}██████${GREEN}██████${NC}"
    echo -e ""
}

demonstrate_theme() {
    echo -e "${CYAN}📋 Demostrando características del tema Rastafari:${NC}\n"

    echo -e "${RED}🔴 ROJO${NC} - OS Icon, Status Error, Elementos de sistema críticos"
    echo -e "${YELLOW}🟡 AMARILLO${NC} - Git Status, Background Jobs, Virtual Environment"
    echo -e "${GREEN}🟢 VERDE${NC} - Directory, Context, Status OK, CPU/Memory (bajo uso)"

    echo -e "\n${CYAN}🎨 Layout del Prompt:${NC}"
    echo -e "${RED}[OS]${YELLOW}[Git]${GREEN}[Dir]${YELLOW}[CPU]${RED}[Mem]${GREEN}[Status]${YELLOW}[Jobs]${GREEN}[Context]${NC}"
    echo -e "${GREEN}❯${NC} comando-aquí"

    echo -e "\n${CYAN}💻 Métricas de Sistema Incluidas:${NC}"
    echo -e "• ${YELLOW}CPU Usage${NC} - Porcentaje de uso del procesador"
    echo -e "• ${GREEN}Memory Free${NC} - Memoria libre disponible en MB"
    echo -e "• ${RED}Colores dinámicos${NC} - Cambian según el uso (Verde<30%, Amarillo<70%, Rojo>70%)"
}

check_theme_installation() {
    echo -e "${CYAN}🔍 Verificando instalación del tema:${NC}\n"

    local issues=0

    # Verificar Powerlevel10k
    if [[ -d "$HOME/.oh-my-zsh/custom/themes/powerlevel10k" ]]; then
        echo -e "${GREEN}✅ Powerlevel10k instalado${NC}"
    else
        echo -e "${RED}❌ Powerlevel10k no encontrado${NC}"
        ((issues++))
    fi

    # Verificar archivo de configuración
    if [[ -f "$HOME/.p10k.zsh" ]]; then
        echo -e "${GREEN}✅ Archivo .p10k.zsh existe${NC}"

        # Verificar si tiene configuración rastafari
        if grep -q "RASTAFARI" "$HOME/.p10k.zsh"; then
            echo -e "${GREEN}✅ Configuración Rastafari detectada${NC}"
        else
            echo -e "${YELLOW}⚠️ Configuración Rastafari no detectada${NC}"
            ((issues++))
        fi

        # Verificar funciones personalizadas
        if grep -q "prompt_system_cpu" "$HOME/.p10k.zsh"; then
            echo -e "${GREEN}✅ Función CPU personalizada encontrada${NC}"
        else
            echo -e "${YELLOW}⚠️ Función CPU no encontrada${NC}"
            ((issues++))
        fi

        if grep -q "prompt_system_memory" "$HOME/.p10k.zsh"; then
            echo -e "${GREEN}✅ Función Memory personalizada encontrada${NC}"
        else
            echo -e "${YELLOW}⚠️ Función Memory no encontrada${NC}"
            ((issues++))
        fi
    else
        echo -e "${RED}❌ Archivo .p10k.zsh no existe${NC}"
        ((issues++))
    fi

    # Verificar Zsh como shell
    if [[ "$SHELL" =~ zsh ]] || command -v zsh >/dev/null 2>&1; then
        echo -e "${GREEN}✅ Zsh disponible${NC}"
    else
        echo -e "${RED}❌ Zsh no configurado como shell${NC}"
        ((issues++))
    fi

    echo -e "\n${CYAN}📊 Resultado de la verificación:${NC}"
    if [[ $issues -eq 0 ]]; then
        echo -e "${GREEN}🎉 ¡Todo está configurado correctamente!${NC}"
        echo -e "${GREEN}El tema Rastafari debería estar funcionando.${NC}"
    else
        echo -e "${YELLOW}⚠️ Se encontraron $issues problema(s).${NC}"
        echo -e "${CYAN}💡 Ejecuta el módulo de configuración Zsh para corregirlos.${NC}"
    fi

    return $issues
}

show_system_metrics() {
    echo -e "${CYAN}💻 Métricas actuales del sistema:${NC}\n"

    # CPU Usage
    if [[ -f /proc/stat ]]; then
        local cpu_line=$(head -n 1 /proc/stat)
        local cpu_values=(${cpu_line#cpu })
        local idle=${cpu_values[3]}
        local total=0
        for val in "${cpu_values[@]:0:8}"; do
            total=$((total + val))
        done
        if [[ $total -gt 0 ]]; then
            local cpu_usage=$(( (total - idle) * 100 / total ))
            if (( cpu_usage < 30 )); then
                echo -e "${GREEN}🔥 CPU: ${cpu_usage}% (Verde - Bajo uso)${NC}"
            elif (( cpu_usage < 70 )); then
                echo -e "${YELLOW}🔥 CPU: ${cpu_usage}% (Amarillo - Uso moderado)${NC}"
            else
                echo -e "${RED}🔥 CPU: ${cpu_usage}% (Rojo - Alto uso)${NC}"
            fi
        fi
    fi

    # Memory
    if [[ -f /proc/meminfo ]]; then
        local total_kb=$(grep '^MemTotal:' /proc/meminfo | awk '{print $2}')
        local available_kb=$(grep '^MemAvailable:' /proc/meminfo | awk '{print $2}')
        if [[ -z "$available_kb" ]]; then
            available_kb=$(grep '^MemFree:' /proc/meminfo | awk '{print $2}')
        fi

        if [[ $total_kb -gt 0 && -n "$available_kb" ]]; then
            local mem_free_mb=$(( available_kb / 1024 ))
            local used_kb=$((total_kb - available_kb))
            local mem_usage=$(( used_kb * 100 / total_kb ))

            if (( mem_usage < 30 )); then
                echo -e "${GREEN}💾 Memoria: ${mem_free_mb}MB libres (Verde - Buen estado)${NC}"
            elif (( mem_usage < 70 )); then
                echo -e "${YELLOW}💾 Memoria: ${mem_free_mb}MB libres (Amarillo - Uso moderado)${NC}"
            else
                echo -e "${RED}💾 Memoria: ${mem_free_mb}MB libres (Rojo - Memoria baja)${NC}"
            fi
        fi
    fi
}

activate_theme() {
    echo -e "${CYAN}🔄 Activando tema Rastafari...${NC}\n"

    if [[ -f "$HOME/.p10k.zsh" ]]; then
        echo -e "${YELLOW}📝 Recargando configuración de Powerlevel10k...${NC}"

        # Si estamos en zsh, recargar la configuración
        if [[ -n "${ZSH_VERSION:-}" ]]; then
            source "$HOME/.p10k.zsh" 2>/dev/null || true
            echo -e "${GREEN}✅ Configuración recargada${NC}"
        else
            echo -e "${CYAN}💡 Para activar el tema, ejecuta: exec zsh${NC}"
        fi

        echo -e "${GREEN}🎨 Tema Rastafari activado!${NC}"
    else
        echo -e "${RED}❌ No se encuentra el archivo de configuración${NC}"
        echo -e "${CYAN}💡 Ejecuta primero el módulo de configuración Zsh${NC}"
    fi
}

show_commands_help() {
    echo -e "${CYAN}📖 Comandos útiles para el tema Rastafari:${NC}\n"

    echo -e "${YELLOW}Configuración:${NC}"
    echo -e "  ${GREEN}source ~/.p10k.zsh${NC}     - Recargar configuración del tema"
    echo -e "  ${GREEN}exec zsh${NC}               - Reiniciar shell con nuevo tema"

    echo -e "\n${YELLOW}Personalización:${NC}"
    echo -e "  ${GREEN}p10k configure${NC}         - Configurar tema interactivamente"
    echo -e "  ${GREEN}p10k reload${NC}            - Recargar configuración"

    echo -e "\n${YELLOW}Información del sistema:${NC}"
    echo -e "  ${GREEN}htop${NC}                   - Monitor de recursos del sistema"
    echo -e "  ${GREEN}free -h${NC}               - Ver uso de memoria"
    echo -e "  ${GREEN}cat /proc/cpuinfo${NC}     - Información del CPU"
}

show_menu() {
    echo -e "${CYAN}┌─────────────────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│         ${RED}🇯🇲 ${YELLOW}TEMA RASTAFARI ${GREEN}🇯🇲${CYAN}         │${NC}"
    echo -e "${CYAN}├─────────────────────────────────────────────────┤${NC}"
    echo -e "${WHITE}│  1. 🎨 Demostrar características del tema       │${NC}"
    echo -e "${WHITE}│  2. 🔍 Verificar instalación                   │${NC}"
    echo -e "${WHITE}│  3. 💻 Mostrar métricas actuales del sistema   │${NC}"
    echo -e "${WHITE}│  4. 🔄 Activar tema Rastafari                  │${NC}"
    echo -e "${WHITE}│  5. 📖 Mostrar comandos útiles                 │${NC}"
    echo -e "${WHITE}│  0. 🚪 Salir                                   │${NC}"
    echo -e "${CYAN}└─────────────────────────────────────────────────┘${NC}"
    echo -e "\n${YELLOW}Selecciona una opción [0-5]:${NC} "
}

main() {
    show_rastafari_banner

    while true; do
        show_menu
        read -r choice

        case $choice in
            1)
                demonstrate_theme
                ;;
            2)
                check_theme_installation
                ;;
            3)
                show_system_metrics
                ;;
            4)
                activate_theme
                ;;
            5)
                show_commands_help
                ;;
            0)
                echo -e "${RED}🇯🇲 ${YELLOW}¡Gracias por usar el tema Rastafari! ${GREEN}🇯🇲${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}❌ Opción inválida. Selecciona un número del 0-5.${NC}"
                sleep 2
                ;;
        esac

        echo -e "\n${YELLOW}Presiona Enter para continuar...${NC}"
        read -r
        clear
        show_rastafari_banner
    done
}

# Si el script es ejecutado directamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi