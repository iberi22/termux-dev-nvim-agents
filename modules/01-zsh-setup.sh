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

# Crear configuración .zshrc completa
echo -e "${YELLOW}⚙️ Configurando .zshrc completo...${NC}"

# Crear directorio de configuraciones si no existe
CONFIG_DIR="$(dirname "$0")/../config/zsh"
mkdir -p "$CONFIG_DIR"

# Crear configuración de aliases
cat > "$CONFIG_DIR/aliases.zsh" << 'EOF'
# ====================================
# ALIASES PERSONALIZADOS
# ====================================

# Navegación mejorada
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ~='cd ~'
alias -- -='cd -'

# Listado mejorado (usa ls por defecto, upgradeable a exa)
if command -v exa >/dev/null 2>&1; then
    alias ls='exa --icons --group-directories-first'
    alias ll='exa -la --icons --group-directories-first'
    alias la='exa -a --icons --group-directories-first'
    alias lt='exa --tree --level=2 --icons'
    alias l='exa --icons --group-directories-first'
else
    alias ll='ls -la'
    alias la='ls -A'
    alias l='ls -CF'
fi

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

# Herramientas modernas (con fallbacks)
if command -v bat >/dev/null 2>&1; then
    alias cat='bat --paging=never'
fi
if command -v fd >/dev/null 2>&1; then
    alias find='fd'
fi
if command -v rg >/dev/null 2>&1; then
    alias grep='rg'
fi
if command -v dust >/dev/null 2>&1; then
    alias du='dust'
fi
if command -v duf >/dev/null 2>&1; then
    alias df='duf'
fi
if command -v procs >/dev/null 2>&1; then
    alias ps='procs'
fi
if command -v htop >/dev/null 2>&1; then
    alias top='htop'
fi

# Yazi (explorador de archivos)
alias y='yazi'
alias yy='yazi .'
alias yz='yazi --cwd-file="$HOME/.cache/yazi-cwd"'

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

# AI agents aliases
alias ai-chat='nvim -c "CodeCompanionChat"'
alias ai-help='ai-help'
alias ai-review='ai-code-review'
alias ai-docs='ai-generate-docs'
alias ai-init='ai-init-project'
EOF

# Crear configuración de funciones
cat > "$CONFIG_DIR/functions.zsh" << 'EOF'
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
    echo -e "${BLUE}Memory:${NC} $(free -h 2>/dev/null | awk '/^Mem:/ {print $3 "/" $2}' || echo 'N/A')"
    echo -e "${BLUE}Disk:${NC} $(df -h / 2>/dev/null | awk 'NR==2 {print $3 "/" $2 " (" $5 " used)"}' || echo 'N/A')"
    echo -e "${BLUE}Uptime:${NC} $(uptime -p 2>/dev/null || echo 'N/A')"
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

# Función para obtener uso de CPU (para Powerlevel10k)
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

# Función para obtener uso de memoria (para Powerlevel10k)
get_memory_usage() {
    if command -v free >/dev/null 2>&1; then
        local mem_info=$(free | grep '^Mem:')
        local total=$(echo $mem_info | awk '{print $2}')
        local used=$(echo $mem_info | awk '{print $3}')
        if [[ $total -gt 0 ]]; then
            local usage=$((used * 100 / total))
            echo "${usage}%"
        else
            echo "0%"
        fi
    elif [[ -f /proc/meminfo ]]; then
        local total=$(grep '^MemTotal:' /proc/meminfo | awk '{print $2}')
        local available=$(grep '^MemAvailable:' /proc/meminfo | awk '{print $2}')
        if [[ $total -gt 0 && $available -gt 0 ]]; then
            local used=$((total - available))
            local usage=$((used * 100 / total))
            echo "${usage}%"
        else
            echo "0%"
        fi
    else
        echo "N/A"
    fi
}
EOF

