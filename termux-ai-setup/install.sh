#!/bin/bash

# ====================================
# TERMUX AI SETUP - QUICK INSTALLER
# One-command installation script
# ====================================

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# GitHub repository info
REPO_OWNER="iberi22"
REPO_NAME="termux-dev-nvim-agents"
BRANCH="main"
BASE_URL="https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/${BRANCH}/termux-ai-setup"

# Installation directory
INSTALL_DIR="$HOME/termux-ai-setup"

show_banner() {
    clear
    echo -e "${PURPLE}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║              TERMUX AI SETUP - QUICK INSTALLER              ║"
    echo "║         🚀 One-command installation for Termux AI           ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}\n"
}

check_termux() {
    if [[ ! -d "/data/data/com.termux" ]]; then
        echo -e "${RED}❌ This script must be run in Termux${NC}"
        exit 1
    fi
    
    if ! command -v pkg >/dev/null 2>&1; then
        echo -e "${RED}❌ Termux package manager not found${NC}"
        exit 1
    fi
}

install_prerequisites() {
    echo -e "${BLUE}📦 Installing prerequisites...${NC}"
    
    # Update packages first
    pkg update -y >/dev/null 2>&1
    
    # Install essential tools
    for tool in curl wget git unzip; do
        if ! command -v $tool >/dev/null 2>&1; then
            echo -e "${YELLOW}Installing $tool...${NC}"
            pkg install -y $tool >/dev/null 2>&1
        fi
    done
    
    echo -e "${GREEN}✅ Prerequisites installed${NC}"
}

download_setup() {
    echo -e "${BLUE}📥 Downloading Termux AI Setup...${NC}"
    
    # Remove existing installation
    if [[ -d "$INSTALL_DIR" ]]; then
        rm -rf "$INSTALL_DIR"
    fi
    
    # Create installation directory
    mkdir -p "$INSTALL_DIR"
    cd "$INSTALL_DIR"
    
    # Download main setup script
    if ! wget -q "$BASE_URL/setup.sh" -O setup.sh; then
        echo -e "${RED}❌ Failed to download setup script${NC}"
        exit 1
    fi
    
    # Download modules directory
    mkdir -p modules config/neovim/lua/plugins
    
    local modules=(
        "00-base-packages.sh"
        "01-zsh-setup.sh" 
        "02-neovim-setup.sh"
        "03-ai-integration.sh"
        "04-workflows-setup.sh"
        "05-ssh-setup.sh"
        "06-fonts-setup.sh"
        "test-installation.sh"
    )
    
    echo -e "${YELLOW}Downloading modules...${NC}"
    for module in "${modules[@]}"; do
        if ! wget -q "$BASE_URL/modules/$module" -O "modules/$module"; then
            echo -e "${YELLOW}⚠️  Warning: Could not download module $module${NC}"
        fi
    done
    
    # Download Neovim configs
    echo -e "${YELLOW}Downloading Neovim configurations...${NC}"
    local configs=("ai.lua" "ui.lua")
    for config in "${configs[@]}"; do
        if ! wget -q "$BASE_URL/config/neovim/lua/plugins/$config" -O "config/neovim/lua/plugins/$config"; then
            echo -e "${YELLOW}⚠️  Warning: Could not download config $config${NC}"
        fi
    done
    
    # Make scripts executable
    chmod +x setup.sh
    chmod +x modules/*.sh
    
    echo -e "${GREEN}✅ Download completed${NC}"
}

run_installation() {
    echo -e "${BLUE}🚀 Starting automatic installation...${NC}"
    
    cd "$INSTALL_DIR"
    
    # Request storage permission once (optional but helpful)
    if [ ! -d "$HOME/storage" ]; then
        echo -e "${YELLOW}🔐 Requesting storage access permission...${NC}"
        termux-setup-storage || true
        sleep 1
    fi

    # Run complete installation in automatic mode
    ./setup.sh auto
    
    echo -e "${GREEN}🎉 Installation completed successfully!${NC}"
    echo -e "${CYAN}📍 Installation directory: $INSTALL_DIR${NC}"
    echo -e "${CYAN}🔄 Please restart your terminal or run: exec \$SHELL${NC}"
}

main() {
    show_banner
    
    echo -e "${CYAN}🔍 Checking environment...${NC}"
    check_termux
    
    install_prerequisites
    download_setup
    run_installation
    
    echo -e "\n${GREEN}✅ Termux AI Setup installation complete!${NC}"
    echo -e "${CYAN}To manage your installation, run:${NC}"
    echo -e "${WHITE}  cd $INSTALL_DIR && ./setup.sh${NC}"
}

# Handle interrupts
trap 'echo -e "\n${RED}⚠️ Installation interrupted${NC}"; exit 1' INT TERM

# Run main function
main "$@"
