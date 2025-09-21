# 🚀 Termux AI Development Environment

## Professional AI-powered development environment for Termux (Android)

## 🎯 Quick Installation

### ⚡ One-Command Install (Optimized)

```bash
pkg update && pkg install -y wget && wget -qO- https://raw.githubusercontent.com/iberi22/termux-dev-nvim-agents/main/termux-ai-setup/install.sh | bash
```

**What this does:**

1. Updates Termux repositories
2. Installs `wget` if not available
3. Downloads and runs the installation script automatically

### 🔧 Manual Installation (Alternative)

```bash
# Step 1: Install wget (if needed)
pkg update && pkg install -y wget

# Step 2: Download and run setup
wget -O setup.sh https://raw.githubusercontent.com/iberi22/termux-dev-nvim-agents/main/termux-ai-setup/setup.sh
chmod +x setup.sh
./setup.sh
```

## ✨ Features

- 🤖 **Native AI CLIs**: OpenAI Codex, Google Gemini, Qwen-code (OAuth flows)
- ⚡ **Complete Neovim**: LSP, Treesitter, AI plugins
- 🐚 **Modern Terminal**: Zsh + Oh My Zsh + Powerlevel10k


## 📦 Components

| Component | Description | Commands |
|-----------|-------------|----------|
| **Base Packages** | Git, Node.js, Python, CLI tools | Essential development tools |
| **Zsh Setup** | Oh My Zsh, themes, plugins | Modern shell experience |
| **Neovim Complete** | LSP, Treesitter, AI integration | Full-featured code editor |
| **AI Integration** | Native CLI tools for AI coding | `codex`, `gemini`, `qwen-code` |
| **Workflows** | Automated AI-powered tasks | Intelligent development flows |
| **SSH Config** | GitHub integration setup | Secure git operations |

## 🚀 Multi-Language Documentation

### 🇪🇸 Español

### Entorno de desarrollo con IA para Termux

**Instalación rápida (optimizada):**

```bash
pkg update && pkg install -y wget && wget -qO- https://raw.githubusercontent.com/iberi22/termux-dev-nvim-agents/main/termux-ai-setup/install.sh | bash
```

**Características principales:**

- CLIs nativos de IA (OpenAI Codex, Google Gemini, Qwen)
- Neovim completo con LSP y plugins de IA
- Terminal moderno con Zsh + Oh My Zsh
- Workflows de automatización inteligente
- Instalación modular y profesional

### 🇺🇸 English

### AI-powered development environment for Termux

**Quick install (optimized):**

```bash
pkg update && pkg install -y wget && wget -qO- https://raw.githubusercontent.com/iberi22/termux-dev-nvim-agents/main/termux-ai-setup/install.sh | bash
```

**Key features:**

- Native AI CLIs (OpenAI Codex, Google Gemini, Qwen)
- Complete Neovim with LSP and AI plugins
- Modern terminal with Zsh + Oh My Zsh
- Intelligent automation workflows
- Professional modular installation

### 🇧🇷 Português

### Ambiente de desenvolvimento com IA para Termux

**Instalação rápida (otimizada):**

```bash
pkg update && pkg install -y wget && wget -qO- https://raw.githubusercontent.com/iberi22/termux-dev-nvim-agents/main/termux-ai-setup/install.sh | bash
```

**Características principais:**

- CLIs nativos de IA (OpenAI Codex, Google Gemini, Qwen)
- Neovim completo com LSP e plugins de IA
- Terminal moderno com Zsh + Oh My Zsh
- Workflows de automação inteligente
- Instalação modular e profissional

## 🎮 Interactive Menu

After installation, use the interactive menu:

```text
┌─────────────────────────────────────────────────┐
│                  MAIN MENU                      │
├─────────────────────────────────────────────────┤
│  1. 📦 Install Base Packages                   │
│  2. 🐚 Configure Zsh + Oh My Zsh               │
│  3. ⚡ Install and Configure Neovim            │
│  4. 🔐 Configure SSH for GitHub                │
│  5. 🤖 Configure AI Integration                │
│  6. 🔄 Configure AI Workflows                  │
│  7. 🖋️  Install Nerd Fonts + Set Font         │
│  8. 🌟 Complete Installation (Automatic)       │
│  9. 🧪 Run Installation Tests                  │
│ 10. 🧹 Clean and Reinstall from Scratch        │
│  0. 🚪 Exit                                     │
└─────────────────────────────────────────────────┘
```

## 🤖 AI Commands

After installation, access these AI-powered commands:

```bash
# OpenAI Codex (OAuth login)
codex login
codex

# Google Gemini CLI (OAuth login)
gemini

# Qwen Code Assistant
qwen

# Neovim with AI plugins
nvim
```

## 📁 Project Structure

