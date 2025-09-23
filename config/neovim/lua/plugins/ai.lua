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
      require("plugins.codecompanion.codecompanion-notifier"):init()

      local group = vim.api.nvim_create_augroup("CodeCompanionHooks", {})

      vim.api.nvim_create_autocmd({ "User" }, {
        pattern = "CodeCompanionInlineFinished",
        group = group,
        callback = function(request)
          vim.lsp.buf.format({ bufnr = request.buf })
        end,
      })
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
        -- Enhanced Copilot adapters
        copilot_4o = function()
          return require("codecompanion.adapters").extend("copilot", {
            schema = {
              model = {
                default = "gpt-4o",
              },
            },
          })
        end,
        copilot_claude = function()
          return require("codecompanion.adapters").extend("copilot", {
            schema = {
              model = {
                default = "claude-3.5-sonnet",
              },
            },
          })
        end,
        copilot_gemini = function()
          return require("codecompanion.adapters").extend("copilot", {
            schema = {
              model = {
                default = "gemini-2.0-flash-exp",
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
          opts = { "internal", "filler", "closeoff", "algorithm:patience", "followwrap", "linematch:120" },
          provider = "default",
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
          roles = {
            llm = function(adapter)
              return "AI (" .. adapter.formatted_name .. ")"
            end,
            user = "Developer",
          },
          tools = {
            groups = {
              ["termux_dev"] = {
                description = "Termux Development - Terminal commands and Android-specific development",
                tools = {
                  "cmd_runner",
                  "editor",
                  "files",
                },
              },
            },
          },
        },
      },
    },
  },

  -- GP.nvim - OpenAI, Anthropic, and other providers
  {
    "robitx/gp.nvim",
    enabled = true,
    cmd = { "GpChatNew", "GpChatPaste", "GpChatToggle", "GpChatFinder", "GpRewrite", "GpAppend", "GpPrepend", "GpEnew", "GpNew", "GpVnew", "GpTabnew" },
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

        -- Anthropic provider
        providers = {
          openai = {
            endpoint = "https://api.openai.com/v1/chat/completions",
          },
          anthropic = {
            endpoint = "https://api.anthropic.com/v1/messages",
            secret = ai_env.ANTHROPIC_API_KEY,
          },
          chutes = {
            endpoint = "https://chutes.ai/api/v1/chat/completions",
            secret = ai_env.CHUTES_API_KEY,
          },
          moonshot = {
            endpoint = "https://api.moonshot.cn/v1/chat/completions",
            secret = ai_env.MOONSHOT_API_KEY,
          },
        },

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
          {
            name = "GLM-4.5",
            provider = "chutes",
            chat = true,
            command = false,
            model = { model = "chutes-glm-4.5-fp8", temperature = 0.7 },
            system_prompt = "You are an AI assistant specialized in coding and terminal operations.",
          },
          {
            name = "Kimi",
            provider = "moonshot",
            chat = true,
            command = false,
            model = { model = "moonshot-v1-8k", temperature = 0.8 },
            system_prompt = "You are an AI assistant for development and problem-solving.",
          },
        },

        -- Chat settings
        chat_dir = vim.fn.stdpath("data"):gsub("/$", "") .. "/gp/chats",
        chat_user_prefix = "💬:",
        chat_assistant_prefix = { "🤖:", "[{{agent}}]" },
        chat_topic_gen_prompt = "Summarize the topic of our conversation above in two or three words. Respond only with those words.",
        chat_topic_gen_model = "gpt-3.5-turbo",
        chat_confirm_delete = true,
        chat_conceal_model_params = true,
        chat_shortcut_respond = { modes = { "n", "i", "v", "x" }, shortcut = "<C-g><C-g>" },
        chat_shortcut_delete = { modes = { "n", "i", "v", "x" }, shortcut = "<C-g>d" },
        chat_shortcut_stop = { modes = { "n", "i", "v", "x" }, shortcut = "<C-g>s" },
        chat_shortcut_new = { modes = { "n", "i", "v", "x" }, shortcut = "<C-g>c" },

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
    build = function()
      if vim.fn.has("win32") == 1 then
        return "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false"
      else
        return "make"
      end
    end,
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
        chutes = {
          endpoint = "https://chutes.ai/api/v1",
          model = "chutes-glm-4.5-fp8",
          api_key_name = "CHUTES_API_KEY",
        },
      },
      behaviour = {
        enable_cursor_planning_mode = true,
      },
      file_selector = {
        provider = "snacks",
        provider_opts = {},
      },
      windows = {
        position = "left",
        wrap = true,
        width = 30,
        sidebar_header = {
          enabled = true,
        },
      },
    },
    dependencies = {
      "MunifTanjim/nui.nvim",
      {
        "HakonHarnes/img-clip.nvim",
        event = "VeryLazy",
        opts = {
          default = {
            embed_image_as_base64 = false,
            prompt_for_file_name = false,
            drag_and_drop = {
              insert_mode = true,
            },
            use_absolute_path = true,
          },
        },
      },
    },
  },

  -- Claude Code - Direct Claude integration
  {
    "greggh/claude-code.nvim",
    enabled = false, -- Disabled by default, can be enabled by user
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    keys = {
      { "<leader>clc", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude Code" },
      { "<leader>clr", "<cmd>ClaudeCodeResume<cr>", desc = "Resume conversation" },
      { "<leader>clt", "<cmd>ClaudeCodeContinue<cr>", desc = "Continue recent conversation" },
      { "<leader>clv", "<cmd>ClaudeCodeVerbose<cr>", desc = "Verbose logging" },
    },
    config = function()
      require("claude-code").setup()
    end,
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

  -- Blink compatibility for AI completions
  {
    "saghen/blink.cmp",
    optional = true,
    dependencies = { "saghen/blink.compat" },
    opts = {
      sources = {
        default = { "avante_commands", "avante_mentions", "avante_files" },
        compat = {
          "avante_commands",
          "avante_mentions",
          "avante_files",
        },
        providers = {
          avante_commands = {
            name = "avante_commands",
            module = "blink.compat.source",
            score_offset = 90,
            opts = {},
          },
          avante_files = {
            name = "avante_files",
            module = "blink.compat.source",
            score_offset = 100,
            opts = {},
          },
          avante_mentions = {
            name = "avante_mentions",
            module = "blink.compat.source",
            score_offset = 1000,
            opts = {},
          },
        },
      },
    },
  },
}