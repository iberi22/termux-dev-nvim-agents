#!/bin/bash

# ====================================
# MÓDULO: Instalación y Configuración de Zsh
# Instala Zsh, Oh My Zsh, plugins y métricas de sistema
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

echo -e "${BLUE}🐚 Configurando Zsh + Oh My Zsh...${NC}"

# Verificar si Zsh ya está instalado
if command -v zsh >/dev/null 2>&1; then
    echo -e "${GREEN}✅ Zsh ya está instalado${NC}"
else
    echo -e "${YELLOW}📦 Instalando Zsh...${NC}"
    if ! pkg install -y zsh; then
        echo -e "${RED}❌ Error instalando Zsh${NC}"
        exit 1
    fi
    echo -e "${GREEN}✅ ZP10K_CONFIG

echo -e "${GREEN}✅ Configuración de Powerlevel10k creada${NC}"

# Validar que Powerlevel10k se instaló correctamente
if [[ -f "$HOME/.p10k.zsh" ]]; then
    echo -e "${GREEN}✅ Archivo .p10k.zsh verificado${NC}"
else
    echo -e "${YELLOW}⚠️ Creando archivo .p10k.zsh de respaldo...${NC}"
    cat > "$HOME/.p10k.zsh" << 'EOF'
# Configuración mínima de Powerlevel10k
# Si ves este mensaje, ejecuta 'p10k configure' para personalizar tu prompt

# Enable Powerlevel10k instant prompt
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Configuración básica
typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir vcs)
typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status command_execution_time background_jobs)
typeset -g POWERLEVEL9K_MODE='nerdfont-complete'
EOF
    echo -e "${GREEN}✅ Archivo .p10k.zsh de respaldo creado${NC}"
fi

echo -e "\n${GREEN}📊 RESUMEN DE CONFIGURACIÓN ZSH${NC}"h instalado correctamente${NC}"
fi

# Verificar si Oh My Zsh ya está instalado
if [[ -d "$HOME/.oh-my-zsh" ]]; then
    echo -e "${GREEN}✅ Oh My Zsh ya está instalado${NC}"
else
    echo -e "${YELLOW}🎨 Instalando Oh My Zsh...${NC}"

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
    echo -e "${BLUE}📥 Instalando zsh-autosuggestions...${NC}"
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    echo -e "${GREEN}✅ zsh-autosuggestions instalado${NC}"
fi

