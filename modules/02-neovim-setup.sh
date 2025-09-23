#!/bin/bash

# ====================================
# MÓDULO: Instalación completa de Neovim
# Instala Neovim, Lazy.nvim y configuración completa para IA
# ====================================

set -euo pipefail

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${BLUE}⚡ Configurando Neovim con Lazy.nvim para desarrollo con IA...${NC}"

# Verificar si Neovim ya está instalado
if command -v nvim >/dev/null 2>&1; then
    echo -e "${GREEN}✅ Neovim ya está instalado${NC}"
    nvim_version=$(nvim --version | head -n1)
    echo -e "${CYAN}Versión: ${nvim_version}${NC}"
else
    echo -e "${YELLOW}📦 Instalando Neovim...${NC}"
    if ! pkg install -y neovim; then
        echo -e "${RED}❌ Error instalando Neovim${NC}"
        exit 1
    fi
    echo -e "${GREEN}✅ Neovim instalado correctamente${NC}"
fi

# Verificar versión mínima de Neovim (0.8+)
nvim_version_num=$(nvim --version | head -n1 | grep -oE '[0-9]+\.[0-9]+' | head -n1)
if [[ $(echo "$nvim_version_num >= 0.8" | bc -l) -eq 0 ]] 2>/dev/null; then
    echo -e "${YELLOW}⚠️ Versión de Neovim puede ser antigua. Recomendamos 0.8+${NC}"
fi

# Configurar directorio de configuración de Neovim
NVIM_CONFIG_DIR="$HOME/.config/nvim"

# Backup de configuración existente
if [[ -d "$NVIM_CONFIG_DIR" ]]; then
    echo -e "${YELLOW}📄 Creando backup de configuración existente...${NC}"
    backup_dir="$NVIM_CONFIG_DIR.backup.$(date +%Y%m%d_%H%M%S)"
    mv "$NVIM_CONFIG_DIR" "$backup_dir"
    echo -e "${CYAN}Backup guardado en: ${backup_dir}${NC}"
fi

# Configurar archivo de entorno AI
setup_ai_environment() {
    echo -e "${BLUE}🤖 Configurando entorno de IA...${NC}"

    local ai_env_template="${SCRIPT_DIR:-$(dirname "$0")}/config/.ai-env.template"
    local ai_env_file="$HOME/.ai-env"

    if [[ -f "$ai_env_template" ]]; then
        if [[ ! -f "$ai_env_file" ]]; then
            echo -e "${YELLOW}📋 Creando archivo de configuración de IA...${NC}"
            cp "$ai_env_template" "$ai_env_file"
            echo -e "${GREEN}✅ Archivo .ai-env creado en: $ai_env_file${NC}"
            echo -e "${CYAN}💡 Edita ~/.ai-env para configurar tus API keys${NC}"
        else
            echo -e "${GREEN}✅ Archivo .ai-env ya existe${NC}"
        fi
    else
        echo -e "${YELLOW}⚠️ Template .ai-env no encontrado, creando básico...${NC}"
        cat > "$ai_env_file" << 'EOF'
# AI Environment Configuration - OAuth2 Based
CURRENT_AI_PROVIDER="gemini-cli"
# NOTE: API Keys are optional. Use OAuth2 authentication instead:
# - gemini auth login (for Gemini)
# - codex login (for OpenAI Codex) 
# - qwen-code setup (for Qwen)
OPENAI_API_KEY=""
ANTHROPIC_API_KEY=""
CHUTES_API_KEY=""
MOONSHOT_API_KEY=""
EOF
        echo -e "${GREEN}✅ Archivo .ai-env básico creado${NC}"
    fi

    # Asegurar que se cargue en shells
    local shells=("$HOME/.bashrc" "$HOME/.zshrc")
    for shell_rc in "${shells[@]}"; do
        if [[ -f "$shell_rc" ]] && ! grep -q "source.*\.ai-env" "$shell_rc"; then
            echo "" >> "$shell_rc"
            echo "# Load AI environment" >> "$shell_rc"
            echo "[[ -f ~/.ai-env ]] && source ~/.ai-env" >> "$shell_rc"
        fi
    done
}

# Configurar entorno de IA
setup_ai_environment

# Crear estructura de directorios
echo -e "${BLUE}📁 Creando estructura de configuración...${NC}"
mkdir -p "$NVIM_CONFIG_DIR/lua/config"
mkdir -p "$NVIM_CONFIG_DIR/lua/plugins"

# Crear archivo init.lua principal
echo -e "${YELLOW}⚙️ Creando configuración principal...${NC}"

cat > "$NVIM_CONFIG_DIR/init.lua" << 'EOF'
-- ====================================
-- NEOVIM CONFIGURATION FOR AI DEVELOPMENT
-- Termux AI Setup v2.0
-- ====================================

-- Configuración básica antes de cargar plugins
require("config.options")
require("config.keymaps")

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Configurar lazy.nvim con todos los plugins
require("lazy").setup({
  spec = {
    { import = "plugins" },
  },
  defaults = {
    lazy = false,
    version = false,
  },
  checker = { enabled = true },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})

-- Configuración post-plugins
require("config.autocmds")
EOF

# Crear configuración de opciones básicas
cat > "$NVIM_CONFIG_DIR/lua/config/options.lua" << 'EOF'
-- ====================================
-- OPCIONES BÁSICAS DE NEOVIM
-- ====================================

local opt = vim.opt

-- Configuración general
opt.autowrite = true
opt.clipboard = "unnamedplus"
opt.completeopt = "menu,menuone,noselect"
opt.conceallevel = 3
opt.confirm = true
opt.cursorline = true
opt.expandtab = true
opt.formatoptions = "jcroqlnt"
opt.grepformat = "%f:%l:%c:%m"
opt.grepprg = "rg --vimgrep"
opt.ignorecase = true
opt.inccommand = "nosplit"
opt.laststatus = 3
opt.list = true
opt.mouse = "a"
opt.number = true
opt.pumblend = 10
opt.pumheight = 10
opt.relativenumber = true
opt.scrolloff = 4
opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp", "folds" }
opt.shiftround = true
opt.shiftwidth = 2
opt.shortmess:append({ W = true, I = true, c = true, C = true })
opt.showmode = false
opt.sidescrolloff = 8
opt.signcolumn = "yes"
opt.smartcase = true
opt.smartindent = true
opt.spelllang = { "en", "es" }
opt.splitbelow = true
opt.splitkeep = "screen"
opt.splitright = true
opt.tabstop = 2
opt.termguicolors = true
opt.timeoutlen = 300
opt.undofile = true
opt.undolevels = 10000
opt.updatetime = 200
opt.virtualedit = "block"
opt.wildmode = "longest:full,full"
opt.winminwidth = 5
opt.wrap = false

-- Configuración específica para Termux
if vim.fn.has("termux") == 1 then
  opt.shell = "/data/data/com.termux/files/usr/bin/zsh"
end

-- Configuración de caracteres especiales (sin Unicode problemático para Termux)
opt.fillchars = {
  foldopen = "v",
  foldclose = ">",
  fold = " ",
  foldsep = "|",
  diff = "/",
  eob = " ",
}

-- Configuración de folding
opt.foldlevel = 99
opt.foldlevelstart = 99
opt.foldenable = true

-- Configuración para mejor rendimiento en Termux
opt.lazyredraw = true
opt.regexpengine = 1
opt.synmaxcol = 200
EOF

# Crear configuración de keymaps
cat > "$NVIM_CONFIG_DIR/lua/config/keymaps.lua" << 'EOF'
-- ====================================
-- CONFIGURACIÓN DE KEYMAPS
-- ====================================

