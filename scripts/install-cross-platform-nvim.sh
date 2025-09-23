#!/usr/bin/env bash

# ====================================
# Rastafari Neovim Cross-Platform Installer
# Detects platform and installs appropriate configuration
# ====================================

# Colors for cross-platform support
RED='\033[38;2;255;107;107m'
YELLOW='\033[38;2;255;217;61m'
GREEN='\033[38;2;107;207;127m'
WHITE='\033[38;2;245;245;245m'
GRAY='\033[38;2;160;160;160m'
RESET='\033[0m'
BOLD='\033[1m'

# Platform detection
detect_platform() {
    if [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]] || [[ -n "$WINDIR" ]]; then
        PLATFORM="windows"
        OS_NAME="Windows"
    elif [[ -f "/proc/version" ]] && grep -qi "microsoft\|wsl" /proc/version; then
        PLATFORM="wsl"
        OS_NAME="WSL"
    elif [[ -n "$TERMUX_VERSION" ]] || [[ "$PREFIX" == "/data/data/com.termux/files/usr" ]]; then
        PLATFORM="termux"
        OS_NAME="Termux"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        PLATFORM="macos"
        OS_NAME="macOS"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        PLATFORM="linux"
        OS_NAME="Linux"
    else
        PLATFORM="unknown"
        OS_NAME="Unknown"
    fi
}

# Show platform info
show_platform_info() {
    printf "\n${GREEN}${BOLD}🌿 Rastafari Neovim Cross-Platform Installer 🌿${RESET}\n\n"
    printf "${YELLOW}Detected Platform: ${WHITE}${OS_NAME}${RESET}\n"
    printf "${GRAY}OS Type: ${WHITE}${OSTYPE}${RESET}\n"

    if [[ "$PLATFORM" == "termux" ]]; then
        printf "${GRAY}Termux Version: ${WHITE}${TERMUX_VERSION:-Unknown}${RESET}\n"
    fi

    printf "${GRAY}Architecture: ${WHITE}$(uname -m)${RESET}\n"
    printf "${GRAY}Shell: ${WHITE}${SHELL##*/}${RESET}\n"
}

# Check prerequisites for each platform
check_prerequisites() {
    printf "\n${YELLOW}🔍 Checking prerequisites for ${OS_NAME}...${RESET}\n"

    local missing_deps=()

    # Common requirements
    if ! command -v git &> /dev/null; then
        missing_deps+=("git")
    fi

    if ! command -v curl &> /dev/null && ! command -v wget &> /dev/null; then
        missing_deps+=("curl or wget")
    fi

    # Platform-specific requirements
    case "$PLATFORM" in
        "windows")
            if ! command -v powershell.exe &> /dev/null && ! command -v pwsh.exe &> /dev/null; then
                missing_deps+=("PowerShell")
            fi
            ;;
        "termux")
            if ! command -v pkg &> /dev/null; then
                printf "${RED}❌ This doesn't appear to be a proper Termux environment${RESET}\n"
                return 1
            fi
            ;;
        "macos")
            if ! command -v xcode-select &> /dev/null; then
                missing_deps+=("Xcode Command Line Tools")
            fi
            ;;
    esac

    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        printf "${RED}❌ Missing dependencies:${RESET}\n"
        for dep in "${missing_deps[@]}"; do
            printf "   • ${dep}\n"
        done
        printf "\n${YELLOW}Please install missing dependencies and run again.${RESET}\n"
        return 1
    else
        printf "${GREEN}✅ All prerequisites met!${RESET}\n"
        return 0
    fi
}

# Get Neovim config directory for platform
get_config_dir() {
    case "$PLATFORM" in
        "windows")
            echo "$HOME/AppData/Local/nvim"
            ;;
        "macos"|"linux"|"wsl")
            echo "$HOME/.config/nvim"
            ;;
        "termux")
            echo "$HOME/.config/nvim"
            ;;
        *)
            echo "$HOME/.config/nvim"
            ;;
    esac
}

