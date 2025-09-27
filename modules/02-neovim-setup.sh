#!/bin/bash

# =================================================================
# MODULE: 02-NEOVIM-SETUP
#
# Installs and configures a complete Neovim IDE setup for AI
# development, based on Lazy.nvim.
#
# This script is idempotent. It will not run if an existing
# Neovim configuration is detected, to prevent overwriting.
# =================================================================

# --- Source Helper Functions ---
# shellcheck disable=SC1091
source "$(dirname "$0")/../scripts/helpers.sh"

# --- Constants ---
readonly NVIM_CONFIG_DIR="$HOME/.config/nvim"
readonly NVIM_INIT_FILE="${NVIM_CONFIG_DIR}/init.lua"
readonly AI_ENV_FILE="$HOME/.ai-env"
readonly SHELL_CONFIG_MARKER="# --- Load AI Environment ---"

# --- Functions ---

# Checks if Neovim is installed.
check_neovim_installed() {
    log_info "Verificando la instalación de Neovim..."
    if ! command -v nvim >/dev/null 2>&1; then
        log_error "Neovim no está instalado. Por favor, asegúrate de que '00-base-packages.sh' se haya ejecutado correctamente."
        exit 1
    fi
    log_success "Neovim está instalado."
}

# Sets up the .ai-env file for API keys and provider configuration.
setup_ai_environment_file() {
    log_info "Configurando el archivo de entorno de IA (.ai-env)..."
    if [[ -f "$AI_ENV_FILE" ]]; then
        log_success "El archivo '${AI_ENV_FILE}' ya existe. Omitiendo."
        return
    fi

    log_info "Creando un nuevo archivo '${AI_ENV_FILE}'..."
    cat > "$AI_ENV_FILE" << 'EOF'
# AI Environment Configuration
# Use 'gemini auth login' for Gemini CLI (OAuth2). API keys are optional.
CURRENT_AI_PROVIDER="gemini-cli"
OPENAI_API_KEY=""
ANTHROPIC_API_KEY=""
EOF
    log_success "Archivo '${AI_ENV_FILE}' creado. Edítalo para añadir tus API keys si las necesitas."
}

# Ensures the shell profiles source the .ai-env file.
ensure_ai_env_sourcing() {
    log_info "Asegurando que los perfiles de la shell carguen '.ai-env'..."
    local source_line="[[ -f \"$AI_ENV_FILE\" ]] && source \"$AI_ENV_FILE\""

    local shell_profiles=("$HOME/.bashrc" "$HOME/.zshrc")
    for profile in "${shell_profiles[@]}"; do
        if [[ -f "$profile" ]]; then
            if ! grep -qF -- "$SHELL_CONFIG_MARKER" "$profile"; then
                log_info "Añadiendo la carga de '.ai-env' a '$profile'..."
                echo -e "\n${SHELL_CONFIG_MARKER}\n${source_line}\n" >> "$profile"
                log_success "Configuración añadida a '$profile'."
            else
                log_success "La carga de '.ai-env' ya está configurada en '$profile'."
            fi
        fi
    done
}

# Creates the entire Neovim configuration directory structure and files.
create_nvim_config_files() {
    log_info "Creando la estructura de directorios y archivos de configuración de Neovim..."
    mkdir -p "${NVIM_CONFIG_DIR}/lua/config"
    mkdir -p "${NVIM_CONFIG_DIR}/lua/plugins"

    # --- Create init.lua ---
    cat > "${NVIM_CONFIG_DIR}/init.lua" << 'EOF'
-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)
-- Load basic options and keymaps first
require("config.options")
require("config.keymaps")
-- Setup Lazy with all plugins
require("lazy").setup({ spec = { { import = "plugins" } } })
EOF
    log_success "init.lua creado."

    # --- Create config/options.lua ---
    cat > "${NVIM_CONFIG_DIR}/lua/config/options.lua" << 'EOF'
-- Basic Neovim options
local opt = vim.opt
opt.autowrite = true
opt.clipboard = "unnamedplus"
opt.completeopt = "menu,menuone,noselect"
opt.cursorline = true
opt.expandtab = true
opt.ignorecase = true
opt.inccommand = "nosplit"
opt.laststatus = 3
opt.list = true
opt.mouse = "a"
opt.number = true
opt.relativenumber = true
opt.scrolloff = 8
opt.shiftwidth = 2
opt.sidescrolloff = 8
opt.signcolumn = "yes"
opt.smartcase = true
opt.smartindent = true
opt.splitbelow = true
opt.splitright = true
opt.tabstop = 2
opt.termguicolors = true
opt.timeoutlen = 300
opt.undofile = true
opt.wrap = false
if vim.fn.has("termux") == 1 then
  opt.shell = "/data/data/com.termux/files/usr/bin/zsh"
