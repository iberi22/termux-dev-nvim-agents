#!/bin/bash

# ====================================
# MÓDULO: Instalación y Configuración de Zsh
# Tema Rastafari completo o versión minimalista
# ====================================

set -euo pipefail

# Colores para salida
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m'

# Variables globales
readonly MODULE_NAME="01-zsh-setup"
readonly STATE_MARKER_DIR="$HOME/.termux-ai-setup/state"
readonly MODULE_MARKER="$STATE_MARKER_DIR/${MODULE_NAME}.ok"
readonly CONFIG_DIR="$(dirname "$0")/../config/zsh"
readonly USER_ZSH_CONFIG="$HOME/.config/zsh"

# Tema seleccionado (por defecto Rastafari)
ZSH_THEME_SELECTED="rastafari"

# Funciones de logging
log() { printf "%b%s%b\n" "$1" "$2" "$NC"; }
log_section() { log "$BLUE" "■ $1"; }
log_info() { log "$CYAN" "→ $1"; }
log_success() { log "$GREEN" "✓ $1"; }
log_warn() { log "$YELLOW" "⚠ $1"; }
log_error() { log "$RED" "✗ $1"; }

# Función de error
handle_error() {
    local exit_code=$?
    local line=${BASH_LINENO[0]:-unknown}
    log_error "Error en ${MODULE_NAME} (línea ${line}). Código: ${exit_code}"
    exit "$exit_code"
}

trap 'handle_error' ERR

# Verificar si ya está completado
check_previous_run() {
    if [[ -f "$MODULE_MARKER" && "${TERMUX_AI_FORCE_MODULES:-0}" != "1" ]]; then
        log_success "${MODULE_NAME} ya completado anteriormente"
        exit 0
    fi
}

# Verificar entorno Termux
assert_termux_environment() {
    if ! command -v pkg >/dev/null 2>&1; then
        log_error "Este módulo requiere ejecutarse dentro de Termux"
        exit 1
    fi
}

# Sistema de selección de tema
select_zsh_theme() {
    log_section "Selección de Tema Zsh"

    if [[ "${TERMUX_AI_ZSH_THEME:-}" == "minimal" ]]; then
        ZSH_THEME_SELECTED="minimal"
        log_info "Tema seleccionado automáticamente: Minimalista"
        return 0
    fi

    if [[ "${TERMUX_AI_AUTO:-}" == "1" || "${TERMUX_AI_SILENT:-}" == "1" ]]; then
        log_info "Modo automático: usando tema Rastafari completo"
        return 0
    fi

    echo
    log "$BLUE" "Selecciona el tema para Zsh:"
    echo
    log "$GREEN" "1) Rastafari Completo (Rojo, Amarillo, Verde + métricas completas)"
    log "$CYAN" "2) Minimalista (Directorio + Git + RAM)"
    echo

    local choice
    read -r -p "Elige tema [1-2] (por defecto: 1): " choice

    case "${choice:-1}" in
        1) ZSH_THEME_SELECTED="rastafari" ;;
        2) ZSH_THEME_SELECTED="minimal" ;;
        *) ZSH_THEME_SELECTED="rastafari" ;;
    esac

    log_success "Tema seleccionado: ${ZSH_THEME_SELECTED}"
}

