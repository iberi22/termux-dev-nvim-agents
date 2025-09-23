-- ====================================
-- Rastafari Colorscheme for Neovim
-- Inspired by Bob Marley's legacy and Rastafari colors
-- Colors: Red (#FF6B6B), Yellow (#FFD93D), Green (#6BCF7F)
-- ====================================

return {
  -- Custom Rastafari colorscheme plugin
  {
    "rasta-nvim/rastafari.nvim",
    name = "rastafari",
    priority = 1000,
    config = function()
      -- Rastafari color palette
      local colors = {
        -- Core Rastafari colors
        rasta_red = "#FF6B6B",      -- Fire red
        rasta_yellow = "#FFD93D",   -- Sun yellow
        rasta_green = "#6BCF7F",    -- Nature green

        -- Complementary colors
        dark_red = "#CC5555",
        dark_yellow = "#E6C234",
        dark_green = "#55A065",

        -- Background colors
        bg_dark = "#1A1A1A",
        bg_medium = "#2A2A2A",
        bg_light = "#3A3A3A",

        -- Text colors
        fg_primary = "#F5F5F5",
        fg_secondary = "#D0D0D0",
        fg_tertiary = "#A0A0A0",

        -- Accent colors
        orange = "#FF8C42",
        purple = "#9B59B6",
        blue = "#3498DB",

        -- Status colors
        success = "#6BCF7F",
        warning = "#FFD93D",
        error = "#FF6B6B",
        info = "#3498DB",
      }

      -- Define highlight groups
      local function setup_highlights()
        local highlights = {
          -- Editor basics
          Normal = { fg = colors.fg_primary, bg = colors.bg_dark },
          NormalFloat = { fg = colors.fg_primary, bg = colors.bg_medium },
          NormalNC = { fg = colors.fg_secondary, bg = colors.bg_dark },

          -- Cursor and selection
          Cursor = { fg = colors.bg_dark, bg = colors.rasta_yellow },
          CursorLine = { bg = colors.bg_medium },
          CursorColumn = { bg = colors.bg_medium },
          Visual = { bg = colors.dark_green },
          VisualNOS = { bg = colors.dark_green },

          -- Line numbers and signs
          LineNr = { fg = colors.fg_tertiary },
          CursorLineNr = { fg = colors.rasta_yellow, bold = true },
          SignColumn = { bg = colors.bg_dark },

          -- Syntax highlighting
          Comment = { fg = colors.fg_tertiary, italic = true },
          Constant = { fg = colors.rasta_yellow },
          String = { fg = colors.rasta_green },
          Character = { fg = colors.rasta_green },
          Number = { fg = colors.rasta_yellow },
          Boolean = { fg = colors.rasta_red },
          Float = { fg = colors.rasta_yellow },

          Identifier = { fg = colors.fg_primary },
          Function = { fg = colors.rasta_red, bold = true },

          Statement = { fg = colors.rasta_red, bold = true },
          Conditional = { fg = colors.rasta_red },
          Repeat = { fg = colors.rasta_red },
          Label = { fg = colors.rasta_yellow },
          Operator = { fg = colors.fg_primary },
          Keyword = { fg = colors.rasta_red, bold = true },
          Exception = { fg = colors.rasta_red },

          PreProc = { fg = colors.rasta_yellow },
          Include = { fg = colors.rasta_yellow },
          Define = { fg = colors.rasta_yellow },
          Macro = { fg = colors.rasta_yellow },
          PreCondit = { fg = colors.rasta_yellow },

          Type = { fg = colors.rasta_green },
          StorageClass = { fg = colors.rasta_green },
          Structure = { fg = colors.rasta_green },
          Typedef = { fg = colors.rasta_green },

          Special = { fg = colors.orange },
          SpecialChar = { fg = colors.orange },
          Tag = { fg = colors.rasta_red },
          Delimiter = { fg = colors.fg_secondary },
          SpecialComment = { fg = colors.rasta_yellow, italic = true },
          Debug = { fg = colors.error },

          -- UI elements
          Pmenu = { fg = colors.fg_primary, bg = colors.bg_medium },
          PmenuSel = { fg = colors.bg_dark, bg = colors.rasta_yellow },
          PmenuSbar = { bg = colors.bg_light },
          PmenuThumb = { bg = colors.rasta_green },

          StatusLine = { fg = colors.fg_primary, bg = colors.bg_medium },
          StatusLineNC = { fg = colors.fg_tertiary, bg = colors.bg_medium },
          WildMenu = { fg = colors.bg_dark, bg = colors.rasta_yellow },

          TabLine = { fg = colors.fg_secondary, bg = colors.bg_medium },
          TabLineFill = { bg = colors.bg_dark },
          TabLineSel = { fg = colors.bg_dark, bg = colors.rasta_yellow },

          -- Window splits
          VertSplit = { fg = colors.bg_light },
          WinSeparator = { fg = colors.bg_light },

          -- Search and matches
          Search = { fg = colors.bg_dark, bg = colors.rasta_yellow },
          IncSearch = { fg = colors.bg_dark, bg = colors.rasta_red },
          MatchParen = { fg = colors.rasta_yellow, bold = true },

          -- Diff colors
          DiffAdd = { bg = colors.dark_green },
          DiffChange = { bg = colors.dark_yellow },
          DiffDelete = { bg = colors.dark_red },
          DiffText = { bg = colors.rasta_yellow },

          -- Diagnostics
          DiagnosticError = { fg = colors.error },
          DiagnosticWarn = { fg = colors.warning },
          DiagnosticInfo = { fg = colors.info },
          DiagnosticHint = { fg = colors.rasta_green },

          -- LSP highlights
          LspReferenceText = { bg = colors.bg_light },
          LspReferenceRead = { bg = colors.bg_light },
          LspReferenceWrite = { bg = colors.bg_light },

          -- Tree-sitter highlights
          ["@keyword"] = { fg = colors.rasta_red, bold = true },
          ["@function"] = { fg = colors.rasta_red, bold = true },
          ["@variable"] = { fg = colors.fg_primary },
          ["@parameter"] = { fg = colors.fg_secondary },
          ["@property"] = { fg = colors.rasta_green },
          ["@string"] = { fg = colors.rasta_green },
          ["@number"] = { fg = colors.rasta_yellow },
          ["@boolean"] = { fg = colors.rasta_red },
          ["@type"] = { fg = colors.rasta_green },
          ["@constant"] = { fg = colors.rasta_yellow },
          ["@comment"] = { fg = colors.fg_tertiary, italic = true },
          ["@operator"] = { fg = colors.fg_primary },
          ["@punctuation"] = { fg = colors.fg_secondary },

          -- Git signs
          GitSignsAdd = { fg = colors.success },
          GitSignsChange = { fg = colors.warning },
          GitSignsDelete = { fg = colors.error },

          -- Telescope
          TelescopeNormal = { fg = colors.fg_primary, bg = colors.bg_medium },
          TelescopeBorder = { fg = colors.rasta_green, bg = colors.bg_medium },
          TelescopeSelection = { fg = colors.bg_dark, bg = colors.rasta_yellow },
          TelescopeMatching = { fg = colors.rasta_red, bold = true },

          -- NvimTree
          NvimTreeNormal = { fg = colors.fg_primary, bg = colors.bg_dark },
          NvimTreeFolderIcon = { fg = colors.rasta_yellow },
          NvimTreeFolderName = { fg = colors.rasta_green },
          NvimTreeOpenedFolderName = { fg = colors.rasta_green, bold = true },
          NvimTreeFileName = { fg = colors.fg_primary },
          NvimTreeSpecialFile = { fg = colors.rasta_red },
          NvimTreeGitDirty = { fg = colors.warning },
          NvimTreeGitNew = { fg = colors.success },
          NvimTreeGitDeleted = { fg = colors.error },

          -- Which-key
          WhichKey = { fg = colors.rasta_red, bold = true },
          WhichKeyDesc = { fg = colors.fg_primary },
          WhichKeyGroup = { fg = colors.rasta_green },
          WhichKeySeparator = { fg = colors.fg_tertiary },

          -- Mason
          MasonNormal = { fg = colors.fg_primary, bg = colors.bg_medium },
          MasonHeader = { fg = colors.bg_dark, bg = colors.rasta_yellow, bold = true },
          MasonHighlight = { fg = colors.rasta_red, bold = true },

          -- Dashboard / Startup screen
          StartupHeader = { fg = colors.rasta_red, bold = true },
          StartupSection = { fg = colors.rasta_yellow },
          StartupKey = { fg = colors.rasta_green },
          StartupDesc = { fg = colors.fg_primary },

          -- Floating windows
          FloatBorder = { fg = colors.rasta_green },
          FloatTitle = { fg = colors.rasta_yellow, bold = true },
        }

        -- Apply highlights
        for group, opts in pairs(highlights) do
          vim.api.nvim_set_hl(0, group, opts)
        end
      end

      -- Setup the colorscheme
      setup_highlights()

      -- Set colorscheme name
      vim.g.colors_name = "rastafari"

      -- Set terminal colors
      if vim.fn.has("termguicolors") == 1 then
        vim.o.termguicolors = true
        vim.g.terminal_color_0 = colors.bg_dark
        vim.g.terminal_color_1 = colors.rasta_red
        vim.g.terminal_color_2 = colors.rasta_green
        vim.g.terminal_color_3 = colors.rasta_yellow
        vim.g.terminal_color_4 = colors.blue
        vim.g.terminal_color_5 = colors.purple
        vim.g.terminal_color_6 = colors.orange
        vim.g.terminal_color_7 = colors.fg_primary
        vim.g.terminal_color_8 = colors.fg_tertiary
        vim.g.terminal_color_9 = colors.rasta_red
        vim.g.terminal_color_10 = colors.rasta_green
        vim.g.terminal_color_11 = colors.rasta_yellow
        vim.g.terminal_color_12 = colors.blue
        vim.g.terminal_color_13 = colors.purple
        vim.g.terminal_color_14 = colors.orange
        vim.g.terminal_color_15 = colors.fg_primary
      end
    end,
  },

  -- Update LazyVim configuration to use Rastafari colorscheme
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "rastafari",
    },
  },

  -- Update lualine to use rastafari theme
  {
    "nvim-lualine/lualine.nvim",
    opts = function()
      -- Define rastafari lualine theme
      local colors = {
        rasta_red = "#FF6B6B",
        rasta_yellow = "#FFD93D",
        rasta_green = "#6BCF7F",
        bg_dark = "#1A1A1A",
        bg_medium = "#2A2A2A",
        fg_primary = "#F5F5F5",
        fg_secondary = "#D0D0D0",
      }

      local rastafari_theme = {
        normal = {
          a = { fg = colors.bg_dark, bg = colors.rasta_green, gui = "bold" },
          b = { fg = colors.fg_primary, bg = colors.bg_medium },
          c = { fg = colors.fg_secondary, bg = colors.bg_dark },
        },
        insert = {
          a = { fg = colors.bg_dark, bg = colors.rasta_yellow, gui = "bold" },
        },
        visual = {
          a = { fg = colors.bg_dark, bg = colors.rasta_red, gui = "bold" },
        },
        command = {
          a = { fg = colors.bg_dark, bg = colors.rasta_green, gui = "bold" },
        },
        replace = {
          a = { fg = colors.bg_dark, bg = colors.rasta_red, gui = "bold" },
        },
        inactive = {
          a = { fg = colors.fg_secondary, bg = colors.bg_medium },
          b = { fg = colors.fg_secondary, bg = colors.bg_medium },
          c = { fg = colors.fg_secondary, bg = colors.bg_dark },
        },
      }

      return {
        options = {
          theme = rastafari_theme,
          icons_enabled = true,
          section_separators = { left = "", right = "" },
          component_separators = { left = "│", right = "│" },
        },
        sections = {
          lualine_a = {
            { "mode", fmt = function(str) return "🎵 " .. str end }
          },
          lualine_b = {
            { "branch", icon = "🌿" },
            { "diff", symbols = { added = "✚", modified = "✹", removed = "✖" } },
          },
          lualine_c = {
            { "filename", path = 1, symbols = { modified = "🔥", readonly = "🔒" } },
          },
          lualine_x = {
            { "diagnostics", symbols = { error = "🚫", warn = "⚠️", info = "ℹ️", hint = "💡" } },
            { "filetype", icon_only = true },
          },
          lualine_y = {
            { "progress", fmt = function(str) return "📍 " .. str end },
          },
          lualine_z = {
            { "location", fmt = function(str) return "🎯 " .. str end },
          },
        },
      }
    end,
  },
}