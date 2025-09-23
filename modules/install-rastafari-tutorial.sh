#!/data/data/com.termux/files/usr/bin/bash

# ====================================
# Install Rastafari Tutorial System
# Sets up first-time user tutorial
# ====================================

install_rastafari_tutorial() {
    echo "📚 Installing Rastafari Tutorial System..."

    local tutorial_script="$HOME/.rastafari-tutorial.sh"

    # Copy tutorial script to home directory
    if [ -f "scripts/rastafari-tutorial.sh" ]; then
        cp "scripts/rastafari-tutorial.sh" "$tutorial_script"
        chmod +x "$tutorial_script"
        echo "✅ Tutorial script installed to $tutorial_script"
    else
        echo "❌ Tutorial script not found!"
        return 1
    fi

    # Create tutorial command
    create_tutorial_command

    # Add first-time detection to shell startup
    setup_first_time_detection

    echo ""
    echo "✅ Rastafari Tutorial System installed successfully!"
    echo "📖 New users will see the tutorial automatically"
    echo "🎓 Run 'rasta-tutorial' anytime to access it"
}

create_tutorial_command() {
    local bin_dir="$PREFIX/bin"
    local command_file="$bin_dir/rasta-tutorial"

    # Create global command if we have write access to PREFIX/bin
    if [ -w "$bin_dir" ]; then
        cat > "$command_file" << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
# Rastafari Tutorial Command Wrapper
exec "$HOME/.rastafari-tutorial.sh" "$@"
EOF
        chmod +x "$command_file"
        echo "✅ Global 'rasta-tutorial' command created"
    else
        # Add to user's bin directory
        local user_bin="$HOME/.local/bin"
        mkdir -p "$user_bin"

        cat > "$user_bin/rasta-tutorial" << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
# Rastafari Tutorial Command Wrapper
exec "$HOME/.rastafari-tutorial.sh" "$@"
EOF
        chmod +x "$user_bin/rasta-tutorial"

        # Add to PATH if not already there
        local path_export='export PATH="$HOME/.local/bin:$PATH"'

        if [ -f "$HOME/.bashrc" ] && ! grep -q ".local/bin" "$HOME/.bashrc"; then
            echo "$path_export" >> "$HOME/.bashrc"
        fi

        if [ -f "$HOME/.zshrc" ] && ! grep -q ".local/bin" "$HOME/.zshrc"; then
            echo "$path_export" >> "$HOME/.zshrc"
        fi

        echo "✅ User 'rasta-tutorial' command created in ~/.local/bin"
    fi
}

setup_first_time_detection() {
    local first_time_check='
# Rastafari First-Time Tutorial Detection
if [ ! -f "$HOME/.rastafari_setup_complete" ] && [ -f "$HOME/.rastafari-tutorial.sh" ] && [ -t 0 ] && [ -z "$RASTAFARI_TUTORIAL_SHOWN" ]; then
    export RASTAFARI_TUTORIAL_SHOWN=1

    # Show brief welcome and ask if user wants tutorial
    printf "\n\033[38;2;107;207;127m🌿 Welcome to Rastafari Termux! 🌿\033[0m\n"
    printf "\033[38;2;245;245;245mThis appears to be your first time here.\033[0m\n"
    printf "\033[38;2;255;217;61mWould you like to run the setup tutorial? (y/n): \033[0m"

    read -r run_tutorial
    if [[ "$run_tutorial" =~ ^[Yy] ]]; then
        "$HOME/.rastafari-tutorial.sh"
    else
        printf "\033[38;2;160;160;160mYou can run it later with: \033[38;2;245;245;245mrasta-tutorial\033[0m\n"
        printf "\033[38;2;107;207;127mOne love! 💚💛❤️\033[0m\n\n"
    fi
fi'

    # Add to bashrc
    if [ -f "$HOME/.bashrc" ] && ! grep -q "Rastafari First-Time Tutorial" "$HOME/.bashrc"; then
        echo "$first_time_check" >> "$HOME/.bashrc"
        echo "✅ First-time detection added to .bashrc"
    fi

    # Add to zshrc if exists
    if [ -f "$HOME/.zshrc" ] && ! grep -q "Rastafari First-Time Tutorial" "$HOME/.zshrc"; then
        echo "$first_time_check" >> "$HOME/.zshrc"
        echo "✅ First-time detection added to .zshrc"
    fi
}

# Create tutorial quick start guide
create_tutorial_guide() {
    local guide_file="$HOME/.rastafari-tutorial-guide.md"

    cat > "$guide_file" << 'EOF'
# Rastafari Tutorial Quick Guide

## Tutorial Commands
- `rasta-tutorial` - Run/resume tutorial
- `rasta-tutorial reset` - Start over
- `rasta-tutorial status` - Check progress

## Tutorial Steps
1. **System Information** - Learn about Termux
2. **Package Installation** - Install essential tools
3. **Git Configuration** - Set up version control
4. **SSH Keys** - Generate authentication keys
5. **Neovim Introduction** - Learn the editor basics
6. **Shell Customization** - Customize your terminal
7. **Final Setup** - Complete Rastafari installation

## After Tutorial
- Use `rasta-help` to see all available commands
- Run `rasta-tips` for development wisdom
- Start coding with `rasta-neovim`

## Getting Help
- Tutorial help: `rasta-tutorial help`
- System help: `rasta-help`
- Tips system: `rasta-tips help`

One love, one terminal! 💚💛❤️
EOF

    echo "✅ Tutorial guide created at ~/.rastafari-tutorial-guide.md"
}

# Run installation if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_rastafari_tutorial
    create_tutorial_guide
fi