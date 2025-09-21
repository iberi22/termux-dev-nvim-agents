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
PURPLE='\033[0;35m'
NC='\033[0m'

show_banner() {
    clear
    echo -e "${PURPLE}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║              TERMUX AI SETUP - DIAGNOSTIC TOOL              ║${NC}"
    echo -e "${PURPLE}║                   🔍 System Health Check                    ║${NC}"
    echo -e "${PURPLE}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

show_banner

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

# Check current working directory
echo -e "\n${CYAN}=== Directory Context ===${NC}"
echo -e "${BLUE}Current directory: ${PWD}${NC}"
echo -e "${BLUE}Home directory: ${HOME}${NC}"
echo -e "${BLUE}Expected location: ${HOME}/termux-ai-setup${NC}"

if [[ "$PWD" != "$HOME/termux-ai-setup" ]]; then
    echo -e "${YELLOW}⚠️  You're not in the correct directory!${NC}"
    echo -e "${CYAN}💡 Change to the correct directory: cd ~/termux-ai-setup${NC}"
fi

# Check modules
echo -e "\n${CYAN}=== Modules Check ===${NC}"
MODULES_DIR="modules"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FULL_MODULES_DIR="${SCRIPT_DIR}/modules"

echo -e "${BLUE}Script directory: ${SCRIPT_DIR}${NC}"
echo -e "${BLUE}Modules directory: ${FULL_MODULES_DIR}${NC}"

if [[ -d "$MODULES_DIR" ]]; then
    echo -e "${GREEN}✅ modules directory exists (relative)${NC}"
elif [[ -d "$FULL_MODULES_DIR" ]]; then
    echo -e "${GREEN}✅ modules directory exists (absolute)${NC}"
    MODULES_DIR="$FULL_MODULES_DIR"
else
    echo -e "${RED}❌ modules directory not found in either location${NC}"
fi

if [[ -d "$MODULES_DIR" ]]; then
    REQUIRED_MODULES=(
        "00-base-packages.sh"
        "01-zsh-setup.sh"
        "02-neovim-setup.sh"
        "03-ai-integration.sh"
        "04-workflows-setup.sh"
        "05-ssh-setup.sh"
        "06-fonts-setup.sh"
        "99-clean-reset.sh"
        "test-installation.sh"
    )

    MISSING_MODULES=()
    BROKEN_MODULES=()
    
    for module in "${REQUIRED_MODULES[@]}"; do
        module_path="$MODULES_DIR/$module"
        if [[ -f "$module_path" ]]; then
            if [[ -x "$module_path" ]]; then
                # Check if file is corrupted or has syntax errors
                if bash -n "$module_path" 2>/dev/null; then
                    echo -e "${GREEN}  ✅ $module${NC}"
                else
                    echo -e "${RED}  💥 $module (SYNTAX ERROR)${NC}"
                    BROKEN_MODULES+=("$module")
                fi
            else
                echo -e "${YELLOW}  ⚠️  $module (not executable - fixing...)${NC}"
                chmod +x "$module_path"
            fi
        else
            echo -e "${RED}  ❌ $module (MISSING)${NC}"
            MISSING_MODULES+=("$module")
        fi
    done

    # Show detailed file info for debugging
    echo -e "\n${CYAN}=== Detailed Module Info ===${NC}"
    ls -la "$MODULES_DIR"/*.sh 2>/dev/null || echo -e "${YELLOW}No .sh files found in modules directory${NC}"

    if [ ${#MISSING_MODULES[@]} -gt 0 ]; then
        echo -e "\n${RED}❌ Missing modules detected: ${MISSING_MODULES[*]}${NC}"
    fi
    
    if [ ${#BROKEN_MODULES[@]} -gt 0 ]; then
        echo -e "\n${RED}💥 Corrupted modules detected: ${BROKEN_MODULES[*]}${NC}"
    fi
    
    if [ ${#MISSING_MODULES[@]} -gt 0 ] || [ ${#BROKEN_MODULES[@]} -gt 0 ]; then
        echo -e "\n${YELLOW}💡 Fix by re-running the installer:${NC}"
        echo -e "${CYAN}   wget -qO- https://raw.githubusercontent.com/iberi22/termux-dev-nvim-agents/main/termux-ai-setup/install.sh | bash${NC}"
    fi
else
    echo -e "${RED}❌ modules directory not accessible${NC}"
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

# Check core system tools
echo -e "\n${CYAN}=== System Tools ===${NC}"
tools=("node" "npm" "python" "git" "curl" "wget")
for tool in "${tools[@]}"; do
    if command -v "$tool" >/dev/null 2>&1; then
        version=$($tool --version 2>/dev/null | head -n1 || echo "version available")
        echo -e "${GREEN}  ✅ $tool: $version${NC}"
    else
        echo -e "${RED}  ❌ $tool: not found${NC}"
    fi
done

# Summary and recommendations
echo -e "\n${PURPLE}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${PURPLE}║                         SUMMARY                              ║${NC}"
echo -e "${PURPLE}╚══════════════════════════════════════════════════════════════╝${NC}"

ISSUES_FOUND=false

# Check for common issues
if [[ "$PWD" != "$HOME/termux-ai-setup" ]]; then
    echo -e "${RED}🚨 ISSUE: You're in the wrong directory${NC}"
    echo -e "${CYAN}   Fix: cd ~/termux-ai-setup${NC}"
    ISSUES_FOUND=true
fi

if [[ ! -d "$HOME/termux-ai-setup/modules" ]] || [[ ${#MISSING_MODULES[@]} -gt 0 ]] || [[ ${#BROKEN_MODULES[@]} -gt 0 ]]; then
    echo -e "${RED}🚨 ISSUE: Installation files are missing or corrupted${NC}"
    echo -e "${CYAN}   Fix: Re-run the installer${NC}"
    ISSUES_FOUND=true
fi

if ! command -v node >/dev/null 2>&1; then
    echo -e "${YELLOW}⚠️  WARNING: Node.js not found${NC}"
    echo -e "${CYAN}   Fix: Run base packages installation${NC}"
    ISSUES_FOUND=true
fi

if [[ "$ISSUES_FOUND" == false ]]; then
    echo -e "${GREEN}🎉 No critical issues found! Your installation looks healthy.${NC}"
    echo -e "\n${CYAN}💡 Next steps:${NC}"
    echo -e "${CYAN}   • Run setup menu: ./setup.sh${NC}"
    echo -e "${CYAN}   • Run tests: ./setup.sh (option 9)${NC}"
    echo -e "${CYAN}   • Start coding: nvim${NC}"
else
    echo -e "\n${YELLOW}🔧 RECOMMENDED FIXES:${NC}"
    echo -e "${CYAN}   1. Ensure you're in the right directory: cd ~/termux-ai-setup${NC}"
    echo -e "${CYAN}   2. Re-run installer if files are missing: wget -qO- https://raw.githubusercontent.com/iberi22/termux-dev-nvim-agents/main/termux-ai-setup/install.sh | bash${NC}"
    echo -e "${CYAN}   3. Run setup: ./setup.sh${NC}"
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