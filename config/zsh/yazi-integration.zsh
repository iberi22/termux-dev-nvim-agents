# ====================================
# Yazi Integration for Zsh
# Integración optimizada con Yazi file manager
# ====================================

# Función principal para Yazi con cambio de directorio automático
yy() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
    yazi "$@" --cwd-file="$tmp"
    if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        cd -- "$cwd"
    fi
    rm -f -- "$tmp"
}

# Función Yazi con preview
yp() {
    yazi --preview "$@"
}

# Función Yazi con integración fzf para selección de directorio
yf() {
    local dir
    if command -v fzf >/dev/null 2>&1; then
        dir=$(find . -type d -not -path '*/\.*' 2>/dev/null | fzf --height 40% --reverse --header="Select directory for Yazi")
        if [[ -n "$dir" ]]; then
            yy "$dir"
        fi
    else
        echo "fzf not found. Install fzf for enhanced directory selection."
        yy "$@"
    fi
}

# Función Yazi mostrando directorio de destino
ys() {
    local dest
    dest=$(yazi --chooser-file=/dev/stdout "$@" | head -1)
    if [[ -n "$dest" ]]; then
        echo "Yazi selected: $dest"
    fi
}

# Alias básicos de Yazi
alias y='yazi'
alias ya='yazi --help'
alias yz='yazi --cwd-file="$HOME/.cache/yazi-cwd"'

# Alias para operaciones comunes con Yazi
alias ycd='yy .'                    # Yazi con cambio de directorio
alias yopen='yazi'                  # Abrir Yazi normalmente
alias ypreview='yp'                 # Yazi en modo preview
alias yselect='ys'                  # Yazi para selección

# Configuración de Yazi si existe archivo de configuración
if [[ -f "$HOME/.config/yazi/yazi.toml" ]]; then
    export YAZI_CONFIG_HOME="$HOME/.config/yazi"
fi

# Función para verificar estado de Yazi
yazi-status() {
    if command -v yazi >/dev/null 2>&1; then
        echo "✅ Yazi está instalado"
        yazi --version
    else
        echo "❌ Yazi no está instalado"
        echo "Ejecuta: cargo install --locked yazi-fm yazi-cli"
    fi
}

# Función para actualizar Yazi
yazi-update() {
    if command -v cargo >/dev/null 2>&1; then
        echo "🔄 Actualizando Yazi..."
        cargo install --locked --force yazi-fm yazi-cli
        echo "✅ Yazi actualizado"
    else
        echo "❌ Cargo no encontrado. Instala Rust primero."
    fi
}

# Auto-completado para Yazi si está disponible
if command -v yazi >/dev/null 2>&1; then
    # Configurar auto-completado básico para comandos yazi
    _yazi_complete() {
        local cur=${COMP_WORDS[COMP_CWORD]}
        COMPREPLY=( $(compgen -W "--help --version --cwd-file --chooser-file --preview" -- $cur) )
    }
    complete -F _yazi_complete yazi yy yp ys yf
fi