# Instalar componentes base
install_base_components() {
    log_section "Instalando componentes base"

    # Zsh
    if ! command -v zsh >/dev/null 2>&1; then
        log_info "Instalando Zsh..."
        pkg install -y zsh
        log_success "Zsh instalado"
    else
        log_success "Zsh ya está instalado"
    fi

    # Oh My Zsh
    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        log_info "Instalando Oh My Zsh..."
        export RUNZSH=no
        export KEEP_ZSHRC=yes
        curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh | sh
        log_success "Oh My Zsh instalado"
    else
        log_success "Oh My Zsh ya está instalado"
    fi

    # Plugins
    local plugins=(
        "zsh-autosuggestions"
        "zsh-syntax-highlighting"
        "zsh-completions"
    )

    for plugin in "${plugins[@]}"; do
        if [[ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/${plugin}" ]]; then
            log_info "Instalando plugin: ${plugin}"
            git clone --depth=1 "https://github.com/zsh-users/${plugin}" "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/${plugin}"
        fi
    done

    # Powerlevel10k
    if [[ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]]; then
        log_info "Instalando Powerlevel10k..."
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
        log_success "Powerlevel10k instalado"
    fi
}

# Configurar tema Rastafari completo
configure_rastafari_theme() {
    log_section "Configurando tema Rastafari completo"

    mkdir -p "$USER_ZSH_CONFIG"

    # Copiar configuraciones preconfiguradas
    if [[ -f "$CONFIG_DIR/aliases.zsh" ]]; then
        cp "$CONFIG_DIR/aliases.zsh" "$USER_ZSH_CONFIG/"
    fi

    if [[ -f "$CONFIG_DIR/functions.zsh" ]]; then
        cp "$CONFIG_DIR/functions.zsh" "$USER_ZSH_CONFIG/"
    fi

    # Configuración Powerlevel10k Rastafari
    if [[ -f "$CONFIG_DIR/p10k-config.zsh" ]]; then
        cp "$CONFIG_DIR/p10k-config.zsh" "$HOME/.p10k.zsh"
    else
        create_rastafari_p10k_config
    fi

    # .zshrc Rastafari
    if [[ -f "$CONFIG_DIR/main-zshrc.template" ]]; then
        cp "$CONFIG_DIR/main-zshrc.template" "$HOME/.zshrc"
    else
        create_rastafari_zshrc
    fi
}

# Configurar tema minimalista
configure_minimal_theme() {
    log_section "Configurando tema minimalista"

    mkdir -p "$USER_ZSH_CONFIG"

    # Aliases minimalistas
    cat > "$USER_ZSH_CONFIG/aliases.zsh" << 'EOF'
# Navegación básica
alias ..='cd ..'
alias ...='cd ../..'
alias ls='ls --color=auto'
alias ll='ls -la'
alias la='ls -A'
alias l='ls -CF'

# Git básico
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git pull'

# Utilidades
alias python='python3'
alias pip='pip3'
EOF

    # Funciones minimalistas
    cat > "$USER_ZSH_CONFIG/functions.zsh" << 'EOF'
# Función básica de extracción
extract() {
    if [ -f "$1" ]; then
        case "$1" in
            *.tar.bz2) tar xjf "$1" ;;
            *.tar.gz)  tar xzf "$1" ;;
            *.bz2)     bunzip2 "$1" ;;
            *.rar)     unrar x "$1" ;;
            *.gz)      gunzip "$1" ;;
            *.tar)     tar xf "$1" ;;
            *.tbz2)    tar xjf "$1" ;;
            *.tgz)     tar xzf "$1" ;;
            *.zip)     unzip "$1" ;;
            *.Z)       uncompress "$1" ;;
            *.7z)      7z x "$1" ;;
            *)         echo "'$1' no puede ser extraído" ;;
        esac
    else
        echo "'$1' no es un archivo válido"
    fi
}
EOF

    # Configuración P10k minimalista
    create_minimal_p10k_config

    # .zshrc minimalista
    create_minimal_zshrc
}

