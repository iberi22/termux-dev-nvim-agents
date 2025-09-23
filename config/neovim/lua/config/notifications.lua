-- ====================================
-- Mason Notification Fix
-- Specific fixes for Mason LSP notification issues
-- ====================================

local M = {}

-- Notification levels configuration
M.setup_notification_levels = function()
  -- Set vim diagnostic levels
  vim.diagnostic.config({
    virtual_text = {
      severity = { min = vim.diagnostic.severity.WARN }
    },
    signs = {
      severity = { min = vim.diagnostic.severity.WARN }
    },
    underline = {
      severity = { min = vim.diagnostic.severity.ERROR }
    },
    float = {
      severity = { min = vim.diagnostic.severity.WARN }
    },
  })

  -- Reduce LSP log level
  vim.lsp.set_log_level("warn")
end

-- Filter Mason notifications
M.setup_mason_notification_filter = function()
  -- Hook into Mason's package installation process
  local mason_registry = require("mason-registry")

  -- List of messages to suppress
  local suppress_patterns = {
    "npm WARN",
    "npm notice",
    "npm info",
    "downloading",
    "extracting",
    "validating",
    "linking",
    "building dependencies",
    "gyp info",
    "make:",
    "gcc:",
    "ld:",
    "ar:",
    "ranlib:",
  }

  -- Custom notification function that filters messages
  local function filtered_notify(msg, level, opts)
    if type(msg) == "string" then
      -- Check if message should be suppressed
      for _, pattern in ipairs(suppress_patterns) do
        if msg:lower():find(pattern:lower(), 1, true) then
          return -- Suppress this notification
        end
      end

      -- Only show important messages
      if level and level >= vim.log.levels.WARN then
        require("notify")(msg, level, opts)
      end
    end
  end

  -- Override mason's notification system
  if mason_registry then
    -- Intercept package installation output
    mason_registry:on("package:install:start", function(pkg)
      vim.schedule(function()
        vim.notify(
          "🌿 Installing " .. pkg.name .. "... Jah guide us!",
          vim.log.levels.INFO,
          {
            title = "Mason - Rastafari Install",
            timeout = 2000,
          }
        )
      end)
    end)

    -- Only show final results
    mason_registry:on("package:install:success", function(pkg)
      vim.schedule(function()
        vim.notify(
          "✅ " .. pkg.name .. " ready fi code! One love! 🌿",
          vim.log.levels.INFO,
          {
            title = "Mason Success",
            timeout = 3000,
          }
        )
      end)
    end)

    mason_registry:on("package:install:failed", function(pkg)
      vim.schedule(function()
        vim.notify(
          "❌ " .. pkg.name .. " installation failed. Babylon problems! 🦁",
          vim.log.levels.ERROR,
          {
            title = "Mason Failed",
            timeout = 5000,
          }
        )
      end)
    end)
  end
end

-- Suppress LSP startup messages
M.setup_lsp_notification_filter = function()
  local original_notify = vim.notify

  vim.notify = function(msg, level, opts)
    if type(msg) == "string" then
      -- Suppress common LSP startup messages
      local lsp_suppress_patterns = {
        "LSP.*started",
        "LSP.*attached",
        "LSP.*ready",
        "Language server.*started",
        "Client.*attached",
        "Workspace.*loaded",
        "Configuration.*updated",
        "Server capabilities",
        "textDocument/semanticTokens",
        "workspace/didChangeConfiguration",
      }

      for _, pattern in ipairs(lsp_suppress_patterns) do
        if msg:match(pattern) then
          return -- Suppress this notification
        end
      end
    end

    -- Call original notify for non-suppressed messages
    return original_notify(msg, level, opts)
  end
end

-- Setup notification management for different environments
M.setup_environment_specific_filters = function()
  local platform = require("config.platform")

  if platform.is_termux() then
    -- Termux-specific: be more aggressive with notification filtering
    vim.g.mason_notification_level = vim.log.levels.ERROR

    -- Reduce update time for better responsiveness
    vim.opt.updatetime = 250

    -- Disable some verbose features
    vim.g.loaded_python3_provider = 0
    vim.g.loaded_ruby_provider = 0
    vim.g.loaded_perl_provider = 0

  elseif platform.is_windows() then
    -- Windows-specific: handle PowerShell output better
    vim.g.mason_notification_level = vim.log.levels.WARN

    -- Set Windows-specific shell options
    if vim.fn.executable("pwsh") == 1 then
      vim.opt.shell = "pwsh"
    elseif vim.fn.executable("powershell") == 1 then
      vim.opt.shell = "powershell"
    end

  else
    -- Linux/macOS: standard filtering
    vim.g.mason_notification_level = vim.log.levels.INFO
  end
end

-- Command to toggle notification levels
M.setup_notification_commands = function()
  -- Command to show/hide all notifications
  vim.api.nvim_create_user_command("RastafariNotifyToggle", function()
    local notify = require("notify")

    if vim.g.rastafari_notifications_enabled == false then
      vim.g.rastafari_notifications_enabled = true
      vim.notify = notify
      vim.notify("🌿 Notifications enabled! Jah speaks!", vim.log.levels.INFO)
    else
      vim.g.rastafari_notifications_enabled = false
      vim.notify("🤫 Notifications disabled. Silent meditation mode...", vim.log.levels.INFO)
      vim.notify = function() end -- Disable notifications
    end
  end, { desc = "Toggle Rastafari notifications on/off" })

  -- Command to set notification level
  vim.api.nvim_create_user_command("RastafariNotifyLevel", function(opts)
    local levels = {
      error = vim.log.levels.ERROR,
      warn = vim.log.levels.WARN,
      info = vim.log.levels.INFO,
      debug = vim.log.levels.DEBUG,
    }

    local level_name = opts.args:lower()
    local level = levels[level_name]

    if level then
      vim.g.rastafari_notification_level = level
      vim.notify(
        "🎵 Notification level set to: " .. level_name:upper(),
        vim.log.levels.INFO,
        { title = "Rastafari Notifications" }
      )
    else
      vim.notify(
        "❌ Invalid level. Use: error, warn, info, debug",
        vim.log.levels.ERROR,
        { title = "Rastafari Notifications" }
      )
    end
  end, {
    desc = "Set Rastafari notification level",
    nargs = 1,
    complete = function()
      return { "error", "warn", "info", "debug" }
    end
  })

  -- Command to clear all notifications
  vim.api.nvim_create_user_command("RastafariNotifyClear", function()
    require("notify").dismiss({ silent = true, pending = true })
    vim.notify("🧹 All notifications cleared! Clean slate, clean mind!", vim.log.levels.INFO)
  end, { desc = "Clear all Rastafari notifications" })
end

-- Initialize all notification fixes
M.init = function()
  -- Apply all notification management setups
  M.setup_notification_levels()
  M.setup_mason_notification_filter()
  M.setup_lsp_notification_filter()
  M.setup_environment_specific_filters()
  M.setup_notification_commands()

  -- Set initial notification state
  vim.g.rastafari_notifications_enabled = true
  vim.g.rastafari_notification_level = vim.log.levels.INFO

  -- Auto-apply settings after Mason loads
  vim.api.nvim_create_autocmd("User", {
    pattern = "MasonToolsStartingInstall",
    callback = function()
      M.setup_mason_notification_filter()
    end
  })

  -- Setup notification cleanup timer
  local timer = vim.loop.new_timer()
  timer:start(30000, 30000, vim.schedule_wrap(function()
    -- Auto-dismiss old notifications every 30 seconds
    pcall(require("notify").dismiss, { silent = true, pending = false })
  end))
end

return M