# Crear configuración de Powerlevel10k
cat > "$CONFIG_DIR/p10k-config.zsh" << 'EOF'
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
    os_icon                 # os identifier
    dir                     # current directory
    vcs                     # git status
    system_cpu              # cpu usage
    system_memory           # memory usage
    command_execution_time  # duration of the last command
    status                  # exit code of the last command
    newline                 # \n
  )

  # The list of segments shown on the right - keep empty for block style
  typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=()

  # Enable multi-line prompt with command on separate line
  typeset -g POWERLEVEL9K_PROMPT_ON_NEWLINE=true
  typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX=''
  typeset -g POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX='%F{green}▶%f '
  typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_SUFFIX=''
  typeset -g POWERLEVEL9K_MULTILINE_LAST_PROMPT_SUFFIX=''

  # Define custom CPU usage segment
  function prompt_system_cpu() {
    local cpu_usage
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
      else
        cpu_usage=0
      fi
    else
      cpu_usage=0
    fi

    local color
    if (( cpu_usage >= 80 )); then
      color=1  # red
    elif (( cpu_usage >= 60 )); then
      color=3  # yellow
    else
      color=2  # green
    fi

    p10k segment -f 0 -b $color -i '🔥' -t "CPU ${cpu_usage}%"
  }

  # Define custom Memory usage segment
  function prompt_system_memory() {
    local mem_usage
    if command -v free >/dev/null 2>&1; then
      local mem_info=$(free | grep '^Mem:')
      local total=$(echo $mem_info | awk '{print $2}')
      local used=$(echo $mem_info | awk '{print $3}')
      if [[ $total -gt 0 ]]; then
        mem_usage=$((used * 100 / total))
      else
        mem_usage=0
      fi
    else
      mem_usage=0
    fi

    local color
    if (( mem_usage >= 80 )); then
      color=1  # red
    elif (( mem_usage >= 60 )); then
      color=3  # yellow
    else
      color=2  # green
    fi

    p10k segment -f 0 -b $color -i '💾' -t "MEM ${mem_usage}%"
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
  typeset -g POWERLEVEL9K_CONTEXT_{DEFAULT,SUDO}_{CONTENT,VISUAL_IDENTIFIER}_EXPANSION=""

  # Background jobs - YELLOW block (Rastafari style)
  typeset -g POWERLEVEL9K_BACKGROUND_JOBS_FOREGROUND=0         # Black text
  typeset -g POWERLEVEL9K_BACKGROUND_JOBS_BACKGROUND=3         # Yellow background
  typeset -g POWERLEVEL9K_BACKGROUND_JOBS_VISUAL_IDENTIFIER_EXPANSION='⚙'

  # Status format - RED/GREEN blocks based on status (Rastafari style)
  typeset -g POWERLEVEL9K_STATUS_EXTENDED_STATES=true
  typeset -g POWERLEVEL9K_STATUS_OK=true
  typeset -g POWERLEVEL9K_STATUS_OK_FOREGROUND=0               # Black text
  typeset -g POWERLEVEL9K_STATUS_OK_BACKGROUND=2               # Green background for success
  typeset -g POWERLEVEL9K_STATUS_OK_VISUAL_IDENTIFIER_EXPANSION='✔'
  typeset -g POWERLEVEL9K_STATUS_ERROR_FOREGROUND=15           # White text
  typeset -g POWERLEVEL9K_STATUS_ERROR_BACKGROUND=1            # Red background for error
  typeset -g POWERLEVEL9K_STATUS_ERROR_VISUAL_IDENTIFIER_EXPANSION='✘'

  # Command execution time - BLUE block
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FOREGROUND=15 # White text
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_BACKGROUND=4  # Blue background
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD=3

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
EOF

# Crear archivo principal .zshrc
cat > "$CONFIG_DIR/main-zshrc.template" << 'EOF'
# ====================================
# ZSH Configuration for AI Development
# Termux AI Setup v3.0 - Rastafari Theme
# ====================================

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

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
# CARGAR CONFIGURACIONES MODULARES
# ====================================

# Cargar aliases personalizados
if [[ -f "$HOME/.config/zsh/aliases.zsh" ]]; then
    source "$HOME/.config/zsh/aliases.zsh"
fi

# Cargar funciones personalizadas
if [[ -f "$HOME/.config/zsh/functions.zsh" ]]; then
    source "$HOME/.config/zsh/functions.zsh"
fi

# Cargar integración optimizada con Yazi
if [[ -f "$HOME/.config/zsh/yazi-integration.zsh" ]]; then
    source "$HOME/.config/zsh/yazi-integration.zsh"
fi

# ====================================
# CONFIGURACIÓN DE HERRAMIENTAS
# ====================================

# Zoxide (mejor cd)
if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init zsh)"
fi

