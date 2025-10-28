return {
  "folke/snacks.nvim", -- use patched fork for https://github.com/folke/snacks.nvim/pull/2012
  ---@module 'snacks'
  ---@type snacks.Config
  opts = {
    picker = {
      sources = {
        explorer = {
          replace_netrw = true,
          git_status = true,
          jump = {
            close = true,
          },
          hidden = true,
          ignored = true,
          win = {
            list = {
              keys = {
                ["]c"] = "explorer_git_next",
                ["[c"] = "explorer_git_prev",
                ["<c-t>"] = { "tab", mode = { "n", "i" } },
              },
            },
          },
          icons = {
            tree = {
              vertical = "  ",
              middle = "  ",
              last = "  ",
            },
          },
        },
        buffers = {
          current = false,
        },
        files = {
          hidden = true,
        },
        recent = {},
        lines = {},
        lsp_references = {
          pattern = "!import !default", -- Exclude Imports and Default Exports
        },
        lsp_symbols = {
          finder = "lsp_symbols",
          format = "lsp_symbol",
          hierarchy = true,
          filter = {
            default = true,
            markdown = true,
            help = true,
          },
        },
        lsp_workspace_symbols = {},
        diagnostics = {},
        diagnostics_buffer = {},
        git_status = {
          preview = "git_status",
        },
        git_diff = {},
      },
    },
  },

  keys = {
    {
      "<leader>a",
      mode = "n",
      function() require("plugins.snacks-multi-grep").multi_grep() end,
      desc = "live grep",
    },

    {
      "<leader>A",
      mode = { "n", "x", "v" },
      function() require("snacks").picker.grep_word() end,
      desc = "grep cursor/selection",
    },

    -- {
    --   "<leader>fg",
    --   function()
    --     require("snacks").picker.git_status()
    --   end,
    --   desc = "Git status",
    -- },

    {
      "<leader>fa",
      function()
        require("snacks").picker.files({
          cmd = "fd",
          args = {
            "--color=never",
            "--hidden",
            "--type",
            "f",
            "--type",
            "l",
            "--no-ignore",
            "--exclude",
            ".git",
          },
        })
      end,
      desc = "[f]ind [a]ll files",
    },

    {
      "<leader><leader>",
      function() require("snacks").picker.buffers() end,
      desc = "Find buffers",
    },

    -- {
    --   "<leader>fj",
    --   function()
    --     require("snacks").picker.jumps()
    --   end,
    --   desc = "Find jumps",
    -- },

    {
      "<leader>fh",
      function() require("snacks").picker.help() end,
      desc = "Find help",
    },

    -- {
    --   "<leader>fz",
    --   function()
    --     require("snacks").picker.lines()
    --   end,
    --   desc = "Find lines",
    -- },

    -- {
    --   "<leader>fr",
    --   function()
    --     require("snacks").picker.resume()
    --   end,
    --   desc = "Find recent files",
    -- },

    -- {
    --   "<leader>cm",
    --   function()
    --     require("snacks").picker.git_log()
    --   end,
    --   desc = "Git commits",
    -- },

    -- {
    --   "<leader>gg",
    --   function()
    --     require("snacks").picker.git_files()
    --   end,
    --   desc = "Find git files",
    -- },

    -- {
    --   "<leader>fd",
    --   function()
    --     require("snacks").picker.diagnostics()
    --   end,
    --   desc = "Find diagnostics",
    -- },
    --
    -- {
    --   "<leader>fs",
    --   function()
    --     require("snacks").picker.lsp_symbols()
    --   end,
    --   desc = "Find document symbols",
    -- },
    --
    -- {
    --   "<leader>ws",
    --   function()
    --     require("snacks").picker.lsp_workspace_symbols()
    --   end,
    --   desc = "Find workspace symbols",
    -- },

    -- {
    --   "<leader>fc",
    --   function()
    --     require("snacks").picker.command_history()
    --   end,
    --   desc = "Find commands",
    -- },

    {
      "<leader>fu",
      function() require("snacks").picker.undo() end,
      desc = "Find undo history",
    },
  },
}
