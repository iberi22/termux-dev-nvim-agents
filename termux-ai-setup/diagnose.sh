#!/bin/bash

# ====================================
# TERMUX AI SETUP - DIAGNOSTIC TOOL
# Checks installation status and identifies problems
# ====================================

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${BLUE}🔍 TERMUX AI SETUP - DIAGNOSTIC TOOL${NC}\n"

# Check Termux environment
echo -e "${CYAN}=== Environment Check ===${NC}"
if [[ -d "/data/data/com.termux" ]]; then
    echo -e "${GREEN}✅ Running in Termux${NC}"
else
    echo -e "${RED}❌ Not running in Termux${NC}"
fi

if command -v pkg >/dev/null 2>&1; then
    echo -e "${GREEN}✅ pkg command available${NC}"
else
    echo -e "${RED}❌ pkg command not found${NC}"
fi

# Check installation directory
echo -e "\n${CYAN}=== Installation Directory ===${NC}"
INSTALL_DIR="$HOME/termux-ai-setup"
if [[ -d "$INSTALL_DIR" ]]; then
    echo -e "${GREEN}✅ Installation directory exists: $INSTALL_DIR${NC}"
    cd "$INSTALL_DIR"
else
    echo -e "${RED}❌ Installation directory not found: $INSTALL_DIR${NC}"
    echo -e "${YELLOW}💡 Run the installer first:${NC}"
    echo -e "${CYAN}   wget -qO- https://raw.githubusercontent.com/iberi22/termux-dev-nvim-agents/main/termux-ai-setup/install.sh | bash${NC}"
    exit 1
fi

# Check main script
echo -e "\n${CYAN}=== Main Scripts ===${NC}"
if [[ -f "setup.sh" ]]; then
    if [[ -x "setup.sh" ]]; then
        echo -e "${GREEN}✅ setup.sh exists and is executable${NC}"
    else
        echo -e "${YELLOW}⚠️  setup.sh exists but not executable (fixing...)${NC}"
        chmod +x setup.sh
    fi
else
    echo -e "${RED}❌ setup.sh not found${NC}"
fi

# Check modules
echo -e "\n${CYAN}=== Modules Check ===${NC}"
MODULES_DIR="modules"
if [[ -d "$MODULES_DIR" ]]; then
    echo -e "${GREEN}✅ modules directory exists${NC}"

    REQUIRED_MODULES=(
        "00-base-packages.sh"
        "01-zsh-setup.sh"
        "02-neovim-setup.sh"
        "03-ai-integration.sh"
        "04-workflows-setup.sh"
        "05-ssh-setup.sh"
        "06-fonts-setup.sh"
        "test-installation.sh"
    )

    MISSING_MODULES=()
    for module in "${REQUIRED_MODULES[@]}"; do
        if [[ -f "$MODULES_DIR/$module" ]]; then
            if [[ -x "$MODULES_DIR/$module" ]]; then
                echo -e "${GREEN}  ✅ $module${NC}"
            else
                echo -e "${YELLOW}  ⚠️  $module (not executable - fixing...)${NC}"
                chmod +x "$MODULES_DIR/$module"
            fi
        else
            echo -e "${RED}  ❌ $module (MISSING)${NC}"
            MISSING_MODULES+=("$module")
        fi
    done

    if [ ${#MISSING_MODULES[@]} -gt 0 ]; then
        echo -e "\n${RED}❌ Missing modules detected!${NC}"
        echo -e "${YELLOW}💡 Re-run the installer to fix:${NC}"
        echo -e "${CYAN}   wget -qO- https://raw.githubusercontent.com/iberi22/termux-dev-nvim-agents/main/termux-ai-setup/install.sh | bash${NC}"
    fi
else
    echo -e "${RED}❌ modules directory not found${NC}"
fi

# Check config files
echo -e "\n${CYAN}=== Configuration Files ===${NC}"
if [[ -d "config/neovim/lua/plugins" ]]; then
    echo -e "${GREEN}✅ config directory structure exists${NC}"

    CONFIGS=("ai.lua" "ui.lua")
    for config in "${CONFIGS[@]}"; do
        if [[ -f "config/neovim/lua/plugins/$config" ]]; then
            echo -e "${GREEN}  ✅ $config${NC}"
        else
            echo -e "${YELLOW}  ⚠️  $config (missing)${NC}"
        fi
    done
else
    echo -e "${YELLOW}⚠️  config directory structure missing${NC}"
fi

# Check internet connectivity
echo -e "\n${CYAN}=== Network Check ===${NC}"
if ping -c 1 google.com &> /dev/null; then
    echo -e "${GREEN}✅ Internet connection working${NC}"
else
    echo -e "${RED}❌ No internet connection${NC}"
fi

# Check storage permissions
echo -e "\n${CYAN}=== Storage Permissions ===${NC}"
if [[ -d "$HOME/storage" ]]; then
    echo -e "${GREEN}✅ Storage access configured${NC}"
else
    echo -e "${YELLOW}⚠️  Storage access not configured${NC}"
    echo -e "${CYAN}   Run: termux-setup-storage${NC}"
fi

echo -e "\n${BLUE}🔍 Diagnostic complete!${NC}"

# Offer to fix common problems
if [ ${#MISSING_MODULES[@]} -gt 0 ]; then
    echo -e "\n${YELLOW}Would you like to re-download missing modules? (y/N):${NC}"
    read -r fix_modules
    if [[ "$fix_modules" =~ ^[Yy]$ ]]; then
        echo -e "${BLUE}Re-running installer...${NC}"
        wget -qO- https://raw.githubusercontent.com/iberi22/termux-dev-nvim-agents/main/termux-ai-setup/install.sh | bash
    fi
fi