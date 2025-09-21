# 🚀 QUICK COMMANDS REFERENCE

## 📱 Windows PowerShell Commands

### Launch Complete Setup
```powershell
# Download and run setup script
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/iberi22/termux-dev-nvim-agents/main/termux-ai-setup/Setup-TermuxAI.ps1" -OutFile "Setup-TermuxAI.ps1"
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

## 📱 Termux Commands (Run in Android Emulator)

### Quick Installation
```bash
# One-command complete setup
wget -qO- https://raw.githubusercontent.com/iberi22/termux-dev-nvim-agents/main/termux-ai-setup/install.sh | bash
```

### Manual Installation
```bash
# Update packages
pkg update && pkg upgrade

# Install prerequisites
pkg install curl wget git

# Download setup
wget -O setup.sh https://raw.githubusercontent.com/iberi22/termux-dev-nvim-agents/main/termux-ai-setup/setup.sh

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
cd ~/termux-ai-setup
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

### API Keys Setup
```bash
# Add to ~/.zshrc
echo 'export GEMINI_API_KEY="your-key-here"' >> ~/.zshrc
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
termux-ai-setup/
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
- **Quick Install**: `wget -qO- https://raw.githubusercontent.com/iberi22/termux-dev-nvim-agents/main/termux-ai-setup/install.sh | bash`
- **Manual Setup**: https://raw.githubusercontent.com/iberi22/termux-dev-nvim-agents/main/termux-ai-setup/setup.sh
- **Gemini API**: https://aistudio.google.com/app/apikey
- **OpenAI API**: https://platform.openai.com/api-keys
- **Termux APK**: https://github.com/termux/termux-app/releases

## 🎯 Quick Start Checklist

- [ ] Install Android Studio + create AVD
- [ ] Download and run `Setup-TermuxAI.ps1`
- [ ] Wait for emulator to start
- [ ] Install Termux APK
- [ ] Open Termux in emulator
- [ ] Run: `wget -qO- https://raw.githubusercontent.com/iberi22/termux-dev-nvim-agents/main/termux-ai-setup/install.sh | bash`
- [ ] Configure API keys (optional)
- [ ] Test AI commands
- [ ] Start coding! 🚀
