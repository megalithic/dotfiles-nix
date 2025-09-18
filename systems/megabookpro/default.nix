{ pkgs
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
    fd
    fzf
    git
    gnumake
    just
    kanata
    neovim
    ripgrep
    tmux
    vim
    zoxide
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
  homebrew = import ../../modules/shared/darwin/homebrew.nix { inherit pkgs lib; };

  # We use determinate nix installer; so we don't need this enabled..
  nix.enable = false;
  nix.optimise.automatic = true;

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
    jetbrains-mono
    maple-mono.NF
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
    nerd-fonts.symbols-only
  ];

  # services.postgresql = {
  #   enable = true;
  #   package = pkgs.postgresql_17;
  # };

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "${system}";

  # do garbage collection bi-daily to keep disk usage low
  nix.gc = {
    automatic = lib.mkDefault true;
    options = lib.mkDefault "--delete-older-than 2d";
  };
}
