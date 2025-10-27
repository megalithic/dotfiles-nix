return {
  "folke/snacks.nvim", -- use patched fork for https://github.com/folke/snacks.nvim/pull/2012
  ---@module 'snacks'
  ---@type snacks.Config
  opts = {
    picker = {
      enabled = true,
      ui_select = true,
      formatters = {
        file = { filename_first = true },
      },
      layout = {
        preset = "ivy",
      },
      previewers = {
        file = {
          max_size = 10 * 1024 * 1024, -- 10MB
        },
      },
      win = {
        preview = {
          wo = {
            wrap = false,
          },
        },
        input = {
          b = {
            number = false,
            relativenumber = false,
          },
          wo = {
            cursorcolumn = false,
            cursorline = false,
            cursorlineopt = "both",
            colorcolumn = "",
            fillchars = "eob: ,lastline:…",
            list = false,
            listchars = "extends:…,tab:  ",
            number = false,
            relativenumber = false,
            signcolumn = "no",
            spell = false,
            winbar = "",
            statuscolumn = "",
            wrap = false,
            sidescrolloff = 0,
          },
          keys = {
            ["<c-t>"] = { "edit_tab", mode = { "i", "n" } },
            ["<c-u>"] = { "preview_scroll_up", mode = { "i", "n" } },
            ["<c-d>"] = { "preview_scroll_down", mode = { "i", "n" } },
            ["<c-f>"] = { "flash", mode = { "n", "i" } },
            ["<CR>"] = { "jump_or_split", mode = { "i", "n" } },
            ["<Esc>"] = { "close", mode = { "i" } },
            ["<C-c>"] = { "cancel", mode = "i" },
          },
        },
        list = {
          keys = {
            ["<c-t>"] = "edit_tab",
          },
        },
      },
      actions = {
        jump_or_split = function(picker, item)
          local target_wins = function()
            local targets = {}
            for _, win in ipairs(vim.api.nvim_list_wins()) do
              local buf = vim.api.nvim_win_get_buf(win)
              local cfg = vim.api.nvim_win_get_config(win)
              if (vim.bo[buf].buflisted and cfg.relative == "") or vim.bo[buf].ft == "snacks_dashboard" then
                local file = vim.api.nvim_buf_get_name(buf)
                table.insert(targets, { win = win, buf = buf, file = file })
              end
            end
            return targets
          end
          local targets = target_wins()
          for _, targ in ipairs(targets) do
            if targ.file == item.file or vim.bo[targ.buf].ft == "snacks_dashboard" then
              picker.opts.jump.reuse_win = true --[[Override]]
              picker:action("jump")
              return
            end
          end
          picker:action("vsplit")
        end,
        cycle_preview = function(picker)
          local layout_config = vim.deepcopy(picker.resolved_layout)

          if layout_config.preview == "main" or not picker.preview.win:valid() then return end

          local function find_preview(root) ---@param root snacks.layout.Box|snacks.layout.Win
            if root.win == "preview" then return root end
            if #root then
              for _, w in ipairs(root) do
                local preview = find_preview(w)
                if preview then return preview end
              end
            end
            return nil
          end

          local preview = find_preview(layout_config.layout)

          if not preview then return end

          local eval = function(s) return type(s) == "function" and s(preview.win) or s end
          --- @type number?, number?
          local width, height = eval(preview.width), eval(preview.height)

          if not width and not height then return end

          local cycle_sizes = { 0.1, 0.9 }
          local size_prop, size

          if height then
            size_prop, size = "height", height
          else
            size_prop, size = "width", width
          end

          picker.init_size = picker.init_size or size ---@diagnostic disable-line: inject-field
          table.insert(cycle_sizes, picker.init_size)
          table.sort(cycle_sizes)

          for i, s in ipairs(cycle_sizes) do
            if size == s then
              local smaller = cycle_sizes[i - 1] or cycle_sizes[#cycle_sizes]
              preview[size_prop] = smaller
              break
            end
          end

          for i, h in ipairs(layout_config.hidden) do
            if h == "preview" then table.remove(layout_config.hidden, i) end
          end

          picker:set_layout(layout_config)
        end,
      },
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
