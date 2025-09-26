#!/bin/bash

# ====================================
# MÓDULO: Instalación y Configuración de Zsh
# Classic Style - Clean and Professional
# ====================================

set -euo pipefail

# Colores para salida
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m'

# Variables globales
readonly MODULE_NAME="01-zsh-setup"
readonly STATE_MARKER_DIR="$HOME/.termux-ai-setup/state"
readonly MODULE_MARKER="$STATE_MARKER_DIR/${MODULE_NAME}.ok"
readonly CONFIG_DIR="$(dirname "$0")/../config/zsh"
readonly USER_ZSH_CONFIG="$HOME/.config/zsh"

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

# Sistema de selección de tema - Solo Classic Style disponible
prepare_classic_theme() {
    log_section "Preparando Classic Style"

    if [[ "${TERMUX_AI_AUTO:-}" == "1" || "${TERMUX_AI_SILENT:-}" == "1" ]]; then
        log_info "Modo automático: usando Classic Style"
        return 0
    fi

    log_info "Configurando Classic Style - Bloques profesionales con colores termux-dev"
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

    # Plugins esenciales
    local plugins=(
        "zsh-autosuggestions"
        "zsh-syntax-highlighting"
        "zsh-completions"
    )

    for plugin in "${plugins[@]}"; do
        local plugin_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/${plugin}"
        if [[ ! -d "$plugin_dir" ]]; then
            log_info "Instalando plugin: ${plugin}"
            git clone --depth=1 "https://github.com/zsh-users/${plugin}" "$plugin_dir"
            log_success "Plugin ${plugin} instalado"
        else
            log_success "Plugin ${plugin} ya está instalado"
        fi
    done

    # Powerlevel10k
    local p10k_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
    if [[ ! -d "$p10k_dir" ]]; then
        log_info "Instalando Powerlevel10k..."
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$p10k_dir"
        log_success "Powerlevel10k instalado"
    else
        log_success "Powerlevel10k ya está instalado"
    fi
}

# Configurar Classic Style
configure_classic_style() {
    log_section "Configurando Classic Style"

    # Crear directorio de configuración
    mkdir -p "$USER_ZSH_CONFIG"

    # Copiar configuración Classic p10k
    if [[ -f "$CONFIG_DIR/p10k-classic.zsh" ]]; then
        cp "$CONFIG_DIR/p10k-classic.zsh" "$USER_ZSH_CONFIG/"
        log_success "Configuración Classic p10k instalada"
    else
        log_warn "Archivo p10k-classic.zsh no encontrado, creando configuración básica"
        create_basic_classic_config
    fi

    # Copiar .zshrc Classic
    if [[ -f "$CONFIG_DIR/zshrc-classic.template" ]]; then
        cp "$CONFIG_DIR/zshrc-classic.template" "$HOME/.zshrc"
        log_success "Configuración .zshrc Classic instalada"
    else
        log_warn "Template zshrc-classic no encontrado, creando configuración básica"
        create_basic_zshrc
    fi

    # Crear enlace simbólico para p10k
    if [[ -f "$USER_ZSH_CONFIG/p10k-classic.zsh" && ! -f "$HOME/.p10k.zsh" ]]; then
        ln -sf "$USER_ZSH_CONFIG/p10k-classic.zsh" "$HOME/.p10k.zsh"
        log_success "Enlace simbólico p10k creado"
    fi
}

# Crear configuración básica si no existen los templates
create_basic_classic_config() {
    cat > "$USER_ZSH_CONFIG/p10k-classic.zsh" << 'EOF'
# Basic Classic Style Configuration
'builtin' 'local' '-a' 'p10k_config_opts'
[[ ! -o 'aliases' ]] || p10k_config_opts+=('aliases')
[[ ! -o 'sh_glob' ]] || p10k_config_opts+=('sh_glob')
[[ ! -o 'no_brace_expand' ]] || p10k_config_opts+=('no_brace_expand')
'builtin' 'setopt' 'no_aliases' 'no_sh_glob' 'brace_expand'

() {
  emulate -L zsh -o extended_glob
  unset -m '(POWERLEVEL9K_*|DEFAULT_USER)~POWERLEVEL9K_GITSTATUS_DIR'
  [[ $ZSH_VERSION == (5.<1->*|<6->.*) ]] || return

  # Classic Style - Single line with blocks
  typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir vcs)
  typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(ram)
  typeset -g POWERLEVEL9K_PROMPT_ON_NEWLINE=false

  # Block separators
  typeset -g POWERLEVEL9K_LEFT_SUBSEGMENT_SEPARATOR=''
  typeset -g POWERLEVEL9K_RIGHT_SUBSEGMENT_SEPARATOR=''
  typeset -g POWERLEVEL9K_LEFT_SEGMENT_SEPARATOR=''
  typeset -g POWERLEVEL9K_RIGHT_SEGMENT_SEPARATOR=''

  # Directory - Blue
  typeset -g POWERLEVEL9K_DIR_FOREGROUND=255
  typeset -g POWERLEVEL9K_DIR_BACKGROUND=33

  # VCS - Green
  typeset -g POWERLEVEL9K_VCS_CLEAN_FOREGROUND=255
  typeset -g POWERLEVEL9K_VCS_CLEAN_BACKGROUND=28
  typeset -g POWERLEVEL9K_VCS_MODIFIED_FOREGROUND=255
  typeset -g POWERLEVEL9K_VCS_MODIFIED_BACKGROUND=208

  # RAM - Cyan
  typeset -g POWERLEVEL9K_RAM_FOREGROUND=0
  typeset -g POWERLEVEL9K_RAM_BACKGROUND=123

  typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet
}

(( ${#p10k_config_opts} )) && setopt ${p10k_config_opts[@]}
'builtin' 'unset' 'p10k_config_opts'
EOF
}

create_basic_zshrc() {
    cat > "$HOME/.zshrc" << 'EOF'
# Basic ZSH Configuration - Classic Style
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
    zsh-completions
)

source $ZSH/oh-my-zsh.sh

# Environment
export EDITOR='nvim'
export VISUAL='nvim'
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Basic aliases
alias ll='ls -la'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias python='python3'
alias pip='pip3'

# Load P10k Classic
[[ -f "$HOME/.config/zsh/p10k-classic.zsh" ]] && source "$HOME/.config/zsh/p10k-classic.zsh"
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh
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
    log_section "Iniciando configuración de Zsh - Classic Style"

    mkdir -p "$STATE_MARKER_DIR"
    check_previous_run
    assert_termux_environment

    prepare_classic_theme
    install_base_components
    configure_classic_style
    configure_font
    configure_default_shell

    # Marcar como completado
    touch "$MODULE_MARKER"

    log_success "Configuración de Zsh Classic Style completada"
    log_info "Estilo: Classic Style - Bloques azul/cyan/verde, memoria solo"
    log_info "Reinicia el terminal para aplicar los cambios"
}

main "$@"
