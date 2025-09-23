#!/data/data/com.termux/files/usr/bin/bash

# ====================================
# Rastafari First-Time Setup Tutorial
# Interactive guide for new users
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

# Tutorial state file
TUTORIAL_STATE_FILE="$HOME/.rastafari-tutorial-state"
SETUP_COMPLETE_FILE="$HOME/.rastafari_setup_complete"

# Function to check if first time setup
is_first_time() {
    [ ! -f "$SETUP_COMPLETE_FILE" ]
}

# Function to get tutorial step
get_tutorial_step() {
    if [ -f "$TUTORIAL_STATE_FILE" ]; then
        cat "$TUTORIAL_STATE_FILE"
    else
        echo "0"
    fi
}

# Function to save tutorial step
save_tutorial_step() {
    echo "$1" > "$TUTORIAL_STATE_FILE"
}

# Function to wait for user input
wait_for_enter() {
    printf "\n${YELLOW}Press Enter to continue...${RESET}"
    read -r
}

# Function to ask yes/no question
ask_yes_no() {
    local question="$1"
    local default="${2:-y}"

    while true; do
        if [ "$default" = "y" ]; then
            printf "${WHITE}$question (Y/n): ${RESET}"
        else
            printf "${WHITE}$question (y/N): ${RESET}"
        fi

        read -r answer
        answer=${answer:-$default}

        case ${answer,,} in
            y|yes) return 0 ;;
            n|no) return 1 ;;
            *) printf "${RED}Please answer yes or no.${RESET}\n" ;;
        esac
    done
}

# Function to show animated welcome
show_welcome() {
    clear
    printf "\n"
    printf "${RED}${BOLD}  ╔═══════════════════════════════════════════════════════════════╗${RESET}\n"
    printf "${YELLOW}${BOLD}  ║                     🌿 WELCOME TO JAH TERMINAL 🌿              ║${RESET}\n"
    printf "${GREEN}${BOLD}  ║                   Rastafari Development Environment           ║${RESET}\n"
    printf "${RED}${BOLD}  ╚═══════════════════════════════════════════════════════════════╝${RESET}\n"
    printf "\n"

    printf "${WHITE}${ITALIC}\"Get up, stand up, code for your rights!\"${RESET}\n"
    printf "${GRAY}                                    - Bob Marley (adapted for developers)${RESET}\n\n"

    printf "${GREEN}${BOLD}🎵 First-Time Setup Tutorial 🎵${RESET}\n\n"
    printf "${WHITE}This tutorial will guide you through setting up your Rastafari development environment.\n"
    printf "You'll learn about Termux, Neovim, Git, and development best practices.${RESET}\n\n"

    printf "${YELLOW}What you'll get:${RESET}\n"
    printf "${WHITE}• 🌿 Custom Rastafari terminal theme\n"
    printf "• 🎵 Neovim with AI-powered coding assistance\n"
    printf "• 🦁 Development tools and shortcuts\n"
    printf "• 🔥 Git configuration and SSH keys\n"
    printf "• ⚡ Productivity tips and wisdom${RESET}\n\n"

    if ask_yes_no "Ready to start your Rastafari coding journey?"; then
        save_tutorial_step "1"
        return 0
    else
        printf "\n${GREEN}No problem! Run ${WHITE}${BOLD}rasta-tutorial${RESET}${GREEN} when you're ready.${RESET}\n"
        printf "${YELLOW}One love! 💚💛❤️${RESET}\n\n"
        exit 0
    fi
}

