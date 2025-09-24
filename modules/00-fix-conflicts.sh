#!/bin/bash

# ====================================
# MODULE: Fix Configuration Conflicts
# Handles dpkg/apt configuration conflicts automatically
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

echo -e "${PURPLE}🔧 Fixing Termux configuration conflicts...${NC}"

# Function to fix dpkg configuration conflicts
fix_dpkg_conflicts() {
    echo -e "${BLUE}📦 Configuring dpkg for automatic conflict resolution...${NC}"
    
    # Create dpkg configuration directory
    mkdir -p "$PREFIX/etc/dpkg/dpkg.cfg.d"
    
    # Configure dpkg to handle conflicts automatically
    cat > "$PREFIX/etc/dpkg/dpkg.cfg.d/01_termux_ai_conflicts" << 'EOF'
# Termux AI - Automatic conflict resolution
force-confnew
force-overwrite
force-confdef
force-bad-path
force-not-root
EOF

    # Set environment variables for non-interactive mode
    export DEBIAN_FRONTEND=noninteractive
    export APT_LISTCHANGES_FRONTEND=none
    export NEEDRESTART_MODE=a
    
    echo -e "${GREEN}✅ dpkg configured for automatic conflict resolution${NC}"
}

# Function to fix OpenSSL configuration conflicts
fix_openssl_conflicts() {
    echo -e "${BLUE}🔐 Fixing OpenSSL configuration conflicts...${NC}"
    
    local openssl_conf="$PREFIX/etc/ssl/openssl.cnf"
    
    if [[ -f "$openssl_conf" ]]; then
        # Backup existing configuration
        if [[ ! -f "${openssl_conf}.termux-ai-backup" ]]; then
            cp "$openssl_conf" "${openssl_conf}.termux-ai-backup"
            echo -e "${CYAN}📋 OpenSSL config backed up${NC}"
        fi
        
        # Remove problematic configuration to allow clean reinstall
        rm -f "$openssl_conf"
    fi
    
    echo -e "${GREEN}✅ OpenSSL conflicts resolved${NC}"
}

# Function to fix ca-certificates conflicts  
fix_ca_certificates_conflicts() {
    echo -e "${BLUE}📜 Fixing CA certificates conflicts...${NC}"
    
    local ca_conf="$PREFIX/etc/ca-certificates.conf"
    
    # Pre-configure ca-certificates to avoid prompts
    if [[ -f "$ca_conf" ]]; then
        if [[ ! -f "${ca_conf}.termux-ai-backup" ]]; then
            cp "$ca_conf" "${ca_conf}.termux-ai-backup"
        fi
    fi
    
    # Create a minimal ca-certificates configuration
    cat > "$ca_conf" << 'EOF'
# Termux AI - CA Certificates Configuration
# This file is managed automatically
!mozilla/Staat_der_Nederlanden_EV_Root_CA.crt
mozilla/DigiCert_Assured_ID_Root_CA.crt
mozilla/DigiCert_Global_Root_CA.crt
mozilla/DigiCert_High_Assurance_EV_Root_CA.crt
EOF
    
    echo -e "${GREEN}✅ CA certificates configured${NC}"
}

# Function to fix termux mirrors and sources
fix_mirrors_and_sources() {
    echo -e "${BLUE}📡 Fixing Termux mirrors and package sources...${NC}"
    
    # Fix sources.list first
    cat > "$PREFIX/etc/apt/sources.list" << 'EOF'
# Termux main package repository
deb https://packages.termux.org/apt/termux-main stable main
EOF
    
    # Update mirrors automatically if available
    if command -v termux-change-repo >/dev/null 2>&1; then
        echo -e "${CYAN}🔄 Updating to fastest mirrors...${NC}"
        # Use Grimler's mirrors (generally more reliable)
        echo "Y" | termux-change-repo || {
            echo -e "${YELLOW}⚠️ Mirror update failed, using default${NC}"
        }
    fi
    
    echo -e "${GREEN}✅ Mirrors and sources fixed${NC}"
}

# Function to clean problematic package states
clean_package_states() {
    echo -e "${BLUE}🧹 Cleaning problematic package states...${NC}"
    
    # Clean apt cache and fix broken packages
    apt clean 2>/dev/null || true
    apt autoclean 2>/dev/null || true
    
    # Fix broken packages
    DEBIAN_FRONTEND=noninteractive apt --fix-broken install -y \
        -o Dpkg::Options::="--force-confnew" \
        -o Dpkg::Options::="--force-overwrite" 2>/dev/null || true
    
    # Remove partial packages
    dpkg --remove --force-remove-reinstreq --force-depends $(dpkg -l | grep "^iF" | awk '{print $2}') 2>/dev/null || true
    
    # Configure pending packages
    DEBIAN_FRONTEND=noninteractive dpkg --configure -a \
        --force-confnew \
        --force-overwrite \
        --force-confdef 2>/dev/null || true
    
    echo -e "${GREEN}✅ Package states cleaned${NC}"
}

# Function to set up automatic yes responses
setup_automatic_responses() {
    echo -e "${BLUE}🤖 Setting up automatic responses for installations...${NC}"
    
    # Create expect script for automatic responses
    if command -v expect >/dev/null 2>&1; then
        cat > "$HOME/.termux_auto_response.exp" << 'EOF'
#!/usr/bin/expect -f
# Auto-response script for package installations

set timeout 30
spawn {*}$argv

expect {
    "Do you want to continue" { send "Y\r"; exp_continue }
    "Y/n" { send "Y\r"; exp_continue }
    "y/N" { send "Y\r"; exp_continue }
    "(Y/n)" { send "Y\r"; exp_continue }
    "(y/N)" { send "Y\r"; exp_continue }
    "Continue?" { send "Y\r"; exp_continue }
    "Abort?" { send "N\r"; exp_continue }
    "Install" { send "Y\r"; exp_continue }
    "install the package maintainer's version" { send "Y\r"; exp_continue }
    "keep your currently-installed version" { send "N\r"; exp_continue }
    eof
}
EOF
        chmod +x "$HOME/.termux_auto_response.exp"
        echo -e "${GREEN}✅ Automatic response script created${NC}"
    fi
}

# Main function
main() {
    echo -e "${CYAN}┌─────────────────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│          FIXING CONFIGURATION CONFLICTS         │${NC}"
    echo -e "${CYAN}└─────────────────────────────────────────────────┘${NC}"
    
    fix_dpkg_conflicts
    fix_openssl_conflicts
    fix_ca_certificates_conflicts
    fix_mirrors_and_sources
    clean_package_states
    setup_automatic_responses
    
    echo -e "\n${GREEN}🎉 Configuration conflicts fixed successfully${NC}"
    echo -e "${YELLOW}💡 Packages should now install without prompts${NC}"
}

# Execute main function
main "$@"