# Install Neovim if not present
install_neovim() {
    if command -v nvim &> /dev/null; then
        printf "${GREEN}✅ Neovim already installed${RESET}\n"
        nvim --version | head -n 1
        return 0
    fi

    printf "${YELLOW}📦 Installing Neovim for ${OS_NAME}...${RESET}\n"

    case "$PLATFORM" in
        "windows")
            if command -v winget &> /dev/null; then
                winget install Neovim.Neovim
            elif command -v choco &> /dev/null; then
                choco install neovim
            else
                printf "${RED}❌ Please install Neovim manually from: https://neovim.io${RESET}\n"
                return 1
            fi
            ;;
        "macos")
            if command -v brew &> /dev/null; then
                brew install neovim
            else
                printf "${RED}❌ Please install Homebrew first: https://brew.sh${RESET}\n"
                return 1
            fi
            ;;
        "linux")
            if command -v apt &> /dev/null; then
                sudo apt update && sudo apt install -y neovim
            elif command -v pacman &> /dev/null; then
                sudo pacman -S neovim
            elif command -v dnf &> /dev/null; then
                sudo dnf install neovim
            elif command -v zypper &> /dev/null; then
                sudo zypper install neovim
            else
                printf "${RED}❌ Please install Neovim using your distribution's package manager${RESET}\n"
                return 1
            fi
            ;;
        "wsl")
            sudo apt update && sudo apt install -y neovim
            ;;
        "termux")
            pkg install neovim
            ;;
        *)
            printf "${RED}❌ Unsupported platform for automatic Neovim installation${RESET}\n"
            return 1
            ;;
    esac

    # Verify installation
    if command -v nvim &> /dev/null; then
        printf "${GREEN}✅ Neovim installed successfully!${RESET}\n"
        nvim --version | head -n 1
        return 0
    else
        printf "${RED}❌ Neovim installation failed${RESET}\n"
        return 1
    fi
}

# Install platform-specific dependencies
install_dependencies() {
    printf "\n${YELLOW}📦 Installing platform-specific dependencies...${RESET}\n"

    case "$PLATFORM" in
        "windows")
            printf "${WHITE}Installing Windows dependencies...${RESET}\n"
            # Node.js for LSP
            if ! command -v node &> /dev/null; then
                if command -v winget &> /dev/null; then
                    winget install OpenJS.NodeJS
                elif command -v choco &> /dev/null; then
                    choco install nodejs
                fi
            fi

            # Python for some plugins
            if ! command -v python &> /dev/null && ! command -v python3 &> /dev/null; then
                if command -v winget &> /dev/null; then
                    winget install Python.Python.3
                elif command -v choco &> /dev/null; then
                    choco install python
                fi
            fi
            ;;

        "macos")
            if command -v brew &> /dev/null; then
                brew install node python3 ripgrep fd
            fi
            ;;

        "linux"|"wsl")
            if command -v apt &> /dev/null; then
                sudo apt install -y nodejs npm python3 python3-pip ripgrep fd-find
            elif command -v pacman &> /dev/null; then
                sudo pacman -S nodejs npm python python-pip ripgrep fd
            elif command -v dnf &> /dev/null; then
                sudo dnf install nodejs npm python3 python3-pip ripgrep fd-find
            fi
            ;;

        "termux")
            pkg install nodejs python ripgrep fd tree curl wget
            ;;
    esac

    printf "${GREEN}✅ Dependencies installation completed${RESET}\n"
}

# Backup existing config
backup_existing_config() {
    local config_dir="$1"

    if [[ -d "$config_dir" ]]; then
        local backup_dir="${config_dir}.backup.$(date +%Y%m%d_%H%M%S)"
        printf "${YELLOW}⚠️  Backing up existing config to: ${backup_dir}${RESET}\n"

        if mv "$config_dir" "$backup_dir"; then
            printf "${GREEN}✅ Backup created successfully${RESET}\n"
        else
            printf "${RED}❌ Failed to create backup${RESET}\n"
            return 1
        fi
    fi

    return 0
}