# FZF configuración
if command -v fzf >/dev/null 2>&1; then
    if command -v fd >/dev/null 2>&1; then
        export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
    fi
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

# Start AI agent with ':' if available
if [[ -x "$HOME/bin/colon" ]]; then
    alias :='$HOME/bin/colon'
fi

# ====================================
# MENSAJES DE BIENVENIDA
# ====================================

# Mostrar información útil al iniciar
if [[ -o interactive ]]; then
    echo -e "${PURPLE}╔═══════════════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║                    🌈 TERMUX AI READY 🎯                    ║${NC}"
    echo -e "${PURPLE}╚═══════════════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo -e "${CYAN}💡 Tip: Type 'sysinfo' for system info, 'sysupdate' to update all${NC}"
    echo -e "${CYAN}🔧 Type 'setup-ai-keys' to configure AI API keys${NC}"
    echo -e "${CYAN}📝 Type 'nvim' to start coding with AI assistance${NC}"
    echo -e "${CYAN}🗂️ Type 'yy' to open Yazi file explorer${NC}"
fi

# Cargar configuración local si existe
if [[ -f "$HOME/.zshrc.local" ]]; then
    source "$HOME/.zshrc.local"
fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
EOF

# Crear script de configuración final
cat > "$CONFIG_DIR/../configure-zsh-final.sh" << 'FINAL_SCRIPT'
#!/bin/bash

# =================================
# SCRIPT: Configuración Final de Zsh
# Aplica la configuración completa después de instalar componentes
# =================================

set -euo pipefail

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${BLUE}🎨 Configurando Zsh final con tema Rastafari...${NC}"

# Crear directorio de configuración del usuario
mkdir -p "$HOME/.config/zsh"

# Copiar archivos de configuración modular
SCRIPT_DIR="$(dirname "$0")"
CONFIG_SOURCE="$SCRIPT_DIR/zsh"

if [[ -f "$CONFIG_SOURCE/aliases.zsh" ]]; then
    cp "$CONFIG_SOURCE/aliases.zsh" "$HOME/.config/zsh/"
    echo -e "${GREEN}✅ Aliases copiados${NC}"
fi

if [[ -f "$CONFIG_SOURCE/functions.zsh" ]]; then
    cp "$CONFIG_SOURCE/functions.zsh" "$HOME/.config/zsh/"
    echo -e "${GREEN}✅ Funciones copiadas${NC}"
fi

# Crear configuración específica de integración con Yazi
cat > "$HOME/.config/zsh/yazi-integration.zsh" << 'YAZI_INTEGRATION'
# ====================================
# INTEGRACIÓN OPTIMIZADA CON YAZI
# ====================================

# Función mejorada para cambiar directorio con Yazi
function yy() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
    yazi "$@" --cwd-file="$tmp"
    if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        cd -- "$cwd"
    fi
    rm -f -- "$tmp"
}

# Función para abrir Yazi en modo preview
function yp() {
    yazi --preview "$@"
}

# Función para abrir Yazi en directorio específico manteniendo el directorio actual
function yd() {
    local target="${1:-.}"
    yazi "$target"
}

