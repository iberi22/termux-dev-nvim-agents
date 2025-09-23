# 🚀 QUICK COMMANDS REFERENCE

## 📱 Windows PowerShell Commands

### Launch Complete Setup
```powershell
# Download and run setup script
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/iberi22/termux-dev-nvim-agents/main/Setup-TermuxAI.ps1" -OutFile "Setup-TermuxAI.ps1"
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
.\Setup-TermuxAI.ps1
```

### Manual Emulator Commands
```powershell
# Set Android environment
$env:ANDROID_HOME = "$env:LOCALAPPDATA\Android\Sdk"
$env:PATH = "$env:ANDROID_HOME\emulator;$env:ANDROID_HOME\platform-tools;$env:PATH"

# List available emulators
emulator -list-avds

# Start emulator (replace with your AVD name)
emulator -avd Pixel_7_Pro_API_33 -gpu host -memory 4096

# Connect via ADB
adb devices
adb shell
```

### Download Termux APK
```powershell
# Get latest Termux APK
$release = Invoke-RestMethod "https://api.github.com/repos/termux/termux-app/releases/latest"
$apk = $release.assets | Where-Object { $_.name -like "*universal.apk" } | Select-Object -First 1
Invoke-WebRequest $apk.browser_download_url -OutFile "termux.apk"

# Install APK
adb install termux.apk
```

## � CI/CD & Development Commands

### Repository Setup (One Command)
```bash
# Complete CI/CD setup and configuration
bash scripts/setup-repo.sh
```

### Development Quality Tools
```bash
# Lint all shell scripts with comprehensive checking
bash scripts/lint.sh

# Verify repository setup and configuration
bash scripts/verify-setup.sh

# Run comprehensive test suite
bats tests/bats/*.bats

# Install pre-commit hooks for automatic linting
cp scripts/pre-commit.sh .git/hooks/pre-commit && chmod +x .git/hooks/pre-commit
```

### CI/CD Workflow Commands
```bash
# Check GitHub Actions status
gh run list

# View specific workflow run details
gh run view [run-id]

# Re-run failed CI workflows
gh run rerun [run-id] --failed

# Create auto-merge PR
gh pr create --title "[auto-merge] Description" --body "Auto-merge eligible PR" --label "auto-merge"

# Create CI fix PR
gh pr create --title "CI: Fix build issues" --body "Automated CI fixes" --label "ci-fix"
```

### CodeRabbit Integration
```bash
# Check CodeRabbit configuration
cat .coderabbit.yml

# View automated issues created by CodeRabbit
gh issue list --label "coderabbit-created"

# Monitor CI failure issues
gh issue list --label "build failed"
```

## �📱 Termux Commands (Run in Android Emulator)

### Quick Installation
```bash
# One-command complete setup
wget -qO- https://raw.githubusercontent.com/iberi22/termux-dev-nvim-agents/main/install.sh | bash
```

### Manual Installation
```bash
# Update packages
pkg update && pkg upgrade

# Install prerequisites
pkg install curl wget git

# Download setup
wget -O setup.sh https://raw.githubusercontent.com/iberi22/termux-dev-nvim-agents/main/setup.sh

# Run setup
chmod +x setup.sh
./setup.sh
```

### Post-Installation Testing
```bash
# Test installed components
node --version
python --version
nvim --version
codex --help
gemini --version

# Run full test suite
cd ~/termux-dev-nvim-agents
./setup.sh
# Select option 8: Run Tests
```

## 🤖 AI Commands

### OpenAI Codex
```bash
codex "write a python web scraper"
codex "create a react component"
codex "debug this javascript code"
```

### Google Gemini
```bash
gemini "explain machine learning concepts"
gemini "write documentation for this code"
gemini "optimize this algorithm"
```

### Qwen Code Assistant
```bash
qwen "refactor this function"
qwen-code "generate unit tests"
```

### Neovim AI Integration
```vim
" In Neovim:
:CopilotChat explain this code
:CodeCompanion write a function
:Copilot setup
```

## 🔧 Configuration Commands

### AI Authentication Setup
```bash
# OAuth2 Authentication (Recommended)
gemini auth login      # Gemini AI via Google OAuth2
codex login           # OpenAI Codex (if available)
qwen setup           # Qwen configuration

# Legacy API Key (Optional)
echo 'export OPENAI_API_KEY="your-key-here"' >> ~/.zshrc
source ~/.zshrc
```

### Git Configuration
```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
ssh-keygen -t ed25519 -C "your.email@example.com"
```

## 📁 File Structure
```
termux-dev-nvim-agents/
├── install.sh                # Quick installer
├── setup.sh                 # Main setup script
├── Setup-TermuxAI.ps1       # Windows PowerShell automation
├── README.md                # Main documentation
├── INSTALLATION_TUTORIAL.md # Complete tutorial
├── QUICK_COMMANDS.md        # This file
└── modules/                 # Installation modules
    ├── 00-base-packages.sh
    ├── 01-zsh-setup.sh
    ├── 02-neovim-setup.sh
    ├── 03-ai-integration.sh
    ├── 04-workflows-setup.sh
    ├── 05-ssh-setup.sh
    └── test-installation.sh
```

## 🌐 URLs Reference

- **Repository**: https://github.com/iberi22/termux-dev-nvim-agents
- **Quick Install**: `wget -qO- https://raw.githubusercontent.com/iberi22/termux-dev-nvim-agents/main/install.sh | bash`
- **Manual Setup**: [raw.githubusercontent.com/iberi22/termux-dev-nvim-agents/main/setup.sh](https://raw.githubusercontent.com/iberi22/termux-dev-nvim-agents/main/setup.sh)
- **Gemini API**: https://aistudio.google.com/app/apikey
- **OpenAI API**: https://platform.openai.com/api-keys
- **Termux APK**: https://github.com/termux/termux-app/releases

## 🎯 Quick Start Checklist

- [ ] Install Android Studio + create AVD
- [ ] Download and run `Setup-TermuxAI.ps1`
- [ ] Wait for emulator to start
- [ ] Install Termux APK
- [ ] Open Termux in emulator
- [ ] Run: `wget -qO- https://raw.githubusercontent.com/iberi22/termux-dev-nvim-agents/main/install.sh | bash`
- [ ] Configure API keys (optional)
- [ ] Test AI commands
- [ ] Start coding! 🚀
