#!/bin/bash

# ====================================
# TERMUX AI PANEL LAUNCHER
# Start the complete web-based control panel
# ====================================

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKEND_DIR="$SCRIPT_DIR/backend"
FRONTEND_DIR="$SCRIPT_DIR/web-ui"

# Function to check dependencies
check_dependencies() {
    echo -e "${BLUE}🔍 Checking dependencies...${NC}"

    # Check Node.js
    if ! command -v node >/dev/null 2>&1; then
        echo -e "${RED}❌ Node.js not found. Please install Node.js first.${NC}"
        exit 1
    fi

    # Check Python
    if ! command -v python3 >/dev/null 2>&1; then
        echo -e "${RED}❌ Python3 not found. Please install Python3 first.${NC}"
        exit 1
    fi

    echo -e "${GREEN}✅ Dependencies verified${NC}"
}

# Function to install backend dependencies
install_backend_deps() {
    echo -e "${BLUE}🐍 Installing backend dependencies...${NC}"

    cd "$BACKEND_DIR"

    # Create virtual environment if it doesn't exist
    if [[ ! -d "venv" ]]; then
        python3 -m venv venv
    fi

    # Activate virtual environment
    source venv/bin/activate

    # Install dependencies
    pip install -r requirements.txt

    echo -e "${GREEN}✅ Backend dependencies installed${NC}"
}

# Function to install frontend dependencies
install_frontend_deps() {
    echo -e "${BLUE}📦 Installing frontend dependencies...${NC}"

    cd "$FRONTEND_DIR"

    # Install npm dependencies
    npm install

    echo -e "${GREEN}✅ Frontend dependencies installed${NC}"
}

# Function to build frontend
build_frontend() {
    echo -e "${BLUE}🏗️ Building frontend...${NC}"

    cd "$FRONTEND_DIR"
    npm run build

    echo -e "${GREEN}✅ Frontend built successfully${NC}"
}

# Function to start backend server
start_backend() {
    echo -e "${BLUE}🚀 Starting backend server...${NC}"

    cd "$BACKEND_DIR"
    source venv/bin/activate

    # Start FastAPI server in background
    python main.py &
    BACKEND_PID=$!

    echo -e "${GREEN}✅ Backend server started (PID: $BACKEND_PID)${NC}"
    echo "$BACKEND_PID" > "$SCRIPT_DIR/.backend.pid"
}

# Function to start frontend dev server
start_frontend_dev() {
    echo -e "${BLUE}🌐 Starting frontend development server...${NC}"

    cd "$FRONTEND_DIR"

    # Start Vite dev server in background
    npm run dev &
    FRONTEND_PID=$!

    echo -e "${GREEN}✅ Frontend dev server started (PID: $FRONTEND_PID)${NC}"
    echo "$FRONTEND_PID" > "$SCRIPT_DIR/.frontend.pid"
}

# Function to stop servers
stop_servers() {
    echo -e "${YELLOW}🛑 Stopping servers...${NC}"

    # Stop backend
    if [[ -f "$SCRIPT_DIR/.backend.pid" ]]; then
        BACKEND_PID=$(cat "$SCRIPT_DIR/.backend.pid")
        if kill -0 "$BACKEND_PID" 2>/dev/null; then
            kill "$BACKEND_PID"
            echo -e "${GREEN}✅ Backend server stopped${NC}"
        fi
        rm -f "$SCRIPT_DIR/.backend.pid"
    fi

    # Stop frontend
    if [[ -f "$SCRIPT_DIR/.frontend.pid" ]]; then
        FRONTEND_PID=$(cat "$SCRIPT_DIR/.frontend.pid")
        if kill -0 "$FRONTEND_PID" 2>/dev/null; then
            kill "$FRONTEND_PID"
            echo -e "${GREEN}✅ Frontend dev server stopped${NC}"
        fi
        rm -f "$SCRIPT_DIR/.frontend.pid"
    fi
}

