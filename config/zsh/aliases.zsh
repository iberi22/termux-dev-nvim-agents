# ====================================
# Zsh Aliases Configuration
# Aliases personalizados para desarrollo y navegación
# ====================================

# Navegación mejorada
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ~='cd ~'
alias -- -='cd -'

# Listado mejorado (usa exa si está disponible, sino ls)
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

# AI aliases
alias ai-chat='nvim -c "CodeCompanionChat"'
alias ai-help='ai-help'
alias ai-review='ai-code-review'
alias ai-docs='ai-generate-docs'
alias ai-init='ai-init-project'