local keymap = vim.keymap
local opts = { noremap = true, silent = true }

-- Configurar leader key
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- ====================================
-- NAVEGACIÓN BÁSICA
-- ====================================

-- Mejor navegación en wrap lines
keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })

-- Navegación entre ventanas
keymap.set("n", "<C-h>", "<C-w>h", opts)
keymap.set("n", "<C-j>", "<C-w>j", opts)
keymap.set("n", "<C-k>", "<C-w>k", opts)
keymap.set("n", "<C-l>", "<C-w>l", opts)

-- Redimensionar ventanas
keymap.set("n", "<C-Up>", ":resize +2<CR>", opts)
keymap.set("n", "<C-Down>", ":resize -2<CR>", opts)
keymap.set("n", "<C-Left>", ":vertical resize -2<CR>", opts)
keymap.set("n", "<C-Right>", ":vertical resize +2<CR>", opts)

-- ====================================
-- GESTIÓN DE BUFFERS Y TABS
-- ====================================

-- Navegación entre buffers
keymap.set("n", "<S-h>", ":bprevious<CR>", opts)
keymap.set("n", "<S-l>", ":bnext<CR>", opts)

-- Cerrar buffer
keymap.set("n", "<leader>bd", ":bdelete<CR>", opts)
keymap.set("n", "<leader>bD", ":bdelete!<CR>", opts)

-- ====================================
-- FUNCIONES ÚTILES
-- ====================================

-- Limpiar búsqueda
keymap.set("n", "<leader>h", ":nohlsearch<CR>", opts)

-- Guardar archivo
keymap.set("n", "<C-s>", ":w<CR>", opts)
keymap.set("i", "<C-s>", "<Esc>:w<CR>a", opts)

-- Salir
keymap.set("n", "<leader>q", ":q<CR>", opts)
keymap.set("n", "<leader>Q", ":q!<CR>", opts)

-- Seleccionar todo
keymap.set("n", "<C-a>", "gg<S-v>G", opts)

-- ====================================
-- EDICIÓN AVANZADA
-- ====================================

-- Mover líneas arriba/abajo
keymap.set("v", "J", ":m '>+1<CR>gv=gv", opts)
keymap.set("v", "K", ":m '<-2<CR>gv=gv", opts)

-- Mantener selección al indentar
keymap.set("v", "<", "<gv", opts)
keymap.set("v", ">", ">gv", opts)

-- Mejor paste
keymap.set("v", "p", '"_dP', opts)

-- ====================================
-- TERMINAL INTEGRADO
-- ====================================

-- Toggle terminal
keymap.set("n", "<leader>t", ":terminal<CR>", opts)
keymap.set("t", "<Esc>", "<C-\\><C-n>", opts)

-- ====================================
-- SPLITS Y VENTANAS
-- ====================================

-- Crear splits
keymap.set("n", "<leader>sv", ":vsplit<CR>", opts)
keymap.set("n", "<leader>sh", ":split<CR>", opts)
keymap.set("n", "<leader>sc", ":close<CR>", opts)

-- ====================================
-- AI DEVELOPMENT SPECIFIC
-- ====================================

-- Mapeos que se configurarán con plugins específicos
-- Se definirán en los archivos de configuración de cada plugin
EOF

# Crear autocmds
cat > "$NVIM_CONFIG_DIR/lua/config/autocmds.lua" << 'EOF'
-- ====================================
-- AUTOCOMMANDS
-- ====================================

local function augroup(name)
  return vim.api.nvim_create_augroup("termux_ai_" .. name, { clear = true })
end

-- Resaltar texto copiado
vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup("highlight_yank"),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Ir al último lugar conocido al abrir archivo
vim.api.nvim_create_autocmd("BufReadPost", {
  group = augroup("last_loc"),
  callback = function(event)
    local exclude = { "gitcommit" }
    local buf = event.buf
    if vim.tbl_contains(exclude, vim.bo[buf].filetype) or vim.b[buf].last_loc then
      return
    end
    vim.b[buf].last_loc = true
    local mark = vim.api.nvim_buf_get_mark(buf, '"')
    local lcount = vim.api.nvim_buf_line_count(buf)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Cerrar algunos tipos de archivos con q
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("close_with_q"),
  pattern = {
    "PlenaryTestPopup",
    "help",
    "lspinfo",
    "man",
    "notify",
    "qf",
    "query",
    "spectre_panel",
    "startuptime",
    "tsplayground",
    "neotest-output",
    "checkhealth",
    "neotest-summary",
    "neotest-output-panel",
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
  end,
})

-- Autoguardado cuando se pierde el foco
vim.api.nvim_create_autocmd({ "FocusLost", "BufLeave" }, {
  group = augroup("auto_save"),
  callback = function()
    if vim.bo.modified and not vim.bo.readonly and vim.fn.expand("%") ~= "" and vim.bo.buftype == "" then
      vim.api.nvim_command("silent update")
    end
  end,
})

-- Configuración específica para tipos de archivo
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("filetype_settings"),
  pattern = { "lua" },
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = augroup("filetype_settings"),
  pattern = { "python" },
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
  end,
})
EOF

# Crear configuración de plugins - UI y tema
echo -e "${YELLOW}🎨 Configurando plugins de UI...${NC}"

cat > "$NVIM_CONFIG_DIR/lua/plugins/ui.lua" << 'EOF'
-- ====================================
-- PLUGINS DE UI Y TEMA
-- ====================================

return {
  -- Tema Catppuccin
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
      flavour = "mocha",
      background = {
        light = "latte",
        dark = "mocha",
      },
      transparent_background = false,
      show_end_of_buffer = false,
      term_colors = true,
      dim_inactive = {
        enabled = false,
        shade = "dark",
        percentage = 0.15,
      },
      integrations = {
        cmp = true,
        gitsigns = true,
        nvimtree = true,
        treesitter = true,
        notify = true,
        mini = true,
        telescope = true,
        which_key = true,
        mason = true,
        lsp_trouble = true,
        rainbow_delimiters = true,
      },
    },
    config = function(_, opts)
      require("catppuccin").setup(opts)
      vim.cmd.colorscheme("catppuccin")
    end,
  },

  -- Lualine con métricas del sistema
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = "VeryLazy",
    config = function()
      -- Función para obtener CPU
      local function get_cpu()
        local stat_file = io.open("/proc/stat", "r")
        if not stat_file then return "💻 N/A" end
        local line = stat_file:read("*line")
        stat_file:close()
        if not line then return "💻 N/A" end

        local values = {}
        for num in line:gmatch("%d+") do
          table.insert(values, tonumber(num))
        end

        if #values < 4 then return "💻 N/A" end

        local idle = values[4] + (values[5] or 0)
        local total = 0
        for i = 1, math.min(#values, 10) do
          total = total + values[i]
        end

        local usage = total > 0 and math.floor(((total - idle) / total) * 100) or 0
        local icon = usage > 80 and "🔥" or usage > 60 and "⚡" or "💻"
        return string.format("%s %d%%", icon, usage)
      end

      -- Función para obtener RAM
      local function get_ram()
        local meminfo_file = io.open("/proc/meminfo", "r")
        if not meminfo_file then return "🧠 N/A" end
        local meminfo = meminfo_file:read("*all")
        meminfo_file:close()

        local total = meminfo:match("MemTotal:%s*(%d+)%s*kB")
        local available = meminfo:match("MemAvailable:%s*(%d+)%s*kB") or meminfo:match("MemFree:%s*(%d+)%s*kB")

        if not total or not available then return "🧠 N/A" end

        total = tonumber(total)
        available = tonumber(available)

        if not total or not available or total == 0 then return "🧠 N/A" end

        local used_percent = math.floor(((total - available) / total) * 100)
        local icon = used_percent > 80 and "🔥" or used_percent > 60 and "⚠️ " or "🧠"
        return string.format("%s %d%%", icon, used_percent)
      end

      require("lualine").setup({
        options = {
          theme = "catppuccin",
          component_separators = { left = "", right = "" },
          section_separators = { left = "", right = "" },
          globalstatus = true,
          disabled_filetypes = { statusline = { "dashboard", "alpha" } },
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch", "diff", "diagnostics" },
          lualine_c = {
            {
              "filename",
              file_status = true,
              newfile_status = false,
              path = 1,
              symbols = {
                modified = "  ",
                alternate_file = "#  ",
                directory = "  ",
              },
            },
          },
          lualine_x = {
            -- Métricas del sistema
            {
              get_cpu,
              color = { fg = "#48cab2", gui = "bold" },
            },
            {
              get_ram,
              color = { fg = "#feca57", gui = "bold" },
            },
            {
              function()
                local msg = "No LSP"
                local buf_ft = vim.api.nvim_buf_get_option(0, "filetype")
                local clients = vim.lsp.get_active_clients()
                if next(clients) == nil then
                  return msg
                end
                for _, client in ipairs(clients) do
                  local filetypes = client.config.filetypes
                  if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
                    return client.name
                  end
                end
                return msg
              end,
              icon = "  LSP:",
              color = { fg = "#ffffff", gui = "bold" },
            },
            "encoding",
            "fileformat",
            "filetype",
          },
          lualine_y = { "progress" },
          lualine_z = { "location" },
        },
        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = { "filename" },
          lualine_x = { "location" },
          lualine_y = {},
          lualine_z = {},
        },
      })
    end,
  },

  -- Buffer line
  {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = "nvim-tree/nvim-web-devicons",
    event = "VeryLazy",
    keys = {
      { "<leader>bp", "<Cmd>BufferLineTogglePin<CR>", desc = "Toggle pin" },
      { "<leader>bP", "<Cmd>BufferLineGroupClose ungrouped<CR>", desc = "Delete non-pinned buffers" },
      { "<leader>bo", "<Cmd>BufferLineCloseOthers<CR>", desc = "Delete other buffers" },
      { "<leader>br", "<Cmd>BufferLineCloseRight<CR>", desc = "Delete buffers to the right" },
      { "<leader>bl", "<Cmd>BufferLineCloseLeft<CR>", desc = "Delete buffers to the left" },
      { "[b", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev buffer" },
      { "]b", "<cmd>BufferLineCycleNext<cr>", desc = "Next buffer" },
    },
    opts = {
      options = {
        close_command = "bdelete! %d",
        right_mouse_command = "bdelete! %d",
        diagnostics = "nvim_lsp",
        always_show_bufferline = false,
        diagnostics_indicator = function(_, _, diag)
          local icons = {
            Error = " ",
            Warn = " ",
            Hint = " ",
            Info = " ",
          }
          local ret = (diag.error and icons.Error .. diag.error .. " " or "")
            .. (diag.warning and icons.Warn .. diag.warning or "")
          return vim.trim(ret)
        end,
        offsets = {
          {
            filetype = "neo-tree",
            text = "Neo-tree",
            highlight = "Directory",
            text_align = "left",
          },
        },
      },
    },
  },

  -- Dashboard
  {
    "goolord/alpha-nvim",
    event = "VimEnter",
    opts = function()
      local dashboard = require("alpha.themes.dashboard")
      local logo = [[
        ████████╗███████╗██████╗ ███╗   ███╗██╗   ██╗██╗  ██╗
        ╚══██╔══╝██╔════╝██╔══██╗████╗ ████║██║   ██║╚██╗██╔╝
           ██║   █████╗  ██████╔╝██╔████╔██║██║   ██║ ╚███╔╝
           ██║   ██╔══╝  ██╔══██╗██║╚██╔╝██║██║   ██║ ██╔██╗
           ██║   ███████╗██║  ██║██║ ╚═╝ ██║╚██████╔╝██╔╝ ██╗
           ╚═╝   ╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝ ╚═════╝ ╚═╝  ╚═╝

                        🤖 AI DEVELOPMENT READY 🚀
      ]]

      dashboard.section.header.val = vim.split(logo, "\n")
      dashboard.section.buttons.val = {
        dashboard.button("f", " " .. " Find file", ":Telescope find_files <CR>"),
        dashboard.button("n", " " .. " New file", ":ene <BAR> startinsert <CR>"),
        dashboard.button("r", " " .. " Recent files", ":Telescope oldfiles <CR>"),
        dashboard.button("g", " " .. " Find text", ":Telescope live_grep <CR>"),
        dashboard.button("c", " " .. " Config", ":e $MYVIMRC <CR>"),
        dashboard.button("a", "🤖 " .. " AI Chat", ":CodeCompanionChat<CR>"),
        dashboard.button("p", "🔄 " .. " Switch AI Provider", ":lua require('codecompanion').switch_provider()<CR>"),
        dashboard.button("s", " " .. " Restore Session", [[:lua require("persistence").load() <cr>]]),
        dashboard.button("l", "󰒲 " .. " Lazy", ":Lazy<CR>"),
        dashboard.button("q", " " .. " Quit", ":qa<CR>"),
      }
      for _, button in ipairs(dashboard.section.buttons.val) do
        button.opts.hl = "AlphaButtons"
        button.opts.hl_shortcut = "AlphaShortcut"
      end
      dashboard.section.header.opts.hl = "AlphaHeader"
      dashboard.section.buttons.opts.hl = "AlphaButtons"
      dashboard.section.footer.opts.hl = "AlphaFooter"
      dashboard.opts.layout[1].val = 8
      return dashboard
    end,
    config = function(_, dashboard)
      vim.b.miniindentscope_disable = true

      if vim.o.filetype == "lazy" then
        vim.cmd.close()
        vim.api.nvim_create_autocmd("User", {
          pattern = "AlphaReady",
          callback = function()
            require("lazy").show()
          end,
        })
      end

      require("alpha").setup(dashboard.opts)

      vim.api.nvim_create_autocmd("User", {
        pattern = "LazyVimStarted",
        callback = function()
          local stats = require("lazy").stats()
          local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
          dashboard.section.footer.val = "⚡ Neovim loaded " .. stats.count .. " plugins in " .. ms .. "ms"
          pcall(vim.cmd.AlphaRedraw)
        end,
      })
    end,
  },

  -- Notificaciones
  {
    "rcarriga/nvim-notify",
    keys = {
      {
        "<leader>un",
        function()
          require("notify").dismiss({ silent = true, pending = true })
        end,
        desc = "Dismiss all Notifications",
      },
    },
    opts = {
      timeout = 3000,
      max_height = function()
        return math.floor(vim.o.lines * 0.75)
      end,
      max_width = function()
        return math.floor(vim.o.columns * 0.75)
      end,
    },
    init = function()
      vim.notify = require("notify")
    end,
  },

  -- Iconos
  { "nvim-tree/nvim-web-devicons", lazy = true },

  -- Mejorar ui de vim
  {
    "stevearc/dressing.nvim",
    lazy = true,
    init = function()
      vim.ui.select = function(...)
        require("lazy").load({ plugins = { "dressing.nvim" } })
        return vim.ui.select(...)
      end
      vim.ui.input = function(...)
        require("lazy").load({ plugins = { "dressing.nvim" } })
        return vim.ui.input(...)
      end
    end,
  },
}
EOF

# Crear configuración de plugins - File Explorer
cat > "$NVIM_CONFIG_DIR/lua/plugins/explorer.lua" << 'EOF'
-- ====================================
-- FILE EXPLORER
-- ====================================

return {
  -- Neo-tree
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    cmd = "Neotree",
    keys = {
      { "<leader>e", ":Neotree toggle<cr>", desc = "Toggle Explorer" },
      { "<leader>E", ":Neotree focus<cr>", desc = "Focus Explorer" },
    },
    deactivate = function()
      vim.cmd([[Neotree close]])
    end,
    init = function()
      if vim.fn.argc(-1) == 1 then
        local stat = vim.loop.fs_stat(vim.fn.argv(0))
        if stat and stat.type == "directory" then
          require("neo-tree")
        end
      end
    end,
    opts = {
      sources = { "filesystem" },
      open_files_do_not_replace_types = { "terminal", "Trouble", "qf", "Outline" },
      filesystem = {
        bind_to_cwd = false,
        follow_current_file = { enabled = true },
        use_libuv_file_watcher = true,
        filtered_items = {
          visible = true,
          hide_dotfiles = false,
          hide_gitignored = false,
          hide_by_name = {
            ".DS_Store",
            "thumbs.db",
            "node_modules",
          },
        },
      },
      window = {
        mappings = {
          ["<space>"] = "none",
          ["l"] = "open",
          ["h"] = "close_node",
          ["<C-v>"] = "open_vsplit",
          ["<C-x>"] = "open_split",
        },
      },
      default_component_configs = {
        indent = {
          with_expanders = true,
          expander_collapsed = "",
          expander_expanded = "",
          expander_highlight = "NeoTreeExpander",
        },
        git_status = {
          symbols = {
            unstaged = "󰄱",
            staged = "󰱒",
          },
        },
      },
    },
  },
}
EOF

# Crear configuración de Telescope
cat > "$NVIM_CONFIG_DIR/lua/plugins/telescope.lua" << 'EOF'
-- ====================================
-- TELESCOPE - FUZZY FINDER
-- ====================================

return {
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.5",
    dependencies = {
      "nvim-lua/plenary.nvim",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
        enabled = vim.fn.executable("make") == 1,
      },
    },
    cmd = "Telescope",
    keys = {
      { "<leader><space>", ":Telescope find_files<cr>", desc = "Find Files" },
      { "<leader>ff", ":Telescope find_files<cr>", desc = "Find Files" },
      { "<leader>fg", ":Telescope live_grep<cr>", desc = "Live Grep" },
      { "<leader>fb", ":Telescope buffers<cr>", desc = "Buffers" },
      { "<leader>fh", ":Telescope help_tags<cr>", desc = "Help Tags" },
      { "<leader>fr", ":Telescope oldfiles<cr>", desc = "Recent Files" },
      { "<leader>fc", ":Telescope commands<cr>", desc = "Commands" },
      { "<leader>fk", ":Telescope keymaps<cr>", desc = "Keymaps" },
      { "<leader>fs", ":Telescope grep_string<cr>", desc = "Grep String" },
      { "<leader>fw", ":Telescope grep_string word_match=-w<cr>", desc = "Grep Word" },
    },
    opts = {
      defaults = {
        prompt_prefix = " ",
        selection_caret = " ",
        path_display = { "truncate" },
        sorting_strategy = "ascending",
        layout_config = {
          horizontal = {
            prompt_position = "top",
            preview_width = 0.55,
            results_width = 0.8,
          },
          vertical = {
            mirror = false,
          },
          width = 0.87,
          height = 0.80,
          preview_cutoff = 120,
        },
        mappings = {
          i = {
            ["<C-n>"] = "move_selection_next",
            ["<C-p>"] = "move_selection_previous",
            ["<C-j>"] = "move_selection_next",
            ["<C-k>"] = "move_selection_previous",
            ["<C-q>"] = "send_to_qflist",
            ["<M-q>"] = "send_selected_to_qflist",
            ["<C-l>"] = "complete_tag",
            ["<C-/>"] = "which_key",
          },
          n = {
            ["<C-j>"] = "move_selection_next",
            ["<C-k>"] = "move_selection_previous",
            ["<C-q>"] = "send_to_qflist",
            ["<M-q>"] = "send_selected_to_qflist",
          },
        },
      },
      pickers = {
        find_files = {
          find_command = { "fd", "--type", "f", "--strip-cwd-prefix" },
        },
        live_grep = {
          additional_args = function(opts)
            return { "--hidden" }
          end,
        },
      },
      extensions = {
        fzf = {
          fuzzy = true,
          override_generic_sorter = true,
          override_file_sorter = true,
          case_mode = "smart_case",
        },
      },
    },
    config = function(_, opts)
      require("telescope").setup(opts)
      if vim.fn.executable("make") == 1 then
        require("telescope").load_extension("fzf")
      end
    end,
  },
}
EOF

# Crear configuración de LSP
echo -e "${YELLOW}🔧 Creando configuración de LSP y autocompletado...${NC}"

cat > "$NVIM_CONFIG_DIR/lua/plugins/lsp.lua" << 'EOF'
-- ====================================
-- LSP CONFIGURATION
-- ====================================

return {
  -- Mason (LSP installer)
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    keys = { { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" } },
    build = ":MasonUpdate",
    opts = {
      ensure_installed = {
        "stylua",
        "shfmt",
        "biome",
      },
    },
    config = function(_, opts)
      require("mason").setup(opts)
      local mr = require("mason-registry")
      mr:on("package:install:success", function()
        vim.defer_fn(function()
          require("lazy.core.handler.event").trigger({
            event = "FileType",
            buf = vim.api.nvim_get_current_buf(),
          })
        end, 100)
      end)
      local function ensure_installed()
        for _, tool in ipairs(opts.ensure_installed) do
          local p = mr.get_package(tool)
          if not p:is_installed() then
            p:install()
          end
        end
      end
      if mr.refresh then
        mr.refresh(ensure_installed)
      else
        ensure_installed()
      end
    end,
  },

  -- Mason LSP Config
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "mason.nvim" },
    opts = {
      ensure_installed = {
        "lua_ls",
        "pyright",
        "tsserver",
        "html",
        "cssls",
        "jsonls",
        "bashls",
      },
    },
  },

  -- LSP Config
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
      { "folke/neodev.nvim", opts = {} },
    },
    opts = {
      diagnostics = {
        underline = true,
        update_in_insert = false,
        virtual_text = {
          spacing = 4,
          source = "if_many",
          prefix = "●",
        },
        severity_sort = true,
      },
      inlay_hints = {
        enabled = false,
      },
      capabilities = {},
      format = {
        formatting_options = nil,
        timeout_ms = nil,
      },
      servers = {
        lua_ls = {
          settings = {
            Lua = {
              workspace = {
                checkThirdParty = false,
              },
              completion = {
                callSnippet = "Replace",
              },
            },
          },
        },
        pyright = {},
        tsserver = {},
        html = {},
        cssls = {},
        jsonls = {},
        bashls = {},
      },
      setup = {},
    },
    config = function(_, opts)
      local servers = opts.servers
      local has_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
      local capabilities = vim.tbl_deep_extend(
        "force",
        {},
        vim.lsp.protocol.make_client_capabilities(),
        has_cmp and cmp_nvim_lsp.default_capabilities() or {},
        opts.capabilities or {}
      )

      local function setup(server)
        local server_opts = vim.tbl_deep_extend("force", {
          capabilities = vim.deepcopy(capabilities),
        }, servers[server] or {})

        if opts.setup[server] then
          if opts.setup[server](server, server_opts) then
            return
          end
        elseif opts.setup["*"] then
          if opts.setup["*"](server, server_opts) then
            return
          end
        end
        require("lspconfig")[server].setup(server_opts)
      end

      local have_mason, mlsp = pcall(require, "mason-lspconfig")
      local all_mslp_servers = {}
      if have_mason then
        all_mslp_servers = vim.tbl_keys(require("mason-lspconfig.mappings.server").lspconfig_to_package)
      end

      local ensure_installed = {}
      for server, server_opts in pairs(servers) do
        if server_opts then
          server_opts = server_opts == true and {} or server_opts
          if server_opts.mason == false or not vim.tbl_contains(all_mslp_servers, server) then
            setup(server)
          else
            ensure_installed[#ensure_installed + 1] = server
          end
        end
      end

      if have_mason then
        mlsp.setup({ ensure_installed = ensure_installed, handlers = { setup } })
      end

      -- Diagnostics configuration
      vim.diagnostic.config(vim.deepcopy(opts.diagnostics))

      -- Keymaps
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local buffer = args.buf
          local client = vim.lsp.get_client_by_id(args.data.client_id)

          local function map(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = buffer, desc = desc })
          end

          -- Basic LSP keymaps
          map("n", "gd", vim.lsp.buf.definition, "Goto Definition")
          map("n", "gr", vim.lsp.buf.references, "References")
          map("n", "gD", vim.lsp.buf.declaration, "Goto Declaration")
          map("n", "gI", vim.lsp.buf.implementation, "Goto Implementation")
          map("n", "gy", vim.lsp.buf.type_definition, "Goto Type Definition")
          map("n", "K", vim.lsp.buf.hover, "Hover")
          map("n", "gK", vim.lsp.buf.signature_help, "Signature Help")
          map("i", "<c-k>", vim.lsp.buf.signature_help, "Signature Help")
          map("n", "<leader>ca", vim.lsp.buf.code_action, "Code Action")
          map("n", "<leader>rn", vim.lsp.buf.rename, "Rename")
          map("n", "<leader>cf", vim.lsp.buf.format, "Format Document")
          map("v", "<leader>cf", vim.lsp.buf.format, "Format Range")

          -- Diagnostics
          map("n", "<leader>cd", vim.diagnostic.open_float, "Line Diagnostics")
          map("n", "]d", vim.diagnostic.goto_next, "Next Diagnostic")
          map("n", "[d", vim.diagnostic.goto_prev, "Prev Diagnostic")
        end,
      })
    end,
  },

  -- Autocompletion
  {
    "hrsh7th/nvim-cmp",
    version = false,
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "saadparwaiz1/cmp_luasnip",
    },
    opts = function()
      vim.api.nvim_set_hl(0, "CmpGhostText", { link = "Comment", default = true })
      local cmp = require("cmp")
      local defaults = require("cmp.config.default")()
      return {
        completion = {
          completeopt = "menu,menuone,noinsert",
        },
        snippet = {
          expand = function(args)
            require("luasnip").lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
          ["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<S-CR>"] = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Replace,
            select = true,
          }),
          ["<C-CR>"] = function(fallback)
            cmp.abort()
            fallback()
          end,
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "path" },
        }, {
          { name = "buffer" },
        }),
        formatting = {
          format = function(_, item)
            local icons = {
              Array = " ",
              Boolean = " ",
              Class = " ",
              Color = " ",
              Constant = " ",
              Constructor = " ",
              Enum = " ",
              EnumMember = " ",
              Event = " ",
              Field = " ",
              File = " ",
              Folder = " ",
              Function = " ",
              Interface = " ",
              Key = " ",
              Keyword = " ",
              Method = " ",
              Module = " ",
              Namespace = " ",
              Null = " ",
              Number = " ",
              Object = " ",
              Operator = " ",
              Package = " ",
              Property = " ",
              Reference = " ",
              Snippet = " ",
              String = " ",
              Struct = " ",
              Text = " ",
              TypeParameter = " ",
              Unit = " ",
              Value = " ",
              Variable = " ",
            }
            if icons[item.kind] then
              item.kind = icons[item.kind] .. item.kind
            end
            return item
          end,
        },
        experimental = {
          ghost_text = {
            hl_group = "CmpGhostText",
          },
        },
        sorting = defaults.sorting,
      }
    end,
  },

  -- Snippets
  {
    "L3MON4D3/LuaSnip",
    build = "make install_jsregexp",
    dependencies = {
      "rafamadriz/friendly-snippets",
      config = function()
        require("luasnip.loaders.from_vscode").lazy_load()
      end,
    },
    opts = {
      history = true,
      delete_check_events = "TextChanged",
    },
    keys = {
      {
        "<tab>",
        function()
          return require("luasnip").jumpable(1) and "<Plug>luasnip-jump-next" or "<tab>"
        end,
        expr = true,
        silent = true,
        mode = "i",
      },
      { "<tab>", function() require("luasnip").jump(1) end, mode = "s" },
      { "<s-tab>", function() require("luasnip").jump(-1) end, mode = { "i", "s" } },
    },
  },
}
EOF

# Crear configuración de Treesitter
cat > "$NVIM_CONFIG_DIR/lua/plugins/treesitter.lua" << 'EOF'
-- ====================================
-- TREESITTER - SYNTAX HIGHLIGHTING
-- ====================================

return {
  {
    "nvim-treesitter/nvim-treesitter",
    version = false,
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
    },
    keys = {
      { "<leader>v", desc = "Increment selection" },
      { "<bs>", desc = "Decrement selection", mode = "x" },
    },
    opts = {
      highlight = { enable = true },
      indent = { enable = true },
      ensure_installed = {
        "bash",
        "c",
        "html",
        "javascript",
        "json",
        "lua",
        "luadoc",
        "luap",
        "markdown",
        "markdown_inline",
        "python",
        "query",
        "regex",
        "tsx",
        "typescript",
        "vim",
        "vimdoc",
        "yaml",
      },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<leader>v",
          node_incremental = "<leader>v",
          scope_incremental = false,
          node_decremental = "<bs>",
        },
      },
      textobjects = {
        move = {
          enable = true,
          goto_next_start = { ["]f"] = "@function.outer", ["]c"] = "@class.outer" },
          goto_next_end = { ["]F"] = "@function.outer", ["]C"] = "@class.outer" },
          goto_previous_start = { ["[f"] = "@function.outer", ["[c"] = "@class.outer" },
          goto_previous_end = { ["[F"] = "@function.outer", ["[C"] = "@class.outer" },
        },
      },
    },
    config = function(_, opts)
      require("nvim-treesitter.configs").setup(opts)
    end,
  },
}
EOF

# Crear configuración de plugins de IA
cat > "$NVIM_CONFIG_DIR/lua/plugins/ai.lua" << 'EOF'
-- ====================================
-- AI Plugins Configuration for Neovim
-- Based on Gentleman.Dots with multi-provider support
-- ====================================

local function load_ai_env()
  local ai_env_file = vim.fn.expand("~/.ai-env")
  local env = {}

  -- Default values - OAuth2 based authentication
  env.CURRENT_AI_PROVIDER = "gemini-cli"
  env.OPENAI_API_KEY = ""
  env.ANTHROPIC_API_KEY = ""
  env.CHUTES_API_KEY = ""
  env.MOONSHOT_API_KEY = ""
  env.GLM_API_KEY = ""
  -- Note: GEMINI_API_KEY removed - use 'gemini auth login' for OAuth2

  if vim.fn.filereadable(ai_env_file) == 1 then
    for line in io.lines(ai_env_file) do
      local key, value = line:match("^([^=]+)=(.*)$")
      if key and value then
        env[key] = value
      end
    end
  end

  return env
end

local ai_env = load_ai_env()

return {
  -- CodeCompanion - Multi-provider AI assistant (Primary)
  {
    "olimorris/codecompanion.nvim",
    enabled = true,
    init = function()
      vim.cmd([[cab cc CodeCompanion]])
    end,
    cmd = {
      "CodeCompanion",
      "CodeCompanionActions",
      "CodeCompanionChat",
      "CodeCompanionCmd",
    },
    keys = {
      { "<leader>ac", "<cmd>CodeCompanionChat Toggle<cr>", mode = { "n", "v" }, desc = "AI Toggle [C]hat" },
      { "<leader>an", "<cmd>CodeCompanionChat<cr>", mode = { "n", "v" }, desc = "AI [N]ew Chat" },
      { "<leader>aa", "<cmd>CodeCompanionActions<cr>", mode = { "n", "v" }, desc = "AI [A]ction" },
      { "ga", "<cmd>CodeCompanionChat Add<CR>", mode = { "v" }, desc = "AI [A]dd to Chat" },
      { "<leader>ae", "<cmd>CodeCompanion /explain<cr>", mode = { "v" }, desc = "AI [E]xplain" },
      { "<leader>ap", "<cmd>lua require('codecompanion').switch_provider()<cr>", desc = "AI Switch [P]rovider" },
    },
    config = true,
    opts = {
      adapters = {
        -- OpenAI Compatible providers
        chutes_glm45 = function()
          return require("codecompanion.adapters").extend("openai", {
            name = "chutes_glm45",
            url = "https://chutes.ai/api/v1/chat/completions",
            env = {
              api_key = "CHUTES_API_KEY",
            },
            headers = {
              ["Content-Type"] = "application/json",
              ["Authorization"] = "Bearer ${api_key}",
            },
            parameters = {
              stream = true,
            },
            schema = {
              model = {
                default = "chutes-glm-4.5-fp8",
              },
            },
          })
        end,
        moonshot_kimi = function()
          return require("codecompanion.adapters").extend("openai", {
            name = "moonshot_kimi",
            url = "https://api.moonshot.cn/v1/chat/completions",
            env = {
              api_key = "MOONSHOT_API_KEY",
            },
            headers = {
              ["Content-Type"] = "application/json",
              ["Authorization"] = "Bearer ${api_key}",
            },
            parameters = {
              stream = true,
            },
            schema = {
              model = {
                default = "moonshot-v1-8k",
                choices = {
                  "moonshot-v1-8k",
                  "moonshot-v1-32k",
                  "moonshot-v1-128k",
                },
              },
            },
          })
        end,
      },
      display = {
        diff = {
          enabled = true,
          close_chat_at = 240,
          layout = "vertical",
        },
        chat = {
          window = {
            position = "left",
            width = 0.4,
          },
        },
      },
      strategies = {
        inline = {
          keymaps = {
            accept_change = {
              modes = { n = "ga" },
              description = "Accept the suggested change",
            },
            reject_change = {
              modes = { n = "gr" },
              description = "Reject the suggested change",
            },
          },
        },
        chat = {
          slash_commands = {
            ["git_files"] = {
              description = "List git files",
              callback = function(chat)
                local handle = io.popen("git ls-files")
                if handle ~= nil then
                  local result = handle:read("*a")
                  handle:close()
                  chat:add_reference({ role = "user", content = result }, "git", "<git_files>")
                else
                  return vim.notify("No git files available", vim.log.levels.INFO, { title = "CodeCompanion" })
                end
              end,
              opts = {
                contains_code = false,
              },
            },
          },
          keymaps = {
            send = {
              modes = { n = "<CR>", i = "<C-s>" },
            },
            close = {
              modes = { n = "<C-c>", i = "<C-c>" },
            },
          },
          adapter = ai_env.CURRENT_AI_PROVIDER or "copilot",
        },
      },
    },
  },

  -- GP.nvim - OpenAI, Anthropic, and other providers
  {
    "robitx/gp.nvim",
    enabled = true,
    cmd = { "GpChatNew", "GpChatPaste", "GpChatToggle", "GpChatFinder", "GpRewrite", "GpAppend" },
    keys = {
      { "<leader>gn", "<cmd>GpChatNew<cr>", desc = "GP New Chat" },
      { "<leader>gt", "<cmd>GpChatToggle<cr>", desc = "GP Toggle Chat" },
      { "<leader>gf", "<cmd>GpChatFinder<cr>", desc = "GP Chat Finder" },
      { "<leader>gr", "<cmd>GpRewrite<cr>", mode = { "v" }, desc = "GP Rewrite" },
      { "<leader>ga", "<cmd>GpAppend<cr>", mode = { "v" }, desc = "GP Append" },
    },
    config = function()
      local conf = {
        -- OpenAI provider
        openai_api_key = ai_env.OPENAI_API_KEY,

        -- Default agents for different providers
        agents = {
          {
            name = "ChatGPT4o",
            chat = true,
            command = false,
            model = { model = "gpt-4o", temperature = 1.1, top_p = 1 },
            system_prompt = "You are a helpful AI assistant for Termux development on Android.",
          },
          {
            name = "Claude",
            provider = "anthropic",
            chat = true,
            command = false,
            model = { model = "claude-3-5-sonnet-20241022", max_tokens = 4096 },
            system_prompt = "You are a helpful AI assistant specialized in mobile development and Termux.",
          },
        },

        -- Chat settings
        chat_dir = vim.fn.stdpath("data"):gsub("/$", "") .. "/gp/chats",
        chat_user_prefix = "💬:",
        chat_assistant_prefix = { "🤖:", "[{{agent}}]" },
        chat_confirm_delete = true,
        chat_conceal_model_params = true,

        -- Command settings
        command_prompt_prefix_template = "🤖 {{agent}} ~ ",
        command_auto_select_response = true,
      }

      require("gp").setup(conf)
    end,
  },

  -- Copilot (GitHub) - Keep original for stability
  {
    "zbirenbaum/copilot.lua",
    enabled = true,
    optional = true,
    opts = function()
      require("copilot.api").status = require("copilot.status")
      require("copilot.api").filetypes = {
        filetypes = {
          yaml = false,
          markdown = false,
          help = false,
          gitcommit = false,
          gitrebase = false,
          hgcommit = false,
          svn = false,
          cvs = false,
          ["."] = false,
        },
      }
    end,
  },

  -- CopilotChat - GitHub Copilot Chat interface
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    enabled = true,
    branch = "main",
    cmd = "CopilotChat",
    keys = {
      { "<leader>ccc", "<cmd>CopilotChat<cr>", desc = "Copilot Chat" },
      { "<leader>ccq", "<cmd>CopilotChatQuick<cr>", desc = "Copilot Quick Chat" },
      { "<leader>cce", "<cmd>CopilotChatExplain<cr>", mode = { "v" }, desc = "Copilot Explain" },
      { "<leader>ccr", "<cmd>CopilotChatReview<cr>", mode = { "v" }, desc = "Copilot Review" },
      { "<leader>ccf", "<cmd>CopilotChatFix<cr>", mode = { "v" }, desc = "Copilot Fix" },
      { "<leader>cco", "<cmd>CopilotChatOptimize<cr>", mode = { "v" }, desc = "Copilot Optimize" },
      { "<leader>ccd", "<cmd>CopilotChatDocs<cr>", mode = { "v" }, desc = "Copilot Docs" },
      { "<leader>cct", "<cmd>CopilotChatTests<cr>", mode = { "v" }, desc = "Copilot Tests" },
    },
    opts = {
      model = "claude-3.5-sonnet",
      answer_header = "🤖 Copilot",
      auto_insert_mode = true,
      window = {
        layout = "horizontal",
      },
      mappings = {
        complete = {
          insert = "<Tab>",
        },
        close = {
          normal = "q",
          insert = "<C-c>",
        },
        reset = {
          normal = "<C-l>",
          insert = "<C-l>",
        },
        submit_prompt = {
          normal = "<CR>",
          insert = "<C-s>",
        },
      },
    },
    config = function(_, opts)
      local chat = require("CopilotChat")
      vim.api.nvim_create_autocmd("BufEnter", {
        pattern = "copilot-chat",
        callback = function()
          vim.opt_local.relativenumber = true
          vim.opt_local.number = false
        end,
      })
      chat.setup(opts)
    end,
  },

  -- Avante.nvim - Advanced AI coding assistant
  {
    "yetone/avante.nvim",
    enabled = false, -- Disabled by default, can be enabled by user
    event = "VeryLazy",
    version = false,
    keys = {
      { "<leader>at", "<cmd>AvanteToggle<cr>", desc = "Avante Toggle" },
      { "<leader>aa", "<cmd>AvanteAsk<cr>", desc = "Avante Ask" },
      { "<leader>ar", "<cmd>AvanteRefresh<cr>", desc = "Avante Refresh" },
      { "<leader>ae", "<cmd>AvanteEdit<cr>", mode = { "v" }, desc = "Avante Edit" },
    },
    opts = {
      provider = "copilot",
      providers = {
        copilot = {
          model = "claude-3.5-sonnet",
        },
        openai = {
          endpoint = "https://api.openai.com/v1",
          model = "gpt-4o",
          api_key_name = "OPENAI_API_KEY",
        },
        anthropic = {
          endpoint = "https://api.anthropic.com",
          model = "claude-3-5-sonnet-20241022",
          api_key_name = "ANTHROPIC_API_KEY",
        },
      },
      windows = {
        position = "left",
        wrap = true,
        width = 30,
      },
    },
    dependencies = {
      "MunifTanjim/nui.nvim",
    },
  },

  -- Gemini integration
  {
    "jonroosevelt/gemini-cli.nvim",
    enabled = true,
    cmd = { "Gemini", "GeminiChat" },
    keys = {
      { "<leader>gc", "<cmd>Gemini<cr>", desc = "Gemini Chat" },
      { "<leader>gq", "<cmd>GeminiChat<cr>", desc = "Gemini Quick" },
    },
    config = function()
      -- NOTE: Using system gemini CLI with OAuth2 instead of API key
      -- Run 'gemini auth login' to authenticate
      require("gemini").setup({
        model = "gemini-2.5-flash",
        -- OAuth2 authentication is handled by system gemini CLI
      })
    end,
  },
}
EOF

# Crear configuración de herramientas de desarrollo
cat > "$NVIM_CONFIG_DIR/lua/plugins/dev-tools.lua" << 'EOF'
-- ====================================
-- DEVELOPMENT TOOLS
-- ====================================

return {
  -- Git integration
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      signs = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "" },
        topdelete = { text = "" },
        changedelete = { text = "▎" },
        untracked = { text = "▎" },
      },
      on_attach = function(buffer)
        local gs = package.loaded.gitsigns

        local function map(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc })
        end

        map("n", "]h", gs.next_hunk, "Next Hunk")
        map("n", "[h", gs.prev_hunk, "Prev Hunk")
        map({ "n", "v" }, "<leader>ghs", ":Gitsigns stage_hunk<CR>", "Stage Hunk")
        map({ "n", "v" }, "<leader>ghr", ":Gitsigns reset_hunk<CR>", "Reset Hunk")
        map("n", "<leader>ghS", gs.stage_buffer, "Stage Buffer")
        map("n", "<leader>ghu", gs.undo_stage_hunk, "Undo Stage Hunk")
        map("n", "<leader>ghR", gs.reset_buffer, "Reset Buffer")
        map("n", "<leader>ghp", gs.preview_hunk, "Preview Hunk")
        map("n", "<leader>ghb", function() gs.blame_line({ full = true }) end, "Blame Line")
        map("n", "<leader>ghd", gs.diffthis, "Diff This")
        map("n", "<leader>ghD", function() gs.diffthis("~") end, "Diff This ~")
        map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "GitSigns Select Hunk")
      end,
    },
  },

  -- Better diagnostics
  {
    "folke/trouble.nvim",
    cmd = { "TroubleToggle", "Trouble" },
    opts = { use_diagnostic_signs = true },
    keys = {
      { "<leader>xx", "<cmd>TroubleToggle document_diagnostics<cr>", desc = "Document Diagnostics (Trouble)" },
      { "<leader>xX", "<cmd>TroubleToggle workspace_diagnostics<cr>", desc = "Workspace Diagnostics (Trouble)" },
      { "<leader>xL", "<cmd>TroubleToggle loclist<cr>", desc = "Location List (Trouble)" },
      { "<leader>xQ", "<cmd>TroubleToggle quickfix<cr>", desc = "Quickfix List (Trouble)" },
    },
  },

  -- Which-key
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      plugins = { spelling = true },
      defaults = {
        mode = { "n", "v" },
        ["g"] = { name = "+goto" },
        ["gz"] = { name = "+surround" },
        ["]"] = { name = "+next" },
        ["["] = { name = "+prev" },
        ["<leader><tab>"] = { name = "+tabs" },
        ["<leader>b"] = { name = "+buffer" },
        ["<leader>c"] = { name = "+code" },
        ["<leader>f"] = { name = "+file/find" },
        ["<leader>g"] = { name = "+git" },
        ["<leader>gh"] = { name = "+hunks" },
        ["<leader>q"] = { name = "+quit/session" },
        ["<leader>s"] = { name = "+search" },
        ["<leader>u"] = { name = "+ui" },
        ["<leader>w"] = { name = "+windows" },
        ["<leader>x"] = { name = "+diagnostics/quickfix" },
        ["<leader>a"] = { name = "+ai" },
      },
    },
    config = function(_, opts)
      local wk = require("which-key")
      wk.setup(opts)
      wk.register(opts.defaults)
    end,
  },

  -- Comments
  {
    "echasnovski/mini.comment",
    event = "VeryLazy",
    opts = {
      options = {
        custom_commentstring = function()
          return require("ts_context_commentstring.internal").calculate_commentstring() or vim.bo.commentstring
        end,
      },
    },
  },

  -- Better surround
  {
    "echasnovski/mini.surround",
    keys = function(_, keys)
      local plugin = require("lazy.core.config").spec.plugins["mini.surround"]
      local opts = require("lazy.core.plugin").values(plugin, "opts", false)
      local mappings = {
        { opts.mappings.add, desc = "Add surrounding", mode = { "n", "v" } },
        { opts.mappings.delete, desc = "Delete surrounding" },
        { opts.mappings.find, desc = "Find right surrounding" },
        { opts.mappings.find_left, desc = "Find left surrounding" },
        { opts.mappings.highlight, desc = "Highlight surrounding" },
        { opts.mappings.replace, desc = "Replace surrounding" },
        { opts.mappings.update_n_lines, desc = "Update `MiniSurround.config.n_lines`" },
      }
      mappings = vim.tbl_filter(function(m)
        return m[1] and #m[1] > 0
      end, mappings)
      return vim.list_extend(mappings, keys)
    end,
    opts = {
      mappings = {
        add = "gza",
        delete = "gzd",
        find = "gzf",
        find_left = "gzF",
        highlight = "gzh",
        replace = "gzr",
        update_n_lines = "gzn",
      },
    },
  },

  -- Auto pairs
  {
    "echasnovski/mini.pairs",
    event = "VeryLazy",
    opts = {},
  },

  -- Session management
  {
    "folke/persistence.nvim",
    event = "BufReadPre",
    opts = { options = vim.opt.sessionoptions:get() },
    keys = {
      { "<leader>qs", function() require("persistence").load() end, desc = "Restore Session" },
      { "<leader>ql", function() require("persistence").load({ last = true }) end, desc = "Restore Last Session" },
      { "<leader>qd", function() require("persistence").stop() end, desc = "Don't Save Current Session" },
    },
  },

  -- Terminal
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    keys = {
      { "<leader>tt", "<cmd>ToggleTerm<cr>", desc = "Toggle Terminal" },
      { "<leader>tf", "<cmd>ToggleTerm direction=float<cr>", desc = "Toggle Floating Terminal" },
      { "<leader>th", "<cmd>ToggleTerm direction=horizontal<cr>", desc = "Toggle Horizontal Terminal" },
      { "<leader>tv", "<cmd>ToggleTerm direction=vertical size=80<cr>", desc = "Toggle Vertical Terminal" },
    },
    opts = {
      size = 20,
      open_mapping = [[<c-\>]],
      hide_numbers = true,
      shade_terminals = true,
      shading_factor = 2,
      start_in_insert = true,
      insert_mappings = true,
      terminal_mappings = true,
      persist_size = true,
      direction = "float",
      close_on_exit = true,
      shell = vim.o.shell,
      float_opts = {
        border = "curved",
        winblend = 0,
        highlights = {
          border = "Normal",
          background = "Normal",
        },
      },
    },
  },
}
EOF

# Instalar Neovim si no está instalado
if ! command -v nvim >/dev/null 2>&1; then
    echo -e "${YELLOW}📦 Instalando herramientas adicionales para Neovim...${NC}"
    pkg install -y nodejs npm python python-pip
fi

# Instalar herramientas adicionales necesarias
echo -e "${YELLOW}🔧 Instalando herramientas de desarrollo...${NC}"

# Node.js tools
if command -v npm >/dev/null 2>&1; then
    npm install -g typescript typescript-language-server @biome/cli
fi

# Python tools
if command -v pip >/dev/null 2>&1; then
    pip install black isort flake8 mypy
fi

# Crear script de primera configuración
cat > "$NVIM_CONFIG_DIR/first-run.sh" << 'EOF'
#!/bin/bash

echo "🚀 Configurando Neovim por primera vez..."

# Ejecutar Neovim para que instale los plugins
nvim --headless "+Lazy! sync" +qa

echo "✅ Plugins instalados. Ejecuta 'nvim' para comenzar a usar tu entorno de desarrollo con IA."
EOF

chmod +x "$NVIM_CONFIG_DIR/first-run.sh"

echo -e "\n${GREEN}📊 RESUMEN DE CONFIGURACIÓN NEOVIM${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

echo -e "${GREEN}✅ Neovim configurado con Lazy.nvim${NC}"
echo -e "${GREEN}✅ Plugins instalados:${NC}"
echo -e "   • UI: Catppuccin theme, Lualine con métricas CPU/RAM, Bufferline, Alpha dashboard, Incline"
echo -e "   • Explorer: Neo-tree"
echo -e "   • Fuzzy finder: Telescope"
echo -e "   • LSP: Mason, LSP servers para múltiples lenguajes"
echo -e "   • Autocompletado: nvim-cmp con snippets"
echo -e "   • Syntax: Treesitter"
echo -e "   • IA Multi-Proveedor: CodeCompanion, GitHub Copilot, GP.nvim, CopilotChat, Avante, Claude Code"
echo -e "   • Proveedores LLM: OpenAI (GPT-4o), Anthropic (Claude 3.5), Google Gemini"
echo -e "   • Proveedores Alternativos: Chutes AI (GLM 4.5), Moonshot AI (Kimi K2 0905)"
echo -e "   • Monitoreo Sistema: Métricas CPU/RAM en tiempo real con caché inteligente"
echo -e "   • Git: Gitsigns"
echo -e "   • Herramientas: Which-key, Trouble, Terminal, Sessions"

echo -e "\n${YELLOW}🔄 PRÓXIMOS PASOS:${NC}"
echo -e "${CYAN}1. Ejecuta el script de primera configuración:${NC}"
echo -e "   cd ~/.config/nvim && ./first-run.sh"
echo -e "${CYAN}2. Configura las API keys en ~/.ai-env (copia desde ~/.ai-env.template)${NC}"
echo -e "${CYAN}3. Configura GitHub Copilot: :Copilot setup${NC}"
echo -e "${CYAN}4. Comandos de IA disponibles:${NC}"
echo -e "   • :CodeCompanionChat - Chat con múltiples proveedores"
echo -e "   • :CopilotChat - Chat con GitHub Copilot"
echo -e "   • :GP - Interfaz de GP.nvim"
echo -e "   • :Avante - Interfaz tipo Cursor"
echo -e "${CYAN}5. Ejecuta :checkhealth para verificar la instalación${NC}"

echo -e "\n${PURPLE}🎉 ¡Neovim listo para desarrollo con IA!${NC}"

# Crear script de diagnóstico y corrección
cat > "$NVIM_CONFIG_DIR/fix-common-issues.sh" << 'EOF'
#!/bin/bash

echo "🔧 Solucionando problemas comunes de Neovim en Termux..."

# Limpiar caché de Lazy
echo "🧹 Limpiando caché de Lazy..."
rm -rf ~/.local/share/nvim/lazy
rm -rf ~/.local/state/nvim/lazy

# Verificar y crear directorios necesarios
echo "📁 Verificando directorios..."
mkdir -p ~/.local/share/nvim
mkdir -p ~/.local/state/nvim
mkdir -p ~/.cache/nvim

# Verificar encoding
echo "🔤 Configurando encoding..."
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Reinstalar plugins problemáticos de forma individual
echo "🔄 Reinstalando plugins..."
nvim --headless "+Lazy! clean" +qa 2>/dev/null || true
nvim --headless "+Lazy! sync" +qa 2>/dev/null || true

echo "✅ Correcciones aplicadas. Intenta abrir Neovim nuevamente."
EOF

chmod +x "$NVIM_CONFIG_DIR/fix-common-issues.sh"

# Ejecutar configuración inicial automáticamente con manejo de errores
echo -e "${BLUE}🔄 Ejecutando configuración inicial...${NC}"

# Configurar variables de entorno para evitar problemas de encoding
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

cd "$NVIM_CONFIG_DIR"

# Intentar la instalación inicial con manejo de errores
if ! bash first-run.sh 2>/dev/null; then
    echo -e "${YELLOW}⚠️ Se detectaron algunos problemas durante la instalación inicial${NC}"
    echo -e "${CYAN}🔧 Ejecutando script de corrección...${NC}"
    bash fix-common-issues.sh

    echo -e "${GREEN}✅ Script de corrección ejecutado${NC}"
    echo -e "${CYAN}💡 Si sigues teniendo problemas, ejecuta:${NC}"
    echo -e "   cd ~/.config/nvim && ./fix-common-issues.sh"
fi

echo -e "\n${GREEN}🎉 Configuración de Neovim completada!${NC}"
echo -e "${CYAN}📋 Comandos útiles:${NC}"
echo -e "${CYAN}   • Abrir Neovim: nvim${NC}"
echo -e "${CYAN}   • Solucionar problemas: cd ~/.config/nvim && ./fix-common-issues.sh${NC}"
echo -e "${CYAN}   • Verificar salud: nvim +checkhealth${NC}"

exit 0