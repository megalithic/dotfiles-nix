-- Load .vimrc
vim.cmd([[runtime .vimrc]])

_G.Icons = {
  lsp = {

    error = "", -- alts:  󰬌      
    warn = "󰔷", -- alts: 󰬞 󰔷   ▲ 󰔷  󰲉
    info = "", -- alts: 󰖧 󱂈 󰋼  󰙎   󰬐 󰰃     ● 󰬐  ∙  󰌶
    hint = "▫", -- alts:  󰬏 󰰀  󰰂 󰰂 󰰁 󰫵 󰋢    ∴
    ok = "✓", -- alts: ✓✓
    clients = "", -- alts:     󱉓 󱡠 󰾂 
  },
  test = {
    passed = "", --alts: 
    failed = "", --alts: 
    running = "",
    skipped = "○",
    unknown = "", -- alts: 
  },
  vscode = {
    Text = "󰉿 ",
    Method = "󰆧 ",
    Function = "󰊕 ",
    Constructor = " ",
    Field = "󰜢 ",
    Variable = "󰀫 ",
    Class = "󰠱 ",
    Interface = " ",
    Module = " ",
    Property = "󰜢 ",
    Unit = "󰑭 ",
    Value = "󰎠 ",
    Enum = " ",
    Keyword = "󰌋 ",
    Snippet = " ",
    Color = "󰏘 ",
    File = "󰈙 ",
    Reference = "󰈇 ",
    Folder = "󰉋 ",
    EnumMember = " ",
    Constant = "󰏿 ",
    Struct = "󰙅 ",
    Event = " ",
    Operator = "󰆕 ",
    TypeParameter = " ",
  },
  kind = {
    Array = "",
    Boolean = "",
    Class = "󰠱",
    -- Class = "", -- Class
    Codeium = "",
    Color = "󰏘",
    -- Color = "", -- Color
    Constant = "󰏿",
    -- Constant = "", -- Constant
    Constructor = "",
    -- Constructor = "", -- Constructor
    Enum = "", -- alts: 
    -- Enum = "", -- Enum -- alts: 了
    EnumMember = "", -- alts: 
    -- EnumMember = "", -- EnumMember
    Event = "",
    Field = "󰜢",
    File = "󰈙",
    -- File = "", -- File
    Folder = "󰉋",
    -- Folder = "", -- Folder
    Function = "󰊕",
    Interface = "",
    Key = "",
    Keyword = "󰌋",
    -- Keyword = "", -- Keyword
    Method = "",
    Module = "",
    Namespace = "",
    Null = "󰟢", -- alts: 󰱥󰟢
    Number = "󰎠", -- alts: 
    Object = "",
    -- Operator = "\u{03a8}", -- Operator
    Operator = "󰆕",
    Package = "",
    Property = "󰜢",
    -- Property = "", -- Property
    Reference = "󰈇",
    Snippet = "", -- alts: 
    String = "", -- alts:  󱀍 󰀬 󱌯
    Struct = "󰙅",
    Text = "󰉿",
    TypeParameter = "",
    Unit = "󰑭",
    -- Unit = "", -- Unit
    Value = "󰎠",
    Variable = "󰀫",
    -- Variable = "", -- Variable, alts: 

    -- Text = "",
    -- Method = "",
    -- Function = "",
    -- Constructor = "",
    -- Field = "",
    -- Variable = "",
    -- Class = "",
    -- Interface = "",
    -- Module = "",
    -- Property = "",
    -- Unit = "",
    -- Value = "",
    -- Enum = "",
    -- Keyword = "",
    -- Snippet = "",
    -- Color = "",
    -- File = "",
    -- Reference = "",
    -- Folder = "",
    -- EnumMember = "",
    -- Constant = "",
    -- Struct = "",
    -- Event = "",
    -- Operator = "",
    -- TypeParameter = "",
  },
  separators = {
    thin_block = "│",
    left_thin_block = "▏",
    vert_bottom_half_block = "▄",
    vert_top_half_block = "▀",
    right_block = "🮉",
    right_med_block = "▐",
    light_shade_block = "░",
  },
  misc = {
    formatter = "", -- alts: 󰉼
    buffers = "",
    clock = "",
    ellipsis = "…",
    lblock = "▌",
    rblock = "▐",
    bug = "", -- alts: 
    question = "",
    lock = "󰌾", -- alts:   
    shaded_lock = "",
    circle = "",
    project = "",
    dashboard = "",
    history = "󰄉",
    comment = "󰅺",
    robot = "󰚩", -- alts: 󰭆
    lightbulb = "󰌵",
    file_tree = "󰙅",
    help = "󰋖", -- alts: 󰘥 󰮥 󰮦 󰋗 󰞋 󰋖
    search = "", -- alts: 󰍉
    exit = "󰈆", -- alts: 󰩈󰿅
    code = "",
    telescope = "",
    terminal = "", -- alts: 
    gear = "",
    package = "",
    list = "",
    sign_in = "",
    check = "✓", -- alts: ✓
    fire = "",
    note = "󰎛",
    bookmark = "",
    pencil = "󰏫",
    arrow_right = "",
    caret_right = "",
    chevron_right = "",
    r_chev = "",
    double_chevron_right = "»",
    table = "",
    calendar = "",
    fold_open = "",
    fold_close = "",
    hydra = "🐙",
    flames = "󰈸", -- alts: 󱠇󰈸
    vsplit = "◫",
    v_border = "▐ ",
    virtual_text = "◆",
    mode_term = "",
    ln_sep = "≡", -- alts: ≡ ℓ 
    sep = "⋮",
    perc_sep = "",
    modified = "", -- alts: ∘✿✸✎ ○∘●●∘■ □ ▪ ▫● ◯ ◔ ◕ ◌ ◎ ◦ ◆ ◇ ▪▫◦∘∙⭘
    mode = "",
    vcs = "",
    readonly = "",
    prompt = "",
    markdown = {
      h1 = "◉", -- alts: 󰉫¹◉
      h2 = "◆", -- alts: 󰉬²◆
      h3 = "󱄅", -- alts: 󰉭³✿
      h4 = "⭘", -- alts: 󰉮⁴○⭘
      h5 = "◌", -- alts: 󰉯⁵◇◌
      h6 = "", -- alts: 󰉰⁶
      dash = "",
    },
  },
  git = {
    add = "▕", -- alts:  ▕,▕, ▎, ┃, │, ▌, ▎ 🮉
    change = "🮉", -- alts:  ▕ ▎║▎ ▀, ▁, ▂, ▃, ▄, ▅, ▆, ▇, █, ▉, ▊, ▋, ▌, ▍, ▎, ▏, ▐
    delete = "█", -- alts: ┊▎▎
    topdelete = "▀",
    changedelete = "▄",
    untracked = "▕",
    mod = "",
    remove = "", -- alts: 
    ignore = "",
    rename = "",
    diff = "",
    repo = "",
    symbol = "", -- alts:  
    unstaged = "󰛄",
  },
}