# zsh-syntax-highlighting
if [[ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" ]]; then
    echo -e "${BLUE}📥 Instalando zsh-syntax-highlighting...${NC}"
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
    echo -e "${GREEN}✅ zsh-syntax-highlighting instalado${NC}"
fi

# zsh-completions
if [[ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-completions" ]]; then
    echo -e "${BLUE}📥 Instalando zsh-completions...${NC}"
    git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-completions
    echo -e "${GREEN}✅ zsh-completions instalado${NC}"
fi

# Instalar Yazi (explorador de archivos terminal)
echo -e "${YELLOW}📂 Instalando Yazi (explorador de archivos)...${NC}"
if ! command -v yazi >/dev/null 2>&1; then
    # Instalar desde cargo (Rust package manager) ya que pkg no incluye yazi aún
    if ! command -v cargo >/dev/null 2>&1; then
        echo -e "${BLUE}📦 Instalando Rust para Yazi...${NC}"
        pkg install -y rust
    fi
    
    if command -v cargo >/dev/null 2>&1; then
        echo -e "${BLUE}📥 Compilando Yazi desde fuente...${NC}"
        cargo install --locked yazi-fm yazi-cli
        echo -e "${GREEN}✅ Yazi instalado${NC}"
    else
        echo -e "${YELLOW}⚠️ No se pudo instalar Yazi, continuando...${NC}"
    fi
else
    echo -e "${GREEN}✅ Yazi ya está instalado${NC}"
fi

# Instalar plugin de Yazi para Oh My Zsh
if [[ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/yazi" ]]; then
    echo -e "${BLUE}📥 Instalando plugin de Yazi para Zsh...${NC}"
    git clone https://github.com/DreamMaoMao/yazi.zsh ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/yazi
    echo -e "${GREEN}✅ Plugin de Yazi instalado${NC}"
fi

# Instalar tema Powerlevel10k
if [[ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]]; then
    echo -e "${BLUE}🎨 Instalando tema Powerlevel10k...${NC}"
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
    echo -e "${GREEN}✅ Powerlevel10k instalado${NC}"
fi

# Crear configuración .zshrc optimizada
echo -e "${YELLOW}⚙️ Configurando .zshrc...${NC}"

# Backup del .zshrc existente si existe
if [[ -f "$HOME/.zshrc" ]]; then
    cp "$HOME/.zshrc" "$HOME/.zshrc.backup.$(date +%Y%m%d_%H%M%S)"
    echo -e "${BLUE}📄 Backup de .zshrc creado${NC}"
fi

# Crear nueva configuración .zshrc optimizada para desarrollo con IA
cat > "$HOME/.zshrc" << 'EOF'
# ====================================
# ZSH Configuration for AI Development
# Termux AI Setup v2.0
# ====================================

# Oh My Zsh path
export ZSH="$HOME/.oh-my-zsh"

# Tema - Powerlevel10k (configurar con p10k configure)
ZSH_THEME="powerlevel10k/powerlevel10k"

# Plugins esenciales
plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
    zsh-completions
    history-substring-search
    colored-man-pages
    extract
    z
    yazi
    node
    npm
    python
    pip
    docker
    kubectl
)

# Cargar Oh My Zsh
source $ZSH/oh-my-zsh.sh

# ====================================
# CONFIGURACIÓN PERSONALIZADA
# ====================================

# Variables de entorno
export EDITOR='nvim'
export VISUAL='nvim'
export BROWSER='termux-open'
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Configuración de Node.js
export NODE_OPTIONS="--max-old-space-size=4096"

# Configuración de Python
export PYTHONPATH="$HOME/.local/lib/python3.11/site-packages:$PYTHONPATH"

# Path personalizado
export PATH="$HOME/.local/bin:$HOME/bin:$PATH"
export PATH="$HOME/.npm-global/bin:$PATH"

# ====================================
# ALIASES PERSONALIZADOS
# ====================================

# Navegación mejorada
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ~='cd ~'
alias -- -='cd -'

# Listado mejorado
alias ls='exa --icons --group-directories-first'
alias ll='exa -la --icons --group-directories-first'
alias la='exa -a --icons --group-directories-first'
alias lt='exa --tree --level=2 --icons'
alias l='exa --icons --group-directories-first'

# Git aliases mejorados
alias g='git'
alias gs='git status -sb'
alias ga='git add'
alias gaa='git add --all'
alias gc='git commit -v'
alias gcm='git commit -m'
alias gco='git checkout'
alias gb='git branch'
alias gp='git push'
alias gl='git pull'
alias glog='git log --oneline --graph --decorate --all'
alias gd='git diff'
alias gds='git diff --staged'

# Herramientas modernas
alias cat='bat --paging=never'
alias find='fd'
alias grep='rg'
alias du='dust'
alias df='duf'
alias ps='procs'
alias top='htop'

# Yazi (explorador de archivos)
alias y='yazi'
alias yy='yazi .'
alias yz='yazi --cwd-file=/tmp/yazi-cwd'

# Termux específicos
alias apt='pkg'
alias install='pkg install'
alias search='pkg search'
alias update='pkg update && pkg upgrade'
alias python='python3'
alias pip='pip3'

# Desarrollo
alias vi='nvim'
alias vim='nvim'
alias code='nvim'
alias serve='python3 -m http.server'
alias json='jq .'
alias weather='curl wttr.in'

# Docker (si está disponible)
alias d='docker'
alias dc='docker-compose'
alias dps='docker ps'
alias di='docker images'

# ====================================
# FUNCIONES ÚTILES
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
    fd -H -I -t f "$1"
}

# Buscar en contenido de archivos
fff() {
    rg -i "$1"
}

# Información del sistema
sysinfo() {
    echo -e "\n${GREEN}System Information:${NC}"
    echo -e "${BLUE}OS:${NC} $(uname -sr)"
    echo -e "${BLUE}Shell:${NC} $SHELL"
    echo -e "${BLUE}Terminal:${NC} $TERM"
    echo -e "${BLUE}CPU:${NC} $(nproc) cores"
    echo -e "${BLUE}Memory:${NC} $(free -h | awk '/^Mem:/ {print $3 "/" $2}')"
    echo -e "${BLUE}Disk:${NC} $(df -h / | awk 'NR==2 {print $3 "/" $2 " (" $5 " used)"}')"
    echo -e "${BLUE}Uptime:${NC} $(uptime -p)"
}

# Actualización rápida del sistema
sysupdate() {
    echo -e "${BLUE}Updating Termux packages...${NC}"
    pkg update && pkg upgrade
    echo -e "${BLUE}Updating Python packages...${NC}"
    pip list --outdated --format=freeze | grep -v '^\-e' | cut -d = -f 1 | xargs -n1 pip install -U
    echo -e "${BLUE}Updating Node.js packages...${NC}"
    npm update -g
    echo -e "${GREEN}System updated!${NC}"
}

# ====================================
# CONFIGURACIÓN DE HERRAMIENTAS
# ====================================

# Zoxide (mejor cd)
if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init zsh)"
fi

# FZF configuración
if command -v fzf >/dev/null 2>&1; then
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
    export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
fi

# Autocompletado para zsh-completions
autoload -U compinit && compinit

# ====================================
# CONFIGURACIÓN DE IA (API KEYS)
# ====================================

# Cargar variables de entorno para APIs de IA
if [[ -f "$HOME/.ai-env" ]]; then
    source "$HOME/.ai-env"
fi

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

# ====================================
# MENSAJES DE BIENVENIDA
# ====================================

# Mostrar información útil al iniciar
if [[ -o interactive ]]; then
    echo -e "${PURPLE}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║                    🚀 TERMUX AI READY 🤖                    ║${NC}"
    echo -e "${PURPLE}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo -e "${CYAN}💡 Tip: Type 'sysinfo' for system info, 'sysupdate' to update all${NC}"
    echo -e "${CYAN}🔧 Type 'setup-ai-keys' to configure AI API keys${NC}"
    echo -e "${CYAN}📚 Type 'nvim' to start coding with AI assistance${NC}"
fi

# Cargar configuración local si existe
if [[ -f "$HOME/.zshrc.local" ]]; then
    # shellcheck disable=SC1090
    source "$HOME/.zshrc.local"
fi

# ====================================
# FUNCIONES DE MÉTRICAS DE SISTEMA
# ====================================

# Función para obtener uso de CPU
get_cpu_usage() {
    if [[ -f /proc/stat ]]; then
        local cpu_line=\$(head -n 1 /proc/stat)
        local cpu_values=(\${cpu_line#cpu })
        local idle=\${cpu_values[3]}
        local total=0
        for val in "\${cpu_values[@]:0:8}"; do
            total=\$((total + val))
        done
        if [[ \$total -gt 0 ]]; then
            local usage=\$(( (total - idle) * 100 / total ))
            echo "\${usage}%"
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
        local mem_info=\$(free | grep '^Mem:')
        local total=\$(echo \$mem_info | awk '{print \$2}')
        local used=\$(echo \$mem_info | awk '{print \$3}')
        if [[ \$total -gt 0 ]]; then
            local usage=\$(( used * 100 / total ))
            echo "\${usage}%"
        else
            echo "0%"
        fi
    elif [[ -f /proc/meminfo ]]; then
        local total=\$(grep '^MemTotal:' /proc/meminfo | awk '{print \$2}')
        local available=\$(grep '^MemAvailable:' /proc/meminfo | awk '{print \$2}')
        if [[ -z "\$available" ]]; then
            available=\$(grep '^MemFree:' /proc/meminfo | awk '{print \$2}')
        fi
        if [[ \$total -gt 0 && -n "\$available" ]]; then
            local used=\$((total - available))
            local usage=\$(( used * 100 / total ))
            echo "\${usage}%"
        else
            echo "0%"
        fi
    else
        echo "N/A"
    fi
}

# Función personalizada para mostrar métricas en el prompt
prompt_system_metrics() {
    local cpu=\$(get_cpu_usage)
    local mem=\$(get_memory_usage)
    local cpu_color="%F{green}"
    local mem_color="%F{green}"

    # Cambiar colores según el uso
    case \${cpu%\%} in
        [0-9]|[1-5][0-9]) cpu_color="%F{green}" ;;
        [6-7][0-9]) cpu_color="%F{yellow}" ;;
        [8-9][0-9]|100) cpu_color="%F{red}" ;;
    esac

    case \${mem%\%} in
        [0-9]|[1-5][0-9]) mem_color="%F{green}" ;;
        [6-7][0-9]) mem_color="%F{yellow}" ;;
        [8-9][0-9]|100) mem_color="%F{red}" ;;
    esac

    p10k segment -f 15 -b 4 -i '💻' -t "\${cpu_color}\${cpu}%f \${mem_color}\${mem}%f"
}

