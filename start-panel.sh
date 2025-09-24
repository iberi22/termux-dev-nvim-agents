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
    local auto_mode="${TERMUX_AI_AUTO:-}"
    local silent_mode="${TERMUX_AI_SILENT:-}"

    if [[ "$silent_mode" == "1" ]]; then
        echo -e "${BLUE}📦 Installing web panel dependencies silently...${NC}"
    else
        echo -e "${BLUE}📦 Installing dependencies...${NC}"
    fi

    # Backend dependencies
    if [[ -f "$BACKEND_DIR/requirements.txt" ]]; then
        if [[ "$silent_mode" != "1" ]]; then
            echo -e "${CYAN}Installing Python dependencies...${NC}"
        fi
        cd "$BACKEND_DIR"

        if [[ "$silent_mode" == "1" ]]; then
            pip3 install -r requirements.txt >/dev/null 2>&1
        else
            pip3 install -r requirements.txt
        fi

        if [[ "$silent_mode" != "1" ]]; then
            echo -e "${GREEN}✅ Backend dependencies installed${NC}"
        fi
    fi

    # Web UI dependencies
    if [[ -f "$WEB_UI_DIR/package.json" ]]; then
        if [[ "$silent_mode" != "1" ]]; then
            echo -e "${CYAN}Installing Node.js dependencies...${NC}"
        fi
        cd "$WEB_UI_DIR"

        if [[ "$silent_mode" == "1" ]]; then
            npm install >/dev/null 2>&1
        else
            npm install
        fi

        if [[ "$silent_mode" != "1" ]]; then
            echo -e "${GREEN}✅ Frontend dependencies installed${NC}"
        fi
    fi

    cd "$SCRIPT_DIR"

    if [[ "$silent_mode" == "1" ]]; then
        echo -e "${GREEN}✅ Web panel dependencies installed${NC}"
    fi
}

start_dev_servers() {
    local silent_mode="${TERMUX_AI_SILENT:-}"

    if [[ "$silent_mode" == "1" ]]; then
        echo -e "${BLUE}🚀 Starting web panel in background...${NC}"
    else
        echo -e "${BLUE}🚀 Starting development servers...${NC}"
    fi

    # Build frontend for production (served by backend)
    if [[ "$silent_mode" != "1" ]]; then
        echo -e "${CYAN}Building frontend...${NC}"
    fi
    cd "$WEB_UI_DIR"

    if [[ "$silent_mode" == "1" ]]; then
        npm run build >/dev/null 2>&1
    else
        npm run build
    fi

    # Start backend (serves frontend static files)
    if [[ "$silent_mode" != "1" ]]; then
        echo -e "${CYAN}Starting backend server...${NC}"
    fi
    cd "$BACKEND_DIR"

    if [[ "$silent_mode" == "1" ]]; then
        # Start in background for silent mode
        nohup python3 main.py >/dev/null 2>&1 &
        BACKEND_PID=$!
        echo -e "${GREEN}✅ Web panel started in background (PID: $BACKEND_PID)${NC}"
        echo -e "${CYAN}🌐 Access at: http://localhost:8000${NC}"
        return 0
    else
        # Interactive mode
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
    fi
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