# 📱 Complete Android Emulator + Termux Installation Tutorial

## 🚀 Step-by-Step Guide: From Zero to AI Development Environment

### Prerequisites
- Windows 10/11 with Hyper-V support
- At least 8GB RAM (16GB recommended)
- 20GB free disk space
- Virtualization enabled in BIOS

---

## 📦 Part 1: Android Emulator Setup

### Option A: Android Studio Emulator (Recommended)

#### 1. Install Android Studio
```powershell
# Download Android Studio from official website
# https://developer.android.com/studio

# Or use Chocolatey
choco install androidstudio
```

#### 2. Create Android Virtual Device (AVD)
```bash
# Open Android Studio
# Go to Tools > AVD Manager
# Click "Create Virtual Device"
# Choose: Pixel 7 Pro (or similar high-spec device)
# System Image: Android 13 (API 33) or newer
# RAM: 4GB+ (8GB recommended)
# Internal Storage: 8GB+
```

#### 3. Launch Emulator
```powershell
# From command line (add Android SDK to PATH)
$env:ANDROID_HOME = "C:\Users\$env:USERNAME\AppData\Local\Android\Sdk"
$env:PATH = "$env:ANDROID_HOME\emulator;$env:ANDROID_HOME\platform-tools;$env:PATH"

# List available AVDs
emulator -list-avds

# Launch emulator (replace 'Pixel_7_Pro_API_33' with your AVD name)
emulator -avd Pixel_7_Pro_API_33
```

### Option B: BlueStacks (Alternative)

#### 1. Install BlueStacks
```powershell
# Download from https://www.bluestacks.com/
# Install with these settings:
# - RAM: 4GB+
# - CPU Cores: 4+
# - Enable Virtualization Technology
```

#### 2. Enable Developer Options
```bash
# In BlueStacks Android:
# 1. Go to Settings > About
# 2. Tap "Build number" 7 times
# 3. Go back to Settings > System > Developer options
# 4. Enable "USB debugging"
```

---

## 📱 Part 2: Termux Installation

### 1. Download Termux APK
```powershell
# Option 1: F-Droid (Recommended - always updated)
# Download F-Droid: https://f-droid.org/F-Droid.apk
# Install F-Droid in emulator
# Search and install "Termux" from F-Droid

# Option 2: Direct APK download
# Download latest Termux APK from: https://github.com/termux/termux-app/releases
Invoke-WebRequest -Uri "https://github.com/termux/termux-app/releases/latest/download/termux-app_v0.118.0+github-debug_universal.apk" -OutFile "termux.apk"
```

### 2. Install APK in Emulator
```powershell
# Using ADB (Android Debug Bridge)
adb devices  # Verify emulator is connected
adb install termux.apk

# Or drag and drop APK file into emulator window
```

### 3. Configure Termux Permissions
```bash
# In Android emulator:
# 1. Open Termux app
# 2. Grant storage permissions when prompted
# 3. Allow Termux to access device storage
```

---

## 🚀 Part 3: Termux AI Setup Installation

### Quick Installation (One Command)
```bash
# In Termux terminal, run:
wget -qO- https://raw.githubusercontent.com/iberi22/termux-dev-nvim-agents/main/install.sh | bash
```

### Manual Installation (Step by Step)
```bash
# 1. Update Termux packages
pkg update && pkg upgrade

# 2. Install essential tools
pkg install curl wget git

# 3. Download setup script
wget -O setup.sh https://raw.githubusercontent.com/iberi22/termux-dev-nvim-agents/main/setup.sh

# 4. Make executable and run
chmod +x setup.sh
./setup.sh

# 5. Select "7. 🌟 Complete Installation (Automatic)"
```

---

## ⚙️ Part 4: Configuration and Testing

### 1. Configure AI Authentication (Recommended)
```bash
# OAuth2 Authentication (Primary Method)
gemini auth login     # Gemini AI via Google OAuth2
codex login          # OpenAI Codex (if available)
qwen setup          # Qwen configuration

# Alternative: API Keys (OpenAI only)
# Get API key: https://platform.openai.com/api-keys
echo 'export OPENAI_API_KEY="your-openai-key-here"' >> ~/.zshrc
source ~/.zshrc
```

### 2. Test Installation
```bash
# Run automated tests
cd ~/termux-dev-nvim-agents
./setup.sh
# Select option 8: "🧪 Run Installation Tests"

# Test individual components
node --version    # Should show Node.js version
python --version  # Should show Python version
nvim --version    # Should show Neovim version
codex --help      # Should show OpenAI Codex help
gemini --version  # Should show Gemini CLI version
```

### 3. Verify AI Integration
```bash
# Test Neovim with AI plugins
nvim test.py

# In Neovim, try:
# :CopilotChat hello world
# :CodeCompanion explain this code

# Test CLI AI tools
codex "write a python function to sort a list"
gemini "explain machine learning basics"
```

---

## 🎮 Part 5: PowerShell Commands for Windows Host

