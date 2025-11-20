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
    # cachi
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
    # helium # Managed by programs.helium module in chromium/default.nix
    # hidden-bar # FIXME: evaluated it and so far, i'm not loving it
    jwt-cli
    # karabiner-elements # Now managed by users/seth/karabiner-elements.nix module
    # karabiner-elements.driver # Now managed by users/seth/karabiner-elements.nix module
    libvterm-neovim
    magika
    nix-update
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
    tmux
    # unstable.devenv # TODO: cachix build failing, blocking devenv
    w3m
    yubikey-manager
    yubikey-personalization
    zoom-us

    # [ai] ----------------------------------------------------------------------------------------
    # ai-tools.opencode
    ai-tools.claude-code
    # ai-tools.claude-code-acp
    unstable.opencode
    # unstable.claude-code
  ];
}
