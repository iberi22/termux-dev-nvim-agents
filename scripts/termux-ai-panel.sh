#!/bin/bash

# ====================================
# TERMUX AI PANEL - POST-INSTALLATION MANAGEMENT
# Panel de control para gestión post-instalación
# ====================================

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Configuration
INSTALL_DIR="$HOME/termux-dev-nvim-agents"
SRC_DIR="$HOME/src"
HTTP_PORT=9999

# Function to show banner
show_banner() {
    clear
    echo -e "${PURPLE}"
    echo "=============================================="
    echo "         TERMUX AI CONTROL PANEL"
    echo "    Post-Installation Management System"
    echo "=============================================="
    echo -e "${NC}\n"
}

# Function to check system health
check_system_health() {
    echo -e "${CYAN}🏥 Estado del Sistema${NC}"
    echo -e "${CYAN}========================${NC}"

    # Node.js version
    if command -v node >/dev/null 2>&1; then
        echo -e "${GREEN}✅ Node.js: $(node --version)${NC}"
    else
        echo -e "${RED}❌ Node.js: No instalado${NC}"
    fi

    # Git version
    if command -v git >/dev/null 2>&1; then
        echo -e "${GREEN}✅ Git: $(git --version | cut -d' ' -f3)${NC}"
    else
        echo -e "${RED}❌ Git: No instalado${NC}"
    fi

    # Zsh version
    if command -v zsh >/dev/null 2>&1; then
        echo -e "${GREEN}✅ Zsh: $(zsh --version | cut -d' ' -f2)${NC}"
    else
        echo -e "${RED}❌ Zsh: No instalado${NC}"
    fi

    # Neovim version
    if command -v nvim >/dev/null 2>&1; then
        echo -e "${GREEN}✅ Neovim: $(nvim --version | head -1 | cut -d' ' -f2)${NC}"
    else
        echo -e "${RED}❌ Neovim: No instalado${NC}"
    fi

    # Gemini CLI
    if command -v gemini >/dev/null 2>&1; then
        if gemini auth test >/dev/null 2>&1; then
            echo -e "${GREEN}✅ Gemini CLI: Autenticado${NC}"
        else
            echo -e "${YELLOW}⚠️ Gemini CLI: No autenticado${NC}"
        fi
    else
        echo -e "${RED}❌ Gemini CLI: No instalado${NC}"
    fi

    # SSH status
    if pgrep sshd >/dev/null 2>&1; then
        echo -e "${GREEN}✅ SSH Server: Activo${NC}"
    else
        echo -e "${YELLOW}⚠️ SSH Server: Inactivo${NC}"
    fi

    echo ""
}

# Function to show disk usage
show_disk_usage() {
    echo -e "${CYAN}💾 Uso del Disco${NC}"
    echo -e "${CYAN}==================${NC}"

    # Total disk usage
    echo -e "${BLUE}Espacio total usado por Termux:${NC}"
    du -sh "$HOME" 2>/dev/null || echo "No disponible"

    # Individual directories
    echo -e "\n${BLUE}Uso por directorios principales:${NC}"
    for dir in "$HOME/.npm" "$HOME/termux-dev-nvim-agents" "$HOME/src" "$HOME/.config"; do
        if [[ -d "$dir" ]]; then
            size=$(du -sh "$dir" 2>/dev/null | cut -f1)
            echo -e "  ${YELLOW}$(basename "$dir"):${NC} $size"
        fi
    done
    echo ""
}

