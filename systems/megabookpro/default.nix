{ inputs
, pkgs
, lib
, username
, system
, hostname
, version
, ...
}:

let
  # For our MANPAGER env var
  # https://github.com/sharkdp/bat/issues/1145
  manpager = pkgs.writeShellScriptBin "manpager" ''
    sh -c 'col -bx | bat -l man -p'
  '';

  lang = "en_US.UTF-8";
in
{
  users.users.${username} = {
    name = username;
    home = "/Users/${username}";
    isHidden = false;
    shell = pkgs.fish;
  };

  networking.hostName = "${hostname}";
  time.timeZone = "America/New_York";
  ids.gids.nixbld = 350;

  # system wide packages (all users)
  environment.systemPackages = with pkgs; [
    bat
    curl
    coreutils
    eza
    fd
    fzf
    git
    gnumake
    jujutsu
    just
    kanata
    karabiner-elements.driver
    nvim-nightly
    ripgrep
    starship
    tmux
    vim
    wget
    zoxide
    zsh
    zsh-autosuggestions
    zsh-syntax-highlighting
  ];

  environment.shells = [ pkgs.zsh pkgs.fish pkgs.bashInteractive ];

  environment.variables = {
    LANG = "${lang}";
    LC_CTYPE = "${lang}";
    LC_ALL = "${lang}";
    EDITOR = "nvim";
    PAGER = "less -FirSwX";
    MANPAGER = "${manpager}/bin/manpager";
    HOMEBREW_PREFIX = "/opt/homebrew";
  };

  # default homebrew stuff for all users
  homebrew = import ../../modules/shared/darwin/homebrew.nix { inherit pkgs lib username; };

  # We use determinate nix installer; so we don't need this enabled..
  nix.enable = false;

  nix.registry = {
    n.to = {
      type = "path";
      path = inputs.nixpkgs;
    };
    u.to = {
      type = "path";
      path = inputs.nixpkgs-unstable;
    };
  };

  # enable flakes globally
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # extra host specs
  # https://github.com/nix-darwin/nix-darwin/issues/1035
  # networking.extraHosts = ''
  #   127.0.0.1	  kubernetes.docker.internal
  #   127.0.0.1   kubernetes.default.svc.cluster.local
  # '';

  # Create /etc/zshrc that loads the nix-darwin environment.
  programs.zsh.enable = true;
  programs.fish.enable = true;
  programs.gnupg.agent.enable = true;
  programs._1password.enable = true;

  fonts.packages = with pkgs; [
    atkinson-hyperlegible
    inter
    jetbrains-mono
    maple-mono.NF
    maple-mono.truetype
    maple-mono.variable
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
    nerd-fonts.symbols-only
    noto-fonts-emoji
  ];

  services = {
    jankyborders = {
      enable = true;
      blur_radius = 5.0;
      hidpi = true;
      active_color = "0xAAB279A7";
      inactive_color = "0x33867A74";
    };
  };

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "${system}";


  # NOTE: only suppported on linux platforms
  # nix.optimise.automatic = true;

  # NOTE: only suppported on linux platforms
  # do garbage collection bi-daily to keep disk usage low
  # nix.gc = {
  #   automatic = lib.mkDefault true;
  #   options = lib.mkDefault "--delete-older-than 2d";
  # };
}
