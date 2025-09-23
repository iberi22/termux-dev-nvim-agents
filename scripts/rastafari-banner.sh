#!/data/data/com.termux/files/usr/bin/bash

# ====================================
# Rastafari Welcome Banner
# Animated banner with color transitions
# Replaces default Termux welcome message
# ====================================

# Color definitions - Rastafari colors
RED='\033[38;2;255;107;107m'      # Rasta Red #FF6B6B
YELLOW='\033[38;2;255;217;61m'    # Rasta Yellow #FFD93D
GREEN='\033[38;2;107;207;127m'    # Rasta Green #6BCF7F
ORANGE='\033[38;2;255;140;66m'    # Orange accent
GOLD='\033[38;2;255;215;0m'       # Gold accent
DARK_GREEN='\033[38;2;85;160;101m'  # Dark green
WHITE='\033[38;2;245;245;245m'    # White text
GRAY='\033[38;2;160;160;160m'     # Gray text
RESET='\033[0m'

# Terminal formatting
BOLD='\033[1m'
DIM='\033[2m'
ITALIC='\033[3m'

# Animation function for color transitions
animate_text() {
    local text="$1"
    local colors=("$RED" "$YELLOW" "$GREEN")
    local delay=0.1

    for color in "${colors[@]}"; do
        printf "\r${color}${BOLD}%s${RESET}" "$text"
        sleep $delay
    done
    printf "\n"
}

# Function to print with color gradient effect
gradient_print() {
    local text="$1"
    local len=${#text}
    local i=0

    while [ $i -lt $len ]; do
        case $((i % 3)) in
            0) printf "${RED}" ;;
            1) printf "${YELLOW}" ;;
            2) printf "${GREEN}" ;;
        esac
        printf "${text:$i:1}"
        ((i++))
    done
    printf "${RESET}\n"
}

# Clear screen and show animated banner
clear

# Main banner with rastafari colors
printf "\n"
printf "${RED}${BOLD}  ██▀███   ▄▄▄        ██████ ▄▄▄█████▓ ▄▄▄        █████▒▄▄▄       ██▀███   ██▓${RESET}\n"
printf "${YELLOW}${BOLD} ▓██ ▒ ██▒▒████▄    ▒██    ▒ ▓  ██▒ ▓▒▒████▄    ▓██   ▒▒████▄    ▓██ ▒ ██▒▓██▒${RESET}\n"
printf "${GREEN}${BOLD} ▓██ ░▄█ ▒▒██  ▀█▄  ░ ▓██▄   ▒ ▓██░ ▒░▒██  ▀█▄  ▒████ ░▒██  ▀█▄  ▓██ ░▄█ ▒▒██▒${RESET}\n"
printf "${RED}${BOLD} ▒██▀▀█▄  ░██▄▄▄▄██   ▒   ██▒░ ▓██▓ ░ ░██▄▄▄▄██ ░▓█▒  ░░██▄▄▄▄██ ▒██▀▀█▄  ░██░${RESET}\n"
printf "${YELLOW}${BOLD} ░██▓ ▒██▒ ▓█   ▓██▒▒██████▒▒  ▒██▒ ░  ▓█   ▓██▒░▒█░    ▓█   ▓██▒░██▓ ▒██▒░██░${RESET}\n"
printf "${GREEN}${BOLD} ░ ▒▓ ░▒▓░ ▒▒   ▓▒█░▒ ▒▓▒ ▒ ░  ▒ ░░    ▒▒   ▓▒█░ ▒ ░    ▒▒   ▓▒█░░ ▒▓ ░▒▓░░▓  ${RESET}\n"
printf "${RED}${BOLD}   ░▒ ░ ▒░  ▒   ▒▒ ░░ ░▒  ░ ░    ░      ▒   ▒▒ ░ ░       ▒   ▒▒ ░  ░▒ ░ ▒░ ▒ ░${RESET}\n"
printf "${YELLOW}${BOLD}   ░░   ░   ░   ▒   ░  ░  ░    ░        ░   ▒    ░ ░     ░   ▒     ░░   ░  ▒ ░${RESET}\n"
printf "${GREEN}${BOLD}    ░           ░  ░      ░                 ░  ░           ░  ░   ░      ░  ${RESET}\n"

printf "\n"

# Animated subtitle
printf "${GOLD}${BOLD}"
gradient_print "                    🌿 T E R M U X   ×   J A H   C O D I N G 🌿"
printf "${RESET}\n"

# Quote rotation
quotes=(
    "Get up, stand up, code for your rights! 🎵"
    "One love, one heart, one terminal! ❤️"
    "Don't worry about a thing, every little bug gonna be alright! 🐛"
    "Emancipate yourself from mental slavery! Learn to code! 🧠"
    "In this great future, you can't forget your Git! 📱"
    "Ubuntu philosophy: I code, therefore we are! 🤝"
)