# Step 1: System Information
tutorial_step_1() {
    clear
    printf "${GREEN}${BOLD}📱 STEP 1: Understanding Your System 📱${RESET}\n\n"

    printf "${WHITE}Let's learn about your Termux environment:${RESET}\n\n"

    # Show device info
    printf "${YELLOW}🔍 Device Information:${RESET}\n"
    printf "${GRAY}Device: ${WHITE}$(getprop ro.product.model 2>/dev/null || echo 'Unknown Android Device')${RESET}\n"
    printf "${GRAY}Android: ${WHITE}$(getprop ro.build.version.release 2>/dev/null || echo 'N/A')${RESET}\n"
    printf "${GRAY}Architecture: ${WHITE}$(uname -m)${RESET}\n"
    printf "${GRAY}Shell: ${WHITE}${SHELL##*/}${RESET}\n\n"

    # Show storage info
    printf "${YELLOW}💾 Storage Information:${RESET}\n"
    if command -v df >/dev/null 2>&1; then
        df -h /data/data/com.termux/files/home | tail -1 | awk '{printf "Available: '$WHITE'%s of %s ('$GRAY'%s used'$WHITE')\\n", $4, $2, $5}'
    else
        printf "Storage information not available\n"
    fi

    printf "\n${YELLOW}📚 Important Termux Concepts:${RESET}\n"
    printf "${WHITE}• Termux is a Linux environment on Android\n"
    printf "• You have your own home directory: ${GREEN}~${WHITE} or ${GREEN}$HOME${WHITE}\n"
    printf "• Install packages with: ${GREEN}pkg install [package]${WHITE}\n"
    printf "• Access Android storage: ${GREEN}termux-setup-storage${WHITE}\n"
    printf "• Files are in: ${GREEN}/data/data/com.termux/files/home/${WHITE}${RESET}\n\n"

    wait_for_enter
    save_tutorial_step "2"
}