### Android Emulator Management
```powershell
# Function to start Android emulator
function Start-AndroidEmulator {
    param([string]$AVDName = "Pixel_7_Pro_API_33")

    $env:ANDROID_HOME = "C:\Users\$env:USERNAME\AppData\Local\Android\Sdk"
    $env:PATH = "$env:ANDROID_HOME\emulator;$env:ANDROID_HOME\platform-tools;$env:PATH"

    Write-Host "🚀 Starting Android Emulator: $AVDName" -ForegroundColor Green
    emulator -avd $AVDName -gpu host -memory 4096
}

# Function to connect to Termux via ADB
function Connect-Termux {
    Write-Host "📱 Connecting to Termux..." -ForegroundColor Blue
    adb devices
    adb shell
}

# Function to install APK
function Install-APK {
    param([string]$APKPath)

    Write-Host "📦 Installing APK: $APKPath" -ForegroundColor Yellow
    adb install $APKPath
}

# Function to download latest Termux
function Get-TermuxAPK {
    $LatestRelease = Invoke-RestMethod -Uri "https://api.github.com/repos/termux/termux-app/releases/latest"
    $APKUrl = $LatestRelease.assets | Where-Object { $_.name -like "*universal.apk" } | Select-Object -First 1 -ExpandProperty browser_download_url

    Write-Host "📥 Downloading latest Termux APK..." -ForegroundColor Cyan
    Invoke-WebRequest -Uri $APKUrl -OutFile "termux-latest.apk"
    Write-Host "✅ Downloaded: termux-latest.apk" -ForegroundColor Green
}
```

### Quick Setup Commands
```powershell
# Complete setup script
function Setup-TermuxAI {
    Write-Host "🚀 Starting Complete Termux AI Setup..." -ForegroundColor Magenta

    # 1. Download Termux if not exists
    if (!(Test-Path "termux-latest.apk")) {
        Get-TermuxAPK
    }

    # 2. Start emulator
    Start-Job -ScriptBlock { Start-AndroidEmulator } -Name "AndroidEmulator"

    # 3. Wait for emulator to start
    Write-Host "⏳ Waiting for emulator to start..." -ForegroundColor Yellow
    do {
        Start-Sleep 5
        $devices = adb devices
    } while ($devices -notmatch "device$")

    # 4. Install Termux
    Install-APK "termux-latest.apk"

    Write-Host "✅ Setup complete! Now open Termux in the emulator and run:" -ForegroundColor Green
    Write-Host "wget -qO- https://raw.githubusercontent.com/iberi22/termux-dev-nvim-agents/main/install.sh | bash" -ForegroundColor Cyan
}
```

---

## 🔧 Part 6: Troubleshooting

### Common Issues and Solutions

#### 1. Emulator Won't Start
```powershell
# Check Hyper-V is enabled
Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All

# Enable if necessary (requires restart)
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All
```

#### 2. ADB Not Found
```powershell
# Add Android SDK to PATH
$AndroidSDK = "C:\Users\$env:USERNAME\AppData\Local\Android\Sdk"
[Environment]::SetEnvironmentVariable("ANDROID_HOME", $AndroidSDK, "User")
[Environment]::SetEnvironmentVariable("PATH", $env:PATH + ";$AndroidSDK\platform-tools;$AndroidSDK\emulator", "User")
```

#### 3. Termux Installation Fails
```bash
# In Termux, if wget fails:
pkg update
pkg install curl wget git

# If SSL errors:
pkg install ca-certificates
```

#### 4. AI CLIs Not Working
```bash
# Check Node.js installation
node --version
npm --version

# Reinstall if needed
pkg install nodejs npm

# Clear npm cache
npm cache clean --force
```

---

## 📊 Part 7: Performance Optimization

### Emulator Settings
```powershell
# High-performance emulator launch
function Start-HighPerformanceEmulator {
    param([string]$AVDName = "Pixel_7_Pro_API_33")

    emulator -avd $AVDName `
        -gpu host `
        -memory 8192 `
        -cores 4 `
        -accel on `
        -no-audio `
        -camera-back none `
        -camera-front none
}
```

### Termux Optimizations
```bash
# In Termux, add to ~/.zshrc for better performance
echo 'export MAKEFLAGS="-j$(nproc)"' >> ~/.zshrc
echo 'export NPM_CONFIG_JOBS=$(nproc)' >> ~/.zshrc
echo 'export PYTHONUNBUFFERED=1' >> ~/.zshrc
```

---

## 🎉 Part 8: Final Verification

### Complete Test Script
```bash
#!/bin/bash
# Run this script in Termux to verify everything works

echo "🧪 Running complete Termux AI setup verification..."

# Test basic tools
echo "📦 Testing basic tools..."
node --version && echo "✅ Node.js OK" || echo "❌ Node.js FAIL"
python --version && echo "✅ Python OK" || echo "❌ Python FAIL"
git --version && echo "✅ Git OK" || echo "❌ Git FAIL"

# Test Neovim
echo "⚡ Testing Neovim..."
nvim --version && echo "✅ Neovim OK" || echo "❌ Neovim FAIL"

# Test AI CLIs
echo "🤖 Testing AI CLIs..."
command -v codex && echo "✅ Codex CLI OK" || echo "❌ Codex CLI FAIL"
command -v gemini && echo "✅ Gemini CLI OK" || echo "❌ Gemini CLI FAIL"
command -v qwen && echo "✅ Qwen CLI OK" || echo "❌ Qwen CLI FAIL"

# Test Zsh
echo "🐚 Testing Zsh..."
zsh --version && echo "✅ Zsh OK" || echo "❌ Zsh FAIL"

echo "🎉 Verification complete!"
echo "🚀 Your Termux AI development environment is ready!"
```

---

## 🌟 Next Steps

After successful installation:

1. **Explore AI Commands:**
   ```bash
   codex "create a web scraper in python"
   gemini "explain docker concepts"
   ```

2. **Configure Neovim:**
   ```bash
   nvim ~/.config/nvim/init.lua
   # Customize your editor settings
   ```

3. **Set up Git:**
   ```bash
   git config --global user.name "Your Name"
   git config --global user.email "your.email@example.com"
   ```

4. **Start Coding:**
   ```bash
   mkdir ~/projects
   cd ~/projects
   nvim hello.py
   ```

**🎉 Congratulations! You now have a complete AI-powered development environment running on Android!**