-- Neovim specific settings
vim.o.icm = "split"
vim.o.cia = "kind,abbr,menu"
vim.o.foldtext = "v:lua.vim.treesitter.foldtext()"
vim.o.winborder = "rounded"

vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"

vim.o.showmode = false

local M = {}

M.opt = {
  cmdwinheight = 4,
  cmdheight = 1,
  diffopt = {
    "vertical",
    "iwhite",
    "hiddenoff",
    "foldcolumn:0",
    "context:4",
    "algorithm:histogram",
    "indent-heuristic",
    "linematch:60",
    "internal",
    "filler",
    "closeoff",
  },
  fillchars = {
    horiz = "━",
    vert = "▕", -- alternatives │┃
    -- horizdown = '┳',
    -- horizup   = '┻',
    -- vertleft  = '┫',
    -- vertright = '┣',
    -- verthoriz = '╋',
    eob = " ", -- suppress ~ at EndOfBuffer
    diff = "╱", -- alts: = ⣿ ░ ─
    msgsep = " ", -- alts: ‾ ─ fold = " ", foldopen = Icons.misc.fold_open, -- alts: ▾ foldsep = "│", foldsep = " ",
    -- foldclose = Icons.misc.fold_close, -- alts: ▸
    stl = " ", -- alts: ─ ⣿ ░ ▐ ▒▓
    stlnc = " ", -- alts: ─
  },
  formatoptions = vim.opt.formatoptions
    - "a" -- Auto formatting is BAD.
    - "t" -- Don't auto format my code. I got linters for that.
    + "c" -- In general, I like it when comments respect textwidth
    + "q" -- Allow formatting comments w/ `gq`
    + "w" -- Trailing whitespace indicates a paragraph
    - "o" -- Insert comment leader after hitting `o` or `O`
    + "r" -- Insert comment leader after hitting Enter
    + "n" -- Indent past the formatlistpat, not underneath it.
    + "j" -- Remove comment leader when makes sense (joining lines)
    -- + "2" -- Use the second line's indent vale when indenting (allows indented first line)
    - "2", -- I'm not in gradeschool anymore
  -- Preview substitutions live, as you type!
  inccommand = "split",
  list = true,
  listchars = {
    eol = nil,
    tab = "» ", -- alts: »│ │
    nbsp = "␣",
    extends = "›", -- alts: … »
    precedes = "‹", -- alts: … «
    trail = "·", -- alts: • BULLET (U+2022, UTF-8: E2 80 A2)
  },
  -- Enable mouse mode, can be useful for resizing splits for example!
  mouse = "a",
  sessionoptions = vim.opt.sessionoptions:remove({ "buffers", "folds" }),
  shada = { "!", "'1000", "<50", "s10", "h" }, -- Increase the shadafile size so that history is longer
  shortmess = vim.opt.shortmess:append({
    I = true, -- No splash screen
    W = true, -- Don't print "written" when editing
    a = true, -- Use abbreviations in messages ([RO] intead of [readonly])
    c = true, -- Do not show ins-completion-menu messages (match 1 of 2)
    F = true, -- Do not print file name when opening a file
    s = true, -- Do not show "Search hit BOTTOM" message
  }),

  showbreak = string.format("%s ", string.rep("↪", 1)), -- Make it so that long lines wrap smartly; alts: -> '…', '↳ ', '→','↪ '
  -- Don't show the mode, since it's already in the status line
  showmode = false,
  showcmd = false,

  suffixesadd = { ".md", ".js", ".ts", ".tsx" }, -- File extensions not required when opening with `gf`

  -- Basic settings
  number = true, -- Line numbers
  relativenumber = true, -- Relative line numbers
  cursorline = true, -- Highlight current line
  wrap = false, -- Don't wrap lines
  scrolloff = 10, -- Keep 10 lines above/below cursor
  sidescrolloff = 8, -- Keep 8 columns left/right of cursor

  -- Indentation vim.opt.tabstop = 2        -- Tab width vim.opt.shiftwidth = 2     -- Indent width vim.opt.softtabstop = 2    -- Soft tab stop
  expandtab = true, -- Use spaces instead of tabs
  smartindent = true, -- Smart auto-indenting
  autoindent = true, -- Copy indent from current line

  -- Search settings
  ignorecase = true, -- Case insensitive search
  smartcase = true, -- Case sensitive if uppercase in search
  hlsearch = false, -- Don't highlight search results
  incsearch = true, -- Show matches as you type

  -- Visual settings
  termguicolors = true, -- Enable 24-bit colors
  signcolumn = "yes", -- Always show sign column
  colorcolumn = "100", -- Show column at 100 characters
  showmatch = true, -- Highlight matching brackets
  matchtime = 2, -- How long to show matching bracket
  completeopt = "menuone,noinsert,noselect", -- Completion options
  showmode = false, -- Don't show mode in command line
  pumheight = 10, -- Popup menu height
  pumblend = 10, -- Popup menu transparency
  winblend = 0, -- Floating window transparency
  winborder = BORDER_STYLE,
  conceallevel = 0, -- Don't hide markup
  concealcursor = "", -- Don't hide cursor line markup
  lazyredraw = true, -- Don't redraw during macros
  synmaxcol = 300, -- Syntax highlighting limit

  -- File handling
  backup = false, -- Don't create backup files
  writebackup = false, -- Don't create backup before writing
  swapfile = false, -- Don't create swap files
  undofile = true, -- Persistent undo
  undodir = vim.fn.expand("~/.vim/undodir"), -- Undo directory
  updatetime = 300, -- Faster completion
  timeoutlen = 500, -- Key timeout duration
  ttimeoutlen = 0, -- Key code timeout
  autoread = true, -- Auto reload files changed outside vim
  autowrite = false, -- Don't auto save

  -- Behavior settings
  hidden = true, -- Allow hidden buffers
  errorbells = false, -- No error bells
  backspace = "indent,eol,start", -- Better backspace behavior
  autochdir = false, -- Don't auto change directory
  iskeyword = vim.opt.iskeyword:append("-"), -- Treat dash as part of word
  path = vim.opt.path:append("**"), -- include subdirectories in search
  selection = "exclusive", -- Selection behavior
  mouse = "a", -- Enable mouse support
  clipboard = vim.opt.clipboard:append("unnamedplus"), -- Use system clipboard
  modifiable = true, -- Allow buffer modifications
  encoding = "UTF-8", -- Set encoding

  -- Cursor settings
  -- guicursor =
  -- "n-v-c:block,i-ci-ve:block,r-cr:hor20,o:hor50,a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor,sm:block-blinkwait175-blinkoff150-blinkon175",
  guicursor = vim.opt.guicursor:append("a:blinkon500-blinkoff100"),

  -- Folding settings
  foldmethod = "expr", -- Use expression for folding
  foldexpr = "nvim_treesitter#foldexpr()", -- Use treesitter for folding
  foldlevel = 99, -- Start with all folds open

  -- Split behavior
  splitbelow = true, -- Horizontal splits go below
  splitright = true, -- Vertical splits go right
}

