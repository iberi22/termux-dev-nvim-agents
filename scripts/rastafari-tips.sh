#!/data/data/com.termux/files/usr/bin/bash

# ====================================
# Rastafari Tips System - Jah Wisdom for Developers
# Random tips about Termux, Neovim, Git, and development
# ====================================

# Color definitions
RED='\033[38;2;255;107;107m'
YELLOW='\033[38;2;255;217;61m'
GREEN='\033[38;2;107;207;127m'
WHITE='\033[38;2;245;245;245m'
GRAY='\033[38;2;160;160;160m'
RESET='\033[0m'
BOLD='\033[1m'
ITALIC='\033[3m'

# Arrays of tips by category
declare -a termux_tips=(
    "📱 Use 'termux-setup-storage' to access your phone's files from Termux"
    "🔧 Install development tools: pkg install git python nodejs-lts neovim"
    "⌨️  Enable hardware keyboard shortcuts in Termux settings"
    "📂 Access Android files via /storage/emulated/0/ or ~/storage/"
    "🔌 Use 'termux-wake-lock' to prevent your device from sleeping during long tasks"
    "🎯 Pin Termux to recent apps to prevent Android from killing it"
    "🔄 Use 'pkg autoclean' to free up space by removing unused packages"
    "📶 Set up SSH server: pkg install openssh && sshd"
    "🎨 Customize your prompt with PS1 variable in ~/.bashrc"
    "⚡ Use 'alias' command to create shortcuts for frequently used commands"
    "🔒 Protect your data: regular backups using 'tar' or 'rsync'"
    "🌐 Access localhost services via 127.0.0.1 or 10.0.2.2 (emulator)"
)

declare -a neovim_tips=(
    "🎵 Use ':Lazy' to manage plugins in LazyVim"
    "🔍 Press '/' to search, 'n' for next match, 'N' for previous"
    "⚡ Use 'gd' to go to definition, 'gr' to find references"
    "📝 Press 'i' for insert mode, 'v' for visual, ':' for command mode"
    "🎯 Use '<leader>ff' to find files with Telescope"
    "🔄 Press 'u' to undo, 'Ctrl+r' to redo changes"
    "📋 Use 'yy' to copy line, 'dd' to delete line, 'p' to paste"
    "🎨 Change colorscheme with ':colorscheme [name]' or use ':Lazy extras'"
    "🧠 Use 'K' to show documentation for symbol under cursor"
    "⚡ Press 'Ctrl+n' and 'Ctrl+p' for autocomplete navigation"
    "🔧 Use ':Mason' to install LSP servers and formatters"
    "🎪 Use ':ZenMode' for distraction-free coding"
    "🌿 Access oil file manager with '-' key for directory editing"
)

declare -a git_tips=(
    "🌱 Initialize repo: git init, then git add . && git commit -m 'Initial commit'"
    "🔄 Stay updated: git pull --rebase to avoid merge commits"
    "🎯 Stage selectively: git add -p for interactive staging"
    "📷 Save work in progress: git stash, restore with git stash pop"
    "🌿 Create branch: git checkout -b feature-name"
    "🔍 View changes: git diff for unstaged, git diff --staged for staged"
    "📊 Check status: git status shows current branch and file states"
    "🎭 View history: git log --oneline --graph for visual commit history"
    "🔙 Undo last commit: git reset --soft HEAD^ (keeps changes staged)"
    "🎨 Rename branch: git branch -m old-name new-name"
    "🧹 Clean untracked files: git clean -fd (be careful!)"
    "🔗 Add remote: git remote add origin <url>, push with git push -u origin main"
)

declare -a development_tips=(
    "🧠 Master the command line - it's your most powerful tool"
    "📚 Read documentation first, Google second - understanding beats copy-pasting"
    "🎯 Write tests before code (TDD) - it saves debugging time later"
    "🔄 Commit early, commit often - small commits are easier to review"
    "🌿 Use meaningful variable names - code should read like a story"
    "⚡ Learn keyboard shortcuts - they compound into massive time savings"
    "🔧 Automate repetitive tasks with scripts - let computers do computer work"
    "📝 Comment your code as if you'll read it in 6 months (you will)"
    "🎨 Consistency matters more than perfection - follow team conventions"
    "🔍 Debug by reading error messages carefully - they're usually helpful"
    "🌊 Learn one thing deeply rather than many things shallowly"
    "🤝 Code review is about learning, not ego - embrace feedback"
)

declare -a productivity_tips=(
    "⏰ Use Pomodoro technique: 25min work, 5min break, repeat"
    "🎯 Plan your day with 3 key tasks - finish these no matter what"
    "🧘 Take breaks every hour - your brain needs rest to perform"
    "💡 Learn in public - teach others to solidify your knowledge"
    "📱 Turn off notifications during deep work sessions"
    "🌅 Code when your energy is highest - usually mornings"
    "🎪 Use multiple monitors if possible - screen real estate matters"
    "📂 Organize files with clear folder structures and naming conventions"
    "🔄 Backup your work regularly - assume your device will break"
    "🎵 Find your focus music - instrumental, nature sounds, or silence"
    "💪 Exercise regularly - physical health improves mental performance"
    "📚 Read code more than you write code - learn from others"
)

