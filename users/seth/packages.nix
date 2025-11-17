{
  config,
  pkgs,
  ...
}: let
  inherit (pkgs.stdenv.hostPlatform) isDarwin;
in {
  home.packages = with pkgs; [
    _1password-cli
    unstable._1password-gui
    amber
    argc
    aws-sam-cli
    awscli2
    bash # macOS ships with a very old version of bash for whatever reason
    blueutil
    cachix
    # cloudflare-warp # not available on nix/darwin at all?
    curlie
    delta
    devbox
    difftastic
    espanso
    ffmpeg
    flyctl
    gh
    git-lfs
    gitAndTools.transcrypt
    gum
    helium
    hidden-bar
    jwt-cli
    karabiner-elements
    karabiner-elements.driver
    libvterm-neovim
    magika
    unstable.obsidian
    openconnect
    openssl_3
    poppler
    pre-commit
    procs
    # raycast
    # qutebrowser
    ripgrep
    spotify
    sqlite
    # terminal-notifier FIXME: not working with nixpkgs (arch not supported?)
    switchaudio-osx
    teams
    tmux
    unstable.devenv
    w3m
    yubikey-manager
    yubikey-personalization
    zoom-us

    # [ai] ----------------------------------------------------------------------------------------
    ai-tools.opencode
    ai-tools.claude-code
    ai-tools.claude-code-acp
  ];
}
