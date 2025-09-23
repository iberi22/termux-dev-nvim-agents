#!/data/data/com.termux/files/usr/bin/bash

# ====================================
# Install Rastafari Banner in Termux
# Replaces default Termux welcome with custom banner
# ====================================

install_rastafari_banner() {
    echo "🌿 Installing Rastafari Banner..."

    local banner_script="$HOME/.rastafari-banner.sh"
    local bashrc_file="$HOME/.bashrc"
    local zshrc_file="$HOME/.zshrc"

    # Copy banner script to home directory
    if [ -f "scripts/rastafari-banner.sh" ]; then
        cp "scripts/rastafari-banner.sh" "$banner_script"
        chmod +x "$banner_script"
        echo "✅ Banner script installed to $banner_script"
    else
        echo "❌ Banner script not found!"
        return 1
    fi

    # Remove default Termux welcome message
    local motd_file="/data/data/com.termux/files/usr/etc/motd"
    if [ -f "$motd_file" ] && [ -w "$motd_file" ]; then
        # Backup original motd
        [ ! -f "${motd_file}.backup" ] && cp "$motd_file" "${motd_file}.backup"

        # Replace with minimal message
        cat > "$motd_file" << 'EOF'
# Rastafari Termux - One Love Terminal
# Welcome message handled by ~/.rastafari-banner.sh
EOF
        echo "✅ Default Termux MOTD replaced"
    fi

    # Add banner to shell initialization files
    local banner_call='
# Rastafari Banner - One Love Terminal
if [ -f "$HOME/.rastafari-banner.sh" ] && [ -t 0 ] && [ -z "$RASTAFARI_BANNER_SHOWN" ]; then
    export RASTAFARI_BANNER_SHOWN=1
    "$HOME/.rastafari-banner.sh"
fi'

    # Add to .bashrc if it exists or create it
    if [ ! -f "$bashrc_file" ]; then
        touch "$bashrc_file"
    fi

    # Check if banner call already exists in bashrc
    if ! grep -q "Rastafari Banner" "$bashrc_file"; then
        echo "$banner_call" >> "$bashrc_file"
        echo "✅ Banner added to .bashrc"
    else
        echo "ℹ️  Banner already configured in .bashrc"
    fi

    # Add to .zshrc if zsh is installed
    if command -v zsh >/dev/null 2>&1; then
        if [ ! -f "$zshrc_file" ]; then
            touch "$zshrc_file"
        fi

        if ! grep -q "Rastafari Banner" "$zshrc_file"; then
            echo "$banner_call" >> "$zshrc_file"
            echo "✅ Banner added to .zshrc"
        else
            echo "ℹ️  Banner already configured in .zshrc"
        fi
    fi

    # Create rastafari command aliases
    create_rastafari_aliases

    echo ""
    echo "🎵 Rastafari banner installation complete! 🎵"
    echo "🌿 Start a new terminal session to see the banner"
    echo "🦁 Or run: source ~/.${SHELL##*/}rc"
}

create_rastafari_aliases() {
    local aliases_file="$HOME/.rastafari-aliases"

    cat > "$aliases_file" << 'EOF'
# ====================================
# Rastafari Terminal Aliases - One Love Commands
# ====================================

# Core Rastafari commands
alias rasta-setup='cd ~/termux-ai-setup && ./setup.sh'
alias rasta-neovim='RASTAFARI_MODE=1 nvim'
alias rasta-banner='$HOME/.rastafari-banner.sh'
alias rasta-config='cd ~/.config && nvim .'
alias rasta-tips='$HOME/.rastafari-tips.sh'

# Development aliases with style
alias jah-code='rasta-neovim'
alias one-love='git status'
alias babylon-clean='git clean -fd'
alias ital-commit='git commit -m'
alias dread-push='git push origin HEAD'
alias zion-pull='git pull --rebase'

# System aliases
alias fire-update='pkg update && pkg upgrade'
alias irie-list='pkg list-installed'
alias roots-tree='tree -a -L 3'
alias riddim-ps='ps aux'
alias sound-system='htop'

# Navigation with vibes
alias go-home='cd ~ && clear'
alias go-config='cd ~/.config'
alias go-termux='cd /data/data/com.termux/files'
alias go-projects='cd ~/projects 2>/dev/null || mkdir -p ~/projects && cd ~/projects'

# File operations with meaning
alias lion-ls='ls -la --color=auto'
alias herb-find='find . -name'
alias natty-dread='grep -r --color=auto'
alias positive-vibe='tail -f'

# Package management
alias install-ting='pkg install'
alias remove-babylon='pkg uninstall'
alias search-herbs='pkg search'

# Development shortcuts
alias python-fire='python3'
alias node-vibes='node'
alias npm-ital='npm install'
alias git-ital='git init'

# Fun commands
alias quote-jah='fortune 2>/dev/null || echo "Every little thing gonna be alright!"'
alias time-now='date "+%Y-%m-%d %H:%M:%S - One Love Time"'
alias weather-irie='curl -s wttr.in/?0 2>/dev/null || echo "Sunshine in your heart! ☀️"'

# Help command
alias rasta-help='echo "
🌿 RASTAFARI TERMINAL COMMANDS 🌿

🔥 CORE COMMANDS:
  rasta-setup     - Run full environment setup
  rasta-neovim    - Start Neovim with Rastafari theme
  rasta-banner    - Show welcome banner again
  rasta-tips      - Get random development tips
  rasta-config    - Open config directory

🎵 DEVELOPMENT VIBES:
  jah-code        - Open Neovim (alias for rasta-neovim)
  one-love        - Git status
  babylon-clean   - Git clean working directory
  ital-commit     - Git commit with message
  dread-push      - Git push to origin
  zion-pull       - Git pull with rebase

🦁 SYSTEM OPERATIONS:
  fire-update     - Update all packages
  lion-ls         - Detailed file listing
  roots-tree      - Show directory tree
  sound-system    - System monitor (htop)

🌿 NAVIGATION:
  go-home         - Return to home directory
  go-config       - Go to .config directory
  go-projects     - Go to projects directory

Type any command to use it. Jah bless! 💚💛❤️
"'

EOF

    # Source aliases in shell config files
    local alias_source='
# Rastafari aliases - One Love Commands
[ -f "$HOME/.rastafari-aliases" ] && source "$HOME/.rastafari-aliases"'

    # Add to bashrc
    if [ -f "$HOME/.bashrc" ] && ! grep -q "Rastafari aliases" "$HOME/.bashrc"; then
        echo "$alias_source" >> "$HOME/.bashrc"
    fi

    # Add to zshrc if exists
    if [ -f "$HOME/.zshrc" ] && ! grep -q "Rastafari aliases" "$HOME/.zshrc"; then
        echo "$alias_source" >> "$HOME/.zshrc"
    fi

    echo "✅ Rastafari aliases created and configured"
}

# Run installation if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_rastafari_banner
fi