declare -a rastafari_wisdom=(
    "🌿 'One love, one heart, one terminal' - Keep your tools unified and simple"
    "🦁 'Get up, stand up for your code rights' - Don't accept broken software"
    "🎵 'Don't worry about bugs, every little thing gonna be alright' - Debug with patience"
    "🔥 'Emancipate yourself from mental slavery' - Learn, don't just copy-paste"
    "⚡ 'In this great future, you can't forget your Git' - Version control is essential"
    "🌍 'Ubuntu philosophy: I code, therefore we are' - Share knowledge with community"
    "🎯 'Babylon system fall down' - Replace bad practices with good ones"
    "💚 'Positive vibration' - Keep your codebase clean and maintainable"
    "🌿 'Natural mystic flowing through the air' - Trust your debugging instincts"
    "🦁 'Lion in the morning, lamb in the evening' - Be fierce with bugs, gentle with teammates"
    "🎪 'Three little birds sat on my window' - Focus on one issue at a time"
    "🔄 'Could you be loved by your codebase?' - Write code you'd want to maintain"
)

# Function to get random tip from category
get_random_tip() {
    local category="$1"
    local -n tips_array="$category"
    local array_size=${#tips_array[@]}
    local random_index=$((RANDOM % array_size))
    echo "${tips_array[$random_index]}"
}

# Function to display a tip with rastafari styling
show_tip() {
    local category="$1"
    local tip_text="$2"
    local category_color=""
    local category_icon=""

    case "$category" in
        "termux_tips")
            category_color="$RED"
            category_icon="📱"
            category_name="TERMUX VIBES"
            ;;
        "neovim_tips")
            category_color="$YELLOW"
            category_icon="🎵"
            category_name="NEOVIM WISDOM"
            ;;
        "git_tips")
            category_color="$GREEN"
            category_icon="🌿"
            category_name="GIT KNOWLEDGE"
            ;;
        "development_tips")
            category_color="$RED"
            category_icon="🔥"
            category_name="CODING FIRE"
            ;;
        "productivity_tips")
            category_color="$YELLOW"
            category_icon="⚡"
            category_name="PRODUCTIVITY POWER"
            ;;
        "rastafari_wisdom")
            category_color="$GREEN"
            category_icon="🦁"
            category_name="JAH WISDOM"
            ;;
    esac

    printf "\n"
    printf "${category_color}${BOLD}${category_icon} ${category_name} ${category_icon}${RESET}\n"
    printf "${WHITE}┌─────────────────────────────────────────────────────────────────┐${RESET}\n"
    printf "${WHITE}│${RESET} ${WHITE}${tip_text}${RESET}\n"
    printf "${WHITE}└─────────────────────────────────────────────────────────────────┘${RESET}\n"
    printf "${GRAY}${ITALIC}   One love, one tip at a time! 💚💛❤️${RESET}\n"
    printf "\n"
}

# Function to show random tip from any category
show_random_tip() {
    local categories=("termux_tips" "neovim_tips" "git_tips" "development_tips" "productivity_tips" "rastafari_wisdom")
    local random_category_index=$((RANDOM % ${#categories[@]}))
    local selected_category="${categories[$random_category_index]}"
    local tip=$(get_random_tip "$selected_category")

    show_tip "$selected_category" "$tip"
}

# Function to show tips from specific category
show_category_tips() {
    local category="$1"
    local count="${2:-1}"

    case "$category" in
        "termux"|"t") category="termux_tips" ;;
        "neovim"|"nvim"|"n") category="neovim_tips" ;;
        "git"|"g") category="git_tips" ;;
        "dev"|"development"|"d") category="development_tips" ;;
        "productivity"|"prod"|"p") category="productivity_tips" ;;
        "wisdom"|"jah"|"w") category="rastafari_wisdom" ;;
        *)
            printf "${RED}❌ Unknown category: $category${RESET}\n"
            show_help
            return 1
            ;;
    esac

    for ((i=1; i<=count; i++)); do
        local tip=$(get_random_tip "$category")
        show_tip "$category" "$tip"
        [ $i -lt $count ] && sleep 0.5
    done
}

