#!/bin/bash

# ====================================
# MODULE: Base Packages Installation
# Installs essential development tools
# ====================================

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}📦 Installing Termux base packages...${NC}"

# Update repositories
echo -e "${YELLOW}🔄 Updating repositories...${NC}"
pkg update -y

echo -e "${YELLOW}⬆️  Upgrading existing packages...${NC}"
pkg upgrade -y

# Mirror warning/help at start
echo -e "${YELLOW}💡 Please ensure your mirrors are up to date!${NC}"

# Essential packages list (optimized for speed and efficiency)
ESSENTIAL_PACKAGES=(
    # Basic system tools
    "curl"
    "wget"
    "git"
    "unzip"
    "zip"

    # Core development tools
    "nodejs-lts"
    "python"

    # Essential editors and tools
    "nano"
    "vim"
    "tree"
    "htop"

    # Network and utilities
    "openssh"
    "jq"
    "ca-certificates"
)

# Optional packages (installed separately for better error handling)
OPTIONAL_PACKAGES=(
    # Advanced search tools
    "ripgrep"
    "fd"
    "fzf"

    # Build tools (only if needed)
    "gcc"
    "clang"
    "make"

    # Modern replacements
    "bat"
    "exa"
    "zoxide"
)

# Function to install packages with retries
install_package_with_retry() {
    local package=$1
    local max_retries=3
    local retry_count=0

    while [[ $retry_count -lt $max_retries ]]; do
        echo -e "${BLUE}📦 Installing: ${package} (attempt $((retry_count + 1))/${max_retries})${NC}"

        if pkg install -y "$package" 2>/dev/null; then
            echo -e "${GREEN}✅ ${package} installed successfully${NC}"
            return 0
        else
            retry_count=$((retry_count + 1))
            if [[ $retry_count -lt $max_retries ]]; then
                echo -e "${YELLOW}⚠️ Retrying ${package} in 2 seconds...${NC}"
                sleep 2
            fi
        fi
    done

    echo -e "${RED}❌ Failed to install ${package} after ${max_retries} attempts${NC}"
    return 1
}

echo -e "${YELLOW}📋 Installing ${#ESSENTIAL_PACKAGES[@]} essential packages...${NC}"

# Install essential packages with error handling and retries
failed_packages=()
successful_packages=()

for package in "${ESSENTIAL_PACKAGES[@]}"; do
    if install_package_with_retry "$package"; then
        successful_packages+=("$package")
    else
        failed_packages+=("$package")
    fi
done

# Install optional packages (less critical)
echo -e "\n${YELLOW}📋 Installing ${#OPTIONAL_PACKAGES[@]} optional packages...${NC}"
optional_failed=()
optional_successful=()

for package in "${OPTIONAL_PACKAGES[@]}"; do
    echo -e "${BLUE}📦 Installing optional: ${package}${NC}"

    if pkg install -y "$package" 2>/dev/null; then
        echo -e "${GREEN}✅ ${package} installed successfully${NC}"
        optional_successful+=("$package")
    else
        echo -e "${YELLOW}⚠️ Optional package ${package} failed (continuing...)${NC}"
        optional_failed+=("$package")
    fi
done

# Skip Python packages installation for minimal setup
# Users can install specific packages later as needed
echo -e "${YELLOW}🐍 Python installed successfully. Use 'pip install <package>' to add libraries as needed.${NC}"

pip_failed=()
pip_successful=()

# Configurar Git si no está configurado
echo -e "${YELLOW}⚙️ Configurando Git...${NC}"
if ! git config --global user.name > /dev/null 2>&1; then
    read -p "Ingresa tu nombre para Git: " git_name
    git config --global user.name "$git_name"
fi

if ! git config --global user.email > /dev/null 2>&1; then
    read -p "Ingresa tu email para Git: " git_email
    git config --global user.email "$git_email"
fi

# Configurar aliases útiles
echo -e "${YELLOW}🔧 Configurando aliases útiles...${NC}"

# Crear archivo de aliases si no existe (con condicionales para evitar errores)
ALIASES_FILE="$HOME/.bash_aliases"
cat > "$ALIASES_FILE" << 'EOF'
# Aliases útiles para desarrollo
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# Git aliases
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline'
alias gd='git diff'