-- vim.print(vim.o.packpath)
-- vim.print(vim.fs.joinpath(vim.fn.stdpath("data"), "site", "pack", "core", "opt"))
-- o = {
--   packpath = vim.o.packpath .. ";" .. string.format("%s/site/pack/core/opt", vim.fn.stdpath("data")), --vim.fs.joinpath(vim.fn.stdpath("data"), "site", "pack", "core", "opt"),
--   -- string.format("%s/site/pack/core", vim.fn.stdpath("data"))
-- }

for _, provider in ipairs({ "node", "perl", "python3", "ruby" }) do
  vim.g["loaded_" .. provider .. "_provider"] = 0
  -- vim.g[provider .. "_host_prog"] = vim.env.XDG_DATA_HOME .. "/mise/installs/" .. provider .. "/latest/bin/" .. provider
end

-- apply the above settings
for scope, opts in pairs(M) do
  local opt_group = vim[scope]

  for opt_key, opt_value in pairs(opts) do
    opt_group[opt_key] = opt_value
  end
end

-- vim.print(vim.o.packpath)

vim.filetype.add({
  filename = {
    [".env"] = "bash",
    [".envrc"] = "bash",
    [".eslintrc"] = "jsonc",
    [".eslintrc.json"] = "jsonc",
    [".prettierrc"] = "jsonc",
    [".tool-versions"] = "conf",
    -- ["Brewfile"] = "ruby",
    -- ["Brewfile.cask"] = "ruby",
    -- ["Brewfile.mas"] = "ruby",
    ["Deskfile"] = "bash",
    ["NEOGIT_COMMIT_EDITMSG"] = "NeogitCommitMessage",
    ["default-gems"] = "conf",
    ["default-node-packages"] = "conf",
    ["default-python-packages"] = "conf",
    ["kitty.conf"] = "kitty",
    ["tool-versions"] = "conf",
    ["tsconfig.json"] = "jsonc",
    id_ed25519 = "pem",
  },
  extension = {
    conf = "conf",
    cts = "typescript",
    eex = "eelixir",
    eslintrc = "jsonc",
    exs = "elixir",
    json = "jsonc",
    keymap = "keymap",
    lexs = "elixir",
    luau = "luau",
    md = "markdown",
    mdx = "markdown",
    mts = "typescript",
    prettierrc = "jsonc",
    typ = "typst",
  },
  pattern = {
    [".*%.conf"] = "conf",
    -- [".*%.env%..*"] = "env",
    [".*%.eslintrc%..*"] = "jsonc",
    ["tsconfig*.json"] = "jsonc",
    [".*/%.vscode/.*%.json"] = "jsonc",
    [".*%.gradle"] = "groovy",
    [".*%.html.en"] = "html",
    [".*%.jst.eco"] = "jst",
    [".*%.prettierrc%..*"] = "jsonc",
    [".*%.theme"] = "conf",
    -- [".*env%..*"] = "bash",
    [".*ignore$"] = "gitignore",
    [".nvimrc"] = "lua",
    ["default-*%-packages"] = "conf",
  },
  -- ['.*tmux.*conf$'] = 'tmux',
})

