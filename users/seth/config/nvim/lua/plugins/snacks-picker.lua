local function get_window_relative_flow_config()
  local win = vim.api.nvim_get_current_win()
  local win_config = vim.api.nvim_win_get_config(win)
  local win_pos = vim.api.nvim_win_get_position(win)
  local win_width = vim.api.nvim_win_get_width(win)
  local win_height = vim.api.nvim_win_get_height(win)

  -- Get editor dimensions
  local editor_width = vim.o.columns
  local editor_height = vim.o.lines

  -- Calculate window position in editor coordinates
  local win_col = win_pos[2]
  local win_row = win_pos[1]

  -- If it's a floating window, use its absolute position
  if win_config.relative and win_config.relative ~= "" then
    win_col = win_config.col or win_col
    win_row = win_config.row or win_row
  end

  -- Calculate picker dimensions relative to current window
  local picker_width = math.min(win_width - 4, math.floor(editor_width * 0.4)) -- Use window width but cap it
  local picker_height = math.floor(win_height * 0.3) -- 30% of window height for bottom third

  -- Position picker centered horizontally within the current window, in the bottom third
  local target_col = win_col + math.floor((win_width - picker_width) / 2)
  local target_row = win_row + math.floor(win_height * 0.67) -- Start at 67% down the window

  -- Ensure picker doesn't go off screen
  if target_col < 0 then
    target_col = 0
  end
  if target_col + picker_width > editor_width then
    target_col = editor_width - picker_width
  end
  if target_row < 0 then
    target_row = 0
  end
  if target_row + picker_height > editor_height then
    target_row = editor_height - picker_height
  end

  -- Return the proper layout structure that Snacks expects
  return {
    preview = "main",
    layout = {
      backdrop = false,
      col = target_col,
      width = picker_width,
      min_width = 50,
      row = target_row,
      height = picker_height,
      min_height = 10,
      box = "vertical",
      border = "solid",
      title = "{title} {live} {flags}",
      title_pos = "center",
      { win = "preview", title = "{preview}", width = 0.6, border = "left" },
      { win = "input", height = 1, border = "solid" },
      { win = "list", border = "none" },
    },
  }
end

