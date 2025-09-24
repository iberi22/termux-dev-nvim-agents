#!/bin/bash

# ====================================
# MODULE: Network and Timeout Fixes
# Fixes network issues, timeouts, and connection problems
# ====================================

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${BLUE}🌐 Fixing network and timeout issues...${NC}"

# Function to configure network timeouts
configure_network_timeouts() {
    echo -e "${CYAN}⏱️ Configuring network timeouts...${NC}"
    
    # Configure apt timeouts
    mkdir -p "$PREFIX/etc/apt/apt.conf.d"
    cat > "$PREFIX/etc/apt/apt.conf.d/99termux-ai-timeouts" << 'EOF'
# Termux AI - Network timeout configuration
Acquire::http::Timeout "30";
Acquire::https::Timeout "30";
Acquire::ftp::Timeout "30";
Acquire::Retries "3";
APT::Get::Assume-Yes "true";
APT::Install-Recommends "false";
APT::Install-Suggests "false";
EOF

    # Configure wget timeouts
    cat > "$HOME/.wgetrc" << 'EOF'
# Termux AI - wget configuration
timeout = 30
tries = 3
retry_connrefused = on
trust_server_names = on
EOF

    # Configure curl timeouts
    cat > "$HOME/.curlrc" << 'EOF'
# Termux AI - curl configuration
connect-timeout = 30
max-time = 60
retry = 3
retry-delay = 1
retry-max-time = 180
EOF

    echo -e "${GREEN}✅ Network timeouts configured${NC}"
}

# Function to fix DNS resolution
fix_dns_resolution() {
    echo -e "${CYAN}🔍 Fixing DNS resolution...${NC}"
    
    # Configure reliable DNS servers
    cat > "$PREFIX/etc/resolv.conf" << 'EOF'
# Termux AI - DNS configuration
nameserver 8.8.8.8
nameserver 8.8.4.4
nameserver 1.1.1.1
nameserver 1.0.0.1
nameserver 208.67.222.222
nameserver 208.67.220.220
EOF

    echo -e "${GREEN}✅ DNS resolution fixed${NC}"
}

# Function to test network connectivity
test_network_connectivity() {
    echo -e "${CYAN}🔗 Testing network connectivity...${NC}"
    
    local test_sites=("google.com" "github.com" "packages.termux.org")
    local successful_tests=0
    
    for site in "${test_sites[@]}"; do
        if ping -c 1 -W 5 "$site" >/dev/null 2>&1; then
            echo -e "${GREEN}✅ $site: OK${NC}"
            successful_tests=$((successful_tests + 1))
        else
            echo -e "${YELLOW}⚠️ $site: Failed${NC}"
        fi
    done
    
    if [[ $successful_tests -gt 0 ]]; then
        echo -e "${GREEN}✅ Network connectivity: OK ($successful_tests/3 sites reachable)${NC}"
        return 0
    else
        echo -e "${RED}❌ Network connectivity: FAILED${NC}"
        return 1
    fi
}

# Function to configure package manager retries
configure_package_manager_retries() {
    echo -e "${CYAN}🔄 Configuring package manager retry logic...${NC}"
    
    # Create retry wrapper for apt
    cat > "$PREFIX/bin/apt-retry" << 'EOF'
#!/bin/bash
# APT retry wrapper

max_retries=3
retry_delay=5
command="$@"

for ((i=1; i<=max_retries; i++)); do
    echo "Attempt $i/$max_retries: $command"
    if timeout 300 $command; then
        exit 0
    fi
    
    if [[ $i -lt $max_retries ]]; then
        echo "Command failed, retrying in ${retry_delay}s..."
        sleep $retry_delay
        retry_delay=$((retry_delay * 2))
    fi
done

echo "Command failed after $max_retries attempts"
exit 1
EOF
    
    chmod +x "$PREFIX/bin/apt-retry"
    echo -e "${GREEN}✅ Package manager retries configured${NC}"
}

# Function to fix certificate issues
fix_certificate_issues() {
    echo -e "${CYAN}🔐 Fixing certificate issues...${NC}"
    
    # Set certificate environment variables
    export SSL_CERT_FILE="$PREFIX/etc/tls/cert.pem"
    export SSL_CERT_DIR="$PREFIX/etc/tls/certs"
    export REQUESTS_CA_BUNDLE="$SSL_CERT_FILE"
    export CURL_CA_BUNDLE="$SSL_CERT_FILE"
    
    # Add to bashrc for persistence
    cat >> "$HOME/.bashrc" << 'EOF'

# Termux AI - Certificate configuration
export SSL_CERT_FILE="$PREFIX/etc/tls/cert.pem"
export SSL_CERT_DIR="$PREFIX/etc/tls/certs" 
export REQUESTS_CA_BUNDLE="$SSL_CERT_FILE"
export CURL_CA_BUNDLE="$SSL_CERT_FILE"
EOF

    echo -e "${GREEN}✅ Certificate issues fixed${NC}"
}

# Main function
main() {
    echo -e "${BLUE}🔧 Applying network and timeout fixes...${NC}"
    
    configure_network_timeouts
    fix_dns_resolution
    configure_package_manager_retries
    fix_certificate_issues
    
    if test_network_connectivity; then
        echo -e "\n${GREEN}🎉 Network fixes applied successfully${NC}"
        echo -e "${CYAN}💡 Network connectivity verified${NC}"
    else
        echo -e "\n${YELLOW}⚠️ Network fixes applied but connectivity issues remain${NC}"
        echo -e "${CYAN}💡 Please check your internet connection${NC}"
    fi
}

# Execute main function
main "$@"