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
  lang = "en_US.UTF-8";
in
{
  imports = [
    ../../modules/shared/darwin/homebrew.nix
  ];

  home-manager = {
    extraSpecialArgs = {
      inherit inputs;
    };
    backupFileExtension = "hm-backup";
  };

  users.users.${username} = {
    name = username;
    home = "/Users/${username}";
    isHidden = false;
    shell = pkgs.fish;
  };

  networking.hostName = "${hostname}";
  time.timeZone = "America/New_York";
  ids.gids.nixbld = 30000;

  # system wide packages (all users)
  environment.systemPackages = with pkgs; [
    bat
    curl
    coreutils
    darwin.trash
    delta
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
    zsh-autosuggestions
    zsh-syntax-highlighting
  ];

  environment.shells = [ pkgs.fish ];
  # environment.shells = [ pkgs.zsh pkgs.fish pkgs.bashInteractive ];

  environment.shellAliases = {
    e = "$EDITOR";
    vim = "$EDITOR";
  };

  environment.variables = {
    LANG = "${lang}";
    LC_CTYPE = "${lang}";
    LC_ALL = "${lang}";
    PAGER = "less -FirSwX";
    EDITOR = "${pkgs.nvim-nightly}/bin/nvim";
    VISUAL = "$EDITOR";
    GIT_EDITOR = "$EDITOR";
    MANPAGER = "$EDITOR +Man!";
    # HOMEBREW_PREFIX = "/opt/homebrew";
    XDG_CACHE_HOME = "/Users/${username}/.local/cache";
    XDG_CONFIG_HOME = "/Users/${username}/.config";
    XDG_DATA_HOME = "/Users/${username}/.local/share";
    XDG_STATE_HOME = "/Users/${username}/.local/state";
  };


  # We use determinate nix installer; so we don't need this enabled..
  nix = {
    # determinate nix installer handles this
    enable = false;
    package = pkgs.nixVersions.latest;
    linux-builder = {
      enable = false;
      maxJobs = 4;
      ephemeral = true;
      config = {
        virtualisation = {
          darwin-builder = {
            diskSize = 40 * 1024;
            memorySize = 8 * 1024;
          };
          cores = 6;
        };
      };
    };
    settings = {
      trusted-users = [
        "@admin"
      ];
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      warn-dirty = false;
      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
        "https://nixpkgs.cachix.org"
        "https://yazi.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "nixpkgs.cachix.org-1:q91R6hxbwFvDqTSDKwDAV4T5PxqXGxswD8vhONFMeOE="
        "yazi.cachix.org-1:Dcdz63NZKfvUCbDGngQDAZq6kOroIrFoyO064uvLh8k="
      ];
      # Recommended when using `direnv` etc.
      keep-derivations = true;
      keep-outputs = true;
    };
    # nixPath = [ "nixpkgs=flake:nixpkgs" ]; # We only use flakes
    nixPath = {
      inherit (inputs) nixpkgs;
      inherit (inputs) darwin;
      inherit (inputs) home-manager;
    };
  };

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


  # extra host specs
  # https://github.com/nix-darwin/nix-darwin/issues/1035
  # networking.extraHosts = ''
  #   127.0.0.1	  kubernetes.docker.internal
  #   127.0.0.1   kubernetes.default.svc.cluster.local
  # '';

  # Create /etc/zshrc that loads the nix-darwin environment.
  programs = {
    zsh.enable = true;
    bash.enable = true;
    fish = {
      enable = true;
      useBabelfish = true;
    };
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };
  # programs.gnupg.agent.enableSSHSupport = true;
  # programs._1password.enable = true;

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
    # usbmuxd = { enable = true; };
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
