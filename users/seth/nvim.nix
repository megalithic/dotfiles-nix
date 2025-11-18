{
  lib,
  pkgs,
  config,
  username,
  ...
}: {
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
    withPython3 = true;
    withNodeJs = true;
    withRuby = true;
    vimdiffAlias = true;
    vimAlias = true;
    extraPackages = with pkgs; [
      actionlint
      bash-language-server
      biome
      black
      bun
      cmake
      copilot-language-server
      deno
      dotenv-linter
      gcc # For treesitter compilation
      git
      gnumake # For various build processes
      golangci-lint
      gopls
      gotools
      hadolint # Docker linter
      isort
      lua51Packages.luarocks
      nixd # nix lsp
      nixfmt-rfc-style # cannot be installed via Mason on macOS, so installed here instead
      nodePackages.prettier
      par
      pngpaste # For Obsidian paste_img command
      ruff
      shfmt # Doesn't work with zsh, only sh & bash
      statix
      stylelint-lsp
      (tailwindcss-language-server.override {nodejs_latest = nodejs_22;})
      taplo # TOML linter and formatter
      tree-sitter # required for treesitter "auto-install" option to work
      typos
      typos-lsp
      typst
      uv
      vscode-langservers-extracted # HTML, CSS, JSON & ESLint LSPs
      vtsls # js/ts LSP
      yaml-language-server
    ];
  };
}
