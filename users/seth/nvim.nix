{
  lib,
  pkgs,
  config,
  username,
  ...
}: {
  # imports = [
  #   # ./nvim-ai.nix,
  # ];

  # Use .vimrc for standard vim settings
  # xdg.configFile."nvim/.vimrc".source = nvim/.vimrc;
  # xdg.configFile."nvim/.vimrc".source = nvim-next/.vimrc;

  # Create folders for backups, swaps, and undo
  home.activation.mkdirNvimFolders = lib.hm.dag.entryAfter ["writeBoundary"] ''
    mkdir -p $HOME/.config/nvim/backups $HOME/.config/nvim/swaps $HOME/.config/nvim/undo
  '';

  xdg.configFile."nvim".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles-nix/users/${username}/nvim";

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    package = pkgs.nvim-nightly;
#
#     # Use init.lua for standard neovim settings
#     extraLuaConfig = lib.fileContents nvim-next/init.lua;
#
#     plugins = with pkgs.unstable.vimPlugins; [
#       # =======================================================================
#       # UI AND THEMES
#       # Zenbones for minimal theme
#       # Switches light/dark automatically with OS
#       # =======================================================================
#       {
#         plugin = zenbones-nvim;
#         type = "lua";
#         config = ''
#           vim.g.zenbones = {
#             solid_line_nr    = true,
#             solid_vert_split = true,
#             darken_noncurrent_window = true,
#             lighten_noncurrent_window = true,
#           }
#           vim.cmd.colorscheme "forestbones"
#         '';
#       }
#       lush-nvim
#       # {
#       #   plugin = pkgs.vimUtils.buildVimPlugin {
#       #     pname = "auto-dark-mode-nvim"; # switch vim color with OS theme
#       #     version = "2025-07-01";
#       #     src = pkgs.fetchFromGitHub {
#       #       owner = "f-person";
#       #       repo = "auto-dark-mode.nvim";
#       #       rev = "97a86c9402c784a254e5465ca2c51481eea310e3";
#       #       hash = "sha256-zedwqG5PeJiSAZCl3GeyHwKDH/QjTz2OqDsFRTMTH/A=";
#       #     };
#       #   };
#       #   type = "lua";
#       #   config = ''
#       #     require('auto-dark-mode').setup({
#       #       update_interval = 1000,
#       #       set_dark_mode = function()
#       #         vim.o.background = 'dark'
#       #       end,
#       #       set_light_mode = function()
#       #         vim.o.background = 'light'
#       #       end,
#       #     })
#       #   '';
#       # }
#       # =======================================================================
#       # PROSE
#       # - Optional prose mode for writing: wrap, bindings, zen
#       # =======================================================================
#       {
#         plugin = zen-mode-nvim;
#         type = "lua";
#         config = ''
#           -- I write prose in markdown, all the following is to help with that.
#           function _G.toggleProse()
#             require("zen-mode").toggle({
#               window = {
#                 backdrop = 1,
#                 width = 80
#               },
#               plugins = {
#                 tmux = { enabled = true }
#               },
#               on_open = function()
#                 if (vim.bo.filetype == "markdown" or vim.bo.filetype == "telekasten") then
#                   vim.o.scrolloff = 999
#                   vim.o.relativenumber = false
#                   vim.o.number = false
#                   vim.o.wrap = true
#                   vim.o.linebreak = true
#                   vim.o.colorcolumn = "0"
#
#                   vim.keymap.set('n', 'j', 'gj', {noremap = true, buffer = true})
#                   vim.keymap.set('n', 'k', 'gk', {noremap = true, buffer = true})
#                 end
#               end,
#               on_close = function()
#                 vim.o.scrolloff = 3
#                 vim.o.relativenumber = true
#                 if (vim.bo.filetype == "markdown" or vim.bo.filetype == "telekasten") then
#                   vim.o.wrap = false
#                   vim.o.linebreak = false
#                   vim.o.colorcolumn = "80"
#                 end
#
#                 vim.keymap.set('n', 'j', 'j', {noremap = true, buffer = true})
#                 vim.keymap.set('n', 'k', 'k', {noremap = true, buffer = true})
#               end
#             })
#           end
#
#           vim.keymap.set(
#             'n',
#             '<localleader>m',
#             ':lua _G.toggleProse()<cr>',
#             {noremap = true, silent = true, desc = "Toggle Writing Mode"}
#           )
#         '';
#       }
#       # =======================================================================
#       # TREESITTER
#       # - enable treesitter options
#       # - TS-enabled context breadcrumbs
#       # - helix style scope selection
#       # =======================================================================
#       {
#         plugin = nvim-treesitter.withAllGrammars; # Treesitter
#         type = "lua";
#         config = ''
#           require'nvim-treesitter.configs'.setup {
#             highlight = { enable = true, },
#             indent = { enable = true },
#           }
#         '';
#       }
#       {
#         plugin = nvim-treesitter-context;
#         type = "lua";
#         config = ''
#           require'treesitter-context'.setup{
#             enable = false
#           }
#           vim.keymap.set('n', '<localleader>c', "<cmd>TSContext toggle<cr>", {noremap = true, silent = true, desc = "Toggle TS Context"})
#         '';
#       }
#       {
#         plugin = nvim-treesitter-textobjects; # helix-style selection of TS tree
#         type = "lua";
#         config = ''
#           require'nvim-treesitter.configs'.setup {
#             incremental_selection = {
#               enable = true,
#               keymaps = {
#                 init_selection = "<M-o>",
#                 scope_incremental = "<M-O>",
#                 node_incremental = "<M-o>",
#                 node_decremental = "<M-i>",
#               },
#             },
#           }
#         '';
#       }
#       # =======================================================================
#       # UTILITIES AND MINI
#       # =======================================================================
#       {
#         plugin = mini-nvim; # Ridiculously complete family of plugins
#         type = "lua";
#         config = ''
#           -- opts decorates keymaps with labels
#           local opts = function(label)
#             return {noremap = true, silent = true, desc = label}
#           end
#
#           require('mini.ai').setup()         -- a/i textobjects
#
#           require('mini.align').setup()      -- aligning
#
#           require('mini.bracketed').setup()  -- unimpaired bindings with TS
#
#           require('mini.snippets').setup()
#
#           require('mini.completion').setup()
#
#           require('mini.diff').setup()
#           vim.keymap.set('n', '<localleader>gd', "<cmd>:lua MiniDiff.toggle_overlay()<cr>", opts("Toggle Diff Overlay"))
#
#           require('mini.extra').setup()      -- extra pickers
#
#           -- require('mini.files').setup({
#           --   options = {
#           --     use_as_default_explorer = false
#           --   }
#           -- })
#           -- local oil_style = function()
#           --   if not MiniFiles.close() then
#           --     MiniFiles.open(vim.api.nvim_buf_get_name(0))
#           --     MiniFiles.reveal_cwd()
#           --   end
#           -- end
#           -- vim.keymap.set('n', '<leader>ev', oil_style, opts("File Explorer"));
#
#           local hipatterns = require('mini.hipatterns')
#           hipatterns.setup({  -- highlight strings and colors
#             highlighters = {
#               -- Highlight standalone 'FIXME', 'HACK', 'TODO', 'NOTE'
#               fixme = { pattern = '%f[%w]()FIXME()%f[%W]', group = 'MiniHipatternsFixme' },
#               hack  = { pattern = '%f[%w]()HACK()%f[%W]',  group = 'MiniHipatternsHack'  },
#               todo  = { pattern = '%f[%w]()TODO()%f[%W]',  group = 'MiniHipatternsTodo'  },
#               note  = { pattern = '%f[%w]()NOTE()%f[%W]',  group = 'MiniHipatternsNote'  },
#
#               -- Highlight hex color strings (`#rrggbb`) using that color
#               hex_color = hipatterns.gen_highlighter.hex_color(),
#             }
#           })
#
#           require('mini.icons').setup()      -- minimal icons
#
#           require('mini.jump').setup()       -- fFtT work past a line
#           local MiniJump2d = require('mini.jump2d').setup({
#             view = {
#               dim = true
#             },
#             mappings = {
#               start_jumping = ""
#             }
#           })
#           vim.keymap.set('n', 'gw', "<cmd>:lua MiniJump2d.start(MiniJump2d.builtin_opts.single_character)<cr>", opts("Jump to Word"))
#
#           require('mini.pairs').setup()      -- pair brackets
#
#           require('mini.pick').setup({
#             mappings = {
#               choose_marked = '<C-q>' -- sends to quickfix anyway
#             }
#           })       -- pickers
#           MiniPick.registry.files_root = function(local_opts)
#             local root_patterns = { ".git" }
#             local root_dir = vim.fs.dirname(vim.fs.find(root_patterns, { upward = true })[1])
#             local opts = { source = { cwd = root_dir } }
#             local_opts.cwd = root_dir -- nil?
#             return MiniPick.builtin.files(local_opts, opts)
#           end
#           vim.keymap.set('n', '<leader>a', "<cmd>Pick grep_live<cr>", opts("Live Grep"))
#           vim.keymap.set('n', '<leader>fF', "<cmd>Pick files tool='git'<cr>", opts("Find Files in CWD"))
#           vim.keymap.set('n', '<leader>ff', "<cmd>Pick files_root tool='git'<cr>", opts("Find Files"))
#           vim.keymap.set('n', '<leader><leader>', "<cmd>Pick buffers<cr>", opts("Buffers"))
#           vim.keymap.set('n', "<leader><space>", "<cmd>Pick resume<cr>", opts("Last Picker"))
#           vim.keymap.set('n', "<leader>gc", "<cmd>Pick git_commits<cr>", opts("Git Commits"))
#           vim.keymap.set('n', "<leader>z", "<cmd>lua MiniPick.builtin.files(nil, {source={cwd=vim.fn.expand('~/src/wiki')}})<cr>", opts("Wiki"))
#
#           require('mini.statusline').setup() -- minimal statusline
#
#           require('mini.surround').setup()
#
#           require('mini.splitjoin').setup()  -- work with parameters
#
#           local miniclue = require('mini.clue')
#           miniclue.setup({                   -- cute prompts about bindings
#             triggers = {
#               { mode = 'n', keys = '<Leader>' },
#               { mode = 'x', keys = '<Leader>' },
#               { mode = 'n', keys = '<space>' },
#               { mode = 'x', keys = '<space>' },
#
#               -- Built-in completion
#               { mode = 'i', keys = '<C-x>' },
#
#               -- `g` key
#               { mode = 'n', keys = 'g' },
#               { mode = 'x', keys = 'g' },
#
#               -- Marks
#               { mode = 'n', keys = "'" },
#               { mode = 'n', keys = '`' },
#               { mode = 'x', keys = "'" },
#               { mode = 'x', keys = '`' },
#
#               -- Registers
#               { mode = 'n', keys = '"' },
#               { mode = 'x', keys = '"' },
#               { mode = 'i', keys = '<C-r>' },
#               { mode = 'c', keys = '<C-r>' },
#
#               -- Window commands
#               { mode = 'n', keys = '<C-w>' },
#
#               -- `z` key
#               { mode = 'n', keys = 'z' },
#               { mode = 'x', keys = 'z' },
#
#               -- Bracketed
#               { mode = 'n', keys = '[' },
#               { mode = 'n', keys = ']' },
#             },
#             clues = {
#               miniclue.gen_clues.builtin_completion(),
#               miniclue.gen_clues.g(),
#               miniclue.gen_clues.marks(),
#               miniclue.gen_clues.registers(),
#               miniclue.gen_clues.windows(),
#               miniclue.gen_clues.z(),
#             },
#           })
#         '';
#       }
#       {
#         plugin = oil-nvim; # Ridiculously complete family of plugins
#         type = "lua";
#         config = ''
#
#           Icons = {kind = {File = "", Folder = ""}}
#     local icon_file = vim.trim(Icons.kind.File)
#     local icon_dir = vim.trim(Icons.kind.Folder)
#     local permission_hlgroups = setmetatable({
#       ["-"] = "OilPermissionNone",
#       ["r"] = "OilPermissionRead",
#       ["w"] = "OilPermissionWrite",
#       ["x"] = "OilPermissionExecute",
#     }, {
#       __index = function()
#         return "OilDir"
#       end,
#     })
#
#     local type_hlgroups = setmetatable({
#       ["-"] = "OilTypeFile",
#       ["d"] = "OilTypeDir",
#       ["f"] = "OilTypeFifo",
#       ["l"] = "OilTypeLink",
#       ["s"] = "OilTypeSocket",
#     }, {
#       __index = function()
#         return "OilTypeFile"
#       end,
#     })
#
#     require("oil").setup({
#       delete_to_trash = true,
#       default_file_explorer = true,
#       skip_confirm_for_simple_edits = true,
#       -- trash_command = "trash-cli",
#       prompt_save_on_select_new_entry = false,
#       use_default_keymaps = false,
#       is_always_hidden = function(name, _bufnr)
#         return name == ".."
#       end,
#       -- columns = {
#       --   "icon",
#       --   -- "permissions",
#       --   -- "size",
#       --   -- "mtime",
#       -- },
#
#       columns = {
#         {
#           "type",
#           icons = {
#             directory = "d",
#             fifo = "f",
#             file = "-",
#             link = "l",
#             socket = "s",
#           },
#           highlight = function(type_str)
#             return type_hlgroups[type_str]
#           end,
#         },
#         {
#           "permissions",
#           highlight = function(permission_str)
#             local hls = {}
#             for i = 1, #permission_str do
#               local char = permission_str:sub(i, i)
#               table.insert(hls, { permission_hlgroups[char], i - 1, i })
#             end
#             return hls
#           end,
#         },
#         { "size", highlight = "Special" },
#         { "mtime", highlight = "Number" },
#         {
#           "icon",
#           default_file = icon_file,
#           directory = icon_dir,
#           add_padding = false,
#         },
#       },
#       view_options = {
#         show_hidden = true,
#       },
#       keymaps = {
#         ["<C-y>"] = "actions.yank_entry",
#         ["g?"] = "actions.show_help",
#         ["gs"] = "actions.change_sort",
#         ["gx"] = "actions.open_external",
#         ["g."] = "actions.toggle_hidden",
#         ["<BS>"] = function()
#           require("oil").open()
#         end,
#         ["gd"] = {
#           desc = "Toggle detail view",
#           callback = function()
#             local oil = require("oil")
#             local config = require("oil.config")
#             if #config.columns == 1 then
#               oil.set_columns({ "icon", "permissions", "size", "mtime" })
#             else
#               oil.set_columns({ "type", "icon" })
#             end
#           end,
#         },
#         ["<CR>"] = "actions.select",
#       },
#     })
#
#
# vim.keymap.set("n", "<leader>ev",
#       function()
#         -- vim.cmd([[vertical rightbelow split|vertical resize 60]])
#         vim.cmd([[vertical rightbelow split]])
#         require("oil").open()
#       end,
#       {desc = "[e]xplore cwd -> oil ([v]split)"})
# vim.keymap.set("n", "<leader>ee",
#       function()
#         require("oil").open()
#       end,
#       {desc = "[e]xplore cwd -> oil ([e]dit)"})
# '';
#       }
#       # =======================================================================
#       # UTILITIES
#       # =======================================================================
#       targets-vim # Classic text-objects
#       vim-eunuch # powerful buffer-level file options
#       vim-ragtag # print/execute bindings for template files
#       vim-speeddating # incrementing dates and times
#       vim-fugitive # :Git actions
#       vim-rhubarb # github plugins for fugitive
#       {
#         plugin = nvim-dap;
#         type = "lua";
#         config = ''
#         '';
#       }
#     ];
#   };
  };
}
