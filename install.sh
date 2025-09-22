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
BASE_URL="https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/${BRANCH}"

# Installation directory
INSTALL_DIR="$HOME/termux-dev-nvim-agents"

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

    # Download diagnostic tool
    echo -e "${CYAN}  → diagnose.sh${NC}"
    if wget -q "$BASE_URL/diagnose.sh" -O diagnose.sh; then
        echo -e "${GREEN}    ✅ Downloaded diagnostic tool${NC}"
    else
        echo -e "${YELLOW}    ⚠️  Could not download diagnostic tool${NC}"
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
        "07-local-ssh-server.sh"
        "06-fonts-setup.sh"
        "99-clean-reset.sh"
        "test-installation.sh"
    )

    echo -e "${YELLOW}Downloading modules...${NC}"
    local failed_modules=()
    for module in "${modules[@]}"; do
        echo -e "${CYAN}  → $module${NC}"
        if wget -q "$BASE_URL/modules/$module" -O "modules/$module"; then
            echo -e "${GREEN}    ✅ Downloaded${NC}"
        else
            echo -e "${RED}    ❌ Failed to download${NC}"
            failed_modules+=("$module")
        fi
    done

    # Report any failures
    if [ ${#failed_modules[@]} -gt 0 ]; then
        echo -e "${RED}❌ Failed to download these modules:${NC}"
        for failed in "${failed_modules[@]}"; do
            echo -e "${RED}  - $failed${NC}"
        done
        echo -e "${YELLOW}⚠️  Installation may be incomplete${NC}"
    fi

    # Download Neovim configs
    echo -e "${YELLOW}Downloading Neovim configurations...${NC}"
    local configs=("ai.lua" "ui.lua")
    for config in "${configs[@]}"; do
        echo -e "${CYAN}  → $config${NC}"
        if wget -q "$BASE_URL/config/neovim/lua/plugins/$config" -O "config/neovim/lua/plugins/$config"; then
            echo -e "${GREEN}    ✅ Downloaded${NC}"
        else
            echo -e "${RED}    ❌ Failed to download config $config${NC}"
        fi
    done

    # Make scripts executable
    chmod +x setup.sh
    chmod +x diagnose.sh 2>/dev/null || true
    chmod +x modules/*.sh 2>/dev/null || true

    # Final verification
    echo -e "${BLUE}🔍 Verifying downloads...${NC}"
    local essential_files=("setup.sh" "modules/00-base-packages.sh" "modules/06-fonts-setup.sh" "modules/07-local-ssh-server.sh")
    for file in "${essential_files[@]}"; do
        if [[ -f "$file" ]]; then
            echo -e "${GREEN}  ✅ $file${NC}"
        else
            echo -e "${RED}  ❌ Missing: $file${NC}"
            echo -e "${RED}❌ Critical file missing. Installation cannot continue.${NC}"
            exit 1
        fi
    done

    echo -e "${GREEN}✅ Download completed and verified${NC}"
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
    echo -e "\n${BLUE}📋 Useful commands:${NC}"
    echo -e "${CYAN}  • Run setup menu: cd ~/termux-dev-nvim-agents && ./setup.sh${NC}"
    echo -e "${CYAN}  • Diagnose problems: cd ~/termux-dev-nvim-agents && ./diagnose.sh${NC}"
    echo -e "${CYAN}  • Test installation: cd ~/termux-dev-nvim-agents && ./setup.sh (option 9)${NC}"
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