# Step 2: Package Installation
tutorial_step_2() {
    clear
    printf "${GREEN}${BOLD}📦 STEP 2: Essential Package Installation 📦${RESET}\n\n"

    printf "${WHITE}Let's install the essential development tools:${RESET}\n\n"

    # Check what's already installed
    local packages=("git" "python" "nodejs-lts" "neovim" "zsh" "tree" "curl" "wget")
    local to_install=()

    printf "${YELLOW}🔍 Checking installed packages:${RESET}\n"
    for pkg in "${packages[@]}"; do
        if command -v "$pkg" >/dev/null 2>&1; then
            printf "${GREEN}✅ $pkg${RESET}\n"
        else
            printf "${RED}❌ $pkg${RESET} (will be installed)\n"
            to_install+=("$pkg")
        fi
    done

    if [ ${#to_install[@]} -gt 0 ]; then
        printf "\n${YELLOW}📋 Packages to install: ${WHITE}${to_install[*]}${RESET}\n\n"

        if ask_yes_no "Install missing packages now?"; then
            printf "\n${GREEN}🚀 Installing packages...${RESET}\n"

            # Update package lists first
            printf "${GRAY}Updating package lists...${RESET}\n"
            pkg update -y

            # Install packages
            for pkg in "${to_install[@]}"; do
                printf "${YELLOW}Installing $pkg...${RESET}\n"
                pkg install "$pkg" -y

                if command -v "$pkg" >/dev/null 2>&1; then
                    printf "${GREEN}✅ $pkg installed successfully${RESET}\n"
                else
                    printf "${RED}❌ Failed to install $pkg${RESET}\n"
                fi
            done

            printf "\n${GREEN}🎉 Package installation complete!${RESET}\n"
        else
            printf "\n${YELLOW}⚠️  You can install packages later with: ${WHITE}pkg install [package]${RESET}\n"
        fi
    else
        printf "\n${GREEN}🎉 All essential packages are already installed!${RESET}\n"
    fi

    wait_for_enter
    save_tutorial_step "3"
}

# Step 3: Git Configuration
tutorial_step_3() {
    clear
    printf "${GREEN}${BOLD}🌿 STEP 3: Git Configuration 🌿${RESET}\n\n"

    printf "${WHITE}Git is essential for version control. Let's configure it:${RESET}\n\n"

    # Check if git is configured
    local git_name=$(git config --global user.name 2>/dev/null)
    local git_email=$(git config --global user.email 2>/dev/null)

    if [ -n "$git_name" ] && [ -n "$git_email" ]; then
        printf "${GREEN}✅ Git is already configured:${RESET}\n"
        printf "${GRAY}Name: ${WHITE}$git_name${RESET}\n"
        printf "${GRAY}Email: ${WHITE}$git_email${RESET}\n\n"

        if ! ask_yes_no "Do you want to change these settings?"; then
            wait_for_enter
            save_tutorial_step "4"
            return 0
        fi
    fi

    printf "${YELLOW}🔧 Let's configure Git:${RESET}\n\n"

    # Get user name
    printf "${WHITE}Enter your full name (for commits): ${RESET}"
    read -r user_name

    # Get user email
    printf "${WHITE}Enter your email address: ${RESET}"
    read -r user_email

    # Configure Git
    if [ -n "$user_name" ] && [ -n "$user_email" ]; then
        git config --global user.name "$user_name"
        git config --global user.email "$user_email"
        git config --global init.defaultBranch main
        git config --global pull.rebase true

        printf "\n${GREEN}✅ Git configured successfully!${RESET}\n"
        printf "${GRAY}Name: ${WHITE}$user_name${RESET}\n"
        printf "${GRAY}Email: ${WHITE}$user_email${RESET}\n"
        printf "${GRAY}Default branch: ${WHITE}main${RESET}\n"
        printf "${GRAY}Pull strategy: ${WHITE}rebase${RESET}\n"
    else
        printf "\n${RED}❌ Git configuration skipped (invalid input)${RESET}\n"
    fi

    wait_for_enter
    save_tutorial_step "4"
}

# Step 4: SSH Key Generation
tutorial_step_4() {
    clear
    printf "${GREEN}${BOLD}🔑 STEP 4: SSH Key Setup 🔑${RESET}\n\n"

    printf "${WHITE}SSH keys allow secure authentication with Git services like GitHub.${RESET}\n\n"

    # Check if SSH key exists
    local ssh_key_exists=false
    if [ -f "$HOME/.ssh/id_ed25519" ] || [ -f "$HOME/.ssh/id_rsa" ]; then
        ssh_key_exists=true
        printf "${GREEN}✅ SSH key already exists${RESET}\n\n"

        # Show existing keys
        printf "${YELLOW}📋 Existing SSH keys:${RESET}\n"
        ls -la ~/.ssh/*.pub 2>/dev/null | awk '{print "  " $9}' || printf "  (No public keys found)\n"
        printf "\n"

        if ! ask_yes_no "Generate a new SSH key anyway?"; then
            wait_for_enter
            save_tutorial_step "5"
            return 0
        fi
    fi

    if ask_yes_no "Generate SSH key for Git authentication?"; then
        printf "\n${GREEN}🔐 Generating SSH key...${RESET}\n"

        # Create .ssh directory if it doesn't exist
        mkdir -p ~/.ssh
        chmod 700 ~/.ssh

        # Get email for key comment
        local git_email=$(git config --global user.email 2>/dev/null)
        if [ -z "$git_email" ]; then
            printf "${WHITE}Enter email for SSH key: ${RESET}"
            read -r git_email
        fi

        # Generate Ed25519 key
        ssh-keygen -t ed25519 -C "$git_email" -f ~/.ssh/id_ed25519 -N ""

        if [ -f ~/.ssh/id_ed25519.pub ]; then
            printf "\n${GREEN}✅ SSH key generated successfully!${RESET}\n"
            printf "\n${YELLOW}📋 Your public key:${RESET}\n"
            printf "${GRAY}$(cat ~/.ssh/id_ed25519.pub)${RESET}\n\n"

            printf "${YELLOW}🔗 To add this key to GitHub:${RESET}\n"
            printf "${WHITE}1. Go to GitHub.com → Settings → SSH and GPG keys\n"
            printf "2. Click 'New SSH key'\n"
            printf "3. Copy the public key above\n"
            printf "4. Paste it and save${RESET}\n\n"

            # Offer to copy to clipboard if termux-api is available
            if command -v termux-clipboard-set >/dev/null 2>&1; then
                if ask_yes_no "Copy SSH key to clipboard?"; then
                    cat ~/.ssh/id_ed25519.pub | termux-clipboard-set
                    printf "${GREEN}✅ SSH key copied to clipboard!${RESET}\n"
                fi
            fi
        else
            printf "\n${RED}❌ SSH key generation failed${RESET}\n"
        fi
    else
        printf "\n${YELLOW}⚠️  SSH key generation skipped${RESET}\n"
    fi

    wait_for_enter
    save_tutorial_step "5"
}

# Step 5: Neovim Introduction
tutorial_step_5() {
    clear
    printf "${GREEN}${BOLD}🎵 STEP 5: Neovim Introduction 🎵${RESET}\n\n"

    printf "${WHITE}Neovim is a powerful text editor. Let's learn the basics:${RESET}\n\n"

    printf "${YELLOW}🎯 Basic Neovim Modes:${RESET}\n"
    printf "${WHITE}• ${GREEN}Normal mode${WHITE}: Navigate and execute commands (default)\n"
    printf "• ${YELLOW}Insert mode${WHITE}: Type text (press ${GREEN}i${WHITE})\n"
    printf "• ${RED}Visual mode${WHITE}: Select text (press ${GREEN}v${WHITE})\n"
    printf "• ${GRAY}Command mode${WHITE}: Execute commands (press ${GREEN}:${WHITE})${RESET}\n\n"

    printf "${YELLOW}⌨️  Essential Shortcuts:${RESET}\n"
    printf "${WHITE}Navigation:\n"
    printf "  ${GREEN}h j k l${WHITE}     - Move left, down, up, right\n"
    printf "  ${GREEN}gg G${WHITE}        - Go to top, bottom of file\n"
    printf "  ${GREEN}0 $${WHITE}         - Go to beginning, end of line\n\n"

    printf "Editing:\n"
    printf "  ${GREEN}i a o${WHITE}       - Insert before cursor, after cursor, new line\n"
    printf "  ${GREEN}dd yy pp${WHITE}    - Delete line, copy line, paste\n"
    printf "  ${GREEN}u Ctrl+r${WHITE}    - Undo, redo\n\n"

    printf "Files:\n"
    printf "  ${GREEN}:w${WHITE}          - Save file\n"
    printf "  ${GREEN}:q${WHITE}          - Quit\n"
    printf "  ${GREEN}:wq${WHITE}         - Save and quit\n"
    printf "  ${GREEN}:q!${WHITE}         - Quit without saving${RESET}\n\n"

    printf "${YELLOW}🌿 Rastafari Neovim Features:${RESET}\n"
    printf "${WHITE}• Custom rastafari color scheme (red, yellow, green)\n"
    printf "• AI-powered code completion and chat\n"
    printf "• File explorer with ${GREEN}<leader>e${WHITE}\n"
    printf "• Find files with ${GREEN}<leader>ff${WHITE}\n"
    printf "• Terminal integration${RESET}\n\n"

    if ask_yes_no "Want to try Neovim now? (we'll open it briefly)"; then
        printf "\n${GREEN}🚀 Opening Neovim...${RESET}\n"
        printf "${YELLOW}When it opens:${RESET}\n"
        printf "${WHITE}1. Look around (use arrow keys or h j k l)\n"
        printf "2. Press ${GREEN}:q${WHITE} and Enter to quit\n"
        printf "3. Don't worry if it looks confusing - it takes practice!${RESET}\n\n"

        wait_for_enter

        # Create a sample file for demonstration
        cat > /tmp/rastafari-demo.txt << 'EOF'
🌿 Welcome to Rastafari Neovim! 🌿

This is a sample file to explore.
Use these keys to navigate:
- h j k l (left, down, up, right)
- Press :q and Enter to quit

One love, one terminal! 💚💛❤️
EOF

        nvim /tmp/rastafari-demo.txt
        rm -f /tmp/rastafari-demo.txt

        printf "\n${GREEN}🎉 Great job! You've tried Neovim!${RESET}\n"
    else
        printf "\n${YELLOW}No problem! You can explore Neovim later with: ${WHITE}nvim${RESET}\n"
    fi

    wait_for_enter
    save_tutorial_step "6"
}

# Step 6: Shell Customization
tutorial_step_6() {
    clear
    printf "${GREEN}${BOLD}🐚 STEP 6: Shell Customization 🐚${RESET}\n\n"

    printf "${WHITE}Let's set up your shell for the best experience:${RESET}\n\n"

    # Check current shell
    printf "${YELLOW}Current shell: ${WHITE}${SHELL##*/}${RESET}\n\n"

    if ask_yes_no "Switch to Zsh with Rastafari theme?"; then
        printf "\n${GREEN}🎨 Setting up Rastafari Zsh theme...${RESET}\n"

        # This would be handled by the main setup script
        printf "${GRAY}This will be configured by the main setup script.${RESET}\n"
        printf "${WHITE}Your shell will have:\n"
        printf "• 🌿 Rastafari colors (red, yellow, green)\n"
        printf "• 🎵 System metrics (CPU, memory)\n"
        printf "• 🦁 Git status integration\n"
        printf "• ⚡ Fast and responsive prompts${RESET}\n"
    else
        printf "\n${YELLOW}You can customize your shell later!${RESET}\n"
    fi

    printf "\n${YELLOW}📚 Useful Shell Tips:${RESET}\n"
    printf "${WHITE}• Use ${GREEN}tab${WHITE} for autocompletion\n"
    printf "• Press ${GREEN}Ctrl+C${WHITE} to cancel commands\n"
    printf "• Use ${GREEN}history${WHITE} to see previous commands\n"
    printf "• Press ${GREEN}Ctrl+R${WHITE} to search command history\n"
    printf "• Use ${GREEN}clear${WHITE} or ${GREEN}Ctrl+L${WHITE} to clear screen${RESET}\n\n"

    wait_for_enter
    save_tutorial_step "7"
}

# Step 7: Final Setup
tutorial_step_7() {
    clear
    printf "${GREEN}${BOLD}🎉 STEP 7: Complete Your Setup 🎉${RESET}\n\n"

    printf "${WHITE}Almost done! Let's finish setting up your Rastafari environment:${RESET}\n\n"

    printf "${YELLOW}🔧 What happens next:${RESET}\n"
    printf "${WHITE}• Full Rastafari theme installation\n"
    printf "• Neovim configuration with AI plugins\n"
    printf "• Custom aliases and commands\n"
    printf "• Development tools setup\n"
    printf "• Tips system activation${RESET}\n\n"

    if ask_yes_no "Run the complete Rastafari setup now?"; then
        printf "\n${GREEN}🚀 Starting complete setup...${RESET}\n\n"

        # Mark tutorial as complete
        touch "$SETUP_COMPLETE_FILE"
        rm -f "$TUTORIAL_STATE_FILE"

        # Run main setup script
        if [ -f "./setup.sh" ]; then
            exec ./setup.sh
        elif [ -f "../setup.sh" ]; then
            exec ../setup.sh
        else
            printf "${RED}❌ Setup script not found!${RESET}\n"
            printf "${WHITE}Please run: ${GREEN}cd termux-ai-setup && ./setup.sh${RESET}\n"
        fi
    else
        printf "\n${GREEN}✅ Tutorial completed!${RESET}\n"
        printf "${WHITE}You can run the full setup anytime with: ${GREEN}./setup.sh${RESET}\n\n"

        # Mark tutorial as complete anyway
        touch "$SETUP_COMPLETE_FILE"
        rm -f "$TUTORIAL_STATE_FILE"

        show_final_message
    fi
}

# Function to show final message
show_final_message() {
    printf "${GREEN}${BOLD}🌿 JAH BLESS YOUR CODING JOURNEY! 🌿${RESET}\n\n"

    printf "${YELLOW}📚 What you learned:${RESET}\n"
    printf "${WHITE}• Termux system basics\n"
    printf "• Package management\n"
    printf "• Git configuration\n"
    printf "• SSH key generation\n"
    printf "• Neovim fundamentals\n"
    printf "• Shell customization${RESET}\n\n"

    printf "${YELLOW}🔗 Useful Commands:${RESET}\n"
    printf "${WHITE}• ${GREEN}rasta-tips${WHITE} - Get development tips\n"
    printf "• ${GREEN}rasta-neovim${WHITE} - Start Neovim with theme\n"
    printf "• ${GREEN}rasta-help${WHITE} - Show all commands\n"
    printf "• ${GREEN}pkg install [package]${WHITE} - Install software\n"
    printf "• ${GREEN}nvim [file]${WHITE} - Edit files${RESET}\n\n"

    printf "${GREEN}${ITALIC}\"Every little thing gonna be alright!\"${RESET}\n"
    printf "${GRAY}                                    - Bob Marley${RESET}\n\n"

    printf "${WHITE}Welcome to the Rastafari development family! 💚💛❤️${RESET}\n\n"
}

# Function to resume tutorial from saved step
resume_tutorial() {
    local current_step=$(get_tutorial_step)

    case "$current_step" in
        "0"|"") show_welcome ;;
        "1") tutorial_step_1 ;;
        "2") tutorial_step_2 ;;
        "3") tutorial_step_3 ;;
        "4") tutorial_step_4 ;;
        "5") tutorial_step_5 ;;
        "6") tutorial_step_6 ;;
        "7") tutorial_step_7 ;;
        *)
            printf "${RED}❌ Invalid tutorial step: $current_step${RESET}\n"
            rm -f "$TUTORIAL_STATE_FILE"
            show_welcome
            ;;
    esac
}