# Crear configuración P10k Rastafari
create_rastafari_p10k_config() {
    cat > "$HOME/.p10k.zsh" << 'EOF'
# Rastafari Theme Configuration - Red, Yellow, Green
'builtin' 'local' '-a' 'p10k_config_opts'
[[ ! -o 'aliases' ]] || p10k_config_opts+=('aliases')
[[ ! -o 'sh_glob' ]] || p10k_config_opts+=('sh_glob')
[[ ! -o 'no_brace_expand' ]] || p10k_config_opts+=('no_brace_expand')
'builtin' 'setopt' 'no_aliases' 'no_sh_glob' 'brace_expand'

() {
  emulate -L zsh -o extended_glob

  [[ $ZSH_VERSION == (5.<1->*|<6->.*) ]] || return

  # Rastafari Rainbow Block Style
  typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
    dir vcs newline prompt_char
  )
  typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(
    status background_jobs history time
  )

  # Multi-line prompt
  typeset -g POWERLEVEL9K_PROMPT_ON_NEWLINE=true
  typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX=''
  typeset -g POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX='%F{green}▶%f '
  typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_SUFFIX=''
  typeset -g POWERLEVEL9K_MULTILINE_LAST_PROMPT_SUFFIX=''

  # Block style
  typeset -g POWERLEVEL9K_LEFT_SUBSEGMENT_SEPARATOR=''
  typeset -g POWERLEVEL9K_RIGHT_SUBSEGMENT_SEPARATOR=''
  typeset -g POWERLEVEL9K_LEFT_SEGMENT_SEPARATOR=''
  typeset -g POWERLEVEL9K_RIGHT_SEGMENT_SEPARATOR=''
  typeset -g POWERLEVEL9K_LEFT_PROMPT_FIRST_SEGMENT_START_SYMBOL=''
  typeset -g POWERLEVEL9K_LEFT_PROMPT_LAST_SEGMENT_END_SYMBOL=''
  typeset -g POWERLEVEL9K_RIGHT_PROMPT_FIRST_SEGMENT_START_SYMBOL=''
  typeset -g POWERLEVEL9K_RIGHT_PROMPT_LAST_SEGMENT_END_SYMBOL=''

  # Add empty line
  typeset -g POWERLEVEL9K_PROMPT_ADD_NEWLINE=true

  # Directory - GREEN block
  typeset -g POWERLEVEL9K_DIR_FOREGROUND=0
  typeset -g POWERLEVEL9K_DIR_BACKGROUND=2
  typeset -g POWERLEVEL9K_SHORTEN_STRATEGY=truncate_to_unique
  typeset -g POWERLEVEL9K_SHORTEN_DELIMITER=
  typeset -g POWERLEVEL9K_DIR_SHORTENED_FOREGROUND=0
  typeset -g POWERLEVEL9K_DIR_ANCHOR_FOREGROUND=0
  typeset -g POWERLEVEL9K_DIR_ANCHOR_BOLD=true

  # Git - YELLOW block
  typeset -g POWERLEVEL9K_VCS_FOREGROUND=0
  typeset -g POWERLEVEL9K_VCS_BACKGROUND=3
  typeset -g POWERLEVEL9K_VCS_LOADING_FOREGROUND=0
  typeset -g POWERLEVEL9K_VCS_LOADING_BACKGROUND=3

  # Status - RED block
  typeset -g POWERLEVEL9K_STATUS_FOREGROUND=0
  typeset -g POWERLEVEL9K_STATUS_BACKGROUND=1
  typeset -g POWERLEVEL9K_STATUS_ERROR_FOREGROUND=0
  typeset -g POWERLEVEL9K_STATUS_ERROR_BACKGROUND=1

  # Time - GREEN block
  typeset -g POWERLEVEL9K_TIME_FOREGROUND=0
  typeset -g POWERLEVEL9K_TIME_BACKGROUND=2
  typeset -g POWERLEVEL9K_TIME_FORMAT='%D{%H:%M:%S}'

  # Background jobs - YELLOW block
  typeset -g POWERLEVEL9K_BACKGROUND_JOBS_FOREGROUND=0
  typeset -g POWERLEVEL9K_BACKGROUND_JOBS_BACKGROUND=3

  # History - CYAN block
  typeset -g POWERLEVEL9K_HISTORY_FOREGROUND=0
  typeset -g POWERLEVEL9K_HISTORY_BACKGROUND=6
}