return {
  enabled = false,
  "jakubbortlik/snacks.nvim", -- use patched fork for https://github.com/folke/snacks.nvim/pull/2012
  ---@module 'snacks'
  ---@type snacks.Config
  dependencies = {
    {
      "madmaxieee/fff.nvim",
      lazy = false, -- lazy loaded by design
      build = "cargo build --release",
    },
  },
  opts = {
    picker = {
      enabled = true,
      ui_select = true,
      formatters = {
        file = { filename_first = true },
      },
      previewers = {
        file = {
          max_size = 10 * 1024 * 1024, -- 10MB
        },
      },
      win = {
        preview = {
          wo = {
            number = false,
            relativenumber = false,
            wrap = false,
          },
        },
        input = {
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
      },
      layouts = {
        default = {
          layout = {
            box = "vertical",
            width = 0.9,
            min_width = 120,
            height = 0.8,
            {
              box = "vertical",
              border = "solid",
              title = "{title} {live} {flags}",
              { win = "input", height = 1, border = "bottom" },
              { win = "list", border = "none" },
            },
            { win = "preview", title = "{preview}", border = "solid" },
          },
        },
        ivy = {
          layout = {
            box = "vertical",
            backdrop = false,
            row = -1,
            width = 0,
            height = 0.4,
            border = "solid",
            title = " {title} {live} {flags}",
            title_pos = "left",
            { win = "input", height = 1, border = "bottom" },
            {
              box = "horizontal",
              { win = "list", border = "none" },
              { win = "preview", title = "{preview}", width = 0.6, border = "left" },
            },
          },
        },
        float = {
          preview = "main",
          layout = {
            position = "float",
            width = 60,
            col = 0.15,
            min_width = 60,
            height = 0.85,
            min_height = 25,
            box = "vertical",
            border = "solid",
            title = "{title} {live} {flags}",
            title_pos = "center",
            { win = "input", height = 1, border = "bottom" },
            { win = "list", border = "none" },
            { win = "preview", title = "{preview}", width = 0.6, border = "left" },
          },
        },
        flow = {
          preview = "main",
          layout = {
            backdrop = false,
            col = 5,
            width = 0.35,
            min_width = 50,
            row = 0.65,
            height = 0.30,
            min_height = 10,
            box = "vertical",
            border = "solid",
            title = "{title} {live} {flags}",
            title_pos = "center",
            { win = "preview", title = "{preview}", width = 0.6, border = "left" },
            { win = "input", height = 1, border = "solid" },
            { win = "list", border = "none" },
          },
        },
        left_bottom_corner = {
          preview = "main",
          layout = {
            width = 0.5,
            min_width = 0.35,
            height = 0.35,
            min_height = 0.35,
            row = 0.5,
            col = 10,
            border = "solid",
            box = "vertical",
            title = "{title} {live} {flags}",
            title_pos = "center",
            { win = "preview", title = "{preview}", width = 0.6, border = "left" },
            { win = "input", height = 1, border = "solid" },
            { win = "list", border = "none" },
          },
        },
        sidebar_right = {
          preview = "main",
          layout = {
            backdrop = false,
            width = 40,
            min_width = 40,
            height = 0,
            position = "right",
            border = "none",
            box = "vertical",
            {
              win = "input",
              height = 1,
              border = "rounded",
              title = "{title} {live} {flags}",
              title_pos = "center",
            },
            { win = "list", border = "none" },
            { win = "preview", title = "{preview}", height = 0.4, border = "top" },
          },
        },
      },
      sources = {
        select = {
          layout = { preset = "flow" },
        },
        explorer = {
          replace_netrw = true,
          git_status = true,
          jump = {
            close = true,
          },
          hidden = true,
          ignored = true,
          layout = {
            preset = "float",
            preview = {
              main = true,
              enabled = false,
            },
          },
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
          layout = {
            preset = "flow",
            border = "solid",
          },
        },
        ---@type snacks.picker.smart.Config
        smart = {
          layout = function()
            return get_window_relative_flow_config()
          end,
        },
        fff = {
          layout = function()
            return get_window_relative_flow_config()
          end,
        },
        ---TODO: filter out empty file
        ---@type snacks.picker.recent.Config
        recent = {
          layout = function()
            return get_window_relative_flow_config()
          end,
        },
        lines = {
          layout = function()
            return get_window_relative_flow_config()
          end,
        },
        lsp_references = {
          pattern = "!import !default", -- Exclude Imports and Default Exports
          layout = function()
            return get_window_relative_flow_config()
          end,
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
          layout = function()
            return get_window_relative_flow_config()
          end,
        },
        lsp_workspace_symbols = {
          layout = function()
            return get_window_relative_flow_config()
          end,
        },
        diagnostics = {
          layout = function()
            return get_window_relative_flow_config()
          end,
        },
        diagnostics_buffer = {
          layout = function()
            return get_window_relative_flow_config()
          end,
        },
        git_status = {
          preview = "git_status",
          layout = function()
            return get_window_relative_flow_config()
          end,
        },
        git_diff = {
          layout = function()
            return get_window_relative_flow_config()
          end,
        },
      },
    },
  },

  keys = {
    {
      "<leader>ff",
      "<cmd>FFFSnacks<cr>",
      desc = "FFF",
    },

    {
      "<leader>a",
      mode = "n",
      function()
        require("plugins.snacks-multi-grep").multi_grep()
      end,
      desc = "Live grep",
    },

    {
      "<leader>A",
      mode = { "n", "x" },
      function()
        require("snacks").picker.grep_word()
      end,
      desc = "Grep string",
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
      desc = "Find all files",
    },

    {
      "<leader><leader>",
      function()
        require("snacks").picker.buffers()
      end,
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
      function()
        require("snacks").picker.help()
      end,
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
      function()
        require("snacks").picker.undo()
      end,
      desc = "Find undo history",
    },
  },
}