# Integration con fzf para selección rápida de archivos con Yazi
function yz() {
    if command -v fzf >/dev/null 2>&1; then
        local selected
        selected=$(fd -t f | fzf --preview='yazi --preview {}' --preview-window=right:70%)
        if [[ -n "$selected" ]]; then
            yazi "$selected"
        fi
    else
        echo "fzf no está instalado, usando yazi normal"
        yazi
    fi
}

# Función para abrir el directorio actual en Yazi y regresar al shell
function ys() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
    yazi --cwd-file="$tmp"
    if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        cd -- "$cwd"
        echo "📁 Cambió a: $cwd"
    fi
    rm -f -- "$tmp"
}

# Configuración de variables de entorno para Yazi
export YAZI_FILE_ONE="$(command -v file)"
export YAZI_CONFIG_HOME="$HOME/.config/yazi"

# Crear directorio de configuración de Yazi si no existe
if [[ ! -d "$YAZI_CONFIG_HOME" ]]; then
    mkdir -p "$YAZI_CONFIG_HOME"
fi

# Auto-setup básico de Yazi si no existe configuración
if [[ ! -f "$YAZI_CONFIG_HOME/yazi.toml" ]] && command -v yazi >/dev/null 2>&1; then
    cat > "$YAZI_CONFIG_HOME/yazi.toml" << 'YAZI_CONFIG'
[manager]
ratio          = [ 1, 4, 3 ]
sort_by        = "alphabetical"
sort_sensitive = false
sort_reverse   = false
sort_dir_first = true
show_hidden    = false
show_symlink   = true

[preview]
tab_size   = 2
max_width  = 600
max_height = 900
cache_dir  = ""

[opener]
edit = [
    { run = 'nvim "$@"', block = true },
    { run = 'nano "$@"', block = true },
]
open = [
    { run = 'termux-open "$1"', desc = "Open" },
]

[open]
rules = [
    { name = "*/", use = [ "edit", "open" ] },
    { mime = "text/*", use = [ "edit", "open" ] },
    { mime = "image/*", use = [ "open" ] },
    { mime = "video/*", use = [ "open" ] },
    { mime = "audio/*", use = [ "open" ] },
    { mime = "application/json", use = [ "edit", "open" ] },
    { mime = "*/javascript", use = [ "edit", "open" ] },
]

[tasks]
micro_workers    = 5
macro_workers    = 10
bizarre_retry    = 5
image_alloc      = 536870912  # 512MB
image_bound      = [ 0, 0 ]
suppress_preload = false

[plugins]
preload = [
    { name = "*", cond = "!mime", run = "mime", prio = "high" },
]
YAZI_CONFIG
    echo "📝 Configuración básica de Yazi creada"
fi

# Alias adicionales específicos para integración con Yazi y Powerlevel10k
alias ya='yazi'           # Acceso rápido
alias yf='yazi $(fd -t d | fzf)'  # Seleccionar directorio con fzf
alias yh='yazi ~'         # Ir a home
alias yr='yazi /'         # Ir a root
alias yt='yazi /tmp'      # Ir a temporal

# Auto-completion para yazi
if command -v yazi >/dev/null 2>&1; then
    # Función para completar directorios para yazi
    _yazi_complete() {
        local cur prev
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"

        case "$prev" in
            yazi|ya|yy|yd)
                # Completar con directorios
                COMPREPLY=($(compgen -d -- "$cur"))
                ;;
        esac
    }

    # Registrar auto-completion
    complete -F _yazi_complete yazi ya yy yd
fi

# Mensaje informativo al cargar la integración
if [[ -o interactive ]] && command -v yazi >/dev/null 2>&1; then
    echo -e "${GREEN}🗂️ Integración con Yazi activada${NC}"
    echo -e "${CYAN}   • yy  - Yazi con cambio de directorio${NC}"
    echo -e "${CYAN}   • yp  - Yazi en modo preview${NC}"
    echo -e "${CYAN}   • yz  - Yazi con fzf integration${NC}"
    echo -e "${CYAN}   • ys  - Yazi y mostrar directorio${NC}"
