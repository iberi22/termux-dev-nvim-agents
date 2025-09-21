#!/bin/bash

# ====================================
# TERMUX AI DEVELOPMENT SETUP
# Modular system to configure Termux with AI
# Repository: https://github.com/iberi22/termux-dev-nvim-agents
# Quick install: wget -qO- https://raw.githubusercontent.com/iberi22/termux-dev-nvim-agents/main/termux-ai-setup/install.sh | bash
# ====================================

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODULES_DIR="${SCRIPT_DIR}/modules"
CONFIG_DIR="${SCRIPT_DIR}/config"
LOG_FILE="${SCRIPT_DIR}/setup.log"

# Function for logging
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Function to show banner
show_banner() {
    clear
    echo -e "${PURPLE}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                    TERMUX AI SETUP v2.0                     ║"
    echo "║         Automated System for AI Development in Termux       ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}\n"
}

# Function to check prerequisites
check_prerequisites() {
    echo -e "${BLUE}🔍 Checking prerequisites...${NC}"

    # Verify we're running in Termux
    if [[ ! -d "/data/data/com.termux" ]]; then
        echo -e "${RED}❌ This script must be run in Termux${NC}"
        exit 1
    fi

    # Verify internet connection
    if ! ping -c 1 google.com &> /dev/null; then
        echo -e "${RED}❌ Internet connection required${NC}"
        exit 1
    fi

    # Verify we have the correct directory structure
    if [[ ! -d "$MODULES_DIR" ]]; then
        echo -e "${RED}❌ Modules directory not found: $MODULES_DIR${NC}"
        echo -e "${YELLOW}💡 Please ensure you're running this script from the correct location.${NC}"
        
        # Check if we're in the wrong directory but termux-ai-setup exists
        if [[ -d "$HOME/termux-ai-setup" && "$PWD" != "$HOME/termux-ai-setup" ]]; then
            echo -e "${CYAN}📍 Found installation at: $HOME/termux-ai-setup${NC}"
            echo -e "${CYAN}🔄 Please run: cd ~/termux-ai-setup && ./setup.sh${NC}"
            exit 1
        fi
        
        echo -e "${YELLOW}💡 Try re-running the installer:${NC}"
        echo -e "${CYAN}   wget -qO- https://raw.githubusercontent.com/iberi22/termux-dev-nvim-agents/main/termux-ai-setup/install.sh | bash${NC}"
        exit 1
    fi

    # Verify essential modules exist
    local essential_modules=("00-base-packages.sh" "test-installation.sh")
    for module in "${essential_modules[@]}"; do
        if [[ ! -f "$MODULES_DIR/$module" ]]; then
            echo -e "${RED}❌ Essential module missing: $module${NC}"
            echo -e "${YELLOW}💡 Please re-run the installer to restore missing files.${NC}"
            exit 1
        fi
    done

    echo -e "${GREEN}✅ Prerequisites verified${NC}"
}

# Function to show main menu
show_main_menu() {
    echo -e "${CYAN}┌─────────────────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│                  MAIN MENU                      │${NC}"
    echo -e "${CYAN}├─────────────────────────────────────────────────┤${NC}"
    echo -e "${WHITE}│  1. 📦 Install Base Packages                   │${NC}"
    echo -e "${WHITE}│  2. 🐚 Configure Zsh + Oh My Zsh               │${NC}"
    echo -e "${WHITE}│  3. ⚡ Install and Configure Neovim            │${NC}"
    echo -e "${WHITE}│  4. 🔐 Configure SSH for GitHub                │${NC}"
    echo -e "${WHITE}│  5. 🤖 Configure AI Integration                │${NC}"
    echo -e "${WHITE}│  6. 🔄 Configure AI Workflows                  │${NC}"
    echo -e "${WHITE}│  7. 🖋️  Install Nerd Fonts + Set Font         │${NC}"
    echo -e "${WHITE}│  8. 🌟 Complete Installation (Automatic)       │${NC}"
    echo -e "${WHITE}│  9. 🧪 Run Installation Tests                  │${NC}"
    echo -e "${WHITE}│ 10. 🧹 Clean and Reinstall from Scratch        │${NC}"
    echo -e "${WHITE}│  0. 🚪 Exit                                    │${NC}"
    echo -e "${CYAN}└─────────────────────────────────────────────────┘${NC}"
    echo -e "\n${YELLOW}Select an option [0-10]:${NC} "
}

