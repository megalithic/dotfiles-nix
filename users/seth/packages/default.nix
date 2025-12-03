{
  config,
  pkgs,
  ...
}: let
  inherit (pkgs.stdenv.hostPlatform) isDarwin;
in {
  imports = [
    ./casks.nix
    # ./mas.nix
    ./fonts.nix
    ./langs.nix
  ];

  home.packages = with pkgs; [
    # _1password-cli
    # _1password-gui
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
    # m-cli
    magika
    mas
    nix-update
    obsidian
    openconnect
    openssl_3
    poppler
    pre-commit
    procs
    ripgrep
    s3cmd
    sqlite
    switchaudio-osx
    terminal-notifier
    tmux
    w3m
    yubikey-manager
    yubikey-personalization
    zoom-us

    # [ai] ----------------------------------------------------------------------------------------
    ai-tools.opencode
    ai-tools.claude-code
    ai-tools.claude-code-acp

    # TODO: sort these with the stuff above
    # [migrated from megabookpro.nix] -------------------------------------------------------------
    # (fenix.complete.withComponents [
    #   "cargo"
    #   "clippy"
    #   "rust-src"
    #   "rustc"
    #   "rustfmt"
    # ])
    # rust-analyzer-nightly
    #
    # bat
    # curl
    # coreutils
    # darwin.trash
    # delta
    # # devenv # TODO: cachix build failing, blocking devenv
    # dust # du + rust = dust. Like du but more intuitive.
    # eza
    # fd
    # # fish
    # # fzf
    # git
    # git-lfs
    # gnumake
    # inetutils
    # jq
    # jujutsu
    # just
    # kanata
    # # karabiner-elements.driver
    # ldns # supplies drill replacement for dig
    # libwebp # WebP image format library
    # # m-cli # A macOS cli tool to manage macOS - a true swis army knife
    # mise
    # netcat
    # nix-index
    # nmap
    # nurl
    # nvim-nightly
    # openssl
    # unzip
    # p7zip
    # ripgrep
    # starship
    # # tmux
    # vim
    # wget
    # yazi
    # yq
    # zip
    # zoxide
    # # zsh
    # zsh-autosuggestions
    # zsh-syntax-highlighting
  ];
}
