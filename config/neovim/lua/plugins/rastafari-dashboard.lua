-- ====================================
-- Rastafari Dashboard Configuration
-- Custom startup screen with Rastafari aesthetics
-- ====================================

return {
  -- Snacks dashboard with rastafari customization
  {
    "folke/snacks.nvim",
    opts = {
      dashboard = {
        sections = {
          { section = "header" },
          { icon = "🌿", title = "One Love Projects", section = "recent_files", indent = 2, padding = 1 },
          { icon = "🎵", title = "Jah Commands", section = "keys", indent = 2, padding = 1 },
          { icon = "🦁", title = "Lion's Den (Sessions)", section = "projects", indent = 2, padding = 1 },
          { section = "startup" },
        },
        preset = {
          header = [[
                    🌿🦁🔥 JAH BLESS NEOVIM 🔥🦁🌿

              ██████╗  █████╗ ███████╗████████╗ █████╗
              ██╔══██╗██╔══██╗██╔════╝╚══██╔══╝██╔══██╗
              ██████╔╝███████║███████╗   ██║   ███████║
              ██╔══██╗██╔══██║╚════██║   ██║   ██╔══██║
              ██║  ██║██║  ██║███████║   ██║   ██║  ██║
              ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝   ╚═╝   ╚═╝  ╚═╝

                 🎵 Get up, stand up, code for your rights! 🎵

                  ════════════════════════════════════════
                  RED 🔴 for the blood of the people
                  YELLOW 🟡 for the wealth of the homeland
                  GREEN 🟢 for the beauty of the land
                  ════════════════════════════════════════

          ]],
          keys = {
            { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
            { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
            { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
            { icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep')" },
            { icon = " ", key = "c", desc = "Config", action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})" },
            { icon = " ", key = "s", desc = "Restore Session", section = "session" },
            { icon = "🌿", key = "z", desc = "Zen Mode", action = ":ZenMode" },
            { icon = "🎵", key = "m", desc = "Mason", action = ":Mason" },
            { icon = "🦁", key = "l", desc = "Lazy", action = ":Lazy" },
            { icon = " ", key = "q", desc = "Quit", action = ":qa" },
          },
        },
      },
      styles = {
        dashboard = {
          backdrop = false,
          border = "rounded",
          win = {
            style = "minimal",
          },
        },
      },
    },
  },

  -- Custom highlight groups for the dashboard
  {
    "folke/snacks.nvim",
    config = function()
      -- Set custom highlight groups for rastafari dashboard
      vim.api.nvim_set_hl(0, "SnacksDashboardHeader", { fg = "#FF6B6B", bold = true })
      vim.api.nvim_set_hl(0, "SnacksDashboardKey", { fg = "#6BCF7F", bold = true })
      vim.api.nvim_set_hl(0, "SnacksDashboardDesc", { fg = "#FFD93D" })
      vim.api.nvim_set_hl(0, "SnacksDashboardIcon", { fg = "#FF6B6B" })
      vim.api.nvim_set_hl(0, "SnacksDashboardTitle", { fg = "#6BCF7F", bold = true })
    end,
  },
}