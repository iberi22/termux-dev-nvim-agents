#!/bin/bash

# ====================================
# START PANEL - Web Panel Launcher
# Inicia el backend y frontend del panel de control
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

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKEND_DIR="$SCRIPT_DIR/backend"
WEB_UI_DIR="$SCRIPT_DIR/web-ui"

show_banner() {
    echo -e "${PURPLE}"
    echo "=============================================="
    echo "         TERMUX AI WEB PANEL"
    echo "    Starting Backend & Frontend Servers"
    echo "=============================================="
    echo -e "${NC}\n"
}

install_dependencies() {
    echo -e "${BLUE}📦 Installing dependencies...${NC}"

    # Backend dependencies
    if [[ -f "$BACKEND_DIR/requirements.txt" ]]; then
        echo -e "${CYAN}Installing Python dependencies...${NC}"
        cd "$BACKEND_DIR"
        pip3 install -r requirements.txt
        echo -e "${GREEN}✅ Backend dependencies installed${NC}"
    fi

    # Web UI dependencies
    if [[ -f "$WEB_UI_DIR/package.json" ]]; then
        echo -e "${CYAN}Installing Node.js dependencies...${NC}"
        cd "$WEB_UI_DIR"
        npm install
        echo -e "${GREEN}✅ Frontend dependencies installed${NC}"
    fi

    cd "$SCRIPT_DIR"
}

start_dev_servers() {
    echo -e "${BLUE}🚀 Starting development servers...${NC}"

    # Build frontend for production (served by backend)
    echo -e "${CYAN}Building frontend...${NC}"
    cd "$WEB_UI_DIR"
    npm run build

    # Start backend (serves frontend static files)
    echo -e "${CYAN}Starting backend server...${NC}"
    cd "$BACKEND_DIR"
    python3 main.py &
    BACKEND_PID=$!

    echo -e "${GREEN}✅ Backend started (PID: $BACKEND_PID)${NC}"
    echo -e "${CYAN}🌐 Backend: http://localhost:8000${NC}"
    echo -e "${CYAN}🌐 Frontend: http://localhost:8000 (served by backend)${NC}"

    # Wait for backend to start
    sleep 3

    echo -e "${YELLOW}💡 Press Ctrl+C to stop servers${NC}"

    # Wait for user interrupt
    trap 'echo -e "\n${YELLOW}🛑 Stopping servers...${NC}"; kill $BACKEND_PID 2>/dev/null; exit 0' INT TERM

    # Keep running
    wait $BACKEND_PID
}

main() {
    case "${1:-}" in
        install)
            show_banner
            install_dependencies
            ;;
        dev)
            show_banner
            start_dev_servers
            ;;
        *)
            echo -e "${RED}Usage: $0 {install|dev}${NC}"
            echo -e "${CYAN}  install  - Install dependencies${NC}"
            echo -e "${CYAN}  dev      - Start development servers${NC}"
            exit 1
            ;;
    esac
}

main "$@"