```text
termux-ai-setup/
├── install.sh              # Quick installer script
├── setup.sh                # Main interactive setup
├── modules/                 # Installation modules
│   ├── 00-base-packages.sh  # Essential tools
│   ├── 01-zsh-setup.sh      # Zsh configuration
│   ├── 02-neovim-setup.sh   # Neovim + plugins
│   ├── 03-ai-integration.sh # AI CLIs setup
│   ├── 04-workflows-setup.sh# AI workflows
│   ├── 05-ssh-setup.sh      # SSH/GitHub config
│   ├── 06-fonts-setup.sh    # Nerd Fonts installer & selector
│   └── test-installation.sh # Automated tests
└── config/                  # Configuration files
    └── neovim/              # Neovim configs
        └── lua/plugins/     # Plugin configurations
```

## 🔧 Requirements

- **Android device** with Termux installed
- **Internet connection** for downloads
- **4GB+ RAM** recommended for full features
- **Storage space**: ~2GB for complete installation
- A web browser in Android for OAuth login flows

## ⚙️ Configuration

### API Keys (Optional)

```bash
# Google Gemini API (optional – use OAuth by default)
export GEMINI_API_KEY="your-api-key-here"

# OpenAI API (optional – use OAuth ChatGPT login)
export OPENAI_API_KEY="your-api-key-here"

Note: By default, both Codex and Gemini CLIs support OAuth interactive login. API keys are optional.
```

### Get API Keys

- **Gemini API**: <https://aistudio.google.com/app/apikey>
- **OpenAI API**: <https://platform.openai.com/api-keys>

## 🧪 Testing

Run automated tests to verify installation:

```bash
cd ~/termux-ai-setup
./setup.sh
# Select option 8: Run Installation Tests
```

## 🔍 Troubleshooting

### Common Issues

#### 1. Permission denied

```bash
chmod +x setup.sh
chmod +x install.sh
```

#### 2. Network issues

```bash
# Check internet connection
ping google.com

# Update Termux packages
pkg update && pkg upgrade
```

#### 3. Installation fails

```bash
# Run individual modules
cd ~/termux-ai-setup
./setup.sh
# Select specific module from menu
```

#### 4. AI CLIs not working

```bash
# Check Node.js installation
node --version
npm --version

# Reinstall AI integration
./setup.sh
# Select option 5: Configure AI Integration
```

## 🧹 Clean and Reinstall

If your environment is in a broken state and you want a fresh start:

```bash
cd ~/termux-ai-setup
./setup.sh
# Select option 10: Clean and Reinstall from Scratch
```

This will:

- Remove Neovim configs and caches
- Remove AI workflows and ai-* wrappers
- Uninstall AI CLIs (codex, gemini, qwen) globally from npm
- Remove Termux custom font
- Optionally remove Zsh/Oh My Zsh and SSH keys
- Offer to run a full reinstall automatically

## 📊 Installation Stats

- **⏱️ Install time**: 5-15 minutes (depending on internet)
- **💾 Disk usage**: ~2GB total
- **🔧 Components**: 50+ packages and tools
- **🤖 AI CLIs**: 3 native integrations
- **⚡ Neovim plugins**: 25+ configured
- **🧪 Tests**: 20+ automated checks
- **🖋️ Fonts**: FiraCode Nerd Font Mono as default (customizable)

## 🌟 What's Included

### Development Tools

- Git, Node.js, Python, GCC/Clang
- Modern CLI tools (ripgrep, fd, fzf, bat)
- Package managers (npm, pip)

### Terminal Experience

- Zsh with Oh My Zsh
- Powerlevel10k theme
- Smart autocompletion
- Syntax highlighting

### Code Editor

- Neovim with Lazy.nvim
- LSP support for multiple languages
- Treesitter syntax highlighting
- AI-powered coding assistance

### AI Integration

- OpenAI Codex CLI
- Google Gemini CLI
- Qwen Code Assistant
- GitHub Copilot integration

### Fonts (Nerd Fonts)

- Default terminal and Neovim font: FiraCode Nerd Font Mono
- Change font anytime from setup menu → option "Install Nerd Fonts + Set Font"
- Included top fonts: FiraCode, JetBrainsMono, Hack, CascadiaCode, SourceCodePro, Meslo, UbuntuMono, Mononoki, VictorMono, Iosevka

## 🤝 Contributing

This project welcomes contributions! Areas for improvement:

- Additional AI CLI integrations
- More language server protocols
- Enhanced automation scripts
- Better error handling
- Documentation improvements

## 📄 License

MIT License - feel free to modify and distribute.

## 🙏 Acknowledgments

Built with modern tools and inspired by the developer community:

- **Termux team** for Android Linux environment
- **Neovim community** for the amazing editor
- **Oh My Zsh** for shell improvements
- **AI providers** for development assistance APIs

---

**🚀 Transform your Android device into a powerful AI development environment!**

**Quick start:** `wget -qO- https://raw.githubusercontent.com/iberi22/termux-dev-nvim-agents/main/termux-ai-setup/install.sh | bash`