# Get random quote
quote_index=$((RANDOM % ${#quotes[@]}))
selected_quote="${quotes[$quote_index]}"

printf "\n${WHITE}${ITALIC}                    \"${selected_quote}\"${RESET}\n"
printf "${GRAY}                                   - Jah Terminal Wisdom${RESET}\n\n"

# System info with rastafari styling
printf "${RED}${BOLD}🔥 FIRE SYSTEM STATUS 🔥${RESET}\n"
printf "${YELLOW}📱 Device: ${WHITE}$(getprop ro.product.model 2>/dev/null || echo 'Termux Container')${RESET}\n"
printf "${GREEN}🌿 OS: ${WHITE}Android $(getprop ro.build.version.release 2>/dev/null || echo 'N/A')${RESET}\n"
printf "${RED}🦁 Shell: ${WHITE}${SHELL##*/} ${BASH_VERSION}${RESET}\n"
printf "${YELLOW}⚡ Uptime: ${WHITE}$(uptime -p 2>/dev/null || echo 'N/A')${RESET}\n"

# Check if this is first time setup
if [ ! -f "$HOME/.rastafari_setup_complete" ]; then
    printf "\n${GOLD}${BOLD}🌟 FIRST TIME SETUP DETECTED! 🌟${RESET}\n"
    printf "${WHITE}Run ${GREEN}${BOLD}setup.sh${WHITE} to configure your Rastafari development environment!${RESET}\n"
fi

# Memory and storage info
if command -v free >/dev/null 2>&1; then
    mem_info=$(free -h 2>/dev/null | grep '^Mem:' | awk '{print $3"/"$2}')
    printf "${GREEN}🧠 Memory: ${WHITE}${mem_info}${RESET}\n"
fi

if command -v df >/dev/null 2>&1; then
    storage_info=$(df -h /data/data/com.termux/files/home 2>/dev/null | tail -1 | awk '{print $3"/"$2" ("$5" used)"}')
    printf "${RED}💾 Storage: ${WHITE}${storage_info}${RESET}\n"
fi

printf "\n"

# Package count
pkg_count=$(dpkg -l 2>/dev/null | grep -c '^ii' || echo "N/A")
printf "${YELLOW}📦 Packages: ${WHITE}${pkg_count} installed${RESET}\n"

# Check for key development tools
tools_status=""
[ -x "$(command -v git)" ] && tools_status+="${GREEN}Git${WHITE}, "
[ -x "$(command -v python)" ] && tools_status+="${GREEN}Python${WHITE}, "
[ -x "$(command -v node)" ] && tools_status+="${GREEN}Node.js${WHITE}, "
[ -x "$(command -v nvim)" ] && tools_status+="${GREEN}Neovim${WHITE}, "
[ -x "$(command -v zsh)" ] && tools_status+="${GREEN}Zsh${WHITE}, "

if [ -n "$tools_status" ]; then
    tools_status=${tools_status%, }  # Remove trailing comma
    printf "${RED}🛠️  Dev Tools: ${WHITE}${tools_status}${RESET}\n"
fi

printf "\n"

# Rastafari development tips
printf "${GOLD}${BOLD}🎵 JAH DEVELOPMENT VIBES 🎵${RESET}\n"
printf "${WHITE}${DIM}┌─────────────────────────────────────────────────────────────┐${RESET}\n"
printf "${WHITE}${DIM}│${RESET} ${RED}🔴${RESET} ${WHITE}Red for passion in coding${RESET}                            ${WHITE}${DIM}│${RESET}\n"
printf "${WHITE}${DIM}│${RESET} ${YELLOW}🟡${RESET} ${WHITE}Yellow for wisdom in debugging${RESET}                        ${WHITE}${DIM}│${RESET}\n"
printf "${WHITE}${DIM}│${RESET} ${GREEN}🟢${RESET} ${WHITE}Green for growth in learning${RESET}                          ${WHITE}${DIM}│${RESET}\n"
printf "${WHITE}${DIM}└─────────────────────────────────────────────────────────────┘${RESET}\n"

printf "\n"

# Quick commands showcase
printf "${GREEN}${BOLD}🚀 QUICK RASTAFARI COMMANDS${RESET}\n"
printf "${WHITE}┌──────────────────┬─────────────────────────────────────────┐${RESET}\n"
printf "${WHITE}│${RESET} ${RED}${BOLD} rasta-setup${RESET}      ${WHITE}│${RESET} ${GRAY}Run full Rastafari environment setup${RESET}   ${WHITE}│${RESET}\n"
printf "${WHITE}│${RESET} ${YELLOW}${BOLD} rasta-neovim${RESET}     ${WHITE}│${RESET} ${GRAY}Start Neovim with Rastafari theme${RESET}        ${WHITE}│${RESET}\n"
printf "${WHITE}│${RESET} ${GREEN}${BOLD} rasta-tips${RESET}       ${WHITE}│${RESET} ${GRAY}Show random development tips${RESET}             ${WHITE}│${RESET}\n"
printf "${WHITE}│${RESET} ${RED}${BOLD} rasta-music${RESET}      ${WHITE}│${RESET} ${GRAY}Play reggae coding playlist${RESET}              ${WHITE}│${RESET}\n"
printf "${WHITE}└──────────────────┴─────────────────────────────────────────┘${RESET}\n"

printf "\n"

# Footer with timestamp
current_time=$(date "+%Y-%m-%d %H:%M:%S")
printf "${GRAY}${DIM}Session started: ${current_time} | One Love Terminal Session 💚💛❤️${RESET}\n"

printf "\n${WHITE}${BOLD}Welcome to the ${RED}R${YELLOW}A${GREEN}S${RED}T${YELLOW}A${GREEN}F${RED}A${YELLOW}R${GREEN}I${WHITE} development environment!${RESET}\n"
printf "${GRAY}Type ${WHITE}${BOLD}rasta-help${RESET}${GRAY} for available commands or ${WHITE}${BOLD}exit${RESET}${GRAY} to leave Jah terminal.${RESET}\n\n"