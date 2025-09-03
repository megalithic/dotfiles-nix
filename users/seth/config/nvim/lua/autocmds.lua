local U = require("utils")

local M = {}
local grp
local augrp = vim.api.nvim_create_augroup
local aucmd = vim.api.nvim_create_autocmd

---@class Autocommand
---@field desc string
---@field event  string[] list of autocommand events
---@field pattern string[] list of autocommand patterns
---@field command string | function
---@field nested  boolean
---@field once    boolean
---@field buffer  number
---@field enabled boolean

---Create an autocommand
---returns the group ID so that it can be cleared or manipulated.
---@param name string
---@param ... Autocommand A list of autocommands to create (variadic parameter)
---@return number
function M.augroup(name, commands)
  --- Validate the keys passed to mega.augroup are valid
  ---@param name string
  ---@param cmd Autocommand
  local function validate_autocmd(name, cmd)
    local keys = { "event", "buffer", "pattern", "desc", "callback", "command", "group", "once", "nested", "enabled" }
    local incorrect = U.fold(function(accum, _, key)
      if not vim.tbl_contains(keys, key) then
        table.insert(accum, key)
      end
      return accum
    end, cmd, {})
    if #incorrect == 0 then
      return
    end
    -- local debug_info = debug.getinfo(2)
    -- local mod_name = vim.fn.fnamemodify(debug_info.short_src, ":t:r")
    -- local mod_line = debug_info.currentline

    vim.schedule(function()
      vim.notify("Incorrect keys: " .. table.concat(incorrect, ", "), vim.log.levels.ERROR, {
        title = string.format("Autocmd: %s", name),
      })
    end)
  end

  assert(name ~= "User", "The name of an augroup CANNOT be User")

  local auname = string.format("mega_mvim-%s", name)
  local id = vim.api.nvim_create_augroup(auname, { clear = true })

  for _, autocmd in ipairs(commands) do
    if autocmd.enabled == nil or autocmd.enabled == true then
      validate_autocmd(name, autocmd)
      local is_callback = type(autocmd.command) == "function"
      vim.api.nvim_create_autocmd(autocmd.event, {
        group = id,
        pattern = autocmd.pattern,
        desc = autocmd.desc,
        callback = is_callback and autocmd.command or nil,
        command = not is_callback and autocmd.command or nil,
        once = autocmd.once,
        nested = autocmd.nested,
        buffer = autocmd.buffer,
      })
    end
  end

  return id
end

vim.api.nvim_create_autocmd("FocusGained", {
  desc = "Update file when it changes",
  command = "checktime",
})

vim.api.nvim_create_autocmd("FileType", {
  desc = "Enable wrap and spell in these filetypes",
  pattern = { "gitcommit", "markdown", "text", "log", "typst" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
  end,
})

vim.api.nvim_create_autocmd("BufReadPre", {
  desc = "Clear the last used search pattern when opening a new buffer",
  pattern = "*",
  callback = function()
    vim.fn.setreg("/", "") -- Clears the search register
    vim.cmd('let @/ = ""') -- Clear the search register using Vim command
  end,
})
vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("HighlightOnYank", { clear = true }),
  callback = function()
    vim.hl.on_yank({ timeout = 230, higroup = "Visual" })
  end,
  desc = "highlight on yank",
})

vim.api.nvim_create_autocmd("BufReadPost", {
  group = vim.api.nvim_create_augroup("GotoLastLoc", { clear = true }),
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
  desc = "last loc",
})

vim.api.nvim_create_autocmd("BufWritePre", {
  group = vim.api.nvim_create_augroup("MakeExecutable", { clear = true }),
  pattern = { "*.sh", "*.bash", "*.zsh" },
  callback = function()
    vim.fn.system("chmod +x " .. vim.fn.expand("%"))
  end,
  desc = "make executable",
})

---- during editing
grp = augrp("Editing", { clear = true })
vim.api.nvim_create_autocmd({ "BufEnter", "CursorMoved", "CursorHoldI" }, {
  group = grp,
  callback = function()
    local win_h = vim.api.nvim_win_get_height(0)
    local off = math.min(vim.o.scrolloff, math.floor(win_h / 2))
    local dist = vim.fn.line("$") - vim.fn.line(".")
    local rem = vim.fn.line("w$") - vim.fn.line("w0") + 1

    if dist < off and win_h - rem + dist < off then
      local view = vim.fn.winsaveview()
      view.topline = view.topline + off - (win_h - rem + dist)
      vim.fn.winrestview(view)
    end
  end,
  desc = "When at eob, bring the current line towards center screen",
})

grp = augrp("Entering", { clear = true })
vim.api.nvim_create_autocmd("VimResized", {
  group = grp,
  command = [[tabdo wincmd =]],
})

aucmd("BufWinEnter", {
  group = grp,
  command = "silent! loadview",
  desc = "Restore view settings",
})

---- Upon leaving a buffer
grp = augrp("Entering", { clear = true })
vim.api.nvim_create_autocmd("BufWinLeave", {
  group = grp,
  command = "silent! mkview",
  desc = "Create view settings",
})

Load_macros(M)

return M