# Herramientas modernas (solo si existen)
if command -v bat >/dev/null 2>&1; then alias cat='bat'; fi
if command -v exa >/dev/null 2>&1; then alias ls='exa --icons'; fi
if command -v fd >/dev/null 2>&1; then alias find='fd'; fi
if command -v zoxide >/dev/null 2>&1; then alias cd='z'; fi

# Termux específicos
alias apt='pkg'
alias python='python3'
alias pip='pip3'
EOF

# Sourcer aliases en bashrc si no está ya
if ! grep -q "source ~/.bash_aliases" "$HOME/.bashrc" 2>/dev/null; then
    echo "source ~/.bash_aliases" >> "$HOME/.bashrc"
fi

# Ensure ~/bin and npm global bin are in PATH for future sessions
mkdir -p "$HOME/bin"
NPM_GBIN=$(npm bin -g 2>/dev/null || echo "")
if ! grep -q 'export PATH="$HOME/bin' "$HOME/.bashrc" 2>/dev/null; then
    echo 'export PATH="$HOME/bin:$PATH"' >> "$HOME/.bashrc"
fi
if [[ -n "$NPM_GBIN" ]] && ! grep -q "$NPM_GBIN" "$HOME/.bashrc" 2>/dev/null; then
    echo "export PATH=\"$NPM_GBIN:\$PATH\"" >> "$HOME/.bashrc"
fi

# Crear directorio de desarrollo
mkdir -p "$HOME/dev"
mkdir -p "$HOME/.config"

# Installation summary
echo -e "\n${GREEN}📊 INSTALLATION SUMMARY${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

echo -e "${GREEN}✅ Essential packages installed (${#successful_packages[@]}/${#ESSENTIAL_PACKAGES[@]}):${NC}"
for package in "${successful_packages[@]}"; do
    echo -e "   • $package"
done

if [[ ${#failed_packages[@]} -gt 0 ]]; then
    echo -e "\n${RED}❌ Essential packages failed (${#failed_packages[@]}):${NC}"
    for package in "${failed_packages[@]}"; do
        echo -e "   • $package"
    done
fi

echo -e "\n${GREEN}✅ Optional packages installed (${#optional_successful[@]}/${#OPTIONAL_PACKAGES[@]}):${NC}"
for package in "${optional_successful[@]}"; do
    echo -e "   • $package"
done

if [[ ${#optional_failed[@]} -gt 0 ]]; then
    echo -e "\n${YELLOW}⚠️ Optional packages skipped (${#optional_failed[@]}):${NC}"
    for package in "${optional_failed[@]}"; do
        echo -e "   • $package"
    done
fi

# Verify critical installations
echo -e "\n${BLUE}🔍 Verifying critical installations...${NC}"

# Map of tools and their version commands
declare -A tools_commands=(
    ["git"]="git --version"
    ["curl"]="curl --version"
    ["node"]="node --version"
    ["python"]="python --version"
    ["npm"]="npm --version"
)

all_critical_ok=true

for tool in "${!tools_commands[@]}"; do
    if command -v "$tool" >/dev/null 2>&1; then
        version=$(${tools_commands[$tool]} 2>/dev/null | head -n1 || echo "N/A")
        echo -e "${GREEN}✅ ${tool}: ${version}${NC}"
    else
        echo -e "${RED}❌ ${tool}: Not found${NC}"
        all_critical_ok=false
    fi
done

if $all_critical_ok; then
    echo -e "\n${GREEN}🎉 Base packages installation completed successfully!${NC}"
    echo -e "${GREEN}🚀 Development environment is ready to use${NC}"
    echo -e "${YELLOW}💡 Tip: Restart terminal to apply all changes${NC}"
    echo -e "${BLUE}📝 Note: Install additional Python packages with: pip install <package>${NC}"
    echo -e "${BLUE}📦 Install more tools as needed with: pkg install <package>${NC}"
    exit 0
else
    echo -e "\n${RED}⚠️ Some critical tools failed to install${NC}"
    echo -e "${YELLOW}🔧 Try installing them manually with: pkg install <package_name>${NC}"
    echo -e "${YELLOW}🔄 Or run this script again to retry${NC}"
    exit 1
fi