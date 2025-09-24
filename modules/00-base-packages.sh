#!/bin/bash

# ====================================
# MODULE: Base Packages Installation (Restored)
# Robust, idempotent installation of essential tools
# ====================================

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
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
    if command -v termux-change-repo >/dev/null 2>&1; then
        echo -e "${CYAN}🔄 Updating mirrors automatically...${NC}"
        echo "Y" | termux-change-repo || true
    fi
    cat > "$PREFIX/etc/apt/sources.list" <<'EOF'
# Termux main repository

EOF
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
    echo -e "${YELLOW}🔄 Updating repositories with retry logic...${NC}"
    local max_retries=3 retry_count=0
    while [[ $retry_count -lt $max_retries ]]; do
        if DEBIAN_FRONTEND=noninteractive apt update -y -o Dpkg::Options::="--force-confnew" -o Dpkg::Options::="--force-overwrite" 2>/dev/null; then
            echo -e "${GREEN}✅ Repositories updated successfully${NC}"; return 0
        fi
        retry_count=$((retry_count+1))
        [[ $retry_count -lt $max_retries ]] && echo -e "${YELLOW}⚠️ Update failed, retrying ($retry_count/$max_retries)...${NC}" && sleep 3
    done
    echo -e "${YELLOW}⚠️ Using cached package metadata${NC}"; return 0
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

ESSENTIAL_PACKAGES=(curl wget git unzip zip nodejs-lts python python-pip make clang nano vim tree htop openssh jq ca-certificates)
OPTIONAL_PACKAGES=(ripgrep fd fzf bat exa zoxide)

is_package_installed() { dpkg -s "$1" >/dev/null 2>&1; }

install_package_with_retry() {
    local package=$1 max_retries=3 retry_count=0
    if is_package_installed "$package"; then
        echo -e "${GREEN}✅ ${package} already installed${NC}"; return 0; fi
    while [[ $retry_count -lt $max_retries ]]; do
        if DEBIAN_FRONTEND=noninteractive apt install -y \
                -o Dpkg::Options::="--force-confnew" \
                -o Dpkg::Options::="--force-overwrite" \
                -o Dpkg::Options::="--force-confdef" \
                "$package" 2>/dev/null; then
            echo -e "${GREEN}✅ ${package} installed${NC}"; return 0; fi
        retry_count=$((retry_count+1))
        [[ $retry_count -lt $max_retries ]] && echo -e "${YELLOW}Retry ${retry_count}/${max_retries} for ${package}...${NC}" && sleep 2
    done
    echo -e "${RED}❌ ${package} failed${NC}"; return 1
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

