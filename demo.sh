#!/bin/bash

# ====================================
# DEMO: Sistema Completo de Termux AI Setup
# Demuestra todas las funcionalidades implementadas
# ====================================

set -euo pipefail

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

# Banner principal
show_demo_banner() {
    clear
    echo -e "${PURPLE}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║                                                                              ║${NC}"
    echo -e "${PURPLE}║              🚀 TERMUX AI DEVELOPMENT ENVIRONMENT DEMO 🚀                   ║${NC}"
    echo -e "${PURPLE}║                                                                              ║${NC}"
    echo -e "${PURPLE}║                    Sistema Completo de Desarrollo con IA                    ║${NC}"
    echo -e "${PURPLE}║                                                                              ║${NC}"
    echo -e "${PURPLE}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# Función para mostrar información del sistema
show_system_info() {
    echo -e "${CYAN}📋 INFORMACIÓN DEL SISTEMA${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    # Información básica
    echo -e "${WHITE}Sistema Operativo:${NC} $(uname -o 2>/dev/null || echo 'Android (Termux)')"
    echo -e "${WHITE}Arquitectura:${NC} $(uname -m)"
    echo -e "${WHITE}Usuario:${NC} $(whoami)"
    echo -e "${WHITE}Directorio:${NC} $(pwd)"
    echo -e "${WHITE}Shell:${NC} $SHELL"

    # Verificar componentes instalados
    echo -e "\n${WHITE}Componentes Instalados:${NC}"

    # Git
    if command -v git &>/dev/null; then
        echo -e "${GREEN}✅ Git:${NC} $(git --version | head -1)"
    else
        echo -e "${RED}❌ Git: No instalado${NC}"
    fi

    # Node.js
    if command -v node &>/dev/null; then
        echo -e "${GREEN}✅ Node.js:${NC} $(node --version)"
    else
        echo -e "${RED}❌ Node.js: No instalado${NC}"
    fi

    # Python
    if command -v python &>/dev/null; then
        echo -e "${GREEN}✅ Python:${NC} $(python --version)"
    else
        echo -e "${RED}❌ Python: No instalado${NC}"
    fi

    # Neovim
    if command -v nvim &>/dev/null; then
        echo -e "${GREEN}✅ Neovim:${NC} $(nvim --version | head -1)"
    else
        echo -e "${RED}❌ Neovim: No instalado${NC}"
    fi

    # Zsh
    if command -v zsh &>/dev/null; then
        echo -e "${GREEN}✅ Zsh:${NC} $(zsh --version)"
    else
        echo -e "${RED}❌ Zsh: No instalado${NC}"
    fi

    # Oh My Zsh
    if [[ -d ~/.oh-my-zsh ]]; then
        echo -e "${GREEN}✅ Oh My Zsh:${NC} Instalado"
    else
        echo -e "${RED}❌ Oh My Zsh: No instalado${NC}"
    fi
}

# Función para demostrar herramientas de IA
demo_ai_tools() {
    echo -e "\n${CYAN}🤖 HERRAMIENTAS DE IA DISPONIBLES${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    # Verificar scripts de IA
    local ai_tools=(
        "ai-code-review:Revisar código con IA"
        "ai-generate-docs:Generar documentación automática"
        "ai-project-analysis:Análisis completo de proyecto"
        "ai-help:Asistente de ayuda con IA"
        "ai-init-project:Inicializar proyecto con workflows de IA"
    )

    for tool_info in "${ai_tools[@]}"; do
        local tool_name="${tool_info%%:*}"
        local tool_desc="${tool_info##*:}"

        if [[ -x ~/bin/$tool_name ]]; then
            echo -e "${GREEN}✅ ${tool_name}:${NC} ${tool_desc}"
        else
            echo -e "${RED}❌ ${tool_name}:${NC} No disponible"
        fi
    done

    # Verificar workflows
    echo -e "\n${WHITE}Workflows de IA:${NC}"
    if [[ -f ~/.config/ai-workflows/run-workflow.sh ]]; then
        echo -e "${GREEN}✅ Sistema de workflows configurado${NC}"

        # Mostrar agentes disponibles
        if [[ -d ~/.config/ai-workflows/agents ]]; then
            echo -e "${WHITE}Agentes disponibles:${NC}"
            for agent_file in ~/.config/ai-workflows/agents/*.poml; do
                if [[ -f "$agent_file" ]]; then
                    local agent_name
                    agent_name=$(basename "$agent_file" .poml)
                    echo -e "   ${CYAN}• ${agent_name}${NC}"
                fi
            done
        fi
    else
        echo -e "${RED}❌ Sistema de workflows no configurado${NC}"
    fi
}

# Función para demostrar configuración de desarrollo
demo_dev_environment() {
    echo -e "\n${CYAN}⚡ ENTORNO DE DESARROLLO${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    # Verificar herramientas de desarrollo
    local dev_tools=(
        "rg:Ripgrep - Búsqueda rápida de texto"
        "fd:fd - Búsqueda rápida de archivos"
        "fzf:FZF - Fuzzy finder"
        "lazygit:LazyGit - Interface Git"
        "tree:Tree - Visualización de directorios"
        "jq:jq - Procesador JSON"
    )

    for tool_info in "${dev_tools[@]}"; do
        local tool_name="${tool_info%%:*}"
        local tool_desc="${tool_info##*:}"

        if command -v "$tool_name" &>/dev/null; then
            echo -e "${GREEN}✅ ${tool_desc}${NC}"
        else
            echo -e "${RED}❌ ${tool_desc} - No instalado${NC}"
        fi
    done

    # Verificar configuración de Neovim
    echo -e "\n${WHITE}Configuración de Neovim:${NC}"
    if [[ -f ~/.config/nvim/init.lua ]]; then
        echo -e "${GREEN}✅ Configuración principal (init.lua)${NC}"

        # Verificar plugins
        local plugins=(
            "ui.lua:Interface y tema"
            "explorer.lua:Explorador de archivos"
            "telescope.lua:Fuzzy finder avanzado"
            "lsp.lua:Language Server Protocol"
            "treesitter.lua:Highlighting avanzado"
            "ai.lua:Integración con IA (Copilot, ChatGPT)"
            "dev-tools.lua:Herramientas de desarrollo"
        )

        echo -e "${WHITE}Plugins configurados:${NC}"
        for plugin_info in "${plugins[@]}"; do
            local plugin_file="${plugin_info%%:*}"
            local plugin_desc="${plugin_info##*:}"

            if [[ -f ~/.config/nvim/lua/plugins/$plugin_file ]]; then
                echo -e "   ${GREEN}✅ ${plugin_desc}${NC}"
            else
                echo -e "   ${RED}❌ ${plugin_desc} - No configurado${NC}"
            fi
        done
    else
        echo -e "${RED}❌ Configuración de Neovim no encontrada${NC}"
    fi
}

# Función para ejecutar demo interactivo
run_interactive_demo() {
    echo -e "\n${CYAN}🎮 DEMO INTERACTIVO${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    echo -e "${YELLOW}¿Qué te gustaría demostrar?${NC}"
    echo -e "1. 🔍 Crear y analizar un proyecto de ejemplo"
    echo -e "2. 🤖 Probar herramientas de IA"
    echo -e "3. 🔄 Ejecutar workflow de IA"
    echo -e "4. 🧪 Ejecutar tests completos"
    echo -e "5. 📊 Mostrar configuración detallada"
    echo -e "0. ⬅️  Volver al menú principal"

    echo -e "\n${CYAN}Selecciona una opción [0-5]:${NC} "
    read -r choice

    case $choice in
        1)
            demo_create_project
            ;;
        2)
            demo_ai_tools_interactive
            ;;
        3)
            demo_workflows
            ;;
        4)
            demo_run_tests
            ;;
        5)
            demo_detailed_config
            ;;
        0)
            return
            ;;
        *)
            echo -e "${RED}❌ Opción inválida${NC}"
            sleep 2
            ;;
    esac
}

# Función para crear proyecto de demo
demo_create_project() {
    echo -e "\n${BLUE}🚀 Creando proyecto de demostración...${NC}"

    local demo_project_dir="$HOME/.cache/termux-ai-demo-$$"

    if [[ -x ~/bin/ai-init-project ]]; then
        echo -e "${YELLOW}Ejecutando: ai-init-project termux-ai-demo $demo_project_dir${NC}"

        if ~/bin/ai-init-project "termux-ai-demo" "$demo_project_dir"; then
            echo -e "${GREEN}✅ Proyecto creado exitosamente${NC}"

            # Mostrar estructura del proyecto
            echo -e "\n${CYAN}📁 Estructura del proyecto:${NC}"
            if command -v tree &>/dev/null; then
                tree "$demo_project_dir" -L 3
            else
                find "$demo_project_dir" -type f | head -20
            fi

            # Mostrar contenido del README
            echo -e "\n${CYAN}📄 Contenido del README.md:${NC}"
            head -20 "$demo_project_dir/README.md"

            echo -e "\n${YELLOW}Presiona Enter para continuar...${NC}"
            read -r

            # Limpiar proyecto demo
            rm -rf "$demo_project_dir" 2>/dev/null || true
        else
            echo -e "${RED}❌ Error al crear el proyecto${NC}"
        fi
    else
        echo -e "${RED}❌ ai-init-project no está disponible${NC}"
    fi
}

# Función para demo de herramientas de IA
demo_ai_tools_interactive() {
    echo -e "\n${BLUE}🤖 Probando herramientas de IA...${NC}"

    # Crear archivo temporal para prueba
    local temp_file="$HOME/.cache/demo_code.py"
    cat > "$temp_file" << 'EOF'
def fibonacci(n):
    if n <= 1:
        return n
    return fibonacci(n-1) + fibonacci(n-2)

# Función sin documentación
def calculate_area(radius):
    return 3.14159 * radius * radius

print(fibonacci(10))
EOF

    echo -e "${CYAN}📄 Archivo de prueba creado: ${temp_file}${NC}"
    cat "$temp_file"

    echo -e "\n${YELLOW}Probando herramientas de IA...${NC}"

    # Probar ai-code-review si está disponible
    if [[ -x ~/bin/ai-code-review ]]; then
        echo -e "\n${CYAN}🔍 Ejecutando ai-code-review:${NC}"
        ~/bin/ai-code-review "$temp_file" || echo -e "${YELLOW}⚠️ Requiere autenticación con Gemini CLI${NC}"
    fi

    # Probar ai-generate-docs si está disponible
    if [[ -x ~/bin/ai-generate-docs ]]; then
        echo -e "\n${CYAN}📚 Ejecutando ai-generate-docs:${NC}"
        ~/bin/ai-generate-docs "$temp_file" || echo -e "${YELLOW}⚠️ Requiere autenticación con Gemini CLI${NC}"
    fi

    # Limpiar archivo temporal
    rm -f "$temp_file"

    echo -e "\n${YELLOW}Presiona Enter para continuar...${NC}"
    read -r
}

# Función para demo de workflows
demo_workflows() {
    echo -e "\n${BLUE}🔄 Demostrando workflows de IA...${NC}"

    if [[ -x ~/.config/ai-workflows/run-workflow.sh ]]; then
        echo -e "${CYAN}Ejecutando: run-workflow.sh (mostrar ayuda)${NC}"
        ~/.config/ai-workflows/run-workflow.sh

        echo -e "\n${CYAN}Agentes disponibles:${NC}"
        if [[ -d ~/.config/ai-workflows/agents ]]; then
            for agent_file in ~/.config/ai-workflows/agents/*.poml; do
                if [[ -f "$agent_file" ]]; then
                    local agent_name
                    agent_name=$(basename "$agent_file" .poml)
                    echo -e "• ${agent_name}"

                    # Mostrar descripción del agente
                    if command -v grep &>/dev/null; then
                        local description
                        description=$(grep -o '<role>.*</role>' "$agent_file" 2>/dev/null | sed 's/<[^>]*>//g' | head -1)
                        if [[ -n "$description" ]]; then
                            echo -e "  ${CYAN}→ ${description:0:80}...${NC}"
                        fi
                    fi
                fi
            done
        fi
    else
        echo -e "${RED}❌ Sistema de workflows no configurado${NC}"
    fi

    echo -e "\n${YELLOW}Presiona Enter para continuar...${NC}"
    read -r
}

# Función para ejecutar tests
demo_run_tests() {
    echo -e "\n${BLUE}🧪 Ejecutando tests de instalación...${NC}"

    # Detect the correct test script location
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    TEST_SCRIPT=""

    if [[ -f "${SCRIPT_DIR}/modules/test-installation.sh" ]]; then
        TEST_SCRIPT="${SCRIPT_DIR}/modules/test-installation.sh"
    elif [[ -f "modules/test-installation.sh" ]]; then
        TEST_SCRIPT="modules/test-installation.sh"
    elif [[ -f "./test-installation.sh" ]]; then
        TEST_SCRIPT="./test-installation.sh"
    fi

    if [[ -n "$TEST_SCRIPT" ]]; then
        echo -e "${CYAN}Ejecutando test completo desde: ${TEST_SCRIPT}${NC}"
        bash "$TEST_SCRIPT"
    else
        echo -e "${RED}❌ Script de tests no encontrado${NC}"
        echo -e "${YELLOW}Ejecutando verificación manual...${NC}"

        # Verificación manual básica
        echo -e "\n${CYAN}Verificación rápida:${NC}"

        local components=("git" "node" "python" "nvim" "zsh")
        for component in "${components[@]}"; do
            if command -v "$component" &>/dev/null; then
                echo -e "${GREEN}✅ $component instalado${NC}"
            else
                echo -e "${RED}❌ $component no encontrado${NC}"
            fi
        done
    fi

    echo -e "\n${YELLOW}Presiona Enter para continuar...${NC}"
    read -r
}

# Función para mostrar configuración detallada
demo_detailed_config() {
    echo -e "\n${BLUE}⚙️ Configuración detallada del sistema${NC}"

    # Mostrar variables de entorno importantes
    echo -e "\n${CYAN}🌍 Variables de entorno:${NC}"
    echo -e "${WHITE}PATH:${NC} ${PATH:0:100}..."
    echo -e "${WHITE}HOME:${NC} $HOME"
    echo -e "${WHITE}SHELL:${NC} $SHELL"

    # Verificar autenticación de Gemini CLI
    if command -v gemini &>/dev/null; then
        echo -e "${WHITE}Gemini CLI:${NC} ${GREEN}Instalado${NC}"
        if gemini auth test &>/dev/null; then
            echo -e "${WHITE}Autenticación:${NC} ${GREEN}Configurada${NC}"
        else
            echo -e "${WHITE}Autenticación:${NC} ${YELLOW}Pendiente${NC}"
        fi
    else
        echo -e "${WHITE}Gemini CLI:${NC} ${RED}No instalado${NC}"
    fi

    # Mostrar archivos de configuración
    echo -e "\n${CYAN}📁 Archivos de configuración:${NC}"

    local config_files=(
        "$HOME/.zshrc:Configuración de Zsh"
        "$HOME/.config/nvim/init.lua:Configuración principal de Neovim"
        "$HOME/.config/ai-workflows/config.yaml:Configuración de workflows"
        "$HOME/.gitconfig:Configuración de Git"
    )

    for config_info in "${config_files[@]}"; do
        local config_file="${config_info%%:*}"
        local config_desc="${config_info##*:}"
        local expanded_file="${config_file/#\~/$HOME}"

        if [[ -f "$expanded_file" ]]; then
            echo -e "${GREEN}✅ ${config_desc}${NC} (${config_file})"
        else
            echo -e "${RED}❌ ${config_desc}${NC} (${config_file})"
        fi
    done

    # Mostrar estructura de directorios importante
    echo -e "\n${CYAN}📂 Estructura de directorios:${NC}"

    local important_dirs=(
        "$HOME/bin:Scripts ejecutables"
        "$HOME/.config/nvim:Configuración de Neovim"
        "$HOME/.config/ai-workflows:Workflows de IA"
        "$HOME/.oh-my-zsh:Oh My Zsh"
    )

    for dir_info in "${important_dirs[@]}"; do
        local dir_path="${dir_info%%:*}"
        local dir_desc="${dir_info##*:}"
        local expanded_dir="${dir_path/#\~/$HOME}"

        if [[ -d "$expanded_dir" ]]; then
            local file_count
            file_count=$(find "$expanded_dir" -type f 2>/dev/null | wc -l)
            echo -e "${GREEN}✅ ${dir_desc}${NC} (${dir_path}) - ${file_count} archivos"
        else
            echo -e "${RED}❌ ${dir_desc}${NC} (${dir_path})"
        fi
    done

    echo -e "\n${YELLOW}Presiona Enter para continuar...${NC}"
    read -r
}

# Función principal del demo
main() {
    while true; do
        show_demo_banner
        show_system_info
        demo_ai_tools
        demo_dev_environment

        echo -e "\n${CYAN}🎮 OPCIONES DE DEMO${NC}"
        echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${WHITE}1.${NC} 🎯 Demo interactivo completo"
        echo -e "${WHITE}2.${NC} 🧪 Ejecutar tests de instalación"
        echo -e "${WHITE}3.${NC} 📊 Mostrar información del sistema"
        echo -e "${WHITE}4.${NC} 🔄 Actualizar y volver a mostrar"
        echo -e "${WHITE}0.${NC} 🚪 Salir"

        echo -e "\n${YELLOW}Selecciona una opción [0-4]:${NC} "
        read -r choice

        case $choice in
            1)
                run_interactive_demo
                ;;
            2)
                demo_run_tests
                ;;
            3)
                clear
                show_system_info
                echo -e "\n${YELLOW}Presiona Enter para continuar...${NC}"
                read -r
                ;;
            4)
                continue
                ;;
            0)
                echo -e "\n${GREEN}🎉 ¡Gracias por probar Termux AI Development Environment!${NC}"
                echo -e "${CYAN}💡 Recuerda usar los comandos ai-* para desarrollo asistido por IA${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}❌ Opción inválida. Selecciona un número del 0-4.${NC}"
                sleep 2
                ;;
        esac
    done
}

# Ejecutar demo
main "$@"