end
opt.fillchars = { eob = " " }
opt.lazyredraw = true
EOF
    log_success "config/options.lua creado."

    # --- Create config/keymaps.lua ---
    cat > "${NVIM_CONFIG_DIR}/lua/config/keymaps.lua" << 'EOF'
-- Basic Keymaps
local keymap = vim.keymap
local opts = { noremap = true, silent = true }
vim.g.mapleader = " "
-- Window navigation
keymap.set("n", "<C-h>", "<C-w>h", opts)
keymap.set("n", "<C-j>", "<C-w>j", opts)
keymap.set("n", "<C-k>", "<C-w>k", opts)
keymap.set("n", "<C-l>", "<C-w>l", opts)
-- Buffer navigation
keymap.set("n", "<S-l>", ":bnext<CR>", opts)
keymap.set("n", "<S-h>", ":bprevious<CR>", opts)
keymap.set("n", "<leader>bd", ":bdelete<CR>", opts)
-- Save
keymap.set("n", "<C-s>", ":w<CR>", opts)
keymap.set("i", "<C-s>", "<Esc>:w<CR>a", opts)
EOF
    log_success "config/keymaps.lua creado."

    # --- Create plugins/ (a minimal set) ---
    cat > "${NVIM_CONFIG_DIR}/lua/plugins/theme.lua" << 'EOF'
return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      require("catppuccin").setup({ flavour = "mocha" })
      vim.cmd.colorscheme("catppuccin")
    end,
  },
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({ options = { theme = "catppuccin" } })
    end,
  },
}
EOF
    log_success "plugins/theme.lua creado."

    cat > "${NVIM_CONFIG_DIR}/lua/plugins/lsp.lua" << 'EOF'
return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp", -- Added missing dependency
    },
    config = function()
      local lspconfig = require("lspconfig")
      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      require("mason").setup()
      require("mason-lspconfig").setup({
        ensure_installed = { "lua_ls", "pyright" },
        handlers = {
          function(server_name)
            lspconfig[server_name].setup({ capabilities = capabilities })
          end,
        },
      })
    end,
  },
  {
    "hrsh7th/nvim-cmp",
    dependencies = { "hrsh7th/cmp-nvim-lsp", "hrsh7th/cmp-buffer", "L3MON4D3/LuaSnip" },
  },
}
EOF
    log_success "plugins/lsp.lua creado."
}

# Installs tools required by Neovim plugins.
install_neovim_tools() {
    log_info "Instalando herramientas externas para Neovim (linters, formatters)..."
    if command -v npm >/dev/null 2>&1; then
        npm install -g typescript typescript-language-server @biomejs/biome
    else
        log_warn "npm no encontrado, omitiendo la instalación de herramientas de JS/TS."
    fi

    if command -v pip >/dev/null 2>&1; then
        pip install black isort flake8 mypy
    else
        log_warn "pip no encontrado, omitiendo la instalación de herramientas de Python."
    fi
    log_success "Herramientas externas procesadas."
}


# --- Main Function ---
main() {
    log_info "=== Iniciando Módulo: Configuración de Neovim ==="

    check_neovim_installed

    # Idempotency Check: If config exists, stop.
    if [[ -f "$NVIM_INIT_FILE" ]]; then
        log_warn "Se ha detectado una configuración de Neovim existente en '${NVIM_INIT_FILE}'."
        log_warn "El módulo se omitirá para evitar sobreescribir tus archivos."
        log_info "Si deseas una instalación limpia, elimina el directorio '${NVIM_CONFIG_DIR}' y vuelve a ejecutar este script."
        log_info "=== Módulo de Configuración de Neovim Omitido ==="
        return
    fi

    setup_ai_environment_file
    ensure_ai_env_sourcing
    create_nvim_config_files
    install_neovim_tools

    log_info "Sincronizando plugins de Neovim por primera vez... (esto puede tardar un momento)"
    if nvim --headless "+Lazy! sync" +qa; then
        log_success "Sincronización de plugins de Neovim completada."
    else
        log_error "Ocurrió un error durante la sincronización de plugins de Neovim."
        log_warn "Puedes intentar solucionarlo ejecutando 'nvim' y luego ':Lazy sync'."
    fi

    log_info "=== Módulo de Configuración de Neovim Completado ==="
}

# --- Execute Main Function ---
main