# Function to show GitHub projects
show_github_projects() {
    echo -e "${CYAN}📂 Proyectos de GitHub${NC}"
    echo -e "${CYAN}======================${NC}"

    if [[ ! -d "$SRC_DIR" ]]; then
        echo -e "${YELLOW}⚠️ Directorio $SRC_DIR no existe${NC}"
        return
    fi

    local found_repos=false
    for repo_dir in "$SRC_DIR"/*; do
        if [[ -d "$repo_dir/.git" ]]; then
            found_repos=true
            local repo_name=$(basename "$repo_dir")
            local current_branch=$(cd "$repo_dir" && git branch --show-current 2>/dev/null || echo "unknown")
            local status=$(cd "$repo_dir" && git status --porcelain 2>/dev/null)

            echo -e "${BLUE}📁 $repo_name${NC} (${YELLOW}$current_branch${NC})"

            if [[ -n "$status" ]]; then
                echo -e "   ${RED}🔴 Cambios pendientes${NC}"
                echo "$status" | head -3 | sed 's/^/     /'
                if [[ $(echo "$status" | wc -l) -gt 3 ]]; then
                    echo "     ... y $(($(echo "$status" | wc -l) - 3)) más"
                fi
            else
                echo -e "   ${GREEN}✅ Sin cambios${NC}"
            fi
            echo ""
        fi
    done

    if [[ "$found_repos" == false ]]; then
        echo -e "${YELLOW}⚠️ No se encontraron repositorios en $SRC_DIR${NC}"
    fi
    echo ""
}

# Function to show SSH public key
show_ssh_key() {
    echo -e "${CYAN}🔑 Llave SSH Pública${NC}"
    echo -e "${CYAN}===================${NC}"

    if [[ -f "$HOME/.ssh/id_ed25519.pub" ]]; then
        echo -e "${GREEN}Tu llave SSH pública (para GitHub):${NC}"
        echo -e "${CYAN}====================================${NC}"
        cat "$HOME/.ssh/id_ed25519.pub"
        echo -e "${CYAN}====================================${NC}"
    else
        echo -e "${RED}❌ No se encontró llave SSH pública${NC}"
        echo -e "${YELLOW}💡 Ejecuta: ssh-keygen -t ed25519 -C 'tu@email.com'${NC}"
    fi
    echo ""
}

# Function to enable SSH server
enable_ssh_server() {
    echo -e "${CYAN}🌐 Habilitando Servidor SSH...${NC}"

    if command -v sv-enable >/dev/null 2>&1; then
        sv-enable sshd
        echo -e "${GREEN}✅ Servidor SSH habilitado permanentemente${NC}"
        local ip=$(ifconfig wlan0 2>/dev/null | grep 'inet ' | awk '{print $2}' | head -1 || echo "IP_NO_DISPONIBLE")
        echo -e "${CYAN}Conéctate usando: ssh -p 8022 $(whoami)@$ip${NC}"
    else
        echo -e "${RED}❌ termux-services no disponible${NC}"
        echo -e "${YELLOW}💡 Instala con: pkg install termux-services${NC}"
    fi
    echo ""
}

# Function to start web interface
start_web_interface() {
    echo -e "${CYAN}🌐 Iniciando Interfaz Web Completa...${NC}"

    local panel_script="$INSTALL_DIR/start-panel.sh"

    if [[ -f "$panel_script" ]]; then
        echo -e "${BLUE}🚀 Verificando dependencias...${NC}"

        # Check if dependencies are installed
        if ! bash "$panel_script" status >/dev/null 2>&1; then
            echo -e "${YELLOW}📦 Instalando dependencias por primera vez...${NC}"
            bash "$panel_script" install
        fi

        echo -e "${GREEN}✅ Iniciando interfaz web completa...${NC}"
        echo -e "${CYAN}Frontend: http://localhost:3000${NC}"
        echo -e "${CYAN}Backend:  http://localhost:8000${NC}"
        echo -e "${YELLOW}💡 Presiona Ctrl+C para detener${NC}"

        # Start in development mode
        bash "$panel_script" dev
    else
        echo -e "${RED}❌ Script de panel web no encontrado${NC}"
        echo -e "${YELLOW}💡 Ejecuta la instalación completa primero${NC}"
    fi
}

# Function to start HTTP server
start_http_server() {
    echo -e "${CYAN}🌐 Iniciando Servidor HTTP en puerto $HTTP_PORT...${NC}"

    # Create a simple index page
    local web_dir="$HOME/termux-web"
    mkdir -p "$web_dir"

    cat > "$web_dir/index.html" << 'EOF'
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Termux AI Panel</title>
    <style>
        body { font-family: Arial, sans-serif; background: #1a1a1a; color: #fff; margin: 0; padding: 20px; }
        .container { max-width: 800px; margin: 0 auto; }
        h1 { color: #4CAF50; text-align: center; }
        .card { background: #2a2a2a; border-radius: 8px; padding: 20px; margin: 10px 0; }
        .status { display: inline-block; padding: 4px 12px; border-radius: 4px; font-size: 0.9em; }
        .status.online { background: #4CAF50; }
        .status.offline { background: #f44336; }
        .btn { background: #2196F3; color: white; padding: 10px 20px; text-decoration: none; border-radius: 4px; display: inline-block; margin: 5px; }
        .btn:hover { background: #1976D2; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🤖 Termux AI Control Panel</h1>
        <div class="card">
            <h2>Estado del Sistema</h2>
            <p>Servidor HTTP: <span class="status online">En Línea</span></p>
            <p>Puerto: <strong>9999</strong></p>
            <p>Acceso desde: <strong>http://DEVICE_IP:9999</strong></p>
        </div>
        <div class="card">
            <h2>Acciones Rápidas</h2>
            <a href="#" class="btn" onclick="alert('Función en desarrollo')">⚙️ Configuración</a>
            <a href="#" class="btn" onclick="alert('Función en desarrollo')">📊 Monitoreo</a>
            <a href="#" class="btn" onclick="alert('Función en desarrollo')">🔄 Actualizar</a>
        </div>
        <div class="card">
            <h2>Información</h2>
            <p>Este es el panel de control web de Termux AI.</p>
            <p>Próximamente: interfaz completa con WebSockets y FastAPI.</p>
        </div>
    </div>
</body>
</html>
EOF

    echo -e "${GREEN}✅ Página web creada en $web_dir${NC}"

    # Try Python HTTP server first, then busybox
    if command -v python3 >/dev/null 2>&1; then
        echo -e "${BLUE}🐍 Usando Python HTTP Server...${NC}"
        cd "$web_dir"
        echo -e "${CYAN}🌐 Servidor disponible en: http://localhost:$HTTP_PORT${NC}"
        echo -e "${YELLOW}💡 Presiona Ctrl+C para detener el servidor${NC}"
        python3 -m http.server "$HTTP_PORT"
    elif command -v busybox >/dev/null 2>&1; then
        echo -e "${BLUE}📦 Usando BusyBox HTTP Server...${NC}"
        cd "$web_dir"
        echo -e "${CYAN}🌐 Servidor disponible en: http://localhost:$HTTP_PORT${NC}"
        echo -e "${YELLOW}💡 Presiona Ctrl+C para detener el servidor${NC}"
        busybox httpd -f -p "$HTTP_PORT"
    else
        echo -e "${RED}❌ No se encontró Python ni BusyBox para el servidor HTTP${NC}"
        echo -e "${YELLOW}💡 Instala Python: pkg install python${NC}"
    fi
}

# Function to show main panel menu
show_panel_menu() {
    echo -e "${CYAN}┌─────────────────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│                PANEL DE CONTROL                 │${NC}"
    echo -e "${CYAN}├─────────────────────────────────────────────────┤${NC}"
    echo -e "${WHITE}│  1. 🏥 Ver Estado del Sistema                  │${NC}"
    echo -e "${WHITE}│  2. 💾 Ver Uso del Disco                       │${NC}"
    echo -e "${WHITE}│  3. 📂 Ver Proyectos de GitHub                 │${NC}"
    echo -e "${WHITE}│  4. 🔑 Mostrar Llave SSH Pública               │${NC}"
    echo -e "${WHITE}│  5. 🌐 Habilitar Servidor SSH                  │${NC}"
    echo -e "${WHITE}│  6. 🖥️  Iniciar Servidor HTTP (Puerto 9999)    │${NC}"
    echo -e "${GREEN}│  7. 🌐 Iniciar Interfaz Web Completa (3000/8000)│${NC}"
    echo -e "${WHITE}│  8. 📊 Vista Completa del Sistema              │${NC}"
    echo -e "${WHITE}│  9. 🔄 Volver al Setup Principal               │${NC}"
    echo -e "${WHITE}│ 99. 🚪 Salir                                   │${NC}"
    echo -e "${CYAN}└─────────────────────────────────────────────────┘${NC}"
    echo -e "\n${YELLOW}Select an option [1-9, 99]:${NC} "
}

# Function to show complete system overview
show_complete_overview() {
    show_banner
    check_system_health
    show_disk_usage
    show_github_projects
}

# Main function
main() {
    # Handle direct actions
    case "${1:-}" in
        "health")
            show_banner
            check_system_health
            exit 0
            ;;
        "disk")
            show_banner
            show_disk_usage
            exit 0
            ;;
        "projects"|"repos")
            show_banner
            show_github_projects
            exit 0
            ;;
        "ssh-key")
            show_banner
            show_ssh_key
            exit 0
            ;;
        "http"|"server")
            show_banner
            start_http_server
            exit 0
            ;;
        "overview")
            show_complete_overview
            exit 0
            ;;
    esac

    # Interactive menu
    while true; do
        show_banner
        show_panel_menu
        read -r choice

        case $choice in
            1)
                check_system_health
                ;;
            2)
                show_disk_usage
                ;;
            3)
                show_github_projects
                ;;
            4)
                show_ssh_key
                ;;
            5)
                enable_ssh_server
                ;;
            6)
                start_http_server
                return 0
                ;;
            7)
                start_web_interface
                return 0
                ;;
            8)
                show_complete_overview
                ;;
            9)
                if [[ -f "$INSTALL_DIR/setup.sh" ]]; then
                    echo -e "${BLUE}🔄 Lanzando setup principal...${NC}"
                    exec bash "$INSTALL_DIR/setup.sh"
                else
                    echo -e "${RED}❌ Setup principal no encontrado${NC}"
                fi
                ;;
            99)
                echo -e "${GREEN}¡Gracias por usar Termux AI Panel!${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}[ERROR] Opción inválida. Selecciona 1-9 o 99.${NC}"
                sleep 2
                ;;
        esac

        if [[ $choice != 6 && $choice != 7 ]]; then  # Don't pause for servers
            echo -e "\n${YELLOW}Presiona Enter para continuar...${NC}"
            read -r
        fi
    done
}

# Execute main function
main "$@"