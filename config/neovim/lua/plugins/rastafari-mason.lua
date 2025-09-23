-- ====================================
-- Rastafari Mason Configuration
-- Custom Mason setup with Rastafari colors and better notifications
-- ====================================

return {
  -- Mason with custom styling
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    build = ":MasonUpdate",
    opts = {
      ui = {
        border = "rounded",
        width = 0.8,
        height = 0.8,
        icons = {
          package_installed = "🌿",
          package_pending = "🎵",
          package_uninstalled = "🦁",
        },
      },
    },
    config = function(_, opts)
      require("mason").setup(opts)

      -- Custom Mason highlight groups with rastafari colors
      vim.api.nvim_set_hl(0, "MasonNormal", { bg = "#1A1A1A" })
      vim.api.nvim_set_hl(0, "MasonHeader", { fg = "#1A1A1A", bg = "#FFD93D", bold = true })
      vim.api.nvim_set_hl(0, "MasonHeaderSecondary", { fg = "#F5F5F5", bg = "#6BCF7F" })
      vim.api.nvim_set_hl(0, "MasonHighlight", { fg = "#FF6B6B", bold = true })
      vim.api.nvim_set_hl(0, "MasonHighlightBlock", { fg = "#1A1A1A", bg = "#6BCF7F" })
      vim.api.nvim_set_hl(0, "MasonHighlightBlockBold", { fg = "#1A1A1A", bg = "#6BCF7F", bold = true })
      vim.api.nvim_set_hl(0, "MasonMuted", { fg = "#A0A0A0" })
      vim.api.nvim_set_hl(0, "MasonMutedBlock", { fg = "#F5F5F5", bg = "#2A2A2A" })
      vim.api.nvim_set_hl(0, "MasonMutedBlockBold", { fg = "#F5F5F5", bg = "#2A2A2A", bold = true })

      -- Fix Mason notifications to be less intrusive
      local mason_registry = require("mason-registry")

      -- Override package installation notifications
      local original_install = mason_registry.Package.install
      mason_registry.Package.install = function(self, opts)
        opts = opts or {}
        local original_on_output = opts.on_output_event

        opts.on_output_event = function(event)
          -- Filter out verbose installation messages
          if event.type == "stdout" or event.type == "stderr" then
            local message = event.data
            -- Only show important messages
            if message:match("error") or message:match("Error") or
               message:match("failed") or message:match("Failed") or
               message:match("success") or message:match("Success") or
               message:match("installed") or message:match("Installed") then
              if original_on_output then
                original_on_output(event)
              end
            end
          end
        end

        return original_install(self, opts)
      end

      -- Custom notification for successful installations
      mason_registry:on("package:install:success", function(pkg)
        vim.schedule(function()
          vim.notify(
            "🌿 " .. pkg.name .. " installed successfully! Jah bless!",
            vim.log.levels.INFO,
            { title = "Mason - One Love Install" }
          )
        end)
      end)

      -- Custom notification for failed installations
      mason_registry:on("package:install:failed", function(pkg)
        vim.schedule(function()
          vim.notify(
            "🦁 " .. pkg.name .. " installation failed. Keep fighting!",
            vim.log.levels.ERROR,
            { title = "Mason - Babylon Problems" }
          )
        end)
      end)
    end,
  },

  -- Mason LSP config with better defaults
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "mason.nvim" },
    opts = {
      ensure_installed = {
        "lua_ls",
        "bashls",
        "pyright",
        "tsserver",
        "jsonls",
        "yamlls",
      },
      automatic_installation = true,
    },
    config = function(_, opts)
      require("mason-lspconfig").setup(opts)

      -- Suppress verbose LSP notifications
      local lspconfig = require("lspconfig")
      local original_setup = lspconfig.util.setup

      lspconfig.util.setup = function(config)
        config.on_attach = function(client, bufnr)
          -- Disable semantic tokens for better performance
          client.server_capabilities.semanticTokensProvider = nil

          -- Custom on_attach logic if needed
          if config.on_attach then
            config.on_attach(client, bufnr)
          end
        end

        return original_setup(config)
      end
    end,
  },

  -- Mason tool installer
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "mason.nvim" },
    opts = {
      ensure_installed = {
        "prettier",
        "stylua",
        "shellcheck",
        "shfmt",
        "black",
        "isort",
      },
      auto_update = false,
      run_on_start = true,
    },
  },

  -- Better notifications with rastafari styling
  {
    "rcarriga/nvim-notify",
    opts = {
      background_colour = "#1A1A1A",
      fps = 30,
      icons = {
        DEBUG = "🎵",
        ERROR = "🔥",
        INFO = "🌿",
        TRACE = "✨",
        WARN = "⚠️ ",
      },
      level = 2,
      minimum_width = 50,
      render = "compact",
      stages = "fade_in_slide_out",
      timeout = 3000,
      top_down = true,
    },
    config = function(_, opts)
      require("notify").setup(opts)

      -- Set as default notification handler
      vim.notify = require("notify")

      -- Custom highlight groups for notifications
      vim.api.nvim_set_hl(0, "NotifyERRORBorder", { fg = "#FF6B6B" })
      vim.api.nvim_set_hl(0, "NotifyWARNBorder", { fg = "#FFD93D" })
      vim.api.nvim_set_hl(0, "NotifyINFOBorder", { fg = "#6BCF7F" })
      vim.api.nvim_set_hl(0, "NotifyDEBUGBorder", { fg = "#A0A0A0" })

      vim.api.nvim_set_hl(0, "NotifyERRORIcon", { fg = "#FF6B6B" })
      vim.api.nvim_set_hl(0, "NotifyWARNIcon", { fg = "#FFD93D" })
      vim.api.nvim_set_hl(0, "NotifyINFOIcon", { fg = "#6BCF7F" })
      vim.api.nvim_set_hl(0, "NotifyDEBUGIcon", { fg = "#A0A0A0" })

      vim.api.nvim_set_hl(0, "NotifyERRORTitle", { fg = "#FF6B6B", bold = true })
      vim.api.nvim_set_hl(0, "NotifyWARNTitle", { fg = "#FFD93D", bold = true })
      vim.api.nvim_set_hl(0, "NotifyINFOTitle", { fg = "#6BCF7F", bold = true })
      vim.api.nvim_set_hl(0, "NotifyDEBUGTitle", { fg = "#A0A0A0", bold = true })
    end,
  },
}