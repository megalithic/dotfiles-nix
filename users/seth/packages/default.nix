{
  config,
  pkgs,
  ...
}: let
  inherit (pkgs.stdenv.hostPlatform) isDarwin;
in {
  imports = [
    ./casks.nix
    ./mas.nix
    ./fonts.nix
    ./langs.nix
  ];

  home.packages = with pkgs; [
    _1password-cli
    unstable._1password-gui
    amber
    argc
    # aws-sam-cli
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
    transcrypt
    gum
    jwt-cli
    libvterm-neovim
    m-cli
    magika
    mas
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
    s3cmd
    spotify
    sqlite
    switchaudio-osx
    terminal-notifier
    tmux
    # unstable.devenv # TODO: cachix build failing, blocking devenv
    w3m
    yubikey-manager
    yubikey-personalization
    zoom-us

    # [ai] ----------------------------------------------------------------------------------------
    ai-tools.opencode
    ai-tools.claude-code
    ai-tools.claude-code-acp
    # opencode
    # claude-code
  ];
}
