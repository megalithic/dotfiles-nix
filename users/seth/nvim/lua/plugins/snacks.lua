if true then
  if false then return {} end

  local repeatable = require("config.repeatable")

  local next_ref_repeat, prev_ref_repeat = repeatable.make_repeatable_move_pair( --
    function() require("snacks").words.jump(vim.v.count1, true) end,
    function() require("snacks").words.jump(-vim.v.count1, true) end
  )

  return {
    {
      "dmtrKovalenko/fff.nvim",
      build = "cargo build --release",
      lazy = false, -- make fff initialize on startup
    },

    {
      -- "madmaxieee/fff-snacks.nvim",
      "ahkohd/fff-snacks.nvim",
      dependencies = {
        "dmtrKovalenko/fff.nvim",
        "folke/snacks.nvim",
      },
      cmd = "FFFSnacks",
      keys = {
        {
          "<leader>ff",
          "<cmd>FFFSnacks<cr>",
          desc = "smart fffiles",
        },
      },
      opts = {
        title = "smart fffiles",
      },
    },

    {
      "folke/snacks.nvim",
      priority = 1000,
      lazy = false,
      opts = {
        bigfile = { enabled = true },
        dashboard = { enabled = false },
        explorer = { enabled = false },
        image = {
          enabled = true,
          math = {
            typst = {
              -- change font size
              tpl = [[
        #set page(width: auto, height: auto, margin: (x: 2pt, y: 2pt))
        #show math.equation.where(block: false): set text(top-edge: "bounds", bottom-edge: "bounds")
        #set text(size: 18pt, fill: rgb("${color}"))
        ${header}
        ${content}]],
            },
          },
        },
        indent = { enabled = false },
        input = { enabled = true },
        notifier = { enabled = false },
        picker = {
          enabled = true,
          ui_select = true,
        },
        quickfile = { enabled = true },
        scroll = { enabled = false },
        statuscolumn = { enabled = false },
        words = { enabled = true },
        styles = {
          input = {
            relative = "cursor",
            row = 1,
          },
          zen = {
            relative = "editor",
            backdrop = { transparent = false },
          },
        },
      },
      keys = {
        {
          "]]",
          next_ref_repeat,
          desc = "Next Reference",
        },
        {
          "[[",
          prev_ref_repeat,
          desc = "Prev Reference",
        },
      },
      init = function()
        local layouts = require("snacks.picker.config.layouts")
        -- layouts.ivy_taller = vim.tbl_deep_extend("keep", { layout = { height = 0.8 } }, layouts.ivy)

        vim.api.nvim_create_user_command("Pick", function(opts)
          local source = opts.fargs[1]
          if source then
            if require("snacks").picker[source] then
              require("snacks").picker[source]()
            else
              vim.notify("unknown snacks picker source: " .. source, vim.log.levels.ERROR)
            end
          else
            require("snacks").picker()
          end
        end, {
          desc = "Open Snacks Picker",
          nargs = "?",
          complete = function() return vim.tbl_keys(require("snacks").picker.sources) end,
        })
        vim.cmd.cabbrev("P", "Pick")

        vim.api.nvim_set_hl(0, "SnacksImageMath", { link = "Normal" })

        _G.dd = function(...) require("snacks").debug.inspect(...) end
        _G.bt = function() require("snacks").debug.backtrace() end

        require("plugins.snacks-picker")
      end,
    },
  }
end