# Function to show usage
show_usage() {
    echo -e "${CYAN}Usage: $0 [command]${NC}"
    echo ""
    echo -e "${WHITE}Commands:${NC}"
    echo -e "  ${YELLOW}install${NC}    Install all dependencies"
    echo -e "  ${YELLOW}dev${NC}        Start development servers"
    echo -e "  ${YELLOW}build${NC}      Build frontend for production"
    echo -e "  ${YELLOW}start${NC}      Start production server"
    echo -e "  ${YELLOW}stop${NC}       Stop all servers"
    echo -e "  ${YELLOW}status${NC}     Show server status"
    echo ""
}

# Function to show server status
show_status() {
    echo -e "${CYAN}📊 Server Status${NC}"
    echo -e "${CYAN}=================${NC}"

    # Backend status
    if [[ -f "$SCRIPT_DIR/.backend.pid" ]]; then
        BACKEND_PID=$(cat "$SCRIPT_DIR/.backend.pid")
        if kill -0 "$BACKEND_PID" 2>/dev/null; then
            echo -e "${GREEN}✅ Backend: Running (PID: $BACKEND_PID)${NC}"
        else
            echo -e "${RED}❌ Backend: Not running${NC}"
            rm -f "$SCRIPT_DIR/.backend.pid"
        fi
    else
        echo -e "${RED}❌ Backend: Not running${NC}"
    fi

    # Frontend status
    if [[ -f "$SCRIPT_DIR/.frontend.pid" ]]; then
        FRONTEND_PID=$(cat "$SCRIPT_DIR/.frontend.pid")
        if kill -0 "$FRONTEND_PID" 2>/dev/null; then
            echo -e "${GREEN}✅ Frontend: Running (PID: $FRONTEND_PID)${NC}"
        else
            echo -e "${RED}❌ Frontend: Not running${NC}"
            rm -f "$SCRIPT_DIR/.frontend.pid"
        fi
    else
        echo -e "${RED}❌ Frontend: Not running${NC}"
    fi

    echo ""
    echo -e "${BLUE}🌐 Access URLs:${NC}"
    echo -e "  Frontend (dev): ${CYAN}http://localhost:3000${NC}"
    echo -e "  Backend API:    ${CYAN}http://localhost:8000${NC}"
    echo -e "  API Docs:       ${CYAN}http://localhost:8000/docs${NC}"
}

# Signal handler for cleanup
cleanup() {
    echo -e "\n${YELLOW}🧹 Cleaning up...${NC}"
    stop_servers
    exit 0
}

trap cleanup INT TERM

# Main execution
main() {
    case "${1:-}" in
        "install")
            check_dependencies
            install_backend_deps
            install_frontend_deps
            echo -e "${GREEN}🎉 All dependencies installed!${NC}"
            ;;
        "dev")
            check_dependencies
            echo -e "${BLUE}🚀 Starting development environment...${NC}"
            start_backend
            sleep 3  # Give backend time to start
            start_frontend_dev

            echo -e "${GREEN}🎉 Development servers started!${NC}"
            echo -e "${CYAN}Frontend: http://localhost:3000${NC}"
            echo -e "${CYAN}Backend:  http://localhost:8000${NC}"
            echo -e "${YELLOW}Press Ctrl+C to stop all servers${NC}"

            # Wait for user interruption
            while true; do
                sleep 1
            done
            ;;
        "build")
            check_dependencies
            build_frontend
            echo -e "${GREEN}🎉 Frontend built for production!${NC}"
            ;;
        "start")
            check_dependencies
            build_frontend
            start_backend
            echo -e "${GREEN}🎉 Production server started!${NC}"
            echo -e "${CYAN}Access: http://localhost:8000${NC}"
            ;;
        "stop")
            stop_servers
            ;;
        "status")
            show_status
            ;;
        *)
            show_usage
            exit 1
            ;;
    esac
}

main "$@"