vim.fn.sign_define(
  "DiagnosticSignError",
  { text = "", hl = "DiagnosticSignError", texthl = "DiagnosticSignError", culhl = "DiagnosticSignErrorLine" }
)
vim.fn.sign_define(
  "DiagnosticSignWarn",
  { text = "", hl = "DiagnosticSignWarn", texthl = "DiagnosticSignWarn", culhl = "DiagnosticSignWarnLine" }
)
vim.fn.sign_define(
  "DiagnosticSignInfo",
  { text = "", hl = "DiagnosticSignInfo", texthl = "DiagnosticSignInfo", culhl = "DiagnosticSignInfoLine" }
)
vim.fn.sign_define(
  "DiagnosticSignHint",
  { text = "", hl = "DiagnosticSignHint", texthl = "DiagnosticSignHint", culhl = "DiagnosticSignHintLine" }
)

-- Make <Tab> work for snippets
vim.keymap.set({ "i", "s" }, "<Tab>", function()
  if vim.snippet.active({ direction = 1 }) then
    return "<cmd>lua vim.snippet.jump(1)<cr>"
  else
    return "<Tab>"
  end
end, { expr = true })

-- Covenience macros
-- fix ellipsis: "..." -> "…"
vim.keymap.set(
  "n",
  "<leader>fe",
  "mc:%s,\\.\\.\\.,…,g<CR>:nohlsearch<CR>`c",
  { noremap = true, silent = true, desc = "... -> …" }
)
-- fix spelling: just an easier finger roll on 40% keyboard
vim.keymap.set("n", "<leader>fs", "1z=", { noremap = true, silent = true, desc = "Fix spelling under cursor" })

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if client:supports_method("textDocument/completion") then
      vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
    end
    if client:supports_method("textDocument/documentColor") then
      vim.lsp.document_color.enable(true, ev.buf, { style = "virtual" })
    end
    if client:supports_method("textDocument/formatting") then
      vim.keymap.set({ "n", "v" }, "grf", function()
        vim.lsp.buf.format({ bufnr = ev.buf })
      end, { buffer = ev.buf, desc = "Format with LSP" })
    end
  end,
})

