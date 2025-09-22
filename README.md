# 🚀 Termux AI Development Environment

[![CI](https://github.com/iberi22/termux-dev-nvim-agents/actions/workflows/ci.yml/badge.svg)](https://github.com/iberi22/termux-dev-nvim-agents/actions/workflows/ci.yml)

## Professional AI-powered development environment for Termux (Android)

## 🎯 Quick Installation

### ⚡ One-Command Install (Optimized)

```bash
termux-setup-storage && pkg update && pkg install -y wget && wget -qO- https://raw.githubusercontent.com/iberi22/termux-dev-nvim-agents/main/install.sh | bash
```

**What this does:**

1. **Sets up storage permissions** (required for file operations)
2. Updates Termux repositories
3. Installs `wget` if not available
4. Downloads and runs the installation script automatically

> **Note:** The `termux-setup-storage` command will request Android storage permissions. Accept when prompted to ensure proper functionality.

### 🔧 Manual Installation (Alternative)

```bash
# Step 1: Install wget (if needed)
pkg update && pkg install -y wget

# Step 2: Set up storage permissions and download complete setup
termux-setup-storage && wget -qO- https://raw.githubusercontent.com/iberi22/termux-dev-nvim-agents/main/install.sh | bash

# Alternative: Download and run setup manually (not recommended)
# wget -O setup.sh https://raw.githubusercontent.com/iberi22/termux-dev-nvim-agents/main/setup.sh
# chmod +x setup.sh
# ./setup.sh
```

### Local SSH/SFTP Access (LAN)

```bash
cd ~/termux-dev-nvim-agents
./setup.sh   # choose option 5 "Enable Local SSH/SFTP Access"
# or run the module directly
bash modules/07-local-ssh-server.sh
```

The module configures a persistent SSH service on port 8022, updates `sshd_config`, and installs helper commands so you can connect from any machine on your network:

```bash
ssh-local-info   # connection summary (user, IP, commands)
ssh-local-start  # start the daemon manually
ssh-local-stop   # stop the daemon
```

These commands are available immediately after running the module because we symlink them into `$PREFIX/bin` and persist `$HOME/bin` in your PATH for future sessions.

From your computer connect with:

```bash
ssh -p 8022 <termux-user>@<device-ip>
```

WinSCP / SFTP: protocol `SFTP`, host `<device-ip>`, port `8022`, user `<termux-user>` plus your password or SSH key.

Troubleshooting if helpers are not found:

- Open a new Termux session (or run `exec $SHELL`) to reload PATH.
- Ensure `$PREFIX/bin` and `$HOME/bin` are in PATH: `echo $PATH`.
- Re-run the module: `bash modules/07-local-ssh-server.sh`.

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
termux-setup-storage && pkg update && pkg install -y wget && wget -qO- https://raw.githubusercontent.com/iberi22/termux-dev-nvim-agents/main/install.sh | bash
```

> **Nota:** El comando `termux-setup-storage` solicitará permisos de almacenamiento de Android. Acepta cuando se te solicite.

**Características principales:**

- CLIs nativos de IA (OpenAI Codex, Google Gemini, Qwen)
- Neovim completo con LSP y plugins de IA
- Terminal moderno con Zsh + Oh My Zsh
- Workflows de automatización inteligente
- Instalación modular y profesional

### Acceso remoto (SSH/SFTP)

```bash
cd ~/termux-dev-nvim-agents
./setup.sh   # selecciona la opción 5 "Enable Local SSH/SFTP Access"
# o ejecuta el módulo directamente
bash modules/07-local-ssh-server.sh
```

El módulo levanta un servicio persistente en el puerto 8022, actualiza `sshd_config` y crea comandos auxiliares (`ssh-local-info`, `ssh-local-start`, `ssh-local-stop`) para conectarte desde tu PC o WinSCP.

Para conectarte desde otro equipo usa:

```bash
ssh -p 8022 <usuario-termux>@<ip-del-dispositivo>
```

En WinSCP selecciona protocolo `SFTP`, host `<ip-del-dispositivo>`, puerto `8022` y tus credenciales de Termux (contraseña o llave pública).

Si los comandos auxiliares no aparecen inmediatamente:

- Abre una nueva sesión de Termux (o ejecuta `exec $SHELL`) para recargar el PATH.
- Verifica que `$PREFIX/bin` y `$HOME/bin` estén en tu PATH: `echo $PATH`.
- Vuelve a ejecutar el módulo: `bash modules/07-local-ssh-server.sh`.

### 🇺🇸 English

### AI-powered development environment for Termux

**Quick install (optimized):**

```bash
termux-setup-storage && pkg update && pkg install -y wget && wget -qO- https://raw.githubusercontent.com/iberi22/termux-dev-nvim-agents/main/install.sh | bash
```

> **Note:** The `termux-setup-storage` command will request Android storage permissions. Accept when prompted.

**Key features:**

- Native AI CLIs (OpenAI Codex, Google Gemini, Qwen)
- Complete Neovim with LSP and AI plugins
- Modern terminal with Zsh + Oh My Zsh
- Intelligent automation workflows
- Professional modular installation

### Acesso remoto (SSH/SFTP)

```bash
cd ~/termux-dev-nvim-agents
./setup.sh   # escolha a opção 5 "Enable Local SSH/SFTP Access"
# ou execute o módulo diretamente
bash modules/07-local-ssh-server.sh
```

O módulo cria um serviço no porto 8022, ajusta o `sshd_config` e gera scripts (`ssh-local-info`, `ssh-local-start`, `ssh-local-stop`) para facilitar o acesso via SSH ou WinSCP.

Conexão a partir do seu computador:

```bash
ssh -p 8022 <usuario-termux>@<ip-do-dispositivo>
```

No WinSCP selecione protocolo `SFTP`, host `<ip-do-dispositivo>`, porta `8022` e suas credenciais do Termux.

Se os comandos auxiliares não aparecerem imediatamente:

- Abra uma nova sessão do Termux (ou execute `exec $SHELL`) para recarregar o PATH.
- Verifique se `$PREFIX/bin` e `$HOME/bin` estão no PATH: `echo $PATH`.
- Rode novamente o módulo: `bash modules/07-local-ssh-server.sh`.

### 🇧🇷 Português

### Ambiente de desenvolvimento com IA para Termux

**Instalação rápida (otimizada):**

```bash
termux-setup-storage && pkg update && pkg install -y wget && wget -qO- https://raw.githubusercontent.com/iberi22/termux-dev-nvim-agents/main/install.sh | bash
```

> **Nota:** O comando `termux-setup-storage` solicitará permissões de armazenamento do Android. Aceite quando solicitado.

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
termux-dev-nvim-agents/
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
cd ~/termux-dev-nvim-agents
./setup.sh
# Select option 8: Run Installation Tests
```

## 🔍 Troubleshooting

### 🩺 Quick Diagnosis

First, run the diagnostic tool to identify issues:

```bash
cd ~/termux-dev-nvim-agents
./diagnose.sh
```

This will check for:

- Correct directory location
- Missing or corrupted files
- System requirements
- Network connectivity

### Common Issues

#### 1. Module not found errors

```bash
# Ensure you're in the correct directory
cd ~/termux-dev-nvim-agents

# Run diagnostics
./diagnose.sh

# If files are missing, re-run installer
wget -qO- https://raw.githubusercontent.com/iberi22/termux-dev-nvim-agents/main/install.sh | bash
```

#### 2. Permission denied

```bash
# Fix permissions for all scripts
cd ~/termux-dev-nvim-agents
chmod +x setup.sh diagnose.sh
chmod +x modules/*.sh
```

#### 3. Network issues

```bash
# Check internet connection
ping google.com

# Update Termux packages
pkg update && pkg upgrade
```

#### 4. Installation fails

```bash
# Run diagnostics first
cd ~/termux-dev-nvim-agents
./diagnose.sh

# Run individual modules
./setup.sh
# Select specific module from menu
```

#### 5. AI CLIs not working

```bash
# Check Node.js installation
node --version
npm --version

# Reinstall AI integration
cd ~/termux-dev-nvim-agents
./setup.sh
# Select option 5: Configure AI Integration
```

## 🧹 Clean and Reinstall

If your environment is in a broken state and you want a fresh start:

```bash
cd ~/termux-dev-nvim-agents
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

## 🔄 CI/CD & Development Automation

This repository includes comprehensive DevOps automation for professional development workflows:

### 🤖 Automated CI/CD Pipeline

- **GitHub Actions CI**: Automated linting, testing, and quality checks
- **Auto-Issue Creation**: Automatic GitHub issues on CI failures (main branch)
- **CodeRabbit Integration**: AI-powered code reviews and issue creation (free for open source)
- **Auto-Merge**: Automatic PR merging when CI passes and labels match
- **Comprehensive Testing**: Bats framework for shell script testing

### 🛠️ Local Development Tools

- **ShellCheck Integration**: Robust shell script linting with custom config
- **Pre-commit Hooks**: Automatic linting before commits
- **Local Lint Script**: `bash scripts/lint.sh` for comprehensive code quality
- **Setup Verification**: `bash scripts/verify-setup.sh` for environment validation

### 📋 Repository Setup

**Quick Setup (after cloning):**

```bash
bash scripts/setup-repo.sh
```

**Manual Setup Steps:**

1. **Enable CodeRabbit**: Visit [coderabbit.ai](https://app.coderabbit.ai/login) and install for this repo (free for open source)
2. **Configure Branch Protection**: Set up branch protection rules requiring CI checks
3. **Install Local Tools**: Run `bash scripts/lint.sh` and set up pre-commit hooks
4. **Verify Setup**: Run `bash scripts/verify-setup.sh` to check configuration

**Development Commands:**

```bash
# Lint all shell scripts
bash scripts/lint.sh

# Run comprehensive tests
bats tests/bats/*.bats

# Verify repository setup
bash scripts/verify-setup.sh

# Full repository configuration
bash scripts/setup-repo.sh
```

### 🏗️ CI/CD Features

- ✅ **Automated Issue Creation**: CI failures automatically create detailed GitHub issues
- 🤖 **CodeRabbit Reviews**: AI-powered PR reviews with shell script expertise
- 🔒 **Quality Gates**: ShellCheck, syntax validation, and comprehensive testing
- 🚀 **Auto-Deployment**: Passing PRs automatically merge with proper labeling
- 📊 **Test Coverage**: Bats framework ensures comprehensive shell script testing
- 🔧 **Local Tools**: Pre-commit hooks and local linting for developer productivity

## 🤝 Contributing

This project welcomes contributions! The automated CI/CD pipeline ensures code quality:

**Development Workflow:**

1. Fork and clone the repository
2. Run `bash scripts/setup-repo.sh` for full environment setup
3. Make changes and test locally with `bash scripts/lint.sh`
4. Create PR - CodeRabbit will automatically review
5. CI pipeline validates changes and auto-merges when approved

**Areas for Improvement:**

- Additional AI CLI integrations
- More language server protocols
- Enhanced automation scripts
- Better error handling
- Documentation improvements
- Extended test coverage

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

**Quick start:** `termux-setup-storage && pkg update && pkg install -y wget && wget -qO- https://raw.githubusercontent.com/iberi22/termux-dev-nvim-agents/main/install.sh | bash`