fi
YAZI_INTEGRATION
echo -e "${GREEN}✅ Integración con Yazi configurada${NC}"

if [[ -f "$CONFIG_SOURCE/p10k-config.zsh" ]]; then
    cp "$CONFIG_SOURCE/p10k-config.zsh" "$HOME/.p10k.zsh"
    echo -e "${GREEN}✅ Configuración Powerlevel10k copiada${NC}"
fi

# Crear .zshrc principal
if [[ -f "$CONFIG_SOURCE/main-zshrc.template" ]]; then
    # Backup del .zshrc existente si existe
    if [[ -f "$HOME/.zshrc" ]]; then
        cp "$HOME/.zshrc" "$HOME/.zshrc.backup.$(date +%Y%m%d_%H%M%S)"
        echo -e "${BLUE}📄 Backup de .zshrc existente creado${NC}"
    fi

    cp "$CONFIG_SOURCE/main-zshrc.template" "$HOME/.zshrc"
    echo -e "${GREEN}✅ Archivo .zshrc principal creado${NC}"
fi

# Configurar Termux específicos
if [[ -d "$HOME/.termux" ]] || command -v termux-reload-settings >/dev/null 2>&1; then
    echo -e "${YELLOW}📱 Configurando Termux...${NC}"

    # Crear directorio de configuración de Termux si no existe
    mkdir -p "$HOME/.termux"

    # Configurar propiedades de Termux para mejor experiencia
    cat > "$HOME/.termux/termux.properties" << 'TERMUX_CONF'
# Termux properties for AI development with Rastafari theme
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
TERMUX_CONF

    # Recarga la configuración de Termux
    termux-reload-settings 2>/dev/null || true
    echo -e "${GREEN}✅ Termux configurado${NC}"
fi

# Configurar zsh como shell por defecto en Termux
if [[ -f "$HOME/.bashrc" ]] && command -v zsh >/dev/null 2>&1; then
    if ! grep -q "exec zsh" "$HOME/.bashrc" 2>/dev/null; then
        echo "" >> "$HOME/.bashrc"
        echo "# Auto-start Zsh" >> "$HOME/.bashrc"
        echo "if [ -x /data/data/com.termux/files/usr/bin/zsh ]; then" >> "$HOME/.bashrc"
        echo "    export SHELL=/data/data/com.termux/files/usr/bin/zsh" >> "$HOME/.bashrc"
        echo "    exec zsh" >> "$HOME/.bashrc"
        echo "fi" >> "$HOME/.bashrc"
        echo -e "${GREEN}✅ Zsh configurado como shell por defecto${NC}"
    fi
fi

echo -e "\n${RED}🎨${YELLOW} CONFIGURACIÓN ZSH RASTAFARI COMPLETADA ${GREEN}🎨${NC}"
echo -e "${RED}───${YELLOW}───────────────────────────────────────────────────────────────────────────────────────${GREEN}───${NC}"
echo -e "${GREEN}✅ Zsh con configuración completa instalado${NC}"
echo -e "${GREEN}✅ Oh My Zsh configurado${NC}"
echo -e "${GREEN}✅ Plugins instalados y activos${NC}"
echo -e "${YELLOW}✅ Tema Powerlevel10k RASTAFARI configurado${NC}"
echo -e "${RED}✅ Configuración Rainbow Style aplicada${NC}"
echo -e "${GREEN}✅ Métricas de sistema integradas (CPU y Memoria)${NC}"
echo -e "${YELLOW}✅ Aliases y funciones útiles cargados${NC}"
echo -e "${CYAN}✅ Integración optimizada con Yazi${NC}"

echo -e "\n${RED}🎭 CARACTERÍSTICAS DEL TEMA RASTAFARI:${NC}"
echo -e "${GREEN}   • Colores: Rojo, Amarillo y Verde en bloques${NC}"
echo -e "${YELLOW}   • CPU y Memoria mostrados en tiempo real${NC}"
echo -e "${RED}   • Comando en línea separada para mejor visibilidad${NC}"
echo -e "${GREEN}   • Estilo Rainbow continuo${NC}"
echo -e "${CYAN}   • Integración perfecta con Yazi file explorer${NC}"

