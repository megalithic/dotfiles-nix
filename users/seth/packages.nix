{ pkgs, ... }: {
  home.packages = with pkgs;
    [
      _1password-cli
      actionlint
      alejandra
      amber
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
      # remember to disable ipv6, otherwise super slow gcloud
      # networksetup -setv6off Wi-Fi
      (google-cloud-sdk.withExtraComponents (
        with pkgs.google-cloud-sdk.components;
        [
          gke-gcloud-auth-plugin
          package-go-module
          pubsub-emulator
        ]
      ))
      google-cloud-sql-proxy
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
      mcphub # used in codecompanion
      markdown-oxide
      marksman
      minikube
      mise-flake.packages.${system}.mise
      neovim
      neovim-remote
      nil
      ninja
      nix-direnv
      nixd
      nixfmt-rfc-style
      nodejs_24
      nodePackages.prettier
      nodePackages.prettierd
      nodePackages.vscode-json-languageserver
      # nodePackages_latest.bash-language-server
      nodePackages_latest.typescript-language-server
      openssl
      pkg-config
      # pnpm
      # prettierd
      python313
      python313Packages.ipython
      python313Packages.sqlfmt
      # vectorcode # used in codecompanion
      ripgrep
      ruff
      # rust
      rust-analyzer
      sd
      selenium-server-standalone
      sesh
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
    ]
    ++ (
      if pkgs.stdenv.isLinux
      then [ gcc coreutils xclip unixtools.ifconfig inotify-tools ncurses5 ]
      else [ ]
    );
}