-- Diagnostic Virtual lines for only current line
vim.diagnostic.config({ virtual_lines = { current_line = true } })

-- LSP Configurations
vim.lsp.config.elixir = {
  cmd = { "lexical" },
  filetypes = { "elixir", "eelixir", "heex" },
  root_markers = { "mix.exs", ".git" },
  settings = {
    elixir = {
      formatting = {
        command = { "mix", "format" },
      },
    },
  },
}

vim.lsp.config.nix = {
  cmd = { "nixd", "--inlay-hints=true" },
  filetypes = { "nix" },
  settings = {
    nixd = {
      nixpkgs = {
        expr = "import <nixpkgs> { }",
      },
      root_markers = { "flake.nix", ".git" },
      formatting = {
        command = { "nixfmt" },
      },
    },
  },
}

vim.lsp.config.lua = {
  cmd = { "lua-language-server" },
  filetypes = { "lua" },
  settings = {
    Lua = {
      runtime = {
        version = "LuaJIT",
        path = vim.split(package.path, ";"),
      },
      diagnostics = { globals = { "vim", "hs" } },
      workspace = {
        library = {
          [vim.fn.expand("$VIMRUNTIME/lua")] = true,
          [vim.fn.expand("$VIMRUNTIME/lua/vim/lsp")] = true,
          [vim.fn.expand("/Applications/Hammerspoon.app/Contents/Resources/extensions/hs/")] = true,
        },
      },
    },
  },
}

vim.lsp.config.ruby = {
  cmd = { "ruby-lsp" },
  filetypes = { "ruby", "eruby" },
  root_markers = { ".git" },
}

vim.lsp.config.markdown = {
  cmd = { "markdown-oxide" },
  filetypes = { "markdown" },
}

vim.lsp.config.javascript = {
  cmd = { "typescript-language-server", "--stdio" },
  filetypes = { "javascript", "typescript", "vue" },
}

vim.lsp.enable({
  "elixir",
  "ruby",
  "nix",
  "lua",
  "markdown",
  "javascript",
})
