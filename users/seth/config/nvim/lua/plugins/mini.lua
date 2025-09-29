return {
  { "nvim-mini/mini.jump", enabled = false, version = false, opts = {} },
  { "nvim-mini/mini.icons", version = false, opts = {} },
  {
    "nvim-mini/mini.indentscope",
    config = function()
      require("mini.indentscope").setup({
        symbol = vim.g.indent_scope_char,
        mappings = {
          goto_top = "[[",
          goto_bottom = "]]",
        },
        draw = {
          delay = 0,
          animation = function()
            return 0
          end,
        },
        options = { try_as_border = true, border = "both", indent_at_cursor = true },
      })

      if Augroup ~= nil then
        Augroup("mini.indentscope", {
          {
            event = "FileType",
            pattern = {
              "help",
              "alpha",
              "dashboard",
              "neo-tree",
              "Trouble",
              "lazy",
              "mason",
              "fzf",
              "dirbuf",
              "terminal",
              "fzf-lua",
              "fzflua",
              "megaterm",
              "nofile",
              "terminal",
              "megaterm",
              "lsp-installer",
              "SidebarNvim",
              "lspinfo",
              "markdown",
              "help",
              "startify",
              "packer",
              "NeogitStatus",
              "oil",
              "DirBuf",
              "markdown",
            },
            command = function()
              vim.b.miniindentscope_disable = true
            end,
          },
        })
      end
    end,
  },
  { "nvim-mini/mini.extra", version = false, opts = {} },
  {
    enabled = true,
    "nvim-mini/mini.pick",
    main = "mini.pick",
    version = false,
    cmd = { "Pick", "MiniPick" },
    lazy = true,
    dependencies = {
      { "echasnovski/mini.extra", config = true },
      { "echasnovski/mini.fuzzy", config = true },
      { "echasnovski/mini.visits", config = true, event = "LazyFile" },
      { "echasnovski/mini.align" },
      {
        "diego-velez/fff.nvim",
        build = "cargo build --release",
        -- build = {
        --   function(args)
        --     local cmd = { "rustup", "run", "nightly", "cargo", "build", "--release" }
        --     ---@type vim.SystemOpts
        --     local opts = { cwd = args.dir, text = true }
        --
        --     vim.notify("Building " .. args.name, vim.log.levels.INFO)
        --     local output = vim.system(cmd, opts):wait()
        --     if output.code ~= 0 then
        --       vim.notify("Failed to build " .. args.name .. "\n" .. output.stderr, vim.log.levels.ERROR)
        --     else
        --       vim.notify("Built " .. args.name, vim.log.levels.INFO)
        --     end
        --   end,
        -- },
      },
    },
    config = function()
      -- require("plugins.mini_pick")
      --
      local setup_target_win_preview = function()
        local opts = MiniPick.get_picker_opts()
        local show, preview, choose = opts.source.show, opts.source.preview, opts.source.choose

        -- Prepare preview and initial buffers
        local preview_buf_id = vim.api.nvim_create_buf(false, true)
        local win_target = MiniPick.get_picker_state().windows.target
        local init_target_buf = vim.api.nvim_win_get_buf(win_target)
        vim.api.nvim_win_set_buf(win_target, preview_buf_id)

        -- Hook into source's methods
        opts.source.show = function(...)
          show(...)
          local cur_item = MiniPick.get_picker_matches().current
          if cur_item == nil then
            return
          end
          preview(preview_buf_id, cur_item)
        end

        local needs_init_buf_restore = true
        opts.source.choose = function(...)
          needs_init_buf_restore = false
          choose(...)
        end

        MiniPick.set_picker_opts(opts)

        -- Set up buffer cleanup
        local cleanup = function()
          if needs_init_buf_restore then
            vim.api.nvim_win_set_buf(win_target, init_target_buf)
          end
          vim.api.nvim_buf_delete(preview_buf_id, { force = true })
        end
        vim.api.nvim_create_autocmd("User", { pattern = "MiniPickStop", once = true, callback = cleanup })
      end
      vim.api.nvim_create_autocmd("User", { pattern = "MiniPickStart", callback = setup_target_win_preview })

      -- Use proper slash depending on OS
      local parent_dir_pattern = vim.fn.has("win32") == 1 and "([^\\/]+)([\\/])" or "([^/]+)(/)"

      -- Shorten a folder's name
      local shorten_dirname = function(name, path_sep)
        local first = vim.fn.strcharpart(name, 0, 1)
        first = first == "." and vim.fn.strcharpart(name, 0, 2) or first
        return first .. path_sep
      end

      -- Shorten one path
      -- WARN: This can only be called for MiniPick
      local make_short_path = function(path)
        local win_id = MiniPick.get_picker_state().windows.main
        local buf_width = vim.api.nvim_win_get_width(win_id)
        local char_count = vim.fn.strchars(path)
        -- Do not shorten the path if it is not needed
        if char_count < buf_width then
          return path
        end

        local shortened_path = path:gsub(parent_dir_pattern, shorten_dirname)
        char_count = vim.fn.strchars(shortened_path)
        -- Return only the filename when the shorten path still overflows
        if char_count >= buf_width then
          return shortened_path:match(parent_dir_pattern)
        end

        return shortened_path
      end

      require("mini.pick").setup({
        mappings = {
          choose = "<CR>",
          choose_in_split = "<C-s>",
          choose_in_vsplit = "<C-v>",
          choose_in_tabpage = "<C-t>",
          choose_marked = "",
        },

        window = {
          config = function()
            local height = math.floor(0.4 * vim.o.lines)
            local width = math.floor(0.35 * vim.o.columns)
            return {
              relative = "laststatus",
              anchor = "NW",
              height = height,
              width = width,
              row = 0,
              col = 0,
            }

            -- -- FLOAT-CENTERED:
            -- local height = math.floor(0.6 * vim.o.lines)
            -- local width = math.floor(0.6 * vim.o.columns)
            -- return {
            --   anchor = "NW",
            --   height = height,
            --   width = width,
            --   row = math.floor(0.5 * (vim.o.lines - height)),
            --   col = math.floor(0.5 * (vim.o.columns - width)),
            -- }
          end,
          prompt_prefix = "󰁔 ",
          prompt_caret = " ",
        },
      })
      -- require("mini.pick").setup({
      --   delay = {
      --     busy = 1,
      --   },
      --
      --   mappings = {
      --     caret_left = "<Left>",
      --     caret_right = "<Right>",
      --
      --     -- choose = "<C-y>",
      --     choose_in_split = "<C-s>",
      --     -- choose = {
      --     --   char = "<CR>",
      --     --   func = function()
      --     --     local choose_mapping = MiniPick.get_picker_opts().mappings.choose_in_vsplit
      --     --     vim.api.nvim_input("<C-y>")
      --     --   end,
      --     -- },
      --     choose_in_vsplit = "<C-y>",
      --     choose_in_tabpage = "<C-t>",
      --     choose_marked = "<C-q>",
      --
      --     delete_char = "<BS>",
      --     delete_char_right = "<Del>",
      --     delete_left = "<C-u>",
      --     delete_word = "<C-w>",
      --
      --     mark = "<C-x>",
      --     mark_all = "<C-a>",
      --
      --     move_down = "<C-n>",
      --     move_start = "<C-g>",
      --     move_up = "<C-p>",
      --
      --     paste = "",
      --
      --     refine = "<C-r>",
      --     refine_marked = "",
      --
      --     scroll_down = "<C-f>",
      --     scroll_left = "<C-Left>",
      --     scroll_right = "<C-Right>",
      --     scroll_up = "<C-b>",
      --
      --     stop = "<Esc>",
      --
      --     toggle_info = "<S-Tab>",
      --     toggle_preview = "<Tab>",
      --
      --     -- another_choose = {
      --     -- 	char = "<CR>",
      --     -- 	func = function()
      --     -- 		local choose_mapping = MiniPick.get_picker_opts().mappings.choose
      --     -- 		vim.api.nvim_input(choose_mapping)
      --     -- 	end,
      --     -- },
      --     -- actual_paste = {
      --     --   char = "<C-r>",
      --     --   func = function()
      --     --     local content = vim.fn.getreg("+")
      --     --     if content ~= "" then
      --     --       local current_query = MiniPick.get_picker_query() or {}
      --     --       table.insert(current_query, content)
      --     --       MiniPick.set_picker_query(current_query)
      --     --     end
      --     --   end,
      --     -- },
      --   },
      --
      --   options = {
      --     use_cache = false,
      --   },
      --
      --   window = {
      --     config = function()
      --       local height = math.floor(0.4 * vim.o.lines)
      --       local width = math.floor(0.4 * vim.o.columns)
      --       return {
      --         relative = "laststatus",
      --         anchor = "NW",
      --         height = height,
      --         width = width,
      --         row = 0,
      --         col = 0,
      --       }
      --     end,
      --     -- config = function()
      --     --   local height = math.floor(0.6 * vim.o.lines)
      --     --   local width = math.floor(0.6 * vim.o.columns)
      --     --   return {
      --     --     anchor = "NW",
      --     --     height = height,
      --     --     width = width,
      --     --     row = math.floor(0.5 * (vim.o.lines - height)),
      --     --     col = math.floor(0.5 * (vim.o.columns - width)),
      --     --   }
      --     -- end,
      --     prompt_prefix = "󰁔 ",
      --     prompt_caret = " ",
      --   },
      -- })

      -- Using primarily for code action
      -- See https://github.com/echasnovski/mini.nvim/discussions/1437
      vim.ui.select = MiniPick.ui_select

      -- Shorten file paths by default
      local show_short_files = function(buf_id, items_to_show, query)
        local short_items_to_show = vim.tbl_map(make_short_path, items_to_show)
        -- TODO: Instead of using default show, replace in order to highlight proper folder and add icons back
        MiniPick.default_show(buf_id, short_items_to_show, query)
      end

      ---@class DVTMiniFiles
      ---@field shorten_dirname boolean
      ---@param local_opts DVTMiniFiles | nil
      ---@param opts table | nil
      MiniPick.registry.files = function(local_opts, opts)
        local_opts = local_opts or {}
        local_opts = vim.tbl_extend("force", local_opts, { shorten_dirname = false })
        if local_opts.shorten_dirname then
          opts = opts or {
            source = { show = show_short_files },
          }
        else
          opts = opts or {}
        end

        MiniPick.builtin.files(local_opts, opts)
      end

      -- Show highlight in buf_lines picker
      -- See https://github.com/echasnovski/mini.nvim/discussions/988#discussioncomment-10398788
      local ns_digit_prefix = vim.api.nvim_create_namespace("cur-buf-pick-show")
      local show_cur_buf_lines = function(buf_id, items, query, opts)
        if items == nil or #items == 0 then
          return
        end

        -- Show as usual
        MiniPick.default_show(buf_id, items, query, opts)

        -- Move prefix line numbers into inline extmarks
        local lines = vim.api.nvim_buf_get_lines(buf_id, 0, -1, false)
        local digit_prefixes = {}
        for i, l in ipairs(lines) do
          local _, prefix_end, prefix = l:find("^(%s*%d+│)")
          if prefix_end ~= nil then
            digit_prefixes[i], lines[i] = prefix, l:sub(prefix_end + 1)
          end
        end

        vim.api.nvim_buf_set_lines(buf_id, 0, -1, false, lines)
        for i, pref in pairs(digit_prefixes) do
          local opts = { virt_text = { { pref, "MiniPickNormal" } }, virt_text_pos = "inline" }
          vim.api.nvim_buf_set_extmark(buf_id, ns_digit_prefix, i - 1, 0, opts)
        end

        -- Set highlighting based on the curent filetype
        local ft = vim.bo[items[1].bufnr].filetype
        local has_lang, lang = pcall(vim.treesitter.language.get_lang, ft)
        local has_ts, _ = pcall(vim.treesitter.start, buf_id, has_lang and lang or ft)
        if not has_ts and ft then
          vim.bo[buf_id].syntax = ft
        end
      end

      MiniPick.registry.buf_lines = function()
        -- local local_opts = { scope = 'current', preserve_order = true } -- use preserve_order
        local local_opts = { scope = "current" }
        MiniExtra.pickers.buf_lines(local_opts, { source = { show = show_cur_buf_lines } })
      end

      -- todo-comments picker section
      local show_todo = function(buf_id, entries, query, opts)
        MiniPick.default_show(buf_id, entries, query, opts)

        -- Add highlighting to every line in the buffer
        for line, entry in ipairs(entries) do
          for _, hl in ipairs(entry.hl) do
            local start = { line - 1, hl[1][1] }
            local finish = { line - 1, hl[1][2] }
            vim.hl.range(buf_id, ns_digit_prefix, hl[2], start, finish, { priority = vim.hl.priorities.user + 1 })
          end
        end
      end
      -- Open LSP picker for the given scope
      ---@param scope "declaration" | "definition" | "document_symbol" | "implementation" | "references" | "type_definition" | "workspace_symbol"
      ---@param autojump boolean? If there is only one result it will jump to it.
      MiniPick.registry.LspPicker = function(scope, autojump)
        ---@return string
        local function get_symbol_query()
          return vim.fn.input("Symbol: ")
        end

        if not autojump then
          local opts = { scope = scope }

          if scope == "workspace_symbol" then
            opts.symbol_query = get_symbol_query()
          end

          MiniExtra.pickers.lsp(opts)
          return
        end

        ---@param opts vim.lsp.LocationOpts.OnList
        local function on_list(opts)
          vim.fn.setqflist({}, " ", opts)

          if #opts.items == 1 then
            vim.cmd.cfirst()
          else
            MiniExtra.pickers.list({ scope = "quickfix" }, {
              source = { name = opts.title },
              window = {
                config = function()
                  local height = math.floor(0.618 * vim.o.lines)
                  local width = math.floor(0.618 * vim.o.columns)
                  return {
                    relative = "cursor",
                    anchor = "NW",
                    height = height,
                    width = width,
                    row = 0,
                    col = 0,
                  }
                end,
              },
            })
          end
        end

        if scope == "references" then
          vim.lsp.buf.references(nil, { on_list = on_list })
          return
        end

        if scope == "workspace_symbol" then
          vim.lsp.buf.workspace_symbol(get_symbol_query(), { on_list = on_list })
          return
        end

        vim.lsp.buf[scope]({ on_list = on_list })
      end

      local ns = vim.api.nvim_create_namespace("DVT MiniPickRanges")
      vim.keymap.set("n", "<leader>sg", function()
        local show = function(buf_id, items, query)
          local hl_groups = {}
          items = vim.tbl_map(function(item)
            -- Get all items as returned by ripgrep
            local path, row, column, str = string.match(item, "^([^|]*)|([^|]*)|([^|]*)|(.*)$")

            path = vim.fs.basename(path)

            -- Trim text found
            str = string.gsub(str, "^%s*(.-)%s*$", "%1")

            local icon, hl = MiniIcons.get("file", path)
            table.insert(hl_groups, hl)

            return string.format("%s %s|%s|%s| %s", icon, path, row, column, str)
          end, items)

          MiniPick.default_show(buf_id, items, query, { show_icons = false })

          -- Add color to icons
          local icon_extmark_opts = { hl_mode = "combine", priority = 210 }
          for i = 1, #hl_groups do
            icon_extmark_opts.hl_group = hl_groups[i]
            icon_extmark_opts.end_row, icon_extmark_opts.end_col = i - 1, 1
            vim.api.nvim_buf_set_extmark(buf_id, ns, i - 1, 0, icon_extmark_opts)
          end
        end

        local set_items_opts = { do_match = false, querytick = 0 }
        local process
        local match = function(_, _, query)
          pcall(vim.loop.process_kill, process)
          if #query == 0 then
            return MiniPick.set_picker_items({}, set_items_opts)
          end

          local command = {
            "rg",
            "--column",
            "--line-number",
            "--no-heading",
            "--field-match-separator",
            "|",
            "--no-follow",
            "--color=never",
            "--",
            table.concat(query),
          }
          process = MiniPick.set_picker_items_from_cli(
            command,
            { set_items_opts = set_items_opts, spawn_opts = { cwd = vim.uv.cwd() } }
          )
        end

        local choose = function(item)
          local path, row, column = string.match(item, "^([^|]*)|([^|]*)|([^|]*)|.*$")
          local chosen = {
            path = path,
            lnum = tonumber(row),
            col = tonumber(column),
          }
          MiniPick.default_choose(chosen)
        end

        MiniPick.start({
          source = {
            name = "Live Grep",
            items = {},
            match = match,
            show = show,
            choose = choose,
          },
        })
      end, { desc = "[S]earch [G]rep" })
      vim.keymap.set("n", "<leader>sG", function()
        vim.ui.input({
          prompt = "What directory do you want to search in? ",
          default = vim.uv.cwd(),
          completion = "dir",
        }, function(input)
          if not input or input == "" then
            return
          end

          MiniPick.builtin.grep_live({}, { source = { cwd = input } })
        end)
      end, { desc = "[S]earch [G]rep in specific directory" })

      vim.keymap.set("n", "<leader>a", function()
        MiniPick.builtin.grep_live()
      end, { desc = "[S]earch [G]rep in specific directory" })
      vim.keymap.set("n", "<leader>A", function()
        local cword = vim.fn.expand("<cword>")
        vim.defer_fn(function()
          MiniPick.set_picker_query({ cword })
        end, 25)
        MiniPick.builtin.grep_live()
      end, { desc = "[S]earch [W]ord" })

      vim.keymap.set(
        { "x" },
        "<leader>A",
        "<cmd>Pick grep pattern='<cword>'<cr>",
        { desc = "grep cursorword/selection" }
      )

      -- Use fff.nvim if it is available
      -- Fallback to MiniPick.builtin.files
      local fff_is_available, fff = pcall(require, "fff")
      if fff_is_available then
        fff.setup({ ui = { picker = "mini" } })
      end
      vim.keymap.set("n", "<leader>ff", function()
        if fff_is_available then
          fff.find_files()
        else
          MiniPick.registry.files()
        end
      end, { desc = "[S]earch [F]iles" }) -- See https://github.com/echasnovski/mini.nvim/discussions/1873
      -- vim.keymap.set("n", "<leader><space>", function()
      -- 	if fff_is_available then
      -- 		fff.find_files()
      -- 	else
      -- 		MiniPick.registry.files()
      -- 	end
      -- end, { desc = "Search Files" })
      vim.keymap.set("n", "<leader>sF", function()
        vim.ui.input({
          prompt = "What directory do you want to search in? ",
          default = vim.uv.cwd(),
          completion = "dir",
        }, function(input)
          if not input or input == "" then
            return
          end

          if fff_is_available then
            fff.find_files_in_dir(input)
            fff.change_indexing_directory(vim.uv.cwd())
          else
            MiniPick.registry.files()
          end
        end)
      end, { desc = "[S]earch [F]iles in specific directory" })
      vim.keymap.set("n", "<leader>sc", function()
        local config_path = vim.fn.stdpath("config")
        if fff_is_available then
          fff.find_files_in_dir(config_path)
          fff.change_indexing_directory(vim.uv.cwd())
        else
          MiniPick.registry.files(nil, {
            source = {
              cwd = config_path,
            },
          })
        end
      end, { desc = "[S]earch [C]onfig" })

      vim.keymap.set("n", "<leader>sh", function()
        MiniPick.builtin.help({ default_split = "vertical" })
      end, { desc = "[S]earch [H]elp" })
      vim.keymap.set("n", "<leader>st", function()
        MiniPick.registry.todo()
      end, { desc = "[S]earch [T]odo" })
      vim.keymap.set("n", "<leader>ss", function()
        MiniExtra.pickers.lsp({ scope = "document_symbol" })
      end, { desc = "[S]earch [S]ymbols" })
      vim.keymap.set("n", "<leader>sr", function()
        MiniExtra.pickers.lsp({ scope = "references" })
      end, { desc = "[S]earch [R]eferences" })
      vim.keymap.set("n", "<leader>sH", function()
        MiniExtra.pickers.history()
      end, { desc = "[S]earch [H]istory" })
      vim.keymap.set("n", "<leader>sd", function()
        MiniExtra.pickers.diagnostic()
      end, { desc = "[S]earch [D]iagnostic" })
      vim.keymap.set("n", "<leader>sb", function()
        MiniPick.builtin.buffers()
      end, { desc = "[S]earch [B]uffers" })
      vim.keymap.set("n", "<leader>n", function()
        vim.cmd.tabnew()
        MiniNotify.show_history()
      end, { desc = "[N]otification History" })
      vim.keymap.set("n", "<leader>sC", function()
        MiniExtra.pickers.colorschemes(nil, nil)
      end, { desc = "[S]earch [C]olorscheme" })
      vim.keymap.set("n", "z=", function()
        local word = vim.fn.expand("<cword>")
        MiniExtra.pickers.spellsuggest(nil, {
          window = {
            config = function()
              local height = math.floor(0.2 * vim.o.lines)
              local width = math.floor(math.max(vim.fn.strdisplaywidth(word) + 2, 20))
              return {
                relative = "cursor",
                anchor = "NW",
                height = height,
                width = width,
                row = 1, -- I want to see <cword>
                col = -1, -- Aligned nicely with <cword>
              }
            end,
          },
        })
      end, { desc = "Show spellings suggestions" })
    end,
  },
  -- {
  --   "nvim-mini/mini.pick",
  --   enabled = false,
  --   main = "mini.pick",
  --   version = false,
  --   cmd = { "Pick", "MiniPick" },
  --   lazy = true,
  --   dependencies = {
  --     { "echasnovski/mini.extra", config = true },
  --     { "echasnovski/mini.fuzzy", config = true },
  --     { "echasnovski/mini.visits", config = true, event = "LazyFile" },
  --     { "echasnovski/mini.align" },
  --     {
  --       "diego-velez/fff.nvim",
  --       build = {
  --         function()
  --           local cmd = { "rustup", "run", "nightly", "cargo", "build", "--release" }
  --           ---@type vim.SystemOpts
  --           local opts = { cwd = args.path, text = true }
  --
  --           vim.notify("Building " .. args.name, vim.log.levels.INFO)
  --           local output = vim.system(cmd, opts):wait()
  --           if output.code ~= 0 then
  --             vim.notify("Failed to build " .. args.name .. "\n" .. output.stderr, vim.log.levels.ERROR)
  --           else
  --             vim.notify("Built " .. args.name, vim.log.levels.INFO)
  --           end
  --         end,
  --       },
  --     },
  --     -- { "echasnovski/mini.fuzzy",  config = true },
  --   },
  --   init = function(plugin)
  --     -- Use mini pick instead of builtin select
  --     vim.ui.select = require("lazy-require").require_on_exported_call(plugin.main).ui_select
  --
  --     vim.keymap.set("n", "<leader>ff", "<cmd>Pick frecency tool='fd'<cr>", { desc = "find files (frecency)" })
  --     vim.keymap.set("n", "<leader>a", "<cmd>Pick grep_live_align<cr>", { desc = "live grep" })
  --     -- vim.keymap.set("n", "<leader>a", "<cmd>Pick grep<cr>", { desc = "find with grep" })
  --     -- vim.keymap.set("x", "<leader>A", 'y<cmd>Pick grep<cr><c-r>"<cr>', { desc = "find current selection" })
  --     vim.keymap.set(
  --       { "n", "x" },
  --       "<leader>A",
  --       "<cmd>Pick grep pattern='<cword>'<cr>",
  --       { desc = "grep cursorword/selection" }
  --     )
  --     -- vim.keymap.set("n", "<leader>A", "<cmd>Pick grep pattern='<cword>'<cr>", { desc = "grep cursor word" })
  --   end,
  --   opts = {
  --     -- delay = {
  --     --   busy = 1,
  --     -- },
  --
  --     mappings = {
  --       caret_left = "<Left>",
  --       caret_right = "<Right>",
  --
  --       choose = "<C-o>",
  --       choose_alt = {
  --         char = "<nl>",
  --         func = function()
  --           vim.api.nvim_input("<cr>")
  --         end,
  --       },
  --       choose_in_split = "<C-h>",
  --       choose_in_vsplit = "<CR>",
  --       choose_in_tabpage = "<C-t>",
  --       choose_marked = "<C-q>",
  --
  --       delete_char = "<BS>",
  --       delete_char_right = "<Del>",
  --       delete_left = "<C-u>",
  --       delete_word = "<C-w>",
  --
  --       mark = "<C-x>",
  --       mark_all = "<C-a>",
  --
  --       move_down = "<C-n>",
  --       move_start = "<C-g>",
  --       move_up = "<C-p>",
  --
  --       paste = "",
  --
  --       refine = "<C-r>",
  --       refine_marked = "",
  --
  --       scroll_down = "<C-f>",
  --       scroll_left = "<C-Left>",
  --       scroll_right = "<C-Right>",
  --       scroll_up = "<C-b>",
  --
  --       stop = "<Esc>",
  --
  --       toggle_info = "<S-Tab>",
  --       toggle_preview = "<Tab>",
  --       --
  --       -- another_choose = {
  --       --   char = "<C-CR>",
  --       --   func = function()
  --       --     local choose_mapping = MiniPick.get_picker_opts().mappings.choose
  --       --     vim.api.nvim_input(choose_mapping)
  --       --   end,
  --       -- },
  --       --   mark = "<c-space>",
  --
  --       --   mark_and_move_down = {
  --       --     char = "<tab>",
  --       --     func = function()
  --       --       local mappings = MiniPick.get_picker_opts().mappings
  --       --       vim.api.nvim_input(mappings.mark .. mappings.move_down)
  --       --     end,
  --       --   },
  --
  --       --   mark_and_move_up = {
  --       --     char = "<s-tab>",
  --       --     func = function()
  --       --       local mappings = MiniPick.get_picker_opts().mappings
  --       --       vim.api.nvim_input(mappings.mark .. mappings.move_up)
  --       --     end,
  --       --   },
  --
  --       -- actual_paste = {
  --       --   char = "<C-y>",
  --       --   func = function()
  --       --     local content = vim.fn.getreg("+")
  --       --     if content ~= "" then
  --       --       local current_query = MiniPick.get_picker_query() or {}
  --       --       table.insert(current_query, content)
  --       --       MiniPick.set_picker_query(current_query)
  --       --     end
  --       --   end,
  --       -- },
  --     },
  --
  --     options = {
  --       use_cache = true,
  --     },
  --
  --     window = {
  --       config = function()
  --         local height = math.floor(0.25 * vim.o.lines)
  --         local width = math.floor(0.25 * vim.o.columns)
  --         return {
  --           relative = "laststatus",
  --           anchor = "NW",
  --           height = height,
  --           width = width,
  --           row = 0,
  --           col = 0,
  --         }
  --       end,
  --       prompt_prefix = "󰁔 ",
  --       prompt_caret = " ",
  --     },
  --   },
  --   config = function(_, opts)
  --     require("mini.pick").setup(opts)
  --
  --     local setup_target_win_preview = function()
  --       local opts = MiniPick.get_picker_opts()
  --       local show, preview, choose = opts.source.show, opts.source.preview, opts.source.choose
  --
  --       -- Prepare preview and initial buffers
  --       local preview_buf_id = vim.api.nvim_create_buf(false, true)
  --       local win_target = MiniPick.get_picker_state().windows.target
  --       local init_target_buf = vim.api.nvim_win_get_buf(win_target)
  --       vim.api.nvim_win_set_buf(win_target, preview_buf_id)
  --
  --       -- Hook into source's methods
  --       opts.source.show = function(...)
  --         show(...)
  --         local cur_item = MiniPick.get_picker_matches().current
  --         if cur_item == nil then
  --           return
  --         end
  --         preview(preview_buf_id, cur_item)
  --       end
  --
  --       local needs_init_buf_restore = true
  --       opts.source.choose = function(...)
  --         needs_init_buf_restore = false
  --         choose(...)
  --       end
  --
  --       MiniPick.set_picker_opts(opts)
  --
  --       -- Set up buffer cleanup
  --       local cleanup = function()
  --         if needs_init_buf_restore then
  --           vim.api.nvim_win_set_buf(win_target, init_target_buf)
  --         end
  --         vim.api.nvim_buf_delete(preview_buf_id, { force = true })
  --       end
  --       vim.api.nvim_create_autocmd("User", { pattern = "MiniPickStop", once = true, callback = cleanup })
  --     end
  --     vim.api.nvim_create_autocmd("User", { pattern = "MiniPickStart", callback = setup_target_win_preview })
  --
  --     -- local MiniFuzzy = require("mini.fuzzy")
  --     -- local MiniVisits = require("mini.visits")
  --     -- MiniPick.registry.frecency = function()
  --     --   local visit_paths = MiniVisits.list_paths()
  --     --   local current_file = vim.fn.expand("%")
  --     --   MiniPick.builtin.files(nil, {
  --     --     source = {
  --     --       match = function(stritems, indices, query)
  --     --         -- Concatenate prompt to a single string
  --     --         local prompt = vim.pesc(table.concat(query))
  --     --
  --     --         -- If ignorecase is on and there are no uppercase letters in prompt,
  --     --         -- convert paths to lowercase for matching purposes
  --     --         local convert_path = function(str)
  --     --           return str
  --     --         end
  --     --         if vim.o.ignorecase and string.find(prompt, "%u") == nil then
  --     --           convert_path = function(str)
  --     --             return string.lower(str)
  --     --           end
  --     --         end
  --     --
  --     --         local current_file_cased = convert_path(current_file)
  --     --         local paths_length = #visit_paths
  --     --
  --     --         -- Flip visit_paths so that paths are lookup keys for the index values
  --     --         local flipped_visits = {}
  --     --         for index, path in ipairs(visit_paths) do
  --     --           local key = vim.fn.fnamemodify(path, ":.")
  --     --           flipped_visits[convert_path(key)] = index - 1
  --     --         end
  --     --
  --     --         local result = {}
  --     --         for _, index in ipairs(indices) do
  --     --           local path = stritems[index]
  --     --           local match_score = prompt == "" and 0 or MiniFuzzy.match(prompt, path).score
  --     --           if match_score >= 0 then
  --     --             local visit_score = flipped_visits[path] or paths_length
  --     --             table.insert(result, {
  --     --               index = index,
  --     --               -- Give current file high value so it's ranked last
  --     --               score = path == current_file_cased and 999999 or match_score + visit_score * 10,
  --     --             })
  --     --           end
  --     --         end
  --     --
  --     --         table.sort(result, function(a, b)
  --     --           return a.score < b.score
  --     --         end)
  --     --
  --     --         return vim.tbl_map(function(val)
  --     --           return val.index
  --     --         end, result)
  --     --       end,
  --     --     },
  --     --   })
  --     -- end
  --
  --     -- local ok_mini_smart_pick, mini_smart_pick =
  --     --   pcall(dofile, vim.fn.stdpath("config") .. "/after/plugin/mini_smart_pick.lua")
  --     --
  --     -- if ok_mini_smart_pick and MiniPick ~= nil then
  --     --   -- vim.keymap.set("n", "<leader>ff", mini_smart_pick.picker)
  --     --   vim.keymap.set("n", "<leader>ff", "<cmd>Pick files<cr>", { desc = "find files" })
  --     -- end
  --
  --     MiniPick.registry.frecency = function()
  --       local function sort(stritems, indices)
  --         local inf = math.huge
  --
  --         local minivisits = require("mini.visits")
  --         local visit_paths = minivisits.list_paths(nil, { sort = minivisits.gen_sort.z() })
  --
  --         -- relative paths to cwd
  --         visit_paths = vim.tbl_map(function(path)
  --           return vim.fn.fnamemodify(path, ":.")
  --         end, visit_paths)
  --         local scores = {}
  --         for i, path in ipairs(visit_paths) do
  --           scores[path] = i
  --         end
  --
  --         -- current file last
  --         local current_file = vim.fn.expand("%:.")
  --         if scores[current_file] then
  --           scores[current_file] = inf
  --         end
  --
  --         indices = vim.deepcopy(indices)
  --         table.sort(indices, function(item1, item2)
  --           local path1 = stritems[item1]
  --           local path2 = stritems[item2]
  --
  --           local score1 = scores[path1] or inf -- inf for paths not visited
  --           local score2 = scores[path2] or inf -- inf for paths not visited
  --
  --           return score1 < score2
  --         end)
  --         return indices
  --       end
  --
  --       local function get_keyword_matches(path, keywords, local_opts)
  --         local_opts = vim.tbl_extend("force", { force_last = true }, local_opts or {})
  --
  --         local matches = {}
  --
  --         if #keywords == 0 then
  --           return nil -- No keywords, return empty list
  --         end
  --
  --         path = path:lower() -- Convert to lowercase for case-insensitive matching
  --
  --         -- Get the last keyword and remaining ones
  --         local keywords_last = keywords[#keywords]
  --
  --         local last_path_separator = path:match("^.*()" .. "/") or 0
  --         local last_start, last_end = path:find(keywords_last, last_path_separator + 1, true)
  --
  --         if last_start == nil then
  --           if local_opts.force_last then
  --             return nil -- Last keyword not found
  --           end
  --         else
  --           -- Store last keyword match and remove it from the list
  --           keywords = vim.list_slice(keywords, 1, #keywords - 1)
  --           table.insert(matches, { last_start, last_end })
  --           path = path:sub(1, last_start - 1) -- Truncate before last keyword
  --         end
  --
  --         -- Find remaining keywords in reverse order
  --         for i = #keywords, 1, -1 do
  --           local keyword = keywords[i]
  --           local start_idx, end_idx = path:find(keyword, 1, true)
  --           if not start_idx then
  --             return nil -- Missing keyword
  --           end
  --
  --           -- Store match
  --           table.insert(matches, { start_idx, end_idx })
  --
  --           -- Truncate path before this keyword
  --           path = path:sub(1, start_idx - 1)
  --         end
  --
  --         -- Reverse order of matches (since we inserted in reverse)
  --         return matches
  --       end
  --
  --       local function match_filter(stritems, indices, query)
  --         if #stritems == 0 or #indices == 0 then
  --           return indices
  --         end
  --
  --         if #query == 0 or query == nil then
  --           return indices
  --         end
  --
  --         local keywords = vim.split(query, " ")
  --         -- if #keywords == 0 or keywords == nil then
  --         --    return indices
  --         -- end
  --         local should_reset_indices = keywords[#keywords] == ""
  --         if should_reset_indices then
  --           for i = 1, #stritems do
  --             indices[i] = i
  --           end
  --         end
  --         local filtered = {}
  --         for _, index in ipairs(indices) do
  --           local item = stritems[index]
  --           if item ~= nil then
  --             local match = get_keyword_matches(item, keywords)
  --             if match ~= nil then
  --               table.insert(filtered, index)
  --             end
  --           end
  --         end
  --         return filtered
  --       end
  --
  --       local function show(buf_id, items, query, local_opts)
  --         local ns = vim.api.nvim_get_namespaces()["MiniPickRanges"]
  --
  --         local icons = {}
  --         local lines = {}
  --         for i, item in ipairs(items) do
  --           local icon_text, icon_hl_group = require("mini.icons").get("file", item)
  --           icons[i] = { text = icon_text, hl_group = icon_hl_group }
  --           lines[i] = icons[i].text .. " " .. item
  --         end
  --
  --         vim.api.nvim_buf_set_lines(buf_id, 0, -1, false, lines)
  --
  --         -- vim.api.nvim_buf_clear_namespace(buf_id, ns, 0, -1)
  --
  --         -- Highlight icons
  --         for i, icon in ipairs(icons) do
  --           local row = i - 1
  --           vim.api.nvim_buf_set_extmark(buf_id, ns, row, 0, {
  --             end_col = 1,
  --             end_row = row,
  --             hl_group = icon.hl_group,
  --             hl_mode = "combine",
  --             priority = 200,
  --           })
  --         end
  --
  --         query = table.concat(query)
  --         -- Highlight matched ranges
  --         for i, item in ipairs(items) do
  --           local keywords = vim.split(query, " ")
  --           local ranges = get_keyword_matches(item, keywords, { force_last = false })
  --           if ranges == nil then
  --             return
  --           end
  --           for _, range in ipairs(ranges) do
  --             local row = i - 1
  --             local start_col = range[1] - 1 + icons[i].text:len() + 1
  --             local end_col = range[2] + icons[i].text:len() + 1
  --             vim.api.nvim_buf_set_extmark(buf_id, ns, row, start_col, {
  --               end_col = end_col,
  --               end_row = row,
  --               hl_group = "MiniPickMatchRanges",
  --               hl_mode = "combine",
  --               priority = 200,
  --             })
  --           end
  --         end
  --       end
  --
  --       MiniPick.builtin.files(nil, {
  --         source = {
  --           name = "Files (MRU)",
  --           match = function(stritems, indices, query)
  --             query = table.concat(query)
  --             indices = match_filter(stritems, indices, query)
  --             if #indices == 0 then
  --               -- If no matches, try again without forcing the last keyword
  --               indices = match_filter(stritems, indices, query .. " ")
  --             end
  --             indices = sort(stritems, indices)
  --             return indices
  --           end,
  --           show = show,
  --         },
  --         options = {
  --           use_cache = false,
  --         },
  --       })
  --     end
  --
  --     MiniPick.registry.buf_lines_colored = function()
  --       local ns_digit_prefix = vim.api.nvim_create_namespace("cur-buf-pick-show")
  --       local show_cur_buf_lines = function(buf_id, items, query, opts)
  --         if items == nil or #items == 0 then
  --           return
  --         end
  --
  --         -- Show as usual
  --         MiniPick.default_show(buf_id, items, query, opts)
  --
  --         -- Move prefix line numbers into inline extmarks
  --         local lines = vim.api.nvim_buf_get_lines(buf_id, 0, -1, false)
  --         local digit_prefixes = {}
  --         for i, l in ipairs(lines) do
  --           local _, prefix_end, prefix = l:find("^(%s*%d+│)")
  --           if prefix_end ~= nil then
  --             digit_prefixes[i], lines[i] = prefix, l:sub(prefix_end + 1)
  --           end
  --         end
  --
  --         vim.api.nvim_buf_set_lines(buf_id, 0, -1, false, lines)
  --         for i, pref in pairs(digit_prefixes) do
  --           local opts = { virt_text = { { pref, "MiniPickNormal" } }, virt_text_pos = "inline" }
  --           vim.api.nvim_buf_set_extmark(buf_id, ns_digit_prefix, i - 1, 0, opts)
  --         end
  --
  --         -- Set highlighting based on the curent filetype
  --         local ft = vim.bo[items[1].bufnr].filetype
  --         local has_lang, lang = pcall(vim.treesitter.language.get_lang, ft)
  --         local has_ts, _ = pcall(vim.treesitter.start, buf_id, has_lang and lang or ft)
  --         if not has_ts and ft then
  --           vim.bo[buf_id].syntax = ft
  --         end
  --       end
  --
  --       local local_opts = { scope = "current", preserve_order = true }
  --       require("mini.extra").pickers.buf_lines(local_opts, { source = { show = show_cur_buf_lines } })
  --     end
  --
  --     MiniPick.registry.grep_live_align = function()
  --       local sep = package.config:sub(1, 1)
  --       local function truncate_path(path)
  --         local parts = vim.split(path, sep)
  --         if #parts > 2 then
  --           parts = { parts[1], "…", parts[#parts] }
  --         end
  --         return table.concat(parts, sep)
  --       end
  --
  --       local function map_gsub(items, pattern, replacement)
  --         return vim.tbl_map(function(item)
  --           item, _ = string.gsub(item, pattern, replacement)
  --           return item
  --         end, items)
  --       end
  --
  --       local show_align_on_nul = function(buf_id, items, query, opts)
  --         -- Shorten the pathname to keep the width of the picker window to something
  --         -- a bit more reasonable for longer pathnames.
  --         items = map_gsub(items, "^%Z+", truncate_path)
  --
  --         -- Because items is an array of blobs (contains a NUL byte), align_strings
  --         -- will not work because it expects strings. So, convert the NUL bytes to a
  --         -- unique (hopefully) separator, then align, and revert back.
  --         items = map_gsub(items, "%z", "#|#")
  --         items = require("mini.align").align_strings(items, {
  --           justify_side = { "left", "right", "right" },
  --           merge_delimiter = { "", " ", "", " ", "" },
  --           split_pattern = "#|#",
  --         })
  --         items = map_gsub(items, "#|#", "\0")
  --
  --         -- Back to the regularly scheduled program :-)
  --         MiniPick.default_show(buf_id, items, query, opts)
  --       end
  --
  --       MiniPick.builtin.grep_live({}, {
  --         source = { show = show_align_on_nul },
  --         window = { config = { width = math.floor(0.816 * vim.o.columns) } },
  --       })
  --     end
  --   end,
  -- },
  {
    "nvim-mini/mini.surround",
    keys = {
      { "S", mode = { "x" } },
      "ys",
      "ds",
      "cs",
    },
    config = function()
      require("mini.surround").setup({
        mappings = {
          add = "ys",
          delete = "ds",
          replace = "cs",
          find = "",
          find_left = "",
          highlight = "",
          update_n_lines = 500,
        },
        custom_surroundings = {
          tag_name_only = {
            input = { "<(%w-)%f[^<%w][^<>]->.-</%1>", "^<()%w+().*</()%w+()>$" },
            output = function()
              local tag_name = require("mini.surround").user_input("Tag name (excluding attributes)")
              if tag_name == nil then
                return nil
              end
              return { left = tag_name, right = tag_name }
            end,
          },
        },
      })

      Keymap("x", "S", [[:<C-u>lua MiniSurround.add('visual')<CR>]])
      Keymap("n", "yss", "ys_", { noremap = false })
    end,
  },
  {
    "nvim-mini/mini.hipatterns",
    opts = function()
      local hi = require("mini.hipatterns")
      return {

        -- Highlight standalone "FIXME", "ERROR", "HACK", "TODO", "NOTE", "WARN", "REF"
        highlighters = {
          fixme = { pattern = "%f[%w]()FIXME()%f[%W]", group = "MiniHipatternsFixme" },
          error = { pattern = "%f[%w]()ERROR()%f[%W]", group = "MiniHipatternsError" },
          hack = { pattern = "%f[%w]()HACK()%f[%W]", group = "MiniHipatternsHack" },
          warn = { pattern = "%f[%w]()WARN()%f[%W]", group = "MiniHipatternsWarn" },
          todo = { pattern = "%f[%w]()TODO()%f[%W]", group = "MiniHipatternsTodo" },
          note = { pattern = "%f[%w]()NOTE()%f[%W]", group = "MiniHipatternsNote" },
          ref = { pattern = "%f[%w]()REF()%f[%W]", group = "MiniHipatternsRef" },
          refs = { pattern = "%f[%w]()REFS()%f[%W]", group = "MiniHipatternsRef" },
          due = { pattern = "%f[%w]()@@%f![%W]", group = "MiniHipatternsDue" },

          hex_color = hi.gen_highlighter.hex_color({ priority = 2000 }),
          shorthand = {
            pattern = "()#%x%x%x()%f[^%x%w]",
            group = function(_, _, data)
              ---@type string
              local match = data.full_match
              local r, g, b = match:sub(2, 2), match:sub(3, 3), match:sub(4, 4)
              local hex_color = "#" .. r .. r .. g .. g .. b .. b

              return MiniHipatterns.compute_hex_color_group(hex_color, "bg")
            end,
            extmark_opts = { priority = 2000 },
          },
        },

        tailwind = {
          enabled = true,
          ft = {
            "astro",
            "css",
            "heex",
            "html",
            "html-eex",
            "javascript",
            "javascriptreact",
            "rust",
            "svelte",
            "typescript",
            "typescriptreact",
            "vue",
            "elixir",
            "phoenix-html",
            "heex",
          },
          -- full: the whole css class will be highlighted
          -- compact: only the color will be highlighted
          style = "full",
        },
      }
    end,
    config = function(_, opts)
      require("mini.hipatterns").setup(opts)
    end,
  },
  {
    "nvim-mini/mini.ai",
    keys = {
      { "a", mode = { "o", "x" } },
      { "i", mode = { "o", "x" } },
    },
    config = function()
      local ai = require("mini.ai")
      local gen_spec = ai.gen_spec
      ai.setup({
        n_lines = 500,
        search_method = "cover_or_next",
        custom_textobjects = {
          o = gen_spec.treesitter({
            a = { "@block.outer", "@conditional.outer", "@loop.outer" },
            i = { "@block.inner", "@conditional.inner", "@loop.inner" },
          }, {}),
          f = gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }, {}),
          c = gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }, {}),
          -- t = { "<(%w-)%f[^<%w][^<>]->.-</%1>", "^<.->%s*().*()%s*</[^/]->$" }, -- deal with selection without the carriage return
          t = { "<([%p%w]-)%f[^<%p%w][^<>]->.-</%1>", "^<.->().*()</[^/]->$" },

          -- scope
          s = gen_spec.treesitter({
            a = { "@function.outer", "@class.outer", "@testitem.outer" },
            i = { "@function.inner", "@class.inner", "@testitem.inner" },
          }),
          S = gen_spec.treesitter({
            a = { "@function.name", "@class.name", "@testitem.name" },
            i = { "@function.name", "@class.name", "@testitem.name" },
          }),
        },
        mappings = {
          around = "a",
          inside = "i",

          around_next = "an",
          inside_next = "in",
          around_last = "al",
          inside_last = "il",

          goto_left = "",
          goto_right = "",
        },
      })
    end,
  },
  {
    "nvim-mini/mini.pairs",
    enabled = false,
    opts = {
      modes = { insert = true, command = false, terminal = false },
      -- skip autopair when next character is one of these
      skip_next = [=[[%w%%%'%[%"%.%`%$]]=],
      -- skip autopair when the cursor is inside these treesitter nodes
      skip_ts = { "string" },
      -- skip autopair when next character is closing pair
      -- and there are more closing pairs than opening pairs
      skip_unbalanced = true,
      -- better deal with markdown code blocks
      markdown = true,
      mappings = {
        ["`"] = { neigh_pattern = "[^\\`]." }, -- Prevent 4th backtick (https://github.com/echasnovski/mini.nvim/issues/31#issuecomment-2151599842)
      },
    },
  },
  {
    "nvim-mini/mini.clue",
    event = "VeryLazy",
    opts = function()
      local ok, clue = pcall(require, "mini.clue")
      if not ok then
        return
      end
      -- REF: https://github.com/ahmedelgabri/dotfiles/blob/main/config/nvim/lua/plugins/mini.lua#L314
      -- Clues for a-z/A-Z marks.
      local function mark_clues()
        local marks = {}
        vim.list_extend(marks, vim.fn.getmarklist(vim.api.nvim_get_current_buf()))
        vim.list_extend(marks, vim.fn.getmarklist())

        return vim
          .iter(marks)
          :map(function(mark)
            local key = mark.mark:sub(2, 2)

            -- Just look at letter marks.
            if not string.match(key, "^%a") then
              return nil
            end

            -- For global marks, use the file as a description.
            -- For local marks, use the line number and content.
            local desc
            if mark.file then
              desc = vim.fn.fnamemodify(mark.file, ":p:~:.")
            elseif mark.pos[1] and mark.pos[1] ~= 0 then
              local line_num = mark.pos[2]
              local lines = vim.fn.getbufline(mark.pos[1], line_num)
              if lines and lines[1] then
                desc = string.format("%d: %s", line_num, lines[1]:gsub("^%s*", ""))
              end
            end

            if desc then
              return {
                mode = "n",
                keys = string.format("`%s", key),
                desc = desc,
              }
            end
          end)
          :totable()
      end

      -- Clues for recorded macros.
      local function macro_clues()
        local res = {}
        for _, register in ipairs(vim.split("abcdefghijklmnopqrstuvwxyz", "")) do
          local keys = string.format('"%s', register)
          local ok, desc = pcall(vim.fn.getreg, register, 1)
          if ok and desc ~= "" then
            table.insert(res, { mode = "n", keys = keys, desc = desc })
            table.insert(res, { mode = "v", keys = keys, desc = desc })
          end
        end

        return res
      end

      return {
        triggers = {
          -- Leader triggers
          { mode = "n", keys = "<leader>" },
          { mode = "x", keys = "<leader>" },

          { mode = "n", keys = "<localleader>" },
          { mode = "x", keys = "<localleader>" },

          { mode = "n", keys = "<C-x>", desc = "+task toggling" },
          -- Built-in completion
          { mode = "i", keys = "<C-x>" },

          -- `g` key
          { mode = "n", keys = "g", desc = "+go[to]" },
          { mode = "x", keys = "g", desc = "+go[to]" },

          -- Marks
          { mode = "n", keys = "'" },
          { mode = "n", keys = "`" },
          { mode = "x", keys = "'" },
          { mode = "x", keys = "`" },

          -- Registers
          { mode = "n", keys = '"' },
          { mode = "x", keys = '"' },
          { mode = "i", keys = "<C-r>" },
          { mode = "c", keys = "<C-r>" },

          -- Window commands
          { mode = "n", keys = "<C-w>" },

          -- `z` key
          { mode = "n", keys = "z" },
          { mode = "x", keys = "z" },

          -- mini.surround
          { mode = "n", keys = "S", desc = "+treesitter" },

          -- Operator-pending mode key
          { mode = "o", keys = "a" },
          { mode = "o", keys = "i" },

          -- Moving between stuff.
          { mode = "n", keys = "[" },
          { mode = "n", keys = "]" },
        },

        clues = {
          { mode = "n", keys = "<leader>e", desc = "+explore/edit files" },
          { mode = "n", keys = "<leader>f", desc = "+find (" .. "default" .. ")" },
          { mode = "n", keys = "<leader>s", desc = "+search" },
          { mode = "n", keys = "<leader>t", desc = "+terminal" },
          { mode = "n", keys = "<leader>r", desc = "+repl" },
          { mode = "n", keys = "<leader>l", desc = "+lsp" },
          { mode = "n", keys = "<leader>n", desc = "+notes" },
          { mode = "n", keys = "<leader>g", desc = "+git" },
          { mode = "n", keys = "<leader>p", desc = "+plugins" },
          { mode = "n", keys = "<localleader>g", desc = "+git" },
          { mode = "n", keys = "<localleader>h", desc = "+git hunk" },
          { mode = "n", keys = "<localleader>t", desc = "+test" },
          { mode = "n", keys = "<localleader>s", desc = "+spell" },
          { mode = "n", keys = "<localleader>d", desc = "+debug" },
          { mode = "n", keys = "<localleader>y", desc = "+yank" },

          { mode = "n", keys = "[", desc = "+prev" },
          { mode = "n", keys = "]", desc = "+next" },

          clue.gen_clues.builtin_completion(),
          clue.gen_clues.g(),
          clue.gen_clues.marks(),
          clue.gen_clues.registers(),
          clue.gen_clues.windows(),
          clue.gen_clues.z(),

          mark_clues,
          macro_clues,
        },
        window = {
          -- Floating window config
          config = function(bufnr)
            local max_width = 0
            for _, line in ipairs(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)) do
              max_width = math.max(max_width, vim.fn.strchars(line))
            end

            -- Keep some right padding.
            max_width = max_width + 2

            return {
              border = "rounded",
              -- Dynamic width capped at 45.
              width = math.min(45, max_width),
            }
          end,

          -- Delay before showing clue window
          delay = 300,

          -- Keys to scroll inside the clue window
          scroll_down = "<C-d>",
          scroll_up = "<C-u>",
        },
      }
    end,
  },
}