# Install Rastafari config
install_rastafari_config() {
    local config_dir="$1"

    printf "\n${GREEN}🌿 Installing Rastafari Neovim configuration...${RESET}\n"

    # Create config directory
    mkdir -p "$config_dir"

    # Copy base configuration files
    if [[ -d "config/neovim" ]]; then
        printf "${WHITE}Copying configuration files...${RESET}\n"
        cp -r config/neovim/* "$config_dir/"

        # Create init.lua that uses cross-platform configuration
        cat > "$config_dir/init.lua" << 'EOF'
-- Rastafari Neovim Cross-Platform Init
-- Auto-detects platform and loads appropriate configuration

-- Load cross-platform configuration
require("config.init-cross-platform")
EOF

        printf "${GREEN}✅ Configuration files copied${RESET}\n"
    else
        printf "${RED}❌ Configuration source not found${RESET}\n"
        return 1
    fi

    # Set proper permissions (Unix-like systems)
    if [[ "$PLATFORM" != "windows" ]]; then
        chmod -R 755 "$config_dir"
    fi

    return 0
}

# Create platform-specific startup script
create_startup_script() {
    local config_dir="$1"

    case "$PLATFORM" in
        "windows")
            # Create PowerShell startup script
            local ps_script="$config_dir/rastafari-nvim.ps1"
            cat > "$ps_script" << 'EOF'
# Rastafari Neovim Windows Startup Script
$env:RASTAFARI_PLATFORM = "windows"
& nvim $args
EOF
            printf "${GREEN}✅ PowerShell startup script created${RESET}\n"
            ;;

        "termux")
            # Create Termux-specific alias
            local alias_file="$HOME/.rastafari-nvim-termux"
            cat > "$alias_file" << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
# Rastafari Neovim Termux Startup
export RASTAFARI_PLATFORM="termux"
exec nvim "$@"
EOF
            chmod +x "$alias_file"
            printf "${GREEN}✅ Termux startup script created${RESET}\n"
            ;;

        *)
            # Create standard Unix startup script
            local startup_script="$HOME/.local/bin/rasta-nvim"
            mkdir -p "$(dirname "$startup_script")"
            cat > "$startup_script" << 'EOF'
#!/usr/bin/env bash
# Rastafari Neovim Startup Script
export RASTAFARI_PLATFORM="$(uname -s | tr '[:upper:]' '[:lower:]')"
exec nvim "$@"
EOF
            chmod +x "$startup_script"
            printf "${GREEN}✅ Startup script created: $startup_script${RESET}\n"
            ;;
    esac
}

# Test installation
test_installation() {
    printf "\n${YELLOW}🧪 Testing installation...${RESET}\n"

    # Test Neovim startup
    if nvim --headless -c 'lua print("Test successful")' -c 'qall' 2>/dev/null; then
        printf "${GREEN}✅ Neovim starts successfully${RESET}\n"
    else
        printf "${RED}❌ Neovim startup test failed${RESET}\n"
        return 1
    fi

    # Test configuration loading
    local config_dir=$(get_config_dir)
    if [[ -f "$config_dir/init.lua" ]]; then
        printf "${GREEN}✅ Configuration file found${RESET}\n"
    else
        printf "${RED}❌ Configuration file missing${RESET}\n"
        return 1
    fi

    printf "${GREEN}✅ Installation test passed!${RESET}\n"
    return 0
}

# Show post-installation instructions
show_post_install_instructions() {
    printf "\n${GREEN}${BOLD}🎉 Rastafari Neovim Installation Complete! 🎉${RESET}\n\n"

    printf "${YELLOW}📋 Next Steps:${RESET}\n"

    case "$PLATFORM" in
        "windows")
            printf "${WHITE}1. Start Neovim: ${GREEN}nvim${WHITE} or use the PowerShell script${RESET}\n"
            printf "${WHITE}2. Wait for plugins to install automatically${RESET}\n"
            printf "${WHITE}3. Restart Neovim after plugin installation${RESET}\n"
            ;;
        "termux")
            printf "${WHITE}1. Start Neovim: ${GREEN}nvim${WHITE} or ${GREEN}rasta-neovim${RESET}\n"
            printf "${WHITE}2. Run ${GREEN}:Lazy${WHITE} to install plugins${RESET}\n"
            printf "${WHITE}3. Use ${GREEN}rasta-tutorial${WHITE} for first-time setup${RESET}\n"
            ;;
        *)
            printf "${WHITE}1. Start Neovim: ${GREEN}nvim${WHITE} or ${GREEN}rasta-nvim${RESET}\n"
            printf "${WHITE}2. Wait for LazyVim to install plugins${RESET}\n"
            printf "${WHITE}3. Run ${GREEN}:checkhealth${WHITE} to verify everything works${RESET}\n"
            ;;
    esac

    printf "\n${YELLOW}🔧 Useful Commands:${RESET}\n"
    printf "${WHITE}• ${GREEN}:Lazy${WHITE} - Plugin manager${RESET}\n"
    printf "${WHITE}• ${GREEN}:Mason${WHITE} - LSP installer${RESET}\n"
    printf "${WHITE}• ${GREEN}:RastafariPlatform${WHITE} - Show platform info${RESET}\n"
    printf "${WHITE}• ${GREEN}:RastafariDiagnostic${WHITE} - System diagnostic${RESET}\n"

    printf "\n${GREEN}${ITALIC}\"One love, one terminal, one Neovim!\"${RESET}\n"
    printf "${GRAY}Welcome to the Rastafari coding family! 💚💛❤️${RESET}\n\n"
}

# Main installation function
main() {
    # Parse command line arguments
    case "${1:-}" in
        "help"|"--help"|"-h")
            printf "${GREEN}${BOLD}Rastafari Neovim Cross-Platform Installer${RESET}\n\n"
            printf "${WHITE}Usage: $0 [options]${RESET}\n"
            printf "${WHITE}Options:${RESET}\n"
            printf "  ${GREEN}help${WHITE}     Show this help message${RESET}\n"
            printf "  ${GREEN}test${WHITE}     Test current installation${RESET}\n"
            printf "  ${GREEN}backup${WHITE}   Backup existing config only${RESET}\n"
            exit 0
            ;;
        "test")
            detect_platform
            show_platform_info
            test_installation
            exit $?
            ;;
        "backup")
            detect_platform
            local config_dir=$(get_config_dir)
            backup_existing_config "$config_dir"
            exit $?
            ;;
    esac

    # Detect platform
    detect_platform
    show_platform_info

    # Check prerequisites
    if ! check_prerequisites; then
        exit 1
    fi

    # Get config directory
    local config_dir=$(get_config_dir)
    printf "${GRAY}Configuration will be installed to: ${WHITE}${config_dir}${RESET}\n"

    # Ask for confirmation
    printf "\n${YELLOW}Continue with installation? (y/N): ${RESET}"
    read -r confirm
    if [[ ! "$confirm" =~ ^[Yy] ]]; then
        printf "${GRAY}Installation cancelled.${RESET}\n"
        exit 0
    fi

    # Install Neovim if needed
    if ! install_neovim; then
        exit 1
    fi

    # Install dependencies
    install_dependencies

    # Backup existing configuration
    if ! backup_existing_config "$config_dir"; then
        exit 1
    fi

    # Install Rastafari configuration
    if ! install_rastafari_config "$config_dir"; then
        exit 1
    fi

    # Create startup script
    create_startup_script "$config_dir"

    # Test installation
    if ! test_installation; then
        printf "${YELLOW}⚠️  Installation completed but tests failed. You may need to configure manually.${RESET}\n"
    fi

    # Show post-installation instructions
    show_post_install_instructions
}

# Run main function
main "$@"