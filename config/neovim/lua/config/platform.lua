-- ====================================
-- Rastafari Neovim Cross-Platform Configuration
-- Works on Windows, Linux, macOS, and Termux
-- ====================================

local M = {}

-- Platform detection
M.is_windows = vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1
M.is_wsl = vim.fn.has("wsl") == 1
M.is_linux = vim.fn.has("unix") == 1 and not M.is_wsl and not vim.fn.has("macunix")
M.is_mac = vim.fn.has("macunix") == 1
M.is_termux = os.getenv("TERMUX_VERSION") ~= nil

-- System info
M.os_name = M.is_windows and "Windows" or M.is_wsl and "WSL" or M.is_termux and "Termux" or M.is_mac and "macOS" or "Linux"

-- Path separator
M.path_sep = M.is_windows and "\\" or "/"

-- Configuration paths
M.config_path = vim.fn.stdpath("config")
M.data_path = vim.fn.stdpath("data")
M.cache_path = vim.fn.stdpath("cache")

-- Cross-platform utilities
M.get_python_path = function()
  if M.is_windows then
    -- Try different Windows Python locations
    local python_paths = {
      "python.exe",
      "python3.exe",
      "C:\\Python311\\python.exe",
      "C:\\Program Files\\Python311\\python.exe",
      vim.fn.expand("~/AppData/Local/Programs/Python/Python311/python.exe"),
    }

    for _, path in ipairs(python_paths) do
      if vim.fn.executable(path) == 1 then
        return path
      end
    end

    return "python.exe" -- Fallback
  elseif M.is_termux then
    return "/data/data/com.termux/files/usr/bin/python"
  else
    -- Linux/macOS
    local python_paths = { "python3", "python" }
    for _, path in ipairs(python_paths) do
      if vim.fn.executable(path) == 1 then
        return path
      end
    end
    return "python3" -- Fallback
  end
end

M.get_node_path = function()
  if M.is_windows then
    local node_paths = {
      "node.exe",
      "C:\\Program Files\\nodejs\\node.exe",
      vim.fn.expand("~/AppData/Roaming/npm/node.exe"),
    }

    for _, path in ipairs(node_paths) do
      if vim.fn.executable(path) == 1 then
        return path
      end
    end

    return "node.exe" -- Fallback
  elseif M.is_termux then
    return "/data/data/com.termux/files/usr/bin/node"
  else
    return vim.fn.executable("node") == 1 and "node" or "nodejs"
  end
end

-- Shell detection and configuration
M.get_shell = function()
  if M.is_windows and not M.is_wsl then
    -- Windows native
    if vim.fn.executable("pwsh.exe") == 1 then
      return { "pwsh.exe", "-NoLogo" }
    elseif vim.fn.executable("powershell.exe") == 1 then
      return { "powershell.exe", "-NoLogo" }
    else
      return { "cmd.exe" }
    end
  elseif M.is_wsl then
    -- WSL
    return { "/bin/bash" }
  elseif M.is_termux then
    -- Termux
    if vim.fn.executable("/data/data/com.termux/files/usr/bin/zsh") == 1 then
      return { "/data/data/com.termux/files/usr/bin/zsh" }
    else
      return { "/data/data/com.termux/files/usr/bin/bash" }
    end
  else
    -- Linux/macOS
    local shell = os.getenv("SHELL") or "/bin/bash"
    return { shell }
  end
end

-- Font configuration based on platform
M.get_font_config = function()
  if M.is_windows then
    return {
      name = "CaskaydiaCove Nerd Font",
      size = 11,
      fallback = { "Consolas", "Courier New" }
    }
  elseif M.is_termux then
    return {
      name = "Termux",
      size = 12,
      fallback = { "monospace" }
    }
  else
    return {
      name = "JetBrainsMono Nerd Font",
      size = 11,
      fallback = { "DejaVu Sans Mono", "monospace" }
    }
  end
end

-- Clipboard configuration
M.setup_clipboard = function()
  if M.is_wsl then
    -- WSL clipboard integration
    vim.g.clipboard = {
      name = 'win32yank-wsl',
      copy = {
        ['+'] = 'win32yank.exe -i --crlf',
        ['*'] = 'win32yank.exe -i --crlf',
      },
      paste = {
        ['+'] = 'win32yank.exe -o --lf',
        ['*'] = 'win32yank.exe -o --lf',
      },
      cache_enabled = false,
    }
  elseif M.is_termux then
    -- Termux clipboard integration
    if vim.fn.executable('termux-clipboard-get') == 1 and vim.fn.executable('termux-clipboard-set') == 1 then
      vim.g.clipboard = {
        name = 'termux',
        copy = {
          ['+'] = 'termux-clipboard-set',
          ['*'] = 'termux-clipboard-set',
        },
        paste = {
          ['+'] = 'termux-clipboard-get',
          ['*'] = 'termux-clipboard-get',
        },
        cache_enabled = false,
      }
    end
  else
    -- Default system clipboard
    vim.opt.clipboard = "unnamedplus"
  end
end

-- Platform-specific LSP configurations
M.get_lsp_config = function()
  local config = {
    -- Common LSP servers for all platforms
    ensure_installed = {
      "lua_ls",
      "jsonls",
      "yamlls",
    },

    -- Platform-specific servers
    platform_servers = {}
  }

  if M.is_windows then
    -- Windows-specific LSP servers
    table.insert(config.ensure_installed, "powershell_es")
    config.platform_servers.powershell_es = {
      bundle_path = vim.fn.stdpath("data") .. "/mason/packages/powershell-editor-services",
    }
  end

  if M.is_termux then
    -- Termux has limited LSP support, focus on essential ones
    config.ensure_installed = {
      "lua_ls",
      "bashls",
      "jsonls",
    }
  else
    -- Full desktop environment
    vim.list_extend(config.ensure_installed, {
      "tsserver",
      "bashls",
      "pyright",
      "eslint",
    })
  end

  return config