echo -e "\n${YELLOW}🔄 PRÓXIMOS PASOS:${NC}"
echo -e "${CYAN}1. Reinicia el terminal para ver el tema Rastafari${NC}"
echo -e "${CYAN}2. El tema se aplicará automáticamente${NC}"
echo -e "${CYAN}3. Usa 'yy' para abrir Yazi file explorer${NC}"
echo -e "${CYAN}4. Usa 'setup-ai-keys' para configurar APIs de IA${NC}"
echo -e "${CYAN}5. Tipo 'sysinfo' para ver información del sistema${NC}"

echo -e "\n${RED}🌈💾 ${YELLOW}¡Configuración Zsh Rastafari lista! ${GREEN}🌈🔥${NC}"

# Intentar cambiar a Zsh inmediatamente si estamos en un entorno interactivo
if [[ $- == *i* ]] && command -v zsh >/dev/null 2>&1; then
    echo -e "${BLUE}🔄 Cambiando a Zsh...${NC}"
    export SHELL=$(which zsh)
    exec zsh -l
fi
FINAL_SCRIPT

chmod +x "$CONFIG_DIR/../configure-zsh-final.sh"

# Crear script de validación
cat > "$CONFIG_DIR/../validate-zsh-setup.sh" << 'VALIDATE_SCRIPT'
#!/bin/bash

# =================================
# SCRIPT: Validación de Configuración Zsh
# Verifica que todos los componentes estén instalados y configurados correctamente
# =================================

set -euo pipefail

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${BLUE}🔍 Validando configuración de Zsh...${NC}\n"

# Función para verificar comandos
check_command() {
    local cmd="$1"
    local desc="$2"
    if command -v "$cmd" >/dev/null 2>&1; then
        echo -e "${GREEN}✅ $desc ($cmd)${NC}"
        return 0
    else
        echo -e "${RED}❌ $desc ($cmd) - NO ENCONTRADO${NC}"
        return 1
    fi
}

# Función para verificar archivos
check_file() {
    local file="$1"
    local desc="$2"
    if [[ -f "$file" ]]; then
        echo -e "${GREEN}✅ $desc${NC}"
        return 0
    else
        echo -e "${RED}❌ $desc - NO ENCONTRADO${NC}"
        return 1
    fi
}

# Función para verificar directorios
check_dir() {
    local dir="$1"
    local desc="$2"
    if [[ -d "$dir" ]]; then
        echo -e "${GREEN}✅ $desc${NC}"
        return 0
    else
        echo -e "${RED}❌ $desc - NO ENCONTRADO${NC}"
        return 1
    fi
}

validation_errors=0

echo -e "${YELLOW}🐚 Verificando componentes básicos:${NC}"
check_command "zsh" "Zsh shell" || ((validation_errors++))
check_command "git" "Git" || ((validation_errors++))
check_command "curl" "Curl" || ((validation_errors++))

echo -e "\n${YELLOW}🎨 Verificando Oh My Zsh y Powerlevel10k:${NC}"
check_dir "$HOME/.oh-my-zsh" "Oh My Zsh" || ((validation_errors++))
check_dir "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" "Powerlevel10k" || ((validation_errors++))

echo -e "\n${YELLOW}🔌 Verificando plugins de Zsh:${NC}"
check_dir "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" "zsh-autosuggestions" || ((validation_errors++))
check_dir "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" "zsh-syntax-highlighting" || ((validation_errors++))
check_dir "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-completions" "zsh-completions" || ((validation_errors++))

echo -e "\n${YELLOW}🗂️ Verificando Yazi:${NC}"
check_command "yazi" "Yazi file manager" || echo -e "${YELLOW}⚠️ Yazi no instalado - se compilará durante la instalación${NC}"
check_command "cargo" "Rust Cargo" || echo -e "${YELLOW}⚠️ Cargo no instalado - se instalará para compilar Yazi${NC}"