# Function to run module with error handling
run_module() {
    local module_name="$1"
    local module_path="${MODULES_DIR}/${module_name}.sh"

    echo -e "${BLUE}🔄 Preparing to run: ${module_name}${NC}"
    
    # Debug information
    echo -e "${CYAN}📍 Looking for module at: ${module_path}${NC}"
    echo -e "${CYAN}📁 Current directory: ${PWD}${NC}"
    echo -e "${CYAN}📁 Script directory: ${SCRIPT_DIR}${NC}"
    echo -e "${CYAN}📁 Modules directory: ${MODULES_DIR}${NC}"

    if [[ ! -f "$module_path" ]]; then
        echo -e "${RED}❌ Module not found: ${module_path}${NC}"
        
        # List available modules for debugging
        if [[ -d "$MODULES_DIR" ]]; then
            echo -e "${CYAN}📋 Available modules in ${MODULES_DIR}:${NC}"
            ls -la "$MODULES_DIR"/*.sh 2>/dev/null || echo -e "${YELLOW}  No .sh files found${NC}"
        else
            echo -e "${RED}� Modules directory doesn't exist: ${MODULES_DIR}${NC}"
        fi
        
        echo -e "${YELLOW}💡 Solutions:${NC}"
        echo -e "${CYAN}  1. Ensure you're in the right directory: cd ~/termux-ai-setup${NC}"
        echo -e "${CYAN}  2. Re-run the installer: wget -qO- https://raw.githubusercontent.com/iberi22/termux-dev-nvim-agents/main/termux-ai-setup/install.sh | bash${NC}"
        return 1
    fi

    if [[ ! -x "$module_path" ]]; then
        echo -e "${YELLOW}⚠️  Making ${module_name} executable...${NC}"
        chmod +x "$module_path"
    fi

    echo -e "${BLUE}� Running: ${module_name}${NC}"
    log "Starting module: ${module_name}"

    if bash "$module_path"; then
        echo -e "${GREEN}✅ ${module_name} completed successfully${NC}"
        log "Module completed: ${module_name}"
        return 0
    else
        local exit_code=$?
        echo -e "${RED}❌ Error in ${module_name} (exit code: ${exit_code})${NC}"
        log "Error in module: ${module_name} (exit code: ${exit_code})"
        return 1
    fi
}

# Function to request Gemini API key
setup_gemini_api() {
    if [[ -z "${GEMINI_API_KEY:-}" ]]; then
        echo -e "${YELLOW}🔑 Gemini API Key Configuration${NC}"
        echo -e "${CYAN}To get personalized AI recommendations during installation${NC}"
        echo -e "${CYAN}you need a Google Gemini API key.${NC}\n"
        echo -e "${CYAN}Get your API key at: https://aistudio.google.com/app/apikey${NC}\n"

        read -p "Enter your Gemini API key (or press Enter to continue without AI): " api_key

        if [[ -n "$api_key" ]]; then
            echo "export GEMINI_API_KEY='$api_key'" >> ~/.bashrc
            echo "export GEMINI_API_KEY='$api_key'" >> ~/.zshrc 2>/dev/null || true
            export GEMINI_API_KEY="$api_key"
            echo -e "${GREEN}✅ API key configured correctly${NC}"
        else
            echo -e "${YELLOW}⚠️  Continuing without AI integration${NC}"
        fi
    else
        echo -e "${GREEN}✅ Gemini API key already configured${NC}"
    fi
}

# Function for complete installation
full_installation() {
    echo -e "${BLUE}🚀 Starting complete installation...${NC}"

    local modules=(
        "00-base-packages"
        "01-zsh-setup"
        "02-neovim-setup"
        "05-ssh-setup"
        "03-ai-integration"
        "04-workflows-setup"
        "06-fonts-setup"  # Set FiraCode Nerd Font Mono by default
    )

    setup_gemini_api

    for module in "${modules[@]}"; do
        if ! run_module "$module"; then
            echo -e "${RED}❌ Installation interrupted at: ${module}${NC}"
            read -p "Do you want to continue with the next module? (y/N): " continue_install
            if [[ ! "$continue_install" =~ ^[Yy]$ ]]; then
                return 1
            fi
        fi
        echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    done

    echo -e "${GREEN}🎉 Complete installation finished!${NC}"
    echo -e "${CYAN}🔄 Restarting terminal...${NC}"

    # Reload configuration
    source ~/.bashrc 2>/dev/null || true
    exec "$SHELL" || true
}

# Main function
main() {
    show_banner
    check_prerequisites

    # Create log file
    log "Starting Termux AI Setup"

    # Check if running in automatic mode
    if [[ "${1:-}" == "auto" ]]; then
        echo -e "${BLUE}🤖 Running in automatic mode...${NC}"
        full_installation
        exit $?
    fi

    while true; do
        show_main_menu
        read -r choice

        case $choice in
            1)
                run_module "00-base-packages"
                ;;
            2)
                run_module "01-zsh-setup"
                ;;
            3)
                run_module "02-neovim-setup"
                ;;
            4)
                run_module "05-ssh-setup"
                ;;
            5)
                setup_gemini_api
                run_module "03-ai-integration"
                ;;
            6)
                run_module "04-workflows-setup"
                ;;
            7)
                # Fonts menu: allow user to select font interactively
                if [[ -f "${MODULES_DIR}/06-fonts-setup.sh" ]]; then
                    if bash "${MODULES_DIR}/06-fonts-setup.sh" menu; then
                        echo -e "${GREEN}✅ Font configured successfully${NC}"
                    else
                        echo -e "${YELLOW}⚠️  Font configuration skipped or failed${NC}"
                    fi
                else
                    echo -e "${RED}❌ Fonts module not found${NC}"
                    echo -e "${YELLOW}💡 Re-run the installer to download missing modules:${NC}"
                    echo -e "${CYAN}   wget -qO- https://raw.githubusercontent.com/iberi22/termux-dev-nvim-agents/main/termux-ai-setup/install.sh | bash${NC}"
                fi
                ;;
            8)
                full_installation
                ;;
            9)
                run_module "test-installation"
                ;;
            10)
                run_module "99-clean-reset"
                ;;
            0)
                echo -e "${GREEN}Thank you for using Termux AI Setup!${NC}"
                log "Setup terminated by user"
                exit 0
                ;;
            *)
                echo -e "${RED}❌ Invalid option. Select a number from 0-10.${NC}"
                sleep 2
                ;;
        esac

        echo -e "\n${YELLOW}Press Enter to continue...${NC}"
        read -r
    done
}

# Signal handling
trap 'echo -e "\n${RED}⚠️ Installation interrupted${NC}"; exit 1' INT TERM

# Execute main function
main "$@"