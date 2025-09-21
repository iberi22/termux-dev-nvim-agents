-- ====================================
-- UI Configuration with System Metrics
-- Based on Gentleman.Dots with CPU/Memory monitoring
-- ====================================

-- System metrics utility functions
local M = {}

-- Cache for system metrics to avoid frequent file reads
local metrics_cache = {
  cpu_percent = 0,
  mem_percent = 0,
  last_update = 0,
  update_interval = 2, -- seconds
}

-- Read CPU usage from /proc/stat
local function get_cpu_usage()
  local stat_file = io.open("/proc/stat", "r")
  if not stat_file then
    return 0
  end

  local line = stat_file:read("*line")
  stat_file:close()

  if not line then
    return 0
  end

  -- Parse CPU line: cpu user nice system idle iowait irq softirq steal guest guest_nice
  local values = {}
  for num in line:gmatch("%d+") do
    table.insert(values, tonumber(num))
  end

  if #values < 4 then
    return 0
  end

  local idle = values[4] + (values[5] or 0) -- idle + iowait
  local total = 0
  for i = 1, math.min(#values, 10) do
    total = total + values[i]
  end

  local usage = total > 0 and math.floor(((total - idle) / total) * 100) or 0
  return math.max(0, math.min(100, usage))
end

-- Read memory usage from /proc/meminfo
local function get_memory_usage()
  local meminfo_file = io.open("/proc/meminfo", "r")
  if not meminfo_file then
    return 0
  end

  local meminfo = meminfo_file:read("*all")
  meminfo_file:close()

  local total = meminfo:match("MemTotal:%s*(%d+)%s*kB")
  local available = meminfo:match("MemAvailable:%s*(%d+)%s*kB") or meminfo:match("MemFree:%s*(%d+)%s*kB")

  if not total or not available then
    return 0
  end

  total = tonumber(total)
  available = tonumber(available)

  if not total or not available or total == 0 then
    return 0
  end

  local used_percent = math.floor(((total - available) / total) * 100)
  return math.max(0, math.min(100, used_percent))
end

-- Update system metrics with caching
local function update_metrics()
  local current_time = vim.loop.now() / 1000

  if current_time - metrics_cache.last_update < metrics_cache.update_interval then
    return
  end

  -- Update in background to avoid blocking UI
  vim.schedule(function()
    metrics_cache.cpu_percent = get_cpu_usage()
    metrics_cache.mem_percent = get_memory_usage()
    metrics_cache.last_update = current_time
  end)
end

-- Get formatted CPU usage
function M.get_cpu()
  update_metrics()
  local cpu = metrics_cache.cpu_percent
  local icon = cpu > 80 and "🔥" or cpu > 60 and "⚡" or "💻"
  return string.format("%s %d%%", icon, cpu)
end

-- Get formatted memory usage
function M.get_memory()
  update_metrics()
  local mem = metrics_cache.mem_percent
  local icon = mem > 80 and "🔥" or mem > 60 and "⚠️ " or "🧠"
  return string.format("%s %d%%", icon, mem)
end

-- Get combined system info
function M.get_system_info()
  update_metrics()
  return string.format("💻 %d%% 🧠 %d%%", metrics_cache.cpu_percent, metrics_cache.mem_percent)
end

return {
  -- Lualine - Enhanced statusline with system metrics
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      options = {
        theme = "auto",
        icons_enabled = true,
        component_separators = { left = '', right = '' },
        section_separators = { left = '', right = '' },
        disabled_filetypes = {
          statusline = {},
          winbar = {},
        },
        ignore_focus = {},
        always_divide_middle = true,
        globalstatus = true,
        refresh = {
          statusline = 1000,
          tabline = 1000,
          winbar = 1000,
        }
      },
      sections = {
        lualine_a = {
          {
            "mode",
            icon = "󱗞",
            separator = { right = '' },
            right_padding = 2,
          },
        },
        lualine_b = {
          {
            "branch",
            icon = "",
          },
          {
            "diff",
            symbols = { added = " ", modified = " ", removed = " " },
          },
          {
            "diagnostics",
            sources = { "nvim_diagnostic", "nvim_lsp" },
            symbols = { error = " ", warn = " ", info = " ", hint = " " },
          },
        },
        lualine_c = {
          {
            "filename",
            file_status = true,
            newfile_status = false,
            path = 1, -- 0: just filename, 1: relative path, 2: absolute path, 3: absolute path with ~ for home
            symbols = {
              modified = "[+]",
              readonly = "[-]",
              unnamed = "[No Name]",
              newfile = "[New]",
            },
          },
        },
        lualine_x = {
          -- System metrics
          {
            M.get_cpu,
            color = function()
              update_metrics()
              local cpu = metrics_cache.cpu_percent
              if cpu > 80 then
                return { fg = '#ff6b6b', gui = 'bold' }
              elseif cpu > 60 then
                return { fg = '#feca57', gui = 'bold' }
              else
                return { fg = '#48cab2', gui = 'bold' }
              end
            end,
          },
          {
            M.get_memory,
            color = function()
              update_metrics()
              local mem = metrics_cache.mem_percent
              if mem > 80 then
                return { fg = '#ff6b6b', gui = 'bold' }
              elseif mem > 60 then
                return { fg = '#feca57', gui = 'bold' }
              else
                return { fg = '#48cab2', gui = 'bold' }
              end
            end,
          },
          {
            "encoding",
            fmt = string.upper,
          },
          {
            "fileformat",
            symbols = {
              unix = "",
              dos = "",
              mac = "",
            },
          },
          {
            "filetype",
            icon_only = true,
          },
        },
        lualine_y = {
          {
            "progress",
            separator = { left = '' },
            left_padding = 2,
          },
        },
        lualine_z = {
          {
            "location",
            separator = { left = '' },
            left_padding = 2,
          },
        },
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { "filename" },
        lualine_x = { "location" },
        lualine_y = {},
        lualine_z = {},
      },
      tabline = {},
      winbar = {},
      inactive_winbar = {},
      extensions = {
        "quickfix",
        "oil",
        {
          filetypes = { "codecompanion" },
          sections = {
            lualine_a = {
              {
                "mode",
                icon = "🤖",
              },
            },
            lualine_b = {
              function()
                return "CodeCompanion"
              end,
            },
            lualine_c = {
              function()
                return "AI Chat Active"
              end,
            },
            lualine_x = {
              M.get_system_info,
            },
            lualine_y = {
              "progress",
            },
            lualine_z = {
              "location",
            },
          },
        },
      },
    },
  },

  -- Incline - Floating filename with system info
  {
    "b0o/incline.nvim",
    event = "BufReadPre",
    priority = 1200,
    config = function()
      require("incline").setup({
        highlight = {
          groups = {
            InclineNormal = { guibg = "#363a4f", guifg = "#cad3f5" },
            InclineNormalNC = { guifg = "#6e738d", guibg = "#24273a" },
          },
        },
        window = { margin = { vertical = 0, horizontal = 1 } },
        hide = {
          cursorline = true,
        },
        render = function(props)
          local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ":t")
          if vim.bo[props.buf].modified then
            filename = "[+] " .. filename
          end

          local icon, color = require("nvim-web-devicons").get_icon_color(filename)
          local system_info = M.get_system_info()

          return {
            { icon, guifg = color },
            { " " },
            { filename },
            { " | " },
            { system_info, guifg = "#8aadf4" },
          }
        end,
      })
    end,
  },

  -- Alpha dashboard with system info
  {
    "goolord/alpha-nvim",
    event = "VimEnter",
    config = function()
      local alpha = require("alpha")
      local dashboard = require("alpha.themes.dashboard")

      -- Custom header with system info
      dashboard.section.header.val = {
        "                                                     ",
        "  ███╗   ██╗██╗   ██╗██╗███╗   ███╗                ",
        "  ████╗  ██║██║   ██║██║████╗ ████║                ",
        "  ██╔██╗ ██║██║   ██║██║██╔████╔██║                ",
        "  ██║╚██╗██║╚██╗ ██╔╝██║██║╚██╔╝██║                ",
        "  ██║ ╚████║ ╚████╔╝ ██║██║ ╚═╝ ██║                ",
        "  ╚═╝  ╚═══╝  ╚═══╝  ╚═╝╚═╝     ╚═╝                ",
        "                                                     ",
        "         🚀 TERMUX AI DEVELOPMENT ENVIRONMENT 🚀    ",
        "                                                     ",
      }

      -- Enhanced buttons with AI shortcuts
      dashboard.section.buttons.val = {
        dashboard.button("f", "  Find file", ":Telescope find_files <CR>"),
        dashboard.button("n", "  New file", ":ene <BAR> startinsert <CR>"),
        dashboard.button("r", "  Recently used files", ":Telescope oldfiles <CR>"),
        dashboard.button("t", "  Find text", ":Telescope live_grep <CR>"),
        dashboard.button("c", "  Configuration", ":e ~/.config/nvim/init.lua <CR>"),
        dashboard.button("a", "🤖  AI Chat", ":CodeCompanionChat<CR>"),
        dashboard.button("g", "🧠  Gemini", ":Gemini<CR>"),
        dashboard.button("p", "🔄  Switch AI Provider", ":lua require('codecompanion').switch_provider()<CR>"),
        dashboard.button("q", "  Quit Neovim", ":qa<CR>"),
      }

      -- Footer with system metrics
      dashboard.section.footer.val = function()
        update_metrics()
        local stats = require("lazy").stats()
        local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
        local system_info = string.format(
          "💻 CPU: %d%% | 🧠 RAM: %d%% | ⚡ Loaded %d plugins in %.2fms",
          metrics_cache.cpu_percent,
          metrics_cache.mem_percent,
          stats.loaded,
          ms
        )
        return { system_info }
      end

      dashboard.section.footer.opts.hl = "Type"
      dashboard.section.header.opts.hl = "Include"
      dashboard.section.buttons.opts.hl = "Keyword"

      dashboard.opts.opts.noautocmd = true
      alpha.setup(dashboard.opts)
    end,
  },

  -- Zen Mode
  {
    "folke/zen-mode.nvim",
    cmd = "ZenMode",
    keys = { { "<leader>z", "<cmd>ZenMode<cr>", desc = "Zen Mode" } },
    opts = {
      plugins = {
        gitsigns = true,
        tmux = true,
        kitty = { enabled = false, font = "+2" },
        alacritty = { enabled = false, font = "14" },
      },
    },
  },

  -- Twilight
  {
    "folke/twilight.nvim",
    cmd = "Twilight",
    keys = { { "<leader>tw", "<cmd>Twilight<cr>", desc = "Twilight" } },
    opts = {
      dimming = {
        alpha = 0.25,
        color = { "Normal", "#ffffff" },
        term_bg = "#000000",
        inactive = false,
      },
      context = 10,
      treesitter = true,
      expand = {
        "function",
        "method",
        "table",
        "if_statement",
      },
      exclude = {},
    },
  },

  -- Which-key
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "classic",
      win = { border = "single" },
      spec = {
        { "<leader>a", group = "AI" },
        { "<leader>ac", desc = "AI Chat Toggle" },
        { "<leader>an", desc = "AI New Chat" },
        { "<leader>aa", desc = "AI Actions" },
        { "<leader>ap", desc = "AI Switch Provider" },
        { "<leader>ae", desc = "AI Explain", mode = "v" },
        { "<leader>c", group = "Code" },
        { "<leader>cc", group = "Copilot Chat" },
        { "<leader>g", group = "Git/Gemini" },
        { "<leader>gc", desc = "Gemini Chat" },
        { "<leader>gq", desc = "Gemini Quick" },
        { "<leader>s", group = "System" },
        { "<leader>sm", desc = "Show System Metrics" },
      },
    },
    keys = {
      {
        "<leader>?",
        function()
          require("which-key").show({ global = false })
        end,
        desc = "Buffer Local Keymaps (which-key)",
      },
      {
        "<leader>sm",
        function()
          update_metrics()
          vim.notify(
            string.format("💻 CPU: %d%% | 🧠 Memory: %d%%", metrics_cache.cpu_percent, metrics_cache.mem_percent),
            vim.log.levels.INFO,
            { title = "System Metrics" }
          )
        end,
        desc = "Show System Metrics",
      },
    },
  },

  -- Snacks (dashboard)
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      bigfile = { enabled = true },
      notifier = {
        enabled = true,
        timeout = 3000,
      },
      quickfile = { enabled = true },
      statuscolumn = { enabled = true },
      words = { enabled = true },
      dashboard = {
        enabled = true,
        preset = {
          header = [[
🚀 TERMUX AI DEVELOPMENT ENVIRONMENT 🚀
           Powered by Neovim + AI
          ]],
        },
        sections = {
          { section = "header" },
          { section = "keys", gap = 1, padding = 1 },
          { section = "startup" },
          {
            section = "terminal",
            cmd = "echo '💻 System Status:' && echo '└─ CPU: " .. (M.get_cpu or function() return "N/A" end)() .. "' && echo '└─ RAM: " .. (M.get_memory or function() return "N/A" end)() .. "'",
            height = 3,
            padding = 1,
          },
        },
      },
    },
  },

  -- Noice for better UI messages
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    opts = {
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = true,
        },
      },
      routes = {
        {
          filter = {
            event = "msg_show",
            any = {
              { find = "%d+L, %d+B" },
              { find = "; after #%d+" },
              { find = "; before #%d+" },
            },
          },
          view = "mini",
        },
      },
      presets = {
        bottom_search = true,
        command_palette = true,
        long_message_to_split = true,
        inc_rename = true,
        lsp_doc_border = false,
      },
      views = {
        cmdline_popup = {
          position = {
            row = 5,
            col = "50%",
          },
          size = {
            width = 60,
            height = "auto",
          },
        },
        popupmenu = {
          relative = "editor",
          position = {
            row = 8,
            col = "50%",
          },
          size = {
            width = 60,
            height = 10,
          },
          border = {
            style = "rounded",
            padding = { 0, 1 },
          },
          win_options = {
            winhighlight = { Normal = "Normal", FloatBorder = "DiagnosticInfo" },
          },
        },
      },
    },
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
  },
}