echo -e "\n${YELLOW}📁 Verificando archivos de configuración:${NC}"
check_dir "$HOME/.config/zsh" "Directorio de configuración modular" || ((validation_errors++))
check_file "$HOME/.config/zsh/aliases.zsh" "Aliases personalizados" || ((validation_errors++))
check_file "$HOME/.config/zsh/functions.zsh" "Funciones personalizadas" || ((validation_errors++))
check_file "$HOME/.config/zsh/yazi-integration.zsh" "Integración con Yazi" || ((validation_errors++))
check_file "$HOME/.p10k.zsh" "Configuración Powerlevel10k" || ((validation_errors++))
check_file "$HOME/.zshrc" "Archivo .zshrc principal" || ((validation_errors++))

echo -e "\n${YELLOW}🛠️ Verificando herramientas opcionales:${NC}"
check_command "fd" "fd (buscador de archivos)" || echo -e "${YELLOW}⚠️ fd no encontrado - funcionalidad limitada${NC}"
check_command "rg" "ripgrep (búsqueda en archivos)" || echo -e "${YELLOW}⚠️ ripgrep no encontrado - funcionalidad limitada${NC}"
check_command "fzf" "fzf (fuzzy finder)" || echo -e "${YELLOW}⚠️ fzf no encontrado - funcionalidad limitada${NC}"
check_command "bat" "bat (cat mejorado)" || echo -e "${YELLOW}⚠️ bat no encontrado - usando cat estándar${NC}"
check_command "exa" "exa (ls mejorado)" || echo -e "${YELLOW}⚠️ exa no encontrado - usando ls estándar${NC}"

echo -e "\n${YELLOW}📱 Verificando configuración Termux (si aplica):${NC}"
if command -v termux-reload-settings >/dev/null 2>&1; then
    check_file "$HOME/.termux/termux.properties" "Configuración Termux"
    if grep -q "exec zsh" "$HOME/.bashrc" 2>/dev/null; then
        echo -e "${GREEN}✅ Auto-start Zsh configurado en .bashrc${NC}"
    else
        echo -e "${YELLOW}⚠️ Auto-start Zsh no configurado en .bashrc${NC}"
    fi
else
    echo -e "${CYAN}ℹ️ No es un entorno Termux - saltando verificaciones específicas${NC}"
fi

echo -e "\n${BLUE}📊 RESUMEN DE VALIDACIÓN:${NC}"
if [[ $validation_errors -eq 0 ]]; then
    echo -e "${GREEN}🎉 ¡Configuración completa y válida!${NC}"
    echo -e "${GREEN}✅ Todos los componentes principales están instalados${NC}"
    echo -e "${CYAN}💡 Reinicia el terminal para aplicar la configuración completa${NC}"
    echo -e "${CYAN}🎯 Usa 'yy' para abrir Yazi con navegación de directorios${NC}"
    echo -e "${CYAN}🔧 Usa 'sysinfo' para ver información del sistema${NC}"
    exit 0
else
    echo -e "${RED}⚠️ Se encontraron $validation_errors errores de configuración${NC}"
    echo -e "${YELLOW}💡 Ejecuta el script de instalación nuevamente para corregir los problemas${NC}"
    exit 1
fi
VALIDATE_SCRIPT

chmod +x "$CONFIG_DIR/../validate-zsh-setup.sh"

echo -e "${GREEN}✅ Archivos de configuración creados en config/zsh/${NC}"
echo -e "${GREEN}✅ Script de configuración final creado${NC}"
echo -e "${YELLOW}📋 Para aplicar la configuración completa, ejecuta:${NC}"
echo -e "${CYAN}   ./config/configure-zsh-final.sh${NC}"
echo -e "${GREEN}✅ Zsh y componentes instalados correctamente${NC}"