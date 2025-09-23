#!/bin/bash

# ====================================
# TERMUX AI AGENT - Agente de IA Headless
# Sistema inteligente para administración de Termux
# Uso: : "tu pregunta aquí"
# ====================================

set -euo pipefail

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

# Configuración del agente
AGENT_NAME="TermuxAI"
SYSTEM_PROMPT="Eres un asistente especializado en Termux y desarrollo móvil. Tu función es:
1. Ayudar con comandos de terminal y configuración de Termux
2. Gestionar instalación de paquetes y herramientas de desarrollo
3. Configurar SSH, Git, GitHub y entornos de desarrollo
4. Resolver problemas técnicos y debugging
5. Sugerir mejores prácticas para desarrollo en Android/Termux
6. Generar scripts y código cuando sea necesario

Siempre responde de forma concisa pero completa. Si necesitas ejecutar comandos, explícalos primero.
Contexto: Usuario trabajando en Termux con acceso a pkg, git, ssh, y herramientas estándar de Linux."

# Función para mostrar banner del agente
show_agent_banner() {
    echo -e "${PURPLE}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║                                                                              ║${NC}"
    echo -e "${PURPLE}║                        🤖 TERMUX AI AGENT 🤖                                ║${NC}"
    echo -e "${PURPLE}║                                                                              ║${NC}"
    echo -e "${PURPLE}║                   Asistente IA para administración Termux                   ║${NC}"
    echo -e "${PURPLE}║                                                                              ║${NC}"
    echo -e "${PURPLE}║                    Uso: : \"tu pregunta aquí\"                                ║${NC}"
    echo -e "${PURPLE}║                                                                              ║${NC}"
    echo -e "${PURPLE}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# Función para verificar dependencias
check_dependencies() {
    local dependencies_met=true

    # Verificar Gemini CLI
    if ! command -v gemini &>/dev/null; then
        echo -e "${RED}❌ Gemini CLI no está instalado${NC}"
        dependencies_met=false
    fi

    # Verificar autenticación
    if ! gemini auth test &>/dev/null; then
        echo -e "${YELLOW}⚠️ Gemini CLI no está autenticado${NC}"
        echo -e "${CYAN}💡 Ejecuta 'gemini auth login' para autenticarte${NC}"
        dependencies_met=false
    fi

    if [[ "$dependencies_met" == "false" ]]; then
        return 1
    fi

    return 0
}

# Función para obtener contexto del sistema
get_system_context() {
    local context=""

    # Información básica del sistema
    context+="Sistema: $(uname -o 2>/dev/null || echo 'Android')\n"
    context+="Arquitectura: $(uname -m)\n"
    context+="Directorio actual: $(pwd)\n"
    context+="Usuario: $(whoami)\n"

    # Herramientas instaladas
    local tools=("git" "node" "python" "nvim" "zsh" "ssh")
    context+="Herramientas disponibles: "
    for tool in "${tools[@]}"; do
        if command -v "$tool" &>/dev/null; then
            context+="$tool "
        fi
    done
    context+="\n"

    # Estado de servicios importantes
    if [[ -d ~/.ssh ]]; then
        context+="SSH configurado: Sí\n"
    fi

    if [[ -f ~/.gitconfig ]]; then
        context+="Git configurado: Sí\n"
    fi

    if [[ -d ~/.oh-my-zsh ]]; then
        context+="Oh-My-Zsh: Instalado\n"
    fi

    echo -e "$context"
}

# Función para procesar consulta con IA
process_ai_query() {
    local user_query="$1"

    if [[ -z "$user_query" ]]; then
        echo -e "${RED}❌ Error: Consulta vacía${NC}"
        return 1
    fi

    # Verificar dependencias
    if ! check_dependencies; then
        return 1
    fi

    echo -e "${CYAN}🤖 Procesando consulta...${NC}"

    # Construir contexto completo
    local system_context
    system_context=$(get_system_context)

    local full_prompt="$SYSTEM_PROMPT

CONTEXTO DEL SISTEMA:
$system_context

CONSULTA DEL USUARIO:
$user_query

Responde de forma práctica y directa."

    # Ejecutar consulta con Gemini CLI en modo headless
    if ! gemini -p "$full_prompt" -m gemini-2.5-flash 2>/dev/null; then
        echo -e "${RED}❌ Error al procesar consulta con Gemini CLI${NC}"
        echo -e "${YELLOW}💡 Verifica tu conectividad y autenticación${NC}"
        return 1
    fi
}

# Función para mostrar ayuda
show_help() {
    echo -e "${CYAN}📚 TERMUX AI AGENT - Ayuda${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${WHITE}Uso básico:${NC}"
    echo -e "  ${GREEN}:${NC} \"¿Cómo instalar Python en Termux?\""
    echo -e "  ${GREEN}:${NC} \"Configurar SSH para GitHub\""
    echo -e "  ${GREEN}:${NC} \"¿Por qué falla mi script de Node.js?\""
    echo ""
    echo -e "${WHITE}Comandos del agente:${NC}"
    echo -e "  ${CYAN}--help${NC}        Mostrar esta ayuda"
    echo -e "  ${CYAN}--status${NC}      Estado del sistema y autenticación"
    echo -e "  ${CYAN}--setup${NC}       Configuración inicial de Gemini CLI"
    echo -e "  ${CYAN}--context${NC}     Mostrar contexto del sistema"
    echo ""
    echo -e "${WHITE}Ejemplos de consultas:${NC}"
    echo -e "  • Instalación de herramientas: ${YELLOW}\"Instalar Git y configurarlo\"${NC}"
    echo -e "  • Troubleshooting: ${YELLOW}\"Mi aplicación Node.js no inicia\"${NC}"
    echo -e "  • Configuración: ${YELLOW}\"Configurar Neovim para desarrollo\"${NC}"
    echo -e "  • Scripts: ${YELLOW}\"Crear script para backup automático\"${NC}"
    echo ""
}

# Función para mostrar estado
show_status() {
    echo -e "${CYAN}📊 ESTADO DEL SISTEMA${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    # Estado de Gemini CLI
    if command -v gemini &>/dev/null; then
        echo -e "${GREEN}✅ Gemini CLI instalado${NC}"
        if gemini auth test &>/dev/null; then
            echo -e "${GREEN}✅ Autenticación activa${NC}"
        else
            echo -e "${RED}❌ Sin autenticación${NC}"
        fi
    else
        echo -e "${RED}❌ Gemini CLI no instalado${NC}"
    fi

    # Mostrar contexto del sistema
    echo -e "\n${WHITE}Contexto del sistema:${NC}"
    get_system_context
}

# Función para configuración inicial
setup_agent() {
    echo -e "${CYAN}⚙️ CONFIGURACIÓN INICIAL${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    # Verificar e instalar Gemini CLI si no existe
    if ! command -v gemini &>/dev/null; then
        echo -e "${YELLOW}📦 Instalando Gemini CLI...${NC}"

        # Instalar Node.js si no existe (requerido para Gemini CLI)
        if ! command -v node &>/dev/null; then
            echo -e "${YELLOW}📦 Instalando Node.js...${NC}"
            pkg install -y nodejs-lts
        fi

    # Instalar Gemini CLI (paquete oficial)
    npm install -g @google/gemini-cli

        if command -v gemini &>/dev/null; then
            echo -e "${GREEN}✅ Gemini CLI instalado correctamente${NC}"
        else
            echo -e "${RED}❌ Error al instalar Gemini CLI${NC}"
            return 1
        fi
    fi

    # Configurar autenticación
    if ! gemini auth test &>/dev/null; then
        echo -e "${YELLOW}🔐 Configurando autenticación...${NC}"
        echo -e "${CYAN}Se abrirá el navegador para autenticación OAuth2${NC}"
        gemini auth login

        if gemini auth test &>/dev/null; then
            echo -e "${GREEN}✅ Autenticación configurada correctamente${NC}"
        else
            echo -e "${RED}❌ Error en la autenticación${NC}"
            return 1
        fi
    fi

        # Configurar modelo por defecto en settings.json si no existe
        local GEMINI_DIR="$HOME/.gemini"
        local SETTINGS_FILE="$GEMINI_DIR/settings.json"
        mkdir -p "$GEMINI_DIR"
        if [[ ! -f "$SETTINGS_FILE" ]]; then
                cat > "$SETTINGS_FILE" <<'JSON'
{
    "model": {
        "name": "gemini-2.5-flash"
    }
}
JSON
                echo -e "${GREEN}✅ Modelo por defecto configurado en ~/.gemini/settings.json${NC}"
        fi

    echo -e "\n${GREEN}🎉 ¡Agente configurado correctamente!${NC}"
    echo -e "${CYAN}💡 Ahora puedes usar: : \"tu consulta\"${NC}"
}

# Función principal
main() {
    local query=""

    # Procesar argumentos
    case "${1:-}" in
        "--help"|"-h")
            show_help
            exit 0
            ;;
        "--status"|"-s")
            show_status
            exit 0
            ;;
        "--setup")
            setup_agent
            exit 0
            ;;
        "--context")
            get_system_context
            exit 0
            ;;
        "")
            show_agent_banner
            show_help
            exit 0
            ;;
        *)
            query="$*"
            ;;
    esac

    # Procesar consulta
    process_ai_query "$query"
}

# Ejecutar función principal
main "$@"