end

-- Performance optimizations based on platform
M.get_performance_config = function()
  local config = {}

  if M.is_termux then
    -- Termux performance optimizations
    config.updatetime = 1000 -- Slower update time
    config.timeout = true
    config.timeoutlen = 1000
    config.ttimeoutlen = 100
    config.lazyredraw = true
    config.ttyfast = false

    -- Reduce some heavy features
    config.foldenable = false
    config.foldmethod = "manual"

  elseif M.is_windows then
    -- Windows optimizations
    config.updatetime = 300
    config.timeout = true
    config.timeoutlen = 500
    config.ttimeoutlen = 50

  else
    -- Linux/macOS - full performance
    config.updatetime = 250
    config.timeout = true
    config.timeoutlen = 300
    config.ttimeoutlen = 0
  end

  return config
end

-- Plugin configurations based on platform
M.get_plugin_config = function()
  local config = {
    -- Plugins to disable on certain platforms
    disabled_plugins = {},

    -- Plugin-specific configurations
    plugin_opts = {}
  }

  if M.is_termux then
    -- Disable resource-heavy plugins on Termux
    config.disabled_plugins = {
      "dashboard-nvim", -- Use simpler alternative
      "nvim-tree/nvim-web-devicons", -- Might cause font issues
      "folke/twilight.nvim", -- Performance intensive
    }

    -- Simpler telescope configuration
    config.plugin_opts.telescope = {
      defaults = {
        layout_strategy = "horizontal",
        layout_config = {
          width = 0.8,
          height = 0.6,
        },
        -- Disable preview for better performance
        preview = false,
      }
    }
  end

  if M.is_windows then
    -- Windows-specific plugin configurations
    config.plugin_opts.neo_tree = {
      filesystem = {
        use_libuv_file_watcher = false, -- Can cause issues on Windows
      }
    }
  end

  return config
end

-- Terminal configuration
M.get_terminal_config = function()
  local config = {
    shell = M.get_shell(),
    size = {
      horizontal = 15,
      vertical = 80,
      float = {
        width = 0.8,
        height = 0.8,
      }
    }
  }

  if M.is_termux then
    -- Adjust sizes for mobile screens
    config.size.horizontal = 10
    config.size.vertical = 60
    config.size.float.width = 0.9
    config.size.float.height = 0.7
  end

  return config
end

-- Key mappings based on platform
M.get_keymaps = function()
  local keymaps = {}

  if M.is_windows then
    -- Windows-specific keymaps (Ctrl instead of Cmd)
    keymaps = {
      { "n", "<C-s>", ":w<CR>", { desc = "Save file" } },
      { "i", "<C-s>", "<Esc>:w<CR>a", { desc = "Save file (insert mode)" } },
      { "n", "<C-z>", ":undo<CR>", { desc = "Undo" } },
      { "n", "<C-y>", ":redo<CR>", { desc = "Redo" } },
    }
  elseif M.is_mac then
    -- macOS-specific keymaps (Cmd key)
    keymaps = {
      { "n", "<D-s>", ":w<CR>", { desc = "Save file" } },
      { "i", "<D-s>", "<Esc>:w<CR>a", { desc = "Save file (insert mode)" } },
      { "n", "<D-z>", ":undo<CR>", { desc = "Undo" } },
      { "n", "<D-S-z>", ":redo<CR>", { desc = "Redo" } },
    }
  else
    -- Linux/Termux - standard keymaps
    keymaps = {
      { "n", "<C-s>", ":w<CR>", { desc = "Save file" } },
      { "i", "<C-s>", "<Esc>:w<CR>a", { desc = "Save file (insert mode)" } },
    }
  end

  return keymaps
end

-- Environment setup function
M.setup_environment = function()
  -- Set python and node hosts
  vim.g.python3_host_prog = M.get_python_path()
  vim.g.node_host_prog = M.get_node_path()

  -- Setup clipboard
  M.setup_clipboard()

  -- Apply performance settings
  local perf_config = M.get_performance_config()
  for option, value in pairs(perf_config) do
    vim.opt[option] = value
  end

  -- Platform-specific settings
  if M.is_windows then
    -- Windows-specific settings
    vim.opt.shellslash = false
    vim.opt.fileformat = "dos"
  elseif M.is_termux then
    -- Termux-specific settings
    vim.opt.mouse = "" -- Disable mouse on mobile
    vim.opt.number = true
    vim.opt.relativenumber = false -- Better for mobile
  end

  -- Set shell
  local shell_config = M.get_terminal_config()
  if shell_config.shell and #shell_config.shell > 0 then
    vim.opt.shell = shell_config.shell[1]
  end
end

-- Debug function to show platform info
M.show_platform_info = function()
  local info = {
    "Platform: " .. M.os_name,
    "Windows: " .. tostring(M.is_windows),
    "WSL: " .. tostring(M.is_wsl),
    "Linux: " .. tostring(M.is_linux),
    "macOS: " .. tostring(M.is_mac),
    "Termux: " .. tostring(M.is_termux),
    "Config path: " .. M.config_path,
    "Python: " .. M.get_python_path(),
    "Node: " .. M.get_node_path(),
    "Shell: " .. table.concat(M.get_shell(), " "),
  }

  print("🌿 Rastafari Neovim Platform Info 🌿")
  for _, line in ipairs(info) do
    print("  " .. line)
  end
end

return M