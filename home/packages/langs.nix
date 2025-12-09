{
  config,
  pkgs,
  ...
}: let
  inherit (pkgs.stdenv.hostPlatform) isDarwin;
in {
  home.packages = with pkgs; [
    # [langs] --------------------------------------------------------------------------------------
    cargo
    harper
    k9s
    kubectl
    kubernetes-helm
    kubie
    lua-language-server
    markdown-oxide
    podman
    shellcheck
    shfmt
    stylua
    # docker --------------------------------------------------------------------------------------
    colima
    docker
    docker-compose
    docker-compose-language-service
    dockerfile-language-server
    # node/js/ts ----------------------------------------------------------------------------------
    nodejs_22
    # nodePackages_latest.nodejs
    # nodePackages_latest.prettier
    # nodePackages_latest.vscode-json-languageserver
    pnpm
    vue-language-server
    # python --------------------------------------------------------------------------------------
    basedpyright
    # python3
    python313
    python313Packages.pip
    python313Packages.websockets
    python313Packages.websocket-client
    python313Packages.ipython
    python313Packages.sqlfmt
    uv
    # nix -----------------------------------------------------------------------------------------
    nixfmt-rfc-style
    alejandra
    nix-direnv
    nil
    # terraform -----------------------------------------------------------------------------------
    # terraform
    # terraform-docs
    # terraform-ls
    # tflint
    # tfsec
    # trivy
    # atlas
  ];
}
