# ====================================
# Zsh Functions Configuration
# Funciones útiles para desarrollo y gestión del sistema
# ====================================

# Crear directorio y navegar a él
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Extraer archivos automáticamente
extract() {
    if [ -f $1 ] ; then
        case $1 in
            *.tar.bz2)   tar xvjf $1     ;;
            *.tar.gz)    tar xvzf $1     ;; 
            *.bz2)       bunzip2 $1      ;; 
            *.rar)       unrar x $1      ;; 
            *.gz)        gunzip $1       ;; 
            *.tar)       tar xvf $1      ;; 
            *.tbz2)      tar xvjf $1     ;; 
            *.tgz)       tar xvzf $1     ;; 
            *.zip)       unzip $1        ;; 
            *.Z)         uncompress $1   ;; 
            *.7z)        7z x $1         ;; 
            *)           echo "'$1' cannot be extracted via >extract<" ;; 
        esac
    else
        echo "'$1' is not a valid file!"
    fi
}

# Buscar archivos y contenido
ff() {
    if command -v fd >/dev/null 2>&1; then
        fd -H -I -t f "$1"
    else
        find . -name "*$1*" -type f
    fi
}

# Buscar en contenido de archivos
fff() {
    if command -v rg >/dev/null 2>&1; then
        rg -i "$1"
    else
        grep -r -i "$1" .
    fi
}

# Información del sistema
sysinfo() {
    echo -e "\n${GREEN}System Information:${NC}"
    echo -e "${BLUE}OS:${NC} $(uname -sr)"
    echo -e "${BLUE}Shell:${NC} $SHELL"
    echo -e "${BLUE}Terminal:${NC} $TERM"
    echo -e "${BLUE}CPU:${NC} $(nproc) cores"
    echo -e "${BLUE}Memory:${NC} $(free -h | awk '/^Mem:/ {print $3 "/" $2}')"
    echo -e "${BLUE}Disk:${NC} $(df -h / | awk 'NR==2 {print $3 "/" $2 " (" $5 " used)"}' )"
    echo -e "${BLUE}Uptime:${NC} $(uptime -p)"
}

# Actualización rápida del sistema
sysupdate() {
    echo -e "${BLUE}Updating Termux packages...${NC}"
    pkg update && pkg upgrade
    if command -v pip3 >/dev/null 2>&1; then
        echo -e "${BLUE}Updating Python packages...${NC}"
        pip list --outdated --format=freeze | grep -v '^\-e' | cut -d = -f 1 | xargs -n1 pip install -U
    fi
    if command -v npm >/dev/null 2>&1; then
        echo -e "${BLUE}Updating Node.js packages...${NC}"
        npm update -g
    fi
    echo -e "${GREEN}System updated!${NC}"
}

# Función para configurar API keys
setup-ai-keys() {
    echo -e "${BLUE}Configurando agentes IA con OAuth2...${NC}"

    # Los agentes IA ahora usan OAuth2 automático
    echo -e "${CYAN}Los agentes IA (Codex, Gemini, Qwen) se configurarán automáticamente${NC}"
    echo -e "${CYAN}con autenticación OAuth2 durante la instalación.${NC}"

    # Información para el usuario
    cat > "$HOME/.ai-info" <<'AI_INFO'
# Información de Agentes IA - Termux AI Setup
#
# Agentes disponibles después de la instalación:
# - gemini auth login    # Autenticación Google OAuth2
# - codex login         # Autenticación OpenAI OAuth2
# - qwen-code           # Agente Qwen para código
#
# Uso: Los agentes se activan automáticamente después de login OAuth2
AI_INFO

    echo -e "${GREEN}Información de agentes IA configurada!${NC}"
}

# Función para obtener uso de CPU
get_cpu_usage() {
    if [[ -f /proc/stat ]]; then
        local cpu_line=$(head -n 1 /proc/stat)
        local cpu_values=(${cpu_line#cpu })
        local idle=${cpu_values[3]}
        local total=0
        for val in "${cpu_values[@]:0:8}"; do
            total=$((total + val))
        done
        if [[ $total -gt 0 ]]; then
            local usage=$(( (total - idle) * 100 / total ))
            echo "${usage}%"
        else
            echo "0%"
        fi
    else
        echo "N/A"
    fi
}

# Función para obtener uso de memoria
get_memory_usage() {
    if command -v free >/dev/null 2>&1; then
        local mem_info=$(free | grep '^Mem:')
        local total=$(echo $mem_info | awk '{print $2}')
        local used=$(echo $mem_info | awk '{print $3}')
        if [[ $total -gt 0 ]]; then
            local usage=$(( used * 100 / total ))
            echo "${usage}%"
        else
            echo "0%"
        fi
    else
        echo "N/A"
    fi
}

# Función para modo headless de Gemini con atajo 'g'
g() {
    if ! command -v gemini &> /dev/null; then
        echo "Error: El comando 'gemini' no está instalado o no se encuentra en el PATH."
        echo "Por favor, instálalo con: npm install -g @google/gemini-cli"
        return 1
    fi

    if [ -z "$1" ]; then
        echo "Uso: g \"tu pregunta\""
        return 1
    fi

    # Se elimina la comprobación 'gemini auth test' porque es poco fiable en algunos entornos.
    # El propio comando 'gemini -p' fallará con un error claro si la autenticación es necesaria.
    gemini -p "$*"
}
