#!/bin/bash

# ====================================
# MODULE: Base Packages Installation (Restored)
# Robust, idempotent installation of essential tools
# ====================================

set -euo pipefail

RED='\033[0;31m'
GREmain() {
    echo -e "${CYAN}🚀 Starting Termux package installation with enhanced robustness${NC}"
    
    # Step 1: Fix mirrors and sources
    fix_termux_mirrors
    
    # Step 2: Pre-configure for non-interactive installation
    preconfigure_packages
    
    # Step 3: Update repositories with enhanced retry logic
    update_repositories
    
    # Step 4: Upgrade existing packages
    upgrade_packages
    
    # Step 5: Install essential packages with detailed tracking
    echo -e "${YELLOW}📋 Installing ${#ESSENTIAL_PACKAGES[@]} essential packages...${NC}"
    local failed_packages=() successful_packages=()
    local package_count=0
    
    for package in "${ESSENTIAL_PACKAGES[@]}"; do
        package_count=$((package_count + 1))
        echo -e "${CYAN}[${package_count}/${#ESSENTIAL_PACKAGES[@]}] Processing: ${package}${NC}"
        
        if install_package_with_retry "$package"; then
            successful_packages+=("$package")
        else
            failed_packages+=("$package")
            echo -e "${RED}⚠️ Critical package ${package} failed to install${NC}"
        fi
    done

    # Step 6: Install optional packages (non-critical)
    echo -e "\n${YELLOW}🎯 Installing ${#OPTIONAL_PACKAGES[@]} optional packages...${NC}"
    local optional_failed=() optional_successful=()
    
    for package in "${OPTIONAL_PACKAGES[@]}"; do
        echo -e "${CYAN}📦 Optional: ${package}${NC}"
        if install_package_with_retry "$package"; then
            optional_successful+=("$package")
        else
            optional_failed+=("$package")
        fi
    done

    # Step 7: Configure Git if needed
    echo -e "${YELLOW}⚙️ Configurando Git...${NC}"
    if [[ "${TERMUX_AI_AUTO:-}" == "1" || "${TERMUX_AI_SILENT:-}" == "1" ]]; then
        if ! git config --global user.name >/dev/null 2>&1; then
            git config --global user.name "${TERMUX_AI_GIT_NAME:-Termux Developer}" 2>/dev/null || true
        fi
        if ! git config --global user.email >/dev/null 2>&1; then
            git config --global user.email "${TERMUX_AI_GIT_EMAIL:-dev@termux.local}" 2>/dev/null || true
        fi
    fi

    # Step 8: Setup useful aliases
    echo -e "${YELLOW}🔧 Configurando aliases útiles...${NC}"
    local ALIASES_FILE="$HOME/.bash_aliases"
    cat > "$ALIASES_FILE" <<'EOF'
# Aliases de Termux AI
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline'
alias gd='git diff'
if command -v bat >/dev/null 2>&1; then alias cat='bat'; fi
if command -v exa >/dev/null 2>&1; then alias ls='exa --icons'; fi
if command -v fd  >/dev/null 2>&1; then alias find='fd'; fi
if command -v zoxide >/dev/null 2>&1; then alias cd='z'; fi
alias apt='pkg'
alias python='python3'
alias pip='pip3'
EOF
    grep -q "source ~/.bash_aliases" "$HOME/.bashrc" 2>/dev/null || echo "source ~/.bash_aliases" >> "$HOME/.bashrc"

    # Step 9: Setup directory structure
    mkdir -p "$HOME/bin" "$HOME/dev" "$HOME/.config"
    local NPM_GBIN
    NPM_GBIN=$(npm bin -g 2>/dev/null || echo "")
    if [[ -n "$NPM_GBIN" ]] && ! grep -q "$NPM_GBIN" "$HOME/.bashrc" 2>/dev/null; then
        echo "export PATH=\"$NPM_GBIN:\$PATH\"" >> "$HOME/.bashrc"
    fi

    # Step 10: Generate detailed installation report
    echo -e "\n${GREEN}📊 ENHANCED INSTALLATION SUMMARY${NC}"
    echo -e "${GREEN}Essential: ${#successful_packages[@]} ok / ${#ESSENTIAL_PACKAGES[@]} total${NC}"
    [[ ${#failed_packages[@]} -gt 0 ]] && echo -e "${RED}Failed essential: ${failed_packages[*]}${NC}"
    echo -e "${GREEN}Optional: ${#optional_successful[@]} ok / ${#OPTIONAL_PACKAGES[@]} total${NC}"
    [[ ${#optional_failed[@]} -gt 0 ]] && echo -e "${YELLOW}Skipped optional: ${optional_failed[*]}${NC}"

    # Step 11: Verify critical tool availability
    local critical_tools=(git curl python node npm pkg)
    local missing_critical=()
    
    for tool in "${critical_tools[@]}"; do
        if ! command -v "$tool" >/dev/null 2>&1; then
            missing_critical+=("$tool")
        fi
    done

    # Step 12: Determine final status and exit appropriately
    if [[ ${#missing_critical[@]} -eq 0 && ${#failed_packages[@]} -eq 0 ]]; then
        echo -e "${GREEN}🎉 Base packages installation completed successfully!${NC}"
        echo -e "${GREEN}✅ All critical tools are available and working${NC}"
        touch "$MODULE_MARKER" 2>/dev/null || true
        if command -v termux_ai_record_module_state >/dev/null 2>&1; then
            termux_ai_record_module_state "$MODULE_NAME" "$0" "completed" 0 || true
        fi
        exit 0
    elif [[ ${#missing_critical[@]} -eq 0 ]]; then
        echo -e "${YELLOW}⚠️ Installation completed with some optional failures${NC}"
        echo -e "${GREEN}✅ All critical tools are available${NC}"
        touch "$MODULE_MARKER" 2>/dev/null || true
        if command -v termux_ai_record_module_state >/dev/null 2>&1; then
            termux_ai_record_module_state "$MODULE_NAME" "$0" "completed" 0 || true
        fi
        exit 0
    else
        echo -e "${RED}❌ Critical installation failures detected${NC}"
        echo -e "${RED}Missing critical tools: ${missing_critical[*]}${NC}"
        echo -e "${YELLOW}💡 You can rerun this module to retry failed installations${NC}"
        if command -v termux_ai_record_module_state >/dev/null 2>&1; then
            termux_ai_record_module_state "$MODULE_NAME" "$0" "partial" 1 || true
        fi
        exit 1
    fi
}N='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${BLUE}📦 Installing Termux base packages...${NC}"

STATE_MARKER_DIR="$HOME/.termux-ai-setup/state"
mkdir -p "$STATE_MARKER_DIR" 2>/dev/null || true
MODULE_NAME="00-base-packages"
MODULE_MARKER="$STATE_MARKER_DIR/${MODULE_NAME}.ok"

if [[ -f "$MODULE_MARKER" && "${TERMUX_AI_FORCE_MODULES:-0}" != "1" ]]; then
    echo -e "${GREEN}🔁 ${MODULE_NAME} ya completado anteriormente (marker). Usa --force para reejecutar.${NC}"
    exit 0
fi

fix_termux_mirrors() {
    echo -e "${YELLOW}🔧 Fixing Termux mirrors and sources...${NC}"
    
    # Check if using deprecated PlayStore version
    if [[ -f "$PREFIX/etc/apt/sources.list" ]]; then
        if grep -q "bintray" "$PREFIX/etc/apt/sources.list" 2>/dev/null; then
            echo -e "${RED}⚠️ Detected deprecated Bintray mirror. Fixing...${NC}"
        fi
    fi
    
    # Ensure termux-tools is up to date first
    if ! apt update -qq 2>/dev/null; then
        echo -e "${YELLOW}⚠️ Initial apt update failed, attempting mirror fix...${NC}"
    fi
    
    # Install or update termux-tools if available
    apt install -y termux-tools 2>/dev/null || true
    
    # Use termux-change-repo if available
    if command -v termux-change-repo >/dev/null 2>&1; then
        echo -e "${CYAN}🔄 Updating mirrors automatically...${NC}"
        # Select a reliable mirror automatically 
        echo -e "1\n1\n" | termux-change-repo 2>/dev/null || {
            echo -e "${YELLOW}⚠️ Automatic mirror change failed, using fallback...${NC}"
            # Fallback to manual configuration with known good mirror
            cat > "$PREFIX/etc/apt/sources.list" <<'EOF'
# The main termux repository
deb https://packages.termux.dev/apt/termux-main stable main
EOF
        }
    else
        # Manual fallback configuration
        echo -e "${YELLOW}⚠️ termux-change-repo not available, using manual config...${NC}"
        cat > "$PREFIX/etc/apt/sources.list" <<'EOF'
# The main termux repository  
deb https://packages.termux.dev/apt/termux-main stable main
EOF
    fi
    
    # Configure dpkg for non-interactive mode
    mkdir -p "$PREFIX/etc/dpkg/dpkg.cfg.d"
    cat > "$PREFIX/etc/dpkg/dpkg.cfg.d/01_termux_ai" <<'EOF'
# Termux AI automatic configuration handling
force-confnew
force-overwrite
EOF
}

preconfigure_packages() {
    echo -e "${YELLOW}⚙️ Pre-configuring system packages...${NC}"
    export DEBIAN_FRONTEND=noninteractive
    export APT_LISTCHANGES_FRONTEND=none
    export NEEDRESTART_MODE=a
    if [[ -f "$PREFIX/etc/ssl/openssl.cnf" && ! -f "$PREFIX/etc/ssl/openssl.cnf.termux-ai-backup" ]]; then
        cp "$PREFIX/etc/ssl/openssl.cnf" "$PREFIX/etc/ssl/openssl.cnf.termux-ai-backup" 2>/dev/null || true
    fi
}

update_repositories() {
    echo -e "${YELLOW}🔄 Updating repositories with enhanced retry logic...${NC}"
    local max_retries=5 retry_count=0
    local backoff_delay=2
    
    while [[ $retry_count -lt $max_retries ]]; do
        retry_count=$((retry_count+1))
        echo -e "${CYAN}📡 Repository update attempt $retry_count/$max_retries...${NC}"
        
        # Clear any problematic cache first
        if [[ $retry_count -gt 1 ]]; then
            rm -rf "$PREFIX/var/lib/apt/lists"/* 2>/dev/null || true
            mkdir -p "$PREFIX/var/lib/apt/lists/partial" 2>/dev/null || true
        fi
        
        if timeout 120 apt update -y -o Acquire::Retries=3 \
            -o Acquire::http::Timeout=30 \
            -o Acquire::ftp::Timeout=30 \
            -o Dpkg::Options::="--force-confnew" \
            -o Dpkg::Options::="--force-overwrite" 2>/dev/null; then
            echo -e "${GREEN}✅ Repositories updated successfully${NC}"
            return 0
        fi
        
        if [[ $retry_count -lt $max_retries ]]; then
            echo -e "${YELLOW}⚠️ Update failed, waiting ${backoff_delay}s before retry...${NC}"
            sleep $backoff_delay
            backoff_delay=$((backoff_delay * 2)) # Exponential backoff
            
            # Try changing mirror on repeated failures
            if [[ $retry_count -eq 3 ]] && command -v termux-change-repo >/dev/null 2>&1; then
                echo -e "${YELLOW}🔄 Switching to different mirror...${NC}"
                echo -e "2\n1\n" | termux-change-repo 2>/dev/null || true
            fi
        fi
    done
    
    echo -e "${YELLOW}⚠️ Repository update failed after $max_retries attempts${NC}"
    echo -e "${YELLOW}🔍 Checking repository accessibility...${NC}"
    
    # Test repository connectivity
    if command -v curl >/dev/null 2>&1; then
        if curl -s --connect-timeout 10 "https://packages.termux.dev/" >/dev/null; then
            echo -e "${GREEN}✅ Main repository is accessible${NC}"
        else
            echo -e "${RED}❌ Repository connectivity issues detected${NC}"
        fi
    fi
    
    echo -e "${CYAN}💡 Continuing with cached package data...${NC}"
    return 0
}

upgrade_packages() {
    echo -e "${YELLOW}⬆️ Upgrading existing packages...${NC}"
    DEBIAN_FRONTEND=noninteractive apt upgrade -y \
        -o Dpkg::Options::="--force-confnew" \
        -o Dpkg::Options::="--force-overwrite" \
        -o Dpkg::Options::="--force-confdef" \
        -o APT::Get::Assume-Yes=true 2>/dev/null || echo -e "${YELLOW}⚠️ Some upgrades failed, continuing...${NC}"
}

echo -e "${YELLOW}💡 Ensure mirrors are healthy for speed${NC}"

ESSENTIAL_PACKAGES=(
    curl wget git unzip zip 
    nodejs-lts python python-pip 
    make clang nano vim tree htop 
    openssh jq ca-certificates
    termux-tools pkg
)
OPTIONAL_PACKAGES=(ripgrep fd fzf bat exa zoxide)

is_package_installed() { dpkg -s "$1" >/dev/null 2>&1; }

install_package_with_retry() {
    local package=$1 max_retries=3 retry_count=0
    
    # Check if already installed first
    if is_package_installed "$package"; then
        echo -e "${GREEN}✅ ${package} already installed${NC}"
        return 0
    fi
    
    # Check if package exists in repository
    if ! apt-cache show "$package" >/dev/null 2>&1; then
        echo -e "${RED}❌ Package ${package} not found in repository${NC}"
        return 1
    fi
    
    echo -e "${CYAN}📦 Installing ${package}...${NC}"
    
    while [[ $retry_count -lt $max_retries ]]; do
        retry_count=$((retry_count+1))
        
        # Clear any partial package states
        apt --fix-broken install -y >/dev/null 2>&1 || true
        
        if timeout 300 apt install -y \
                -o Dpkg::Options::="--force-confnew" \
                -o Dpkg::Options::="--force-overwrite" \
                -o Dpkg::Options::="--force-confdef" \
                -o APT::Get::Assume-Yes=true \
                -o Acquire::Retries=2 \
                -o Acquire::http::Timeout=60 \
                "$package" 2>/dev/null; then
            
            # Verify installation was successful
            if is_package_installed "$package"; then
                echo -e "${GREEN}✅ ${package} installed successfully${NC}"
                return 0
            else
                echo -e "${YELLOW}⚠️ ${package} installation reported success but verification failed${NC}"
            fi
        fi
        
        if [[ $retry_count -lt $max_retries ]]; then
            local wait_time=$((retry_count * 3))
            echo -e "${YELLOW}⏳ Retry $retry_count/$max_retries for ${package} in ${wait_time}s...${NC}"
            sleep $wait_time
            
            # Try to fix any dependency issues
            apt --fix-broken install -y >/dev/null 2>&1 || true
        fi
    done
    
    echo -e "${RED}❌ Failed to install ${package} after $max_retries attempts${NC}"
    return 1
}

main() {
    fix_termux_mirrors
    preconfigure_packages
    update_repositories
    upgrade_packages

    echo -e "${YELLOW}📋 Installing ${#ESSENTIAL_PACKAGES[@]} essential packages...${NC}"
    local failed_packages=() successful_packages=()
    for package in "${ESSENTIAL_PACKAGES[@]}"; do
        if install_package_with_retry "$package"; then
            successful_packages+=("$package")
        else
            failed_packages+=("$package")
        fi
    done

    echo -e "\n${YELLOW}� Installing ${#OPTIONAL_PACKAGES[@]} optional packages...${NC}"
    local optional_failed=() optional_successful=()
    for package in "${OPTIONAL_PACKAGES[@]}"; do
        if install_package_with_retry "$package"; then
            optional_successful+=("$package")
        else
            optional_failed+=("$package")
        fi
    done

    echo -e "${YELLOW}⚙️ Configurando Git...${NC}"
    if [[ "${TERMUX_AI_AUTO:-}" == "1" || "${TERMUX_AI_SILENT:-}" == "1" ]]; then
        if ! git config --global user.name >/dev/null 2>&1; then
            git config --global user.name "${TERMUX_AI_GIT_NAME:-Termux Developer}" 2>/dev/null || true
        fi
        if ! git config --global user.email >/dev/null 2>&1; then
            git config --global user.email "${TERMUX_AI_GIT_EMAIL:-dev@termux.local}" 2>/dev/null || true
        fi
    fi

    echo -e "${YELLOW}🔧 Configurando aliases útiles...${NC}"
    local ALIASES_FILE="$HOME/.bash_aliases"
    cat > "$ALIASES_FILE" <<'EOF'
# Aliases de Termux AI
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline'
alias gd='git diff'
if command -v bat >/dev/null 2>&1; then alias cat='bat'; fi
if command -v exa >/dev/null 2>&1; then alias ls='exa --icons'; fi
if command -v fd  >/dev/null 2>&1; then alias find='fd'; fi
if command -v zoxide >/dev/null 2>&1; then alias cd='z'; fi
alias apt='pkg'
alias python='python3'
alias pip='pip3'
EOF
    grep -q "source ~/.bash_aliases" "$HOME/.bashrc" 2>/dev/null || echo "source ~/.bash_aliases" >> "$HOME/.bashrc"

    mkdir -p "$HOME/bin" "$HOME/dev" "$HOME/.config"
    local NPM_GBIN
    NPM_GBIN=$(npm bin -g 2>/dev/null || echo "")
    if [[ -n "$NPM_GBIN" ]] && ! grep -q "$NPM_GBIN" "$HOME/.bashrc" 2>/dev/null; then
        echo "export PATH=\"$NPM_GBIN:\$PATH\"" >> "$HOME/.bashrc"
    fi

    echo -e "\n${GREEN}📊 INSTALLATION SUMMARY${NC}"
    echo -e "${GREEN}Essential: ${#successful_packages[@]} ok / ${#ESSENTIAL_PACKAGES[@]} total${NC}"
    [[ ${#failed_packages[@]} -gt 0 ]] && echo -e "${RED}Failed essential: ${failed_packages[*]}${NC}"
    echo -e "${GREEN}Optional: ${#optional_successful[@]} ok / ${#OPTIONAL_PACKAGES[@]} total${NC}"
    [[ ${#optional_failed[@]} -gt 0 ]] && echo -e "${YELLOW}Skipped optional: ${optional_failed[*]}${NC}"

    local all_ok=true
    for t in git curl node python npm; do
        if ! command -v "$t" >/dev/null 2>&1; then all_ok=false; fi
    done

    if $all_ok; then
        echo -e "${GREEN}🎉 Base packages installation completed successfully!${NC}"
        touch "$MODULE_MARKER" 2>/dev/null || true
        if command -v termux_ai_record_module_state >/dev/null 2>&1; then
            termux_ai_record_module_state "$MODULE_NAME" "$0" "completed" 0 || true
        fi
        exit 0
    else
        echo -e "${YELLOW}⚠️ Some critical tools missing, you can rerun this module.${NC}"
        if command -v termux_ai_record_module_state >/dev/null 2>&1; then
            termux_ai_record_module_state "$MODULE_NAME" "$0" "partial" 1 || true
        fi
        exit 1
    fi
}

main "$@"

