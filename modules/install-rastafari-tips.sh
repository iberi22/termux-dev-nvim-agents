#!/data/data/com.termux/files/usr/bin/bash

# ====================================
# Install Rastafari Tips System
# Sets up random tips system for Termux development
# ====================================

install_rastafari_tips() {
    echo "🎵 Installing Rastafari Tips System..."

    local tips_script="$HOME/.rastafari-tips.sh"
    local tips_data="$HOME/.rastafari-tips-data"

    # Copy tips script to home directory
    if [ -f "scripts/rastafari-tips.sh" ]; then
        cp "scripts/rastafari-tips.sh" "$tips_script"
        chmod +x "$tips_script"
        echo "✅ Tips script installed to $tips_script"
    else
        echo "❌ Tips script not found!"
        return 1
    fi

    # Create tips data directory for future expansions
    mkdir -p "$tips_data"

    # Create wrapper command for easy access
    create_tips_command

    # Add random tip to shell startup (optional)
    setup_startup_tip

    # Create cron job for daily tips (if cron available)
    setup_daily_tips

    echo ""
    echo "✅ Rastafari Tips System installed successfully!"
    echo "🌿 Try: rasta-tips, rasta-tips git, rasta-tips daily"
    echo "🎵 Type: rasta-tips help for all options"
}

create_tips_command() {
    local bin_dir="$PREFIX/bin"
    local command_file="$bin_dir/rasta-tips"

    # Create global command if we have write access to PREFIX/bin
    if [ -w "$bin_dir" ]; then
        cat > "$command_file" << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
# Rastafari Tips Command Wrapper
exec "$HOME/.rastafari-tips.sh" "$@"
EOF
        chmod +x "$command_file"
        echo "✅ Global 'rasta-tips' command created"
    else
        # Add to user's bin directory
        local user_bin="$HOME/.local/bin"
        mkdir -p "$user_bin"

        cat > "$user_bin/rasta-tips" << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
# Rastafari Tips Command Wrapper
exec "$HOME/.rastafari-tips.sh" "$@"
EOF
        chmod +x "$user_bin/rasta-tips"

        # Add to PATH if not already there
        local path_export='export PATH="$HOME/.local/bin:$PATH"'

        if [ -f "$HOME/.bashrc" ] && ! grep -q ".local/bin" "$HOME/.bashrc"; then
            echo "$path_export" >> "$HOME/.bashrc"
        fi

        if [ -f "$HOME/.zshrc" ] && ! grep -q ".local/bin" "$HOME/.zshrc"; then
            echo "$path_export" >> "$HOME/.zshrc"
        fi

        echo "✅ User 'rasta-tips' command created in ~/.local/bin"
    fi
}

setup_startup_tip() {
    local startup_tip='
# Random Rastafari tip on new session (every 5th login)
if [ -f "$HOME/.rastafari-tips.sh" ] && [ $((RANDOM % 5)) -eq 0 ] && [ -t 0 ]; then
    echo ""
    "$HOME/.rastafari-tips.sh" random
fi'

    # Ask user if they want random tips on startup
    if command -v whiptail >/dev/null 2>&1; then
        if whiptail --title "Rastafari Tips" --yesno "Show random tip every 5th terminal session?" 8 60; then
            add_startup_tip="yes"
        else
            add_startup_tip="no"
        fi
    else
        printf "${YELLOW}Show random tip every 5th terminal session? (y/n): ${WHITE}"
        read -r add_startup_tip
    fi

    if [[ "$add_startup_tip" =~ ^[Yy] ]]; then
        # Add to bashrc
        if [ -f "$HOME/.bashrc" ] && ! grep -q "Random Rastafari tip" "$HOME/.bashrc"; then
            echo "$startup_tip" >> "$HOME/.bashrc"
        fi

        # Add to zshrc
        if [ -f "$HOME/.zshrc" ] && ! grep -q "Random Rastafari tip" "$HOME/.zshrc"; then
            echo "$startup_tip" >> "$HOME/.zshrc"
        fi

        echo "✅ Random startup tips enabled"
    else
        echo "ℹ️  Startup tips disabled (you can still use 'rasta-tips' command)"
    fi
}

setup_daily_tips() {
    # Check if termux-api is available for notifications
    if command -v termux-notification >/dev/null 2>&1; then
        local cron_available=false

        # Check for various cron implementations
        if command -v crontab >/dev/null 2>&1 || command -v crond >/dev/null 2>&1; then
            cron_available=true
        fi

        if [ "$cron_available" = true ]; then
            printf "${YELLOW}Set up daily tip notifications? (y/n): ${WHITE}"
            read -r setup_notifications

            if [[ "$setup_notifications" =~ ^[Yy] ]]; then
                # Create notification script
                local notify_script="$HOME/.rastafari-daily-notify.sh"
                cat > "$notify_script" << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
# Daily Rastafari Tip Notification

tip_output=$("$HOME/.rastafari-tips.sh" daily)
tip_text=$(echo "$tip_output" | tail -n +3 | head -n 1)

if command -v termux-notification >/dev/null 2>&1; then
    termux-notification \
        --title "🌿 Daily Jah Wisdom" \
        --content "$tip_text" \
        --id "rastafari_daily_tip" \
        --priority high \
        --sound
fi
EOF
                chmod +x "$notify_script"

                # Add to crontab (8 AM daily)
                (crontab -l 2>/dev/null; echo "0 8 * * * $notify_script") | crontab -

                echo "✅ Daily tip notifications set up for 8:00 AM"
            fi
        else
            echo "ℹ️  Cron not available - daily notifications not configured"
        fi
    else
        echo "ℹ️  termux-api not installed - daily notifications not available"
        echo "    Install with: pkg install termux-api"
    fi
}

# Create additional tip categories file for user customization
create_custom_tips() {
    local custom_tips_file="$HOME/.rastafari-tips-data/custom-tips.sh"

    cat > "$custom_tips_file" << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash

# ====================================
# Custom Rastafari Tips - Add Your Own Wisdom
# ====================================

# Add your own tip categories here
# Format: declare -a category_name=("tip1" "tip2" "tip3")

declare -a personal_tips=(
    "📝 Add your own personal development tips here"
    "🎯 Share your favorite shortcuts and commands"
    "💡 Document lessons learned from your coding journey"
    "🔧 Include project-specific tips and reminders"
)

declare -a team_tips=(
    "👥 Add tips specific to your team or organization"
    "📋 Include coding standards and best practices"
    "🎪 Share team-specific tools and workflows"
    "🤝 Document collaboration guidelines"
)

# To use custom tips, source this file in the main tips script
# Example: source "$HOME/.rastafari-tips-data/custom-tips.sh"
EOF

    chmod +x "$custom_tips_file"
    echo "✅ Custom tips template created at ~/.rastafari-tips-data/"
}

# Run installation if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_rastafari_tips
    create_custom_tips
fi