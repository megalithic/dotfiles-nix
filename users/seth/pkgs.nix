{ pkgs, config, ... }: {

  # user specific packages instead of system wide
  home.packages = with pkgs; [
    fzf
    fd
    delta
    sesh
    obsidian
    tree
    nixfmt-rfc-style
    # presenterm

    kubectl
    kubectx
    kubernetes-helm
    minikube

    terraform
    tflint
    trivy
    atlas

    rustup

    python313
    python313Packages.ipython
    python313Packages.sqlfmt
    # vectorcode # used in codecompanion
    mcphub # used in codecompanion

    # pnpm_9
    nodejs_24
    nodePackages.prettier
    nodePackages.vscode-json-languageserver

    duckdb
    uv
    ruff
    pre-commit

    kotlin
    jdk21
    gradle
    ktlint
    ktfmt

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

    docker
    docker-compose
    dockerfile-language-server-nodejs
    docker-compose-language-service

    protobuf
    protolint
    buf

    # LSP execs, formatter and linters for neovim
    yaml-language-server
    yamllint

    vim-language-server
    lua-language-server
    stylua

    kotlin-language-server # TODO: migrate to kotlinLspWrapper
    bash-language-server

    # pyright
    basedpyright

    gopls
    templ
    superhtml
    golines
    gofumpt
    # golangci-lint
    # golangci-lint-langserver

    terraform-ls
    nil
    helm-ls
    markdown-oxide # trying this out

    # kotlinLspWrapper
  ];
}