# Function to show all tips from a category
show_all_tips() {
    local category="$1"

    case "$category" in
        "termux"|"t")
            printf "${RED}${BOLD}📱 ALL TERMUX TIPS 📱${RESET}\n\n"
            for tip in "${termux_tips[@]}"; do
                printf "${WHITE}• ${tip}${RESET}\n"
            done
            ;;
        "neovim"|"nvim"|"n")
            printf "${YELLOW}${BOLD}🎵 ALL NEOVIM TIPS 🎵${RESET}\n\n"
            for tip in "${neovim_tips[@]}"; do
                printf "${WHITE}• ${tip}${RESET}\n"
            done
            ;;
        "git"|"g")
            printf "${GREEN}${BOLD}🌿 ALL GIT TIPS 🌿${RESET}\n\n"
            for tip in "${git_tips[@]}"; do
                printf "${WHITE}• ${tip}${RESET}\n"
            done
            ;;
        "dev"|"development"|"d")
            printf "${RED}${BOLD}🔥 ALL DEVELOPMENT TIPS 🔥${RESET}\n\n"
            for tip in "${development_tips[@]}"; do
                printf "${WHITE}• ${tip}${RESET}\n"
            done
            ;;
        "productivity"|"prod"|"p")
            printf "${YELLOW}${BOLD}⚡ ALL PRODUCTIVITY TIPS ⚡${RESET}\n\n"
            for tip in "${productivity_tips[@]}"; do
                printf "${WHITE}• ${tip}${RESET}\n"
            done
            ;;
        "wisdom"|"jah"|"w")
            printf "${GREEN}${BOLD}🦁 ALL JAH WISDOM 🦁${RESET}\n\n"
            for tip in "${rastafari_wisdom[@]}"; do
                printf "${WHITE}• ${tip}${RESET}\n"
            done
            ;;
        *)
            printf "${RED}❌ Unknown category: $category${RESET}\n"
            show_help
            return 1
            ;;
    esac
    printf "\n"
}

# Function to show daily tip (different each day)
show_daily_tip() {
    # Use date as seed for consistent daily tip
    local day_seed=$(date +%j)  # Day of year (1-366)
    RANDOM=$day_seed

    printf "${GREEN}${BOLD}🌅 JAH DAILY WISDOM 🌅${RESET}\n"
    printf "${GRAY}Today's inspiration for $(date '+%Y-%m-%d'):${RESET}\n"
    show_random_tip
}

# Help function
show_help() {
    printf "${GREEN}${BOLD}🌿 RASTAFARI TIPS SYSTEM 🌿${RESET}\n\n"
    printf "${WHITE}${BOLD}USAGE:${RESET}\n"
    printf "  ${YELLOW}rasta-tips${RESET}                    Show random tip\n"
    printf "  ${YELLOW}rasta-tips daily${RESET}             Show daily tip (same each day)\n"
    printf "  ${YELLOW}rasta-tips [category]${RESET}        Show tip from specific category\n"
    printf "  ${YELLOW}rasta-tips [category] [count]${RESET} Show multiple tips from category\n"
    printf "  ${YELLOW}rasta-tips all [category]${RESET}    Show all tips from category\n\n"

    printf "${WHITE}${BOLD}CATEGORIES:${RESET}\n"
    printf "  ${RED}termux, t${RESET}          📱 Termux terminal tips\n"
    printf "  ${YELLOW}neovim, nvim, n${RESET}    🎵 Neovim editor wisdom\n"
    printf "  ${GREEN}git, g${RESET}             🌿 Git version control\n"
    printf "  ${RED}dev, development, d${RESET} 🔥 General development\n"
    printf "  ${YELLOW}productivity, prod, p${RESET} ⚡ Productivity techniques\n"
    printf "  ${GREEN}wisdom, jah, w${RESET}     🦁 Rastafari coding philosophy\n\n"

    printf "${WHITE}${BOLD}EXAMPLES:${RESET}\n"
    printf "  ${GRAY}rasta-tips git 3${RESET}     # Show 3 Git tips\n"
    printf "  ${GRAY}rasta-tips all neovim${RESET} # Show all Neovim tips\n"
    printf "  ${GRAY}rasta-tips wisdom${RESET}     # Show Jah wisdom\n\n"

    printf "${GREEN}One love, one terminal! 💚💛❤️${RESET}\n"
}

# Main script logic
main() {
    case "${1:-random}" in
        "help"|"--help"|"-h")
            show_help
            ;;
        "daily")
            show_daily_tip
            ;;
        "all")
            if [ -n "$2" ]; then
                show_all_tips "$2"
            else
                printf "${RED}❌ Please specify category for 'all' command${RESET}\n"
                show_help
            fi
            ;;
        "random"|"")
            show_random_tip
            ;;
        *)
            local category="$1"
            local count="${2:-1}"

            # Validate count is a number
            if ! [[ "$count" =~ ^[0-9]+$ ]]; then
                count=1
            fi

            # Limit count to reasonable number
            if [ "$count" -gt 10 ]; then
                count=10
                printf "${YELLOW}⚠️  Limited to 10 tips maximum${RESET}\n"
            fi

            show_category_tips "$category" "$count"
            ;;
    esac
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi