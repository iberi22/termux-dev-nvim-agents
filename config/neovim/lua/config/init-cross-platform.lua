-- ====================================
-- Rastafari Neovim Cross-Platform Init
-- Main configuration that adapts to platform
-- ====================================

-- Load platform detection first
local platform = require("config.platform")

-- Load notification management system
local notifications = require("config.notifications")

-- Setup environment based on platform
platform.setup_environment()

-- Initialize notification fixes
notifications.init()

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

-- Platform-specific leader key setup
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Base Neovim settings
vim.opt.encoding = "utf-8"
vim.opt.fileencoding = "utf-8"
vim.opt.number = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.smartindent = true
vim.opt.hlsearch = true
vim.opt.backup = false
vim.opt.showcmd = true
vim.opt.cmdheight = 1
vim.opt.laststatus = 2
vim.opt.scrolloff = 10
vim.opt.inccommand = "split"
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.wrap = false
vim.opt.backspace = { "start", "eol", "indent" }
vim.opt.path:append({ "**" })
vim.opt.wildignore:append({ "*/node_modules/*" })
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.winblend = 0
vim.opt.pumblend = 5
vim.opt.background = "dark"

-- Enable termguicolors if supported
if vim.fn.has("termguicolors") == 1 then
  vim.opt.termguicolors = true
end

-- Platform-specific plugin configuration
local plugin_config = platform.get_plugin_config()

-- LazyVim setup with platform adaptations
require("lazy").setup({
  spec = {
    -- LazyVim core
    {
      "LazyVim/LazyVim",
      import = "lazyvim.plugins",
      opts = {
        colorscheme = "rastafari", -- Use our custom colorscheme
        news = {
          -- Disable news on resource-constrained platforms
          lazyvim = not platform.is_termux,
          neovim = not platform.is_termux,
        },
      },
    },

    -- Platform-conditional imports
    platform.is_termux and {} or { import = "lazyvim.plugins.extras.editor.harpoon2" },
    platform.is_termux and {} or { import = "lazyvim.plugins.extras.editor.telescope" },
    { import = "lazyvim.plugins.extras.lang.json" },
    { import = "lazyvim.plugins.extras.lang.markdown" },

    -- Conditional language servers based on platform
    not platform.is_termux and { import = "lazyvim.plugins.extras.lang.typescript" } or {},
    not platform.is_termux and { import = "lazyvim.plugins.extras.lang.python" } or {},

    -- AI plugins (only on platforms with good internet)
    not platform.is_termux and { import = "lazyvim.plugins.extras.ai.copilot" } or {},

    -- Import our custom Rastafari plugins
    { import = "plugins" },
  },

  defaults = {
    lazy = false,
    version = false,
  },

  install = {
    colorscheme = { "rastafari", "tokyonight", "habamax" },
    missing = not platform.is_termux, -- Don't auto-install on Termux
  },

  checker = {
    enabled = not platform.is_termux, -- Disable update checks on Termux
    notify = false,
  },

  performance = {
    rtp = {
      disabled_plugins = vim.list_extend(
        {
          "gzip",
          "tarPlugin",
          "tohtml",
          "tutor",
          "zipPlugin",
        },
        plugin_config.disabled_plugins or {}
      ),
    },
  },

  ui = {
    border = "rounded",
    size = {
      width = platform.is_termux and 0.9 or 0.8,
      height = platform.is_termux and 0.8 or 0.9,
    },
  },
})

-- Platform-specific keymaps
local keymaps = platform.get_keymaps()
for _, keymap in ipairs(keymaps) do
  vim.keymap.set(keymap[1], keymap[2], keymap[3], keymap[4] or {})
end

-- Additional cross-platform keymaps
vim.keymap.set("n", "<leader>pl", function()
  platform.show_platform_info()
end, { desc = "Show platform info" })

-- Terminal configuration
local terminal_config = platform.get_terminal_config()

-- Auto commands for platform-specific behavior
vim.api.nvim_create_augroup("RastafariPlatform", { clear = true })

-- Termux-specific auto commands
if platform.is_termux then
  vim.api.nvim_create_autocmd("VimEnter", {
    group = "RastafariPlatform",
    callback = function()
      -- Show welcome message on Termux
      vim.notify("🌿 Rastafari Neovim on Termux - One Love! 💚💛❤️", vim.log.levels.INFO)
    end,
  })

  -- Disable some resource-heavy features
  vim.api.nvim_create_autocmd("FileType", {
    group = "RastafariPlatform",
    pattern = "*",
    callback = function()
      vim.opt_local.foldmethod = "manual"
      vim.opt_local.foldenable = false
    end,
  })
end

-- Windows-specific auto commands
if platform.is_windows then
  vim.api.nvim_create_autocmd("VimEnter", {
    group = "RastafariPlatform",
    callback = function()
      vim.notify("🌿 Rastafari Neovim on Windows - Jah bless! 💚💛❤️", vim.log.levels.INFO)
    end,
  })

  -- Windows path handling
  vim.api.nvim_create_autocmd("BufReadPost", {
    group = "RastafariPlatform",
    callback = function()
      -- Convert backslashes to forward slashes in file paths for consistency
      local bufname = vim.api.nvim_buf_get_name(0)
      if bufname and bufname:match("\\") then
        vim.bo.fileformat = "dos"
      end
    end,
  })
end

-- WSL-specific auto commands
if platform.is_wsl then
  vim.api.nvim_create_autocmd("VimEnter", {
    group = "RastafariPlatform",
    callback = function()
      vim.notify("🌿 Rastafari Neovim on WSL - Ubuntu vibes! 💚💛❤️", vim.log.levels.INFO)
    end,
  })
end

-- Create platform-specific user commands
vim.api.nvim_create_user_command("RastafariPlatform", function()
  platform.show_platform_info()
end, { desc = "Show Rastafari platform information" })

vim.api.nvim_create_user_command("RastafariDiagnostic", function()
  local diagnostics = {
    "🌿 Rastafari Neovim Diagnostic 🌿",
    "",
    "Platform: " .. platform.os_name,
    "Python: " .. (vim.g.python3_host_prog or "Not configured"),
    "Node: " .. (vim.g.node_host_prog or "Not configured"),
    "Clipboard: " .. (vim.g.clipboard and vim.g.clipboard.name or "system"),
    "Termguicolors: " .. tostring(vim.opt.termguicolors:get()),
    "Config path: " .. vim.fn.stdpath("config"),
    "Data path: " .. vim.fn.stdpath("data"),
    "",
  }

  -- Check LSP status
  local lsp_clients = vim.lsp.get_active_clients()
  if #lsp_clients > 0 then
    table.insert(diagnostics, "Active LSP servers:")
    for _, client in ipairs(lsp_clients) do
      table.insert(diagnostics, "  • " .. client.name)
    end
  else
    table.insert(diagnostics, "No active LSP servers")
  end

  -- Check plugin status
  local lazy_ok, lazy = pcall(require, "lazy")
  if lazy_ok then
    local plugins = lazy.plugins()
    table.insert(diagnostics, "")
    table.insert(diagnostics, "Loaded plugins: " .. tostring(#plugins))
  end

  -- Display in floating window
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, diagnostics)
  vim.api.nvim_buf_set_option(buf, "modifiable", false)
  vim.api.nvim_buf_set_option(buf, "filetype", "text")

  local width = math.max(60, math.ceil(vim.o.columns * 0.6))
  local height = math.min(#diagnostics + 2, math.ceil(vim.o.lines * 0.8))

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    col = math.ceil((vim.o.columns - width) / 2),
    row = math.ceil((vim.o.lines - height) / 2),
    border = "rounded",
    title = " Rastafari Diagnostic ",
    title_pos = "center",
  })

  vim.api.nvim_win_set_option(win, "wrap", false)
  vim.keymap.set("n", "q", ":close<CR>", { buffer = buf, silent = true })
end, { desc = "Show Rastafari diagnostic information" })

-- Set up Mason LSP configuration based on platform
local lsp_config = platform.get_lsp_config()
if lsp_config then
  vim.api.nvim_create_autocmd("User", {
    pattern = "LazyVimStarted",
    callback = function()
      -- Configure Mason with platform-specific servers
      local mason_ok, mason_lsp = pcall(require, "mason-lspconfig")
      if mason_ok then
        mason_lsp.setup({
          ensure_installed = lsp_config.ensure_installed,
          automatic_installation = not platform.is_termux, -- Manual on Termux
        })
      end
    end,
  })
end

-- Final platform message
vim.api.nvim_create_autocmd("User", {
  pattern = "LazyVimStarted",
  callback = function()
    local messages = {
      Windows = "🌿 One love from Windows! Ready to code with Jah power! 💚💛❤️",
      WSL = "🌿 Ubuntu spirit in Windows! Jah guidance in dual worlds! 💚💛❤️",
      Linux = "🌿 Pure Linux vibes! Free as Rastafari spirit! 💚💛❤️",
      macOS = "🌿 Mac wisdom flowing! Think different with Jah! 💚💛❤️",
      Termux = "🌿 Mobile Rastafari power! Code anywhere, anytime! 💚💛❤️",
    }

    local message = messages[platform.os_name] or "🌿 Rastafari Neovim ready! One love! 💚💛❤️"
    vim.defer_fn(function()
      vim.notify(message, vim.log.levels.INFO, { title = "Rastafari Neovim" })
    end, 1000)
  end,
})