# Main tutorial function
run_tutorial() {
    # Check if setup is already complete
    if [ -f "$SETUP_COMPLETE_FILE" ] && [ ! -f "$TUTORIAL_STATE_FILE" ]; then
        printf "${GREEN}✅ Rastafari setup is already complete!${RESET}\n\n"

        if ask_yes_no "Run tutorial again anyway?"; then
            rm -f "$SETUP_COMPLETE_FILE"
            show_welcome
        else
            printf "${WHITE}Use ${GREEN}rasta-help${WHITE} to see available commands.${RESET}\n"
            exit 0
        fi
    else
        resume_tutorial
    fi
}

# Run tutorial sequence
tutorial_sequence() {
    while true; do
        local current_step=$(get_tutorial_step)

        case "$current_step" in
            "1") tutorial_step_1 ;;
            "2") tutorial_step_2 ;;
            "3") tutorial_step_3 ;;
            "4") tutorial_step_4 ;;
            "5") tutorial_step_5 ;;
            "6") tutorial_step_6 ;;
            "7") tutorial_step_7; break ;;
            *) break ;;
        esac
    done
}

# Handle command line arguments
case "${1:-}" in
    "reset")
        rm -f "$TUTORIAL_STATE_FILE" "$SETUP_COMPLETE_FILE"
        printf "${GREEN}✅ Tutorial reset. Run again to start over.${RESET}\n"
        ;;
    "status")
        if [ -f "$SETUP_COMPLETE_FILE" ]; then
            printf "${GREEN}✅ Setup completed${RESET}\n"
        else
            printf "${YELLOW}⏳ Step $(get_tutorial_step)/7${RESET}\n"
        fi
        ;;
    "help"|"--help"|"-h")
        printf "${GREEN}${BOLD}Rastafari Tutorial Help${RESET}\n\n"
        printf "${WHITE}Commands:${RESET}\n"
        printf "  ${GREEN}rasta-tutorial${WHITE}        Run/resume tutorial\n"
        printf "  ${GREEN}rasta-tutorial reset${WHITE}  Reset tutorial progress\n"
        printf "  ${GREEN}rasta-tutorial status${WHITE} Show tutorial status\n\n"
        ;;
    *)
        run_tutorial
        ;;
esac