return {
  "olimorris/codecompanion.nvim",
  dependencies = {
    { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
    { "nvim-lua/plenary.nvim" },
    { "saghen/blink.cmp" },
  },
  opts = {
    --Refer to: https://github.com/olimorris/codecompanion.nvim/blob/main/lua/codecompanion/config.lua
    strategies = {
      --NOTE: Change the adapter as required
      -- chat = { adapter = "copilot" },
      -- inline = { adapter = "copilot" },
      chat = {
        adapter = "anthropic",
        keymaps = {
          close = { modes = { n = "<C-q>", i = "<C-q>" }, opts = {} },
          options = { modes = { n = "<leader>h" }, opts = {} },
        },
      },
      inline = { adapter = "anthropic" },
    },
    adapters = {
      acp = {
        claude_code = function()
          return require("codecompanion.adapters").extend("claude_code", {
            env = {
              CLAUDE_CODE_OAUTH_TOKEN = "cmd:op read op://shared/megaenv/CLAUDE_CODE_OAUTH_TOKEN --no-newline",
            },
          })
        end,
      },
    },
    -- extensions = {
    --   history = { enabled = true },
    -- },
    opts = {
      log_level = "DEBUG",
    },
  },
  config = function(_, opts)
    require("codecompanion").setup(opts)

    vim.keymap.set(
      { "n", "v" },
      "<localleader>A",
      "<cmd>CodeCompanionActions<cr>",
      { noremap = true, silent = true, desc = "✨ Actions" }
    )
    vim.keymap.set(
      { "n", "v" },
      "<localleader>a",
      "<cmd>CodeCompanionChat Toggle<cr>",
      { noremap = true, silent = true, desc = "✨ Toggle Chat" }
    )
    vim.keymap.set(
      "v",
      "<localleader>c",
      "<cmd>CodeCompanionChat Add<cr>",
      { noremap = true, silent = true, desc = "✨ Add to Chat" }
    )

    vim.cmd([[cab cc CodeCompanion]])
  end,
}
