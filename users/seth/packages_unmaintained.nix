{ pkgs, ... }: {
  home.packages = with pkgs;
    [
      _1password-cli
      actionlint
      ai-tools.opencode
      alejandra

      argc
      autoconf
      autogen
      automake
      basedpyright
      bash-language-server
      bat
      beam.packages.erlang_28.elixir_1_18
      beam.packages.erlang_28.erlang
      btop
      cachix
      charm-freeze
      chromedriver
      cmake
      delta
      deno
      direnv
      docker
      docker-compose
      docker-compose-language-service
      dockerfile-language-server-nodejs
      eza
      fastfetch
      fd
      figlet
      fswatch
      fzf
      gawk
      gettext
      gh
      ghc
      git
      git-lfs
      gum
      harper
      hyperfine
      jq
      jujutsu
      just
      kubectl
      kubectx
      kubernetes-helm
      lazydocker
      lazygit
      lua
      lua-language-server
      lua5_1
      luarocks
      markdown-oxide
      marksman
      # mcphub # used in codecompanion
      minikube
      # mise-flake.packages.${system}.mise
      neovim
      neovim-remote
      nil
      ninja
      nix-direnv
      nixd
      nixfmt-rfc-style
      nodejs_24
      nodePackages_latest.bash-language-server
      nodePackages_latest.typescript-language-server
      nodePackages.prettier
      # nodePackages.prettierd
      nodePackages_latest.vscode-json-languageserver
      openssl
      pkg-config
      pnpm
      # python313
      # python313Packages.ipython
      # python313Packages.sqlfmt
      ripgrep
      ruff
      rust
      rust-analyzer
      selenium-server-standalone
      shellcheck
      shfmt
      silicon
      smartcat
      sqlite-interactive
      stylua
      tailscale
      tailwindcss-language-server
      taplo
      terraform
      terraform-ls
      tflint
      tmux
      tokei
      tree
      tree-sitter
      twm
      typescript
      unstable.claude-code
      unstable.devenv
      unstable.opencode
      unstable.sd
      vectorcode # used in codecompanion
      vim
      vim-language-server
      vscode-langservers-extracted
      vtsls
      weechat
      wget
      yaml-language-server
      yamllint
      yarn
      zig
      zk
      zls
      zsh
    ];
  # ++ [
  #   atkinson-hyperlegible
  #   jetbrains-mono
  #   nerd-fonts.jetbrains-mono
  #   nerd-fonts.fira-code
  #   maple-mono.NF
  #   nerd-fonts.symbols-only
  # ]
  # ++ (
  #   if pkgs.stdenv.isLinux
  #   then [ gcc coreutils xclip unixtools.ifconfig inotify-tools ncurses5 ]
  #   else [ ]
  # );
}
