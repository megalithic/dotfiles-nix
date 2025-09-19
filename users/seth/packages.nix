{ pkgs, config, ... }: {

  packages = with pkgs; [
    # menu ----------------------------------------------------------------------------------------
    ice-bar
    monitorcontrol
    stats

    # gui -----------------------------------------------------------------------------------------
    obsidian
    obs-studio
    obs-studio-plugins
    raycast

    # cli/tui -------------------------------------------------------------------------------------
    _1password-cli
    argc
    atuin
    autoconf
    autogen
    automake
    bandwhich
    btop
    cachix
    charm-freeze
    chromedriver
    curlie
    delta
    direnv
    du-dust # du + rust = dust. Like du but more intuitive.
    gettext
    gh
    ghc
    ghostty.terminfo
    git-lfs
    gnused # GNU tools (for macOS compatibility)
    gum
    htop
    imagemagick
    jq
    lazygit
    lazydocker
    ncurses
    # mise-flake.packages.${system}.mise
    pngpaste
    pkg-config
    unstable.podman
    unstable.podman-compose
    pre-commit
    sqlite-interactive
    tailscale
    television
    tree
    tree-sitter
    yq


    # ai ------------------------------------------------------------------------------------------
    ai-tools.opencode
    ollama
    # vectorcode # used in codecompanion
    # mcphub # used in codecompanion

    # k8s -----------------------------------------------------------------------------------------
    kubectl
    kubectx
    kubernetes-helm
    minikube
    opentofu


    # lua -----------------------------------------------------------------------------------------
    lua
    lua-language-server
    lua5_1
    luarocks

    # lsp --------------------------------------------------------------------------------------------
    bash-language-server
    gofumpt
    golines
    gopls
    harper
    helm-ls
    markdown-oxide
    marksman
    stylua
    superhtml
    templ
    vim-language-server
    yaml-language-server
    yamllint
    tailwindcss-language-server
    taplo

    # kotlin --------------------------------------------------------------------------------------
    kotlin
    kotlin-language-server # TODO: migrate to kotlinLspWrapper
    jdk21
    gradle
    ktlint
    ktfmt

    # docker --------------------------------------------------------------------------------------
    colima
    docker
    docker-compose
    docker-compose-language-service
    dockerfile-language-server-nodejs

    # node/js/ts ----------------------------------------------------------------------------------
    nodejs_22
    nodePackages_latest.nodejs
    nodePackages_latest.prettier
    nodePackages_latest.vscode-json-languageserver
    pnpm
    vtsls
    vue-language-server

    # python --------------------------------------------------------------------------------------
    python3
    python313
    python313Packages.pip
    python313Packages.websockets
    python313Packages.websocket-client
    python313Packages.ipython
    python313Packages.sqlfmt
    uv
    basedpyright

    # rust --------------------------------------------------------------------------------------
    rustup
    ruff
    rust
    rust-analyzer

    # elixir --------------------------------------------------------------------------------------
    beam.packages.erlang_28.elixir_1_18
    beam.packages.erlang_28.erlang

    # nix -----------------------------------------------------------------------------------------
    nixfmt-rfc-style
    alejandra
    nix-direnv
    nil
    nixd

    # terraform -----------------------------------------------------------------------------------
    terraform
    terraform-ls
    tflint
    trivy
    atlas

    # google-cloud --------------------------------------------------------------------------------
    # - remember to disable ipv6, otherwise super slow gcloud
    # - networksetup -setv6off Wi-Fi
    (google-cloud-sdk.withExtraComponents (
      with pkgs.google-cloud-sdk.components;
      [
        gke-gcloud-auth-plugin
        package-go-module
        pubsub-emulator
      ]
    ))
    google-cloud-sql-proxy
  ];
}