# Aliases para comandos de IA
alias ai-chat='nvim -c "CodeCompanionChat"'
alias ai-help='ai-help'
alias ai-review='ai-code-review'
alias ai-docs='ai-generate-docs'
alias ai-init='ai-init-project'

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
EOF

# Cambiar shell por defecto a Zsh
echo -e "${YELLOW}🔄 Configurando Zsh como shell por defecto...${NC}"

# En Termux, cambiar el shell por defecto
if ! grep -q "exec zsh" "$HOME/.bashrc" 2>/dev/null; then
    echo "" >> "$HOME/.bashrc"
    echo "# Auto-start Zsh" >> "$HOME/.bashrc"
    echo "if [ -x /data/data/com.termux/files/usr/bin/zsh ]; then" >> "$HOME/.bashrc"
    echo "    export SHELL=/data/data/com.termux/files/usr/bin/zsh" >> "$HOME/.bashrc"
    echo "    exec zsh" >> "$HOME/.bashrc"
    echo "fi" >> "$HOME/.bashrc"
fi

# Instalar fuentes necesarias para Powerlevel10k
echo -e "${YELLOW}🔤 Configurando fuentes para Powerlevel10k...${NC}"

# Crear directorio de fuentes si no existe
mkdir -p "$HOME/.termux"