(( ${#p10k_config_opts} )) && setopt ${p10k_config_opts[@]}
'builtin' 'unset' 'p10k_config_opts'
EOF
}

# Crear configuración P10k minimalista
create_minimal_p10k_config() {
    cat > "$HOME/.p10k.zsh" << 'EOF'
# Minimal Theme Configuration - Termux Dev Setup Colors
'builtin' 'local' '-a' 'p10k_config_opts'
[[ ! -o 'aliases' ]] || p10k_config_opts+=('aliases')
[[ ! -o 'sh_glob' ]] || p10k_config_opts+=('sh_glob')
[[ ! -o 'no_brace_expand' ]] || p10k_config_opts+=('no_brace_expand')
'builtin' 'setopt' 'no_aliases' 'no_sh_glob' 'brace_expand'

() {
  emulate -L zsh -o extended_glob

  [[ $ZSH_VERSION == (5.<1->*|<6->.*) ]] || return

  # Minimal elements: directory, git, ram
  typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
    dir vcs ram
  )
  typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=()

  # Single line prompt
  typeset -g POWERLEVEL9K_PROMPT_ON_NEWLINE=false
  typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX=''
  typeset -g POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX='▶ '

  # Clean separators
  typeset -g POWERLEVEL9K_LEFT_SUBSEGMENT_SEPARATOR=' '
  typeset -g POWERLEVEL9K_RIGHT_SUBSEGMENT_SEPARATOR=' '
  typeset -g POWERLEVEL9K_LEFT_SEGMENT_SEPARATOR=''
  typeset -g POWERLEVEL9K_RIGHT_SEGMENT_SEPARATOR=''

  # Directory - Blue block
  typeset -g POWERLEVEL9K_DIR_FOREGROUND=15
  typeset -g POWERLEVEL9K_DIR_BACKGROUND=4
  typeset -g POWERLEVEL9K_SHORTEN_STRATEGY=truncate_to_last
  typeset -g POWERLEVEL9K_SHORTEN_DELIMITER=

  # Git - Green block
  typeset -g POWERLEVEL9K_VCS_FOREGROUND=0
  typeset -g POWERLEVEL9K_VCS_BACKGROUND=2

  # RAM - Cyan block
  typeset -g POWERLEVEL9K_RAM_FOREGROUND=0
  typeset -g POWERLEVEL9K_RAM_BACKGROUND=6
  typeset -g POWERLEVEL9K_RAM_ELEMENTS=(ram_free)

  # Prompt char
  typeset -g POWERLEVEL9K_PROMPT_CHAR_FOREGROUND=2
  typeset -g POWERLEVEL9K_PROMPT_CHAR_BACKGROUND=
}

(( ${#p10k_config_opts} )) && setopt ${p10k_config_opts[@]}
'builtin' 'unset' 'p10k_config_opts'
EOF
}

# Crear .zshrc Rastafari
create_rastafari_zshrc() {
    cat > "$HOME/.zshrc" << 'EOF'
# ZSH Configuration - Rastafari Theme
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(git zsh-autosuggestions zsh-syntax-highlighting zsh-completions)
source $ZSH/oh-my-zsh.sh

# Environment
export EDITOR='nvim'
export VISUAL='nvim'
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Load modular config
[[ -f "$HOME/.config/zsh/aliases.zsh" ]] && source "$HOME/.config/zsh/aliases.zsh"
[[ -f "$HOME/.config/zsh/functions.zsh" ]] && source "$HOME/.config/zsh/functions.zsh"

# Load P10k
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
EOF
}

# Crear .zshrc minimalista
create_minimal_zshrc() {
    cat > "$HOME/.zshrc" << 'EOF'
# ZSH Configuration - Minimal Theme
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(git zsh-autosuggestions zsh-syntax-highlighting zsh-completions)
source $ZSH/oh-my-zsh.sh

# Environment
export EDITOR='nvim'
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Load modular config
[[ -f "$HOME/.config/zsh/aliases.zsh" ]] && source "$HOME/.config/zsh/aliases.zsh"
[[ -f "$HOME/.config/zsh/functions.zsh" ]] && source "$HOME/.config/zsh/functions.zsh"

# Load P10k
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
EOF
}

# Configurar fuente FiraCode Mono
configure_font() {
    log_section "Configurando fuente FiraCode Mono"

    mkdir -p "$HOME/.termux"

    # Solo configurar si no existe ya una fuente personalizada
    if [[ ! -f "$HOME/.termux/font.ttf" ]]; then
        log_info "Descargando FiraCode Mono..."
        local tmp_dir
        tmp_dir=$(mktemp -d)

        if curl -L -o "$tmp_dir/firacode.zip" \
            "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/FiraCode.zip" 2>/dev/null; then

            if unzip -j "$tmp_dir/firacode.zip" "*FiraCodeNerdFontMono-Regular.ttf" -d "$tmp_dir" >/dev/null 2>&1; then
                cp "$tmp_dir/FiraCodeNerdFontMono-Regular.ttf" "$HOME/.termux/font.ttf"
                log_success "Fuente FiraCode Mono instalada"
            else
                log_warn "No se pudo extraer la fuente"
            fi
        else
            log_warn "No se pudo descargar la fuente"
        fi

        rm -rf "$tmp_dir"
    else
        log_success "Fuente ya configurada"
    fi
}

# Configurar Zsh como shell por defecto
configure_default_shell() {
    log_section "Configurando Zsh como shell por defecto"

    # Configurar en .bashrc para auto-switch
    if [[ -f "$HOME/.bashrc" ]]; then
        if ! grep -q "exec zsh" "$HOME/.bashrc" 2>/dev/null; then
            echo "" >> "$HOME/.bashrc"
            echo "# Auto-switch to Zsh" >> "$HOME/.bashrc"
            echo "if command -v zsh >/dev/null 2>&1; then" >> "$HOME/.bashrc"
            echo "    exec zsh" >> "$HOME/.bashrc"
            echo "fi" >> "$HOME/.bashrc"
            log_success "Auto-switch a Zsh configurado"
        fi
    fi
}

# Función principal
main() {
    log_section "Iniciando configuración de Zsh"

    mkdir -p "$STATE_MARKER_DIR"
    check_previous_run
    assert_termux_environment

    select_zsh_theme
    install_base_components

    case "$ZSH_THEME_SELECTED" in
        "rastafari") configure_rastafari_theme ;;
        "minimal") configure_minimal_theme ;;
    esac

    configure_font
    configure_default_shell

    # Marcar como completado
    touch "$MODULE_MARKER"

    log_success "Configuración de Zsh completada"
    log_info "Tema seleccionado: ${ZSH_THEME_SELECTED}"
    log_info "Reinicia el terminal para aplicar los cambios"
}

main "$@"
