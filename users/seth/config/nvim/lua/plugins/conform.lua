-- REF:
-- - https://github.com/ahmedelgabri/dotfiles/blob/5ceb4f3220980f95bc674b0785c920fbd9fc45ed/config/nvim/lua/plugins/formatter.lua#L75
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  callback = function(args)
    require("conform").format({ bufnr = args.buf })
  end,
})

Command("ToggleAutoFormat", function()
  vim.g.disable_autoformat = not vim.g.disable_autoformat
  if vim.g.disable_autoformat then
    vim.notify("Disabled auto-formatting.", L.WARN)
  else
    vim.notify("Enabled auto-formatting.", L.INFO)
  end
end, {})

return {
  "stevearc/conform.nvim",
  keys = {
    {
      "<Leader>F",
      function()
        require("conform").format({
          async = true,
          lsp_format = "fallback",
          timeout_ms = 5000,
        })
        vim.notify(
          "Formatted " .. (vim.api.nvim_get_mode().mode == "n" and "buffer" or "selection"),
          vim.log.levels.INFO,
          { id = "toggle_conform", title = "Conform" }
        )
      end,
      mode = { "n", "x" },
      desc = "Format buffer or selection",
    },
  },
  init = function()
    vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
  end,
  config = function()
    local opts = {
      formatters = {
        ["eslint_d"] = {
          command = "eslint_d",
          args = { "--fix-to-stdout", "--stdin", "--stdin-filename", "$FILENAME" },
          cwd = require("conform.util").root_file({ "package.json" }),
        },
        prettierd = {
          require_cwd = true,
        },
        ["pg_format"] = {
          command = "pg_format",
          -- args = { "--inplace", "--config", ".pg_format.conf" },
          args = {
            "--comma-start",
            "--comma-break",
            "--spaces",
            "2",
            "--keyword-case",
            "1",
            "--placeholder",
            '":: "',
            "--format-type",
            "--inplace",
          },
          cwd = require("conform.util").root_file({ ".pg_format.conf" }),
        },
        stylua = {
          command = "stylua",
          args = {
            "--search-parent-directories",
            -- "--respect-ignores",
            "--stdin-filepath",
            "$FILENAME",
            "-",
          },
        },
        beautysh = {
          prepend_args = { "-i", "2" },
        },
        dprint = {
          condition = function(ctx)
            return vim.fs.find({ "dprint.json" }, { path = ctx.filename, upward = true })[1]
          end,
        },
        mix = {
          cwd = function(self, ctx)
            (require("conform.util").root_file({ "mix.exs" }))(self, ctx)
          end,
        },
        statix = {
          command = "statix",
          args = { "fix", "--stdin" },
          stdin = true,
        },
      },
      formatters_by_ft = {
        lua = { "stylua" },
        luau = { "stylua" },
        json = { "fixjson", "prettierd", "prettier", "dprint" },
        jsonc = { "fixjson", "prettierd", "prettier", "dprint" },
        json5 = { "fixjson", "prettierd", "prettier", "dprint" },
        javascript = { "prettierd", "prettier", "dprint" },
        javascriptreact = { "prettierd", "prettier", "dprint" },
        bash = { "shfmt" }, -- shellharden
        c = { "clang_format" },
        cpp = { "clang_format" },
        css = { "prettierd", "prettier" },
        go = { "goimports", "gofmt", "gofumpt" },
        graphql = { "prettierd", "prettier", "dprint" },
        html = { "prettierd", "prettier", "dprint" },
        markdown = { "prettierd", "prettier", "dprint" },
        ["markdown.mdx"] = { "prettierd", "prettier", "dprint" },
        nix = { "nixpkgs_fmt", "statix" },
        -- python = { "isort", "black" },
        python = { "ruff_fix", "ruff_format", "ruff_organize_imports" },
        rust = { "rustfmt" },
        sass = { "prettierd", "prettier" },
        scss = { "prettierd", "prettier" },
        sh = { "shfmt" }, -- shellharden
        sql = { "pg_format", "sqlfluff" },
        terraform = { "tofu_fmt" },
        toml = { "taplo" },
        typescript = { "prettierd", "prettier", "dprint" },
        typescriptreact = { "prettierd", "prettier", "dprint" },
        yaml = { "prettierd", "prettier", "dprint" },
        zig = { "zigfmt" },
        zsh = { "shfmt" }, -- shellhardenhfmt,
        ["_"] = { "trim_whitespace", "trim_newlines", lsp_format = "last" },
      },
      default_format_opts = {
        lsp_format = "fallback",
      },
    }
    if vim.g.started_by_firenvim then
      opts.format_on_save = false
      opts.format_after_save = false
    end

    require("conform.formatters.stylua").env = {
      XDG_CONFIG_HOME = vim.fn.stdpath("config"),
    }
    require("conform.formatters.injected").options.ignore_errors = true
    local util = require("conform.util")
    local clang_format = require("conform.formatters.clang_format")
    local deno_fmt = require("conform.formatters.deno_fmt")
    local ruff = require("conform.formatters.ruff_format")
    local shfmt = require("conform.formatters.shfmt")
    util.add_formatter_args(clang_format, {
      "--style=file",
    })
    util.add_formatter_args(deno_fmt, { "--single-quote", "--prose-wrap", "preserve" }, { append = true })
    util.add_formatter_args(ruff, { "--config", "format.quote-style = 'single'" }, { append = true })
    util.add_formatter_args(shfmt, {
      "--indent",
      "2",
      -- Case Indentation
      "-ci",
      -- Space after Redirect carets (`foo > bar`)
      "-sr",
    })

    require("conform").setup(opts)
  end,
}
