vim.loader.enable()

require("vim._extui").enable({
  enable = false,
  msg = {
    -- msg: similar rendering to the notifier.nvim plugin
    -- cmd: normal cmd mode looking stuff
    target = "cmd",
    timeout = vim.g.extui_msg_timeout or 5000,
  },
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "cmd", "msg", "pager", "dialog" },
  callback = function(_evt)
    vim.api.nvim_set_option_value("winhl", "Normal:PanelBackground,FloatBorder:PanelBorder", {})
  end,
})

--- @diagnostic disable-next-line: duplicate-set-field
vim.deprecate = function() end -- no-op deprecation messages
local ok, mod_or_err = pcall(require, "globals")
if ok then
  -- if not vim.g.started_by_firenvim then
  --   mod_or_err.version()
  -- end
  require("options")
  require("commands")
  require("autocmds")
  require("keymaps")

  -- [[ Install `lazy.nvim` plugin manager ]]
  --    See `:help lazy.nvim.txt` or https://github.com/folke/lazy.nvim for more info
  local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
  if not vim.uv.fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  end ---@diagnostic disable-next-line: undefined-field

  vim.opt.rtp:prepend(lazypath)
  -- settings and autocmds must load before plugins,
  -- but we can manually enable caching before both
  -- of these for optimal performance
  local lc_ok, lazy_cache = pcall(require, "lazy.core.cache")
  if lc_ok then
    lazy_cache.enable()
  end

  local le_ok, lazy_event = pcall(require, "lazy.core.handler.event")
  if le_ok then
    lazy_event.mappings.LazyFile =
      { id = "LazyFile", event = { "BufReadPre", "BufReadPost", "BufNewFile", "BufWritePre" } }
    lazy_event.mappings["User LazyFile"] = lazy_event.mappings.LazyFile
  end

  require("lazy").setup({
    { import = "plugins" },
    -- { import = "plugins.core" },
    -- { import = "plugins.extended" },
  }, {
    dev = {
      -- directory where you store your local plugin projects
      path = "~/code",
      ---@type string[] plugins that match these patterns will use your local versions instead of being fetched from GitHub
      patterns = { "megalithic" },
      fallback = true, -- Fallback to git when local plugin doesn't exist
    },
    install = { missing = true, colorscheme = { vim.g.colorscheme, "default", "habamax" } },
    change_detection = { enabled = true, notify = false },
    {
      rocks = {
        hererocks = true,
      },
    },
    performance = {
      rtp = {
        disabled_plugins = {
          "gzip",
          "netrwPlugin",
          "rplugin",
          "tarPlugin",
          "tohtml",
          "tutor",
          "zipPlugin",
        },
      },
    },
    defaults = { lazy = false },
    ui = {
      backdrop = 100,
    },
  })
else
  vim.notify("Error loading `globals.lua`; unable to continue...\n" .. mod_or_err)
end