# Crear configuración de Powerlevel10k con métricas de sistema
echo -e "${YELLOW}⚙️ Creando configuración de Powerlevel10k con métricas...${NC}"

cat > "$HOME/.p10k.zsh" << 'P10K_CONFIG'
# Generated by Powerlevel10k configuration wizard.
# Custom Rastafari Theme Configuration - Red, Yellow, Green
# Based on romkatv/powerlevel10k.

# Temporarily change options.
'builtin' 'local' '-a' 'p10k_config_opts'
[[ ! -o 'aliases'         ]] || p10k_config_opts+=('aliases')
[[ ! -o 'sh_glob'         ]] || p10k_config_opts+=('sh_glob')
[[ ! -o 'no_brace_expand' ]] || p10k_config_opts+=('no_brace_expand')
'builtin' 'setopt' 'no_aliases' 'no_sh_glob' 'brace_expand'

() {
  emulate -L zsh -o extended_glob

  # Unset all configuration options. This allows you to apply configuration changes without
  # restarting zsh. Edit ~/.p10k.zsh and type `source ~/.p10k.zsh`.
  unset -m '(POWERLEVEL9K_*|DEFAULT_USER)~POWERLEVEL9K_GITSTATUS_DIR'

  # Zsh >= 5.1 is required.
  [[ $ZSH_VERSION == (5.<1->*|<6->.*) ]] || return

  # RASTAFARI RAINBOW STYLE CONFIGURATION
  # Red, Yellow, Green block style with newline for commands

  # The list of segments shown on the left (top line - info block)
  typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
    os_icon                 # OS identifier
    dir                     # current directory
    vcs                     # git status
    system_cpu              # CPU usage
    system_memory           # Memory usage
    status                  # exit code
    background_jobs         # background jobs
    virtualenv              # python virtual environment
    context                 # user@hostname
  )

  # The list of segments shown on the right - keep empty for block style
  typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=()

  # Enable multi-line prompt with command on separate line
  typeset -g POWERLEVEL9K_PROMPT_ON_NEWLINE=true
  typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX=''
  typeset -g POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX='%F{green}❯%f '
  typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_SUFFIX=''
  typeset -g POWERLEVEL9K_MULTILINE_LAST_PROMPT_SUFFIX=''

  # Define custom CPU usage segment
  function prompt_system_cpu() {
    local cpu_usage=0

    # Get CPU usage from /proc/stat
    if [[ -f /proc/stat ]]; then
      local cpu_line=$(head -n 1 /proc/stat)
      local cpu_values=(${cpu_line#cpu })
      local idle=${cpu_values[3]}
      local total=0
      for val in "${cpu_values[@]:0:8}"; do
        total=$((total + val))
      done
      if [[ $total -gt 0 ]]; then
        cpu_usage=$(( (total - idle) * 100 / total ))
      fi
    fi

    # Rastafari color scheme based on usage
    local cpu_bg cpu_fg
    if (( cpu_usage < 30 )); then
      cpu_bg=2    # Green background
      cpu_fg=0    # Black foreground
    elif (( cpu_usage < 70 )); then
      cpu_bg=3    # Yellow background
      cpu_fg=0    # Black foreground
    else
      cpu_bg=1    # Red background
      cpu_fg=15   # White foreground
    fi

    p10k segment -f $cpu_fg -b $cpu_bg -i '🔥' -t "CPU ${cpu_usage}%"
  }

  # Define custom Memory usage segment
  function prompt_system_memory() {
    local mem_free_mb=0 mem_usage=0

    # Get Memory info from /proc/meminfo
    if [[ -f /proc/meminfo ]]; then
      local total_kb=$(grep '^MemTotal:' /proc/meminfo | awk '{print $2}')
      local available_kb=$(grep '^MemAvailable:' /proc/meminfo | awk '{print $2}')
      if [[ -z "$available_kb" ]]; then
        available_kb=$(grep '^MemFree:' /proc/meminfo | awk '{print $2}')
      fi

      if [[ $total_kb -gt 0 && -n "$available_kb" ]]; then
        mem_free_mb=$(( available_kb / 1024 ))
        local used_kb=$((total_kb - available_kb))
        mem_usage=$(( used_kb * 100 / total_kb ))
      fi
    fi

    # Rastafari color scheme based on usage
    local mem_bg mem_fg
    if (( mem_usage < 30 )); then
      mem_bg=2    # Green background
      mem_fg=0    # Black foreground
    elif (( mem_usage < 70 )); then
      mem_bg=3    # Yellow background
      mem_fg=0    # Black foreground
    else
      mem_bg=1    # Red background
      mem_fg=15   # White foreground
    fi

    p10k segment -f $mem_fg -b $mem_bg -i '�' -t "${mem_free_mb}MB Free"
  }

  # RASTAFARI RAINBOW BLOCK STYLE CONFIGURATION

  # Basic style options for rainbow block appearance
  typeset -g POWERLEVEL9K_BACKGROUND=0                          # Black default background
  typeset -g POWERLEVEL9K_LEFT_SUBSEGMENT_SEPARATOR=''          # No subsegment separator
  typeset -g POWERLEVEL9K_RIGHT_SUBSEGMENT_SEPARATOR=''         # No subsegment separator
  typeset -g POWERLEVEL9K_LEFT_SEGMENT_SEPARATOR=''             # No segment separator for block effect
  typeset -g POWERLEVEL9K_RIGHT_SEGMENT_SEPARATOR=''            # No segment separator for block effect
  typeset -g POWERLEVEL9K_LEFT_PROMPT_FIRST_SEGMENT_START_SYMBOL=''
  typeset -g POWERLEVEL9K_LEFT_PROMPT_LAST_SEGMENT_END_SYMBOL=''
  typeset -g POWERLEVEL9K_RIGHT_PROMPT_FIRST_SEGMENT_START_SYMBOL=''
  typeset -g POWERLEVEL9K_RIGHT_PROMPT_LAST_SEGMENT_END_SYMBOL=''

  # Add empty line before each prompt for better readability
  typeset -g POWERLEVEL9K_PROMPT_ADD_NEWLINE=true

  # Current directory - GREEN block (Rastafari style)
  typeset -g POWERLEVEL9K_DIR_FOREGROUND=0                      # Black text
  typeset -g POWERLEVEL9K_DIR_BACKGROUND=2                      # Green background
  typeset -g POWERLEVEL9K_SHORTEN_STRATEGY=truncate_to_unique
  typeset -g POWERLEVEL9K_SHORTEN_DELIMITER=
  typeset -g POWERLEVEL9K_DIR_SHORTENED_FOREGROUND=0            # Black for shortened paths
  typeset -g POWERLEVEL9K_DIR_ANCHOR_FOREGROUND=0               # Black for anchors
  typeset -g POWERLEVEL9K_DIR_ANCHOR_BOLD=true
  local anchor_files=(
    .bzr
    .citc
    .git
    .hg
    .node-version
    .python-version
    .go-version
    .ruby-version
    .lua-version
    .java-version
    .perl-version
    .php-version
    .tool-versions
    .shims
    .svn
    .terraform
    CVS
    Cargo.toml
    composer.json
    go.mod
    package.json
    stack.yaml
  )
  typeset -g POWERLEVEL9K_SHORTEN_FOLDER_MARKER="(${(j:|:)anchor_files})"
  typeset -g POWERLEVEL9K_DIR_TRUNCATE_BEFORE_MARKER=false
  typeset -g POWERLEVEL9K_SHORTEN_DIR_LENGTH=1
  typeset -g POWERLEVEL9K_DIR_MAX_LENGTH=80
  typeset -g POWERLEVEL9K_DIR_MIN_COMMAND_COLUMNS=40
  typeset -g POWERLEVEL9K_DIR_MIN_COMMAND_COLUMNS_PCT=50
  typeset -g POWERLEVEL9K_DIR_HYPERLINK=false
  typeset -g POWERLEVEL9K_DIR_SHOW_WRITABLE=v3

  # Git status - YELLOW block (Rastafari style)
  typeset -g POWERLEVEL9K_VCS_BRANCH_ICON='⎇ '
  typeset -g POWERLEVEL9K_VCS_UNTRACKED_ICON='?'
  typeset -g POWERLEVEL9K_VCS_CLEAN_FOREGROUND=0                # Black text
  typeset -g POWERLEVEL9K_VCS_CLEAN_BACKGROUND=3               # Yellow background
  typeset -g POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND=0           # Black text
  typeset -g POWERLEVEL9K_VCS_UNTRACKED_BACKGROUND=3           # Yellow background
  typeset -g POWERLEVEL9K_VCS_MODIFIED_FOREGROUND=0            # Black text
  typeset -g POWERLEVEL9K_VCS_MODIFIED_BACKGROUND=3            # Yellow background

  # OS identifier - RED block (Rastafari style)
  typeset -g POWERLEVEL9K_OS_ICON_FOREGROUND=15                # White text
  typeset -g POWERLEVEL9K_OS_ICON_BACKGROUND=1                 # Red background

  # Context format: user@hostname - GREEN block (Rastafari style)
  typeset -g POWERLEVEL9K_CONTEXT_TEMPLATE='%n@%m'
  typeset -g POWERLEVEL9K_CONTEXT_FOREGROUND=0                 # Black text
  typeset -g POWERLEVEL9K_CONTEXT_BACKGROUND=2                 # Green background
  typeset -g POWERLEVEL9K_CONTEXT_{DEFAULT,SUDO}_{CONTENT,VISUAL_IDENTIFIER}_EXPANSION=

  # Background jobs - YELLOW block (Rastafari style)
  typeset -g POWERLEVEL9K_BACKGROUND_JOBS_FOREGROUND=0         # Black text
  typeset -g POWERLEVEL9K_BACKGROUND_JOBS_BACKGROUND=3         # Yellow background
  typeset -g POWERLEVEL9K_BACKGROUND_JOBS_VISUAL_IDENTIFIER_EXPANSION='⚙'

  # Status format - RED/GREEN blocks based on status (Rastafari style)
  typeset -g POWERLEVEL9K_STATUS_EXTENDED_STATES=true
  typeset -g POWERLEVEL9K_STATUS_OK=true
  typeset -g POWERLEVEL9K_STATUS_OK_FOREGROUND=0               # Black text
  typeset -g POWERLEVEL9K_STATUS_OK_BACKGROUND=2               # Green background for success
  typeset -g POWERLEVEL9K_STATUS_OK_VISUAL_IDENTIFIER_EXPANSION='✓'
  typeset -g POWERLEVEL9K_STATUS_ERROR_FOREGROUND=15           # White text
  typeset -g POWERLEVEL9K_STATUS_ERROR_BACKGROUND=1            # Red background for error
  typeset -g POWERLEVEL9K_STATUS_ERROR_VISUAL_IDENTIFIER_EXPANSION='✗'

  # Python virtual environment - YELLOW block (Rastafari style)
  typeset -g POWERLEVEL9K_VIRTUALENV_FOREGROUND=0              # Black text
  typeset -g POWERLEVEL9K_VIRTUALENV_BACKGROUND=3              # Yellow background

  # Transient prompt configuration for clean history
  typeset -g POWERLEVEL9K_TRANSIENT_PROMPT=same-dir

  # Instant prompt mode for faster startup
  typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet

  # Additional Rastafari style configurations
  typeset -g POWERLEVEL9K_ICON_PADDING=moderate

  # Enable/disable various elements
  typeset -g POWERLEVEL9K_SHOW_RULER=false
  typeset -g POWERLEVEL9K_RULER_CHAR='─'
  typeset -g POWERLEVEL9K_RULER_FOREGROUND=240

  # Configure directory truncation for better readability in block style
  typeset -g POWERLEVEL9K_SHORTEN_DIR_LENGTH=2
  typeset -g POWERLEVEL9K_DIR_MAX_LENGTH=40
  #              it incompatible with your zsh configuration files.
  #   - quiet:   Enable instant prompt and don't print warnings when detecting console output
  #              during zsh initialization. Choose this if you've read and understood
  #              https://github.com/romkatv/powerlevel10k/blob/master/README.md#instant-prompt.
  #   - verbose: Enable instant prompt and print a warning when detecting console output during
  #              zsh initialization. Choose this if you've never tried instant prompt, live
  #              dangerously, and do like experimental features.
  typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet

  # Hot reload gives you really fast prompt updates when you change prompt configuration.
  typeset -g POWERLEVEL9K_DISABLE_HOT_RELOAD=true

  # If p10k is already loaded, reload configuration.
  # This works even with POWERLEVEL9K_DISABLE_HOT_RELOAD=true.
  (( ! $+functions[p10k] )) || p10k reload
}

# Tell `p10k configure` which file it should overwrite.
typeset -g POWERLEVEL9K_CONFIG_FILE=${${(%):-%x}:a}

(( ${#p10k_config_opts} )) && setopt ${p10k_config_opts[@]}
'builtin' 'unset' 'p10k_config_opts'
P10K_CONFIG

# Configurar Termux para usar una fuente compatible
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

# Cursor
terminal-cursor-blink-rate=0
EOF

# Recarga la configuración de Termux
termux-reload-settings 2>/dev/null || true

echo -e "\n${RED}🌈${YELLOW} RESUMEN DE CONFIGURACIÓN ZSH RASTAFARI ${GREEN}🌈${NC}"
echo -e "${RED}━━━${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${GREEN}━━━${NC}"

echo -e "${GREEN}✅ Zsh instalado y configurado${NC}"
echo -e "${GREEN}✅ Oh My Zsh instalado${NC}"
echo -e "${GREEN}✅ Plugins instalados:${NC}"
echo -e "   • zsh-autosuggestions"
echo -e "   • zsh-syntax-highlighting"
echo -e "   • zsh-completions"
echo -e "${YELLOW}✅ Tema Powerlevel10k RASTAFARI instalado${NC}"
echo -e "${RED}✅ Configuración Rainbow Style aplicada${NC}"
echo -e "${GREEN}✅ Métricas de sistema integradas (CPU y Memoria)${NC}"
echo -e "${YELLOW}✅ Aliases y funciones útiles agregados${NC}"

echo -e "\n${RED}🎨 CARACTERÍSTICAS DEL TEMA RASTAFARI:${NC}"
echo -e "${GREEN}   • Colores: Rojo, Amarillo y Verde en bloques${NC}"
echo -e "${YELLOW}   • CPU y Memoria en lugar de hora/tiempo${NC}"
echo -e "${RED}   • Comando en línea separada para mejor visibilidad${NC}"
echo -e "${GREEN}   • Estilo Rainbow continuo${NC}"

echo -e "\n${YELLOW}🔄 PRÓXIMOS PASOS:${NC}"
echo -e "${CYAN}1. Reinicia el terminal para ver el tema Rastafari${NC}"
echo -e "${CYAN}2. El tema se aplicará automáticamente${NC}"
echo -e "${CYAN}3. Usa 'setup-ai-keys' para configurar APIs de IA${NC}"

echo -e "\n${RED}🇯� ${YELLOW}¡Zsh configurado con estilo Rastafari! ${GREEN}🇯🇲${NC}"

# Intentar cambiar a Zsh inmediatamente
if command -v zsh >/dev/null 2>&1; then
    echo -e "${BLUE}🔄 Cambiando a Zsh...${NC}"
    export SHELL=$(which zsh)
    exec zsh -l
fi