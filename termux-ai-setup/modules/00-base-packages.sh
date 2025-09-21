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

# Essential packages list
PACKAGES=(
    # Basic system tools
    "curl"
    "wget"
    "git"
    "unzip"
    "zip"
    "tar"
    "gzip"

    # Development
    "nodejs"
    "npm"
    "python"
    "python-pip"

    # Editors and search tools
    "vim"
    "nano"
    "ripgrep"
    "fd"
    "fzf"
    "tree"
    "htop"

    # Compilers and build tools
    "gcc"
    "clang"
    "cmake"
    "make"
    "pkg-config"

    # Network tools
    "openssh"
    "rsync"

    # Additional utilities
    "jq"
    "bat"
    "exa"
    "lsd"
    "zoxide"
)

echo -e "${YELLOW}📋 Installing ${#PACKAGES[@]} essential packages...${NC}"

# Install packages with error handling
failed_packages=()
successful_packages=()

for package in "${PACKAGES[@]}"; do
    echo -e "${BLUE}📦 Installing: ${package}${NC}"

    if pkg install -y "$package" 2>/dev/null; then
        echo -e "${GREEN}✅ ${package} installed successfully${NC}"
        successful_packages+=("$package")
    else
        echo -e "${RED}❌ Error installing: ${package}${NC}"
        failed_packages+=("$package")
    fi
done

# Install additional Python tools with pip
echo -e "${YELLOW}🐍 Installing additional Python tools...${NC}"

PYTHON_PACKAGES=(
    "requests"
    "rich"
    "typer"
    "httpx"
    "pydantic"
)

pip_failed=()
pip_successful=()

for py_package in "${PYTHON_PACKAGES[@]}"; do
    echo -e "${BLUE}🐍 Instalando: ${py_package}${NC}"

    if pip install "$py_package" 2>/dev/null; then
        echo -e "${GREEN}✅ ${py_package} instalado correctamente${NC}"
        pip_successful+=("$py_package")
    else
        echo -e "${RED}❌ Error instalando: ${py_package}${NC}"
        pip_failed+=("$py_package")
    fi
done

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

# Crear archivo de aliases si no existe
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

# Herramientas modernas
alias cat='bat'
alias ls='exa --icons'
alias find='fd'
alias cd='z'

# Termux específicos
alias apt='pkg'
alias python='python3'
alias pip='pip3'
EOF

# Sourcer aliases en bashrc si no está ya
if ! grep -q "source ~/.bash_aliases" "$HOME/.bashrc" 2>/dev/null; then
    echo "source ~/.bash_aliases" >> "$HOME/.bashrc"
fi

# Crear directorio de desarrollo
mkdir -p "$HOME/dev"
mkdir -p "$HOME/.config"

# Resumen de instalación
echo -e "\n${GREEN}📊 RESUMEN DE INSTALACIÓN${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

echo -e "${GREEN}✅ Paquetes instalados correctamente (${#successful_packages[@]}):${NC}"
for package in "${successful_packages[@]}"; do
    echo -e "   • $package"
done

if [[ ${#failed_packages[@]} -gt 0 ]]; then
    echo -e "\n${RED}❌ Paquetes que fallaron (${#failed_packages[@]}):${NC}"
    for package in "${failed_packages[@]}"; do
        echo -e "   • $package"
    done
fi

echo -e "\n${GREEN}✅ Paquetes Python instalados correctamente (${#pip_successful[@]}):${NC}"
for package in "${pip_successful[@]}"; do
    echo -e "   • $package"
done

if [[ ${#pip_failed[@]} -gt 0 ]]; then
    echo -e "\n${RED}❌ Paquetes Python que fallaron (${#pip_failed[@]}):${NC}"
    for package in "${pip_failed[@]}"; do
        echo -e "   • $package"
    done
fi

# Verificar instalaciones críticas
echo -e "\n${BLUE}🔍 Verificando instalaciones...${NC}"

critical_tools=("git" "curl" "nodejs" "python" "npm")
all_critical_ok=true

for tool in "${critical_tools[@]}"; do
    if command -v "$tool" >/dev/null 2>&1; then
        version=$(${tool} --version 2>/dev/null | head -n1 || echo "N/A")
        echo -e "${GREEN}✅ ${tool}: ${version}${NC}"
    else
        echo -e "${RED}❌ ${tool}: No encontrado${NC}"
        all_critical_ok=false
    fi
done

if $all_critical_ok; then
    echo -e "\n${GREEN}🎉 ¡Instalación de paquetes básicos completada exitosamente!${NC}"
    echo -e "${YELLOW}💡 Tip: Reinicia el terminal para aplicar todos los cambios${NC}"
    exit 0
else
    echo -e "\n${RED}⚠️ Algunas herramientas críticas no se instalaron correctamente${NC}"
    echo -e "${YELLOW}🔧 Puedes intentar instalarlas manualmente con: pkg install <nombre_paquete>${NC}"
    exit 1
fi