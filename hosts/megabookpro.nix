{
  inputs,
  pkgs,
  config,
  lib,
  username,
  system,
  hostname,
  version,
  ...
}: let
  lang = "en_US.UTF-8";
in {
  imports = [
    ../modules/shared/darwin/homebrew.nix
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

  networking = {
    hostName = "${hostname}";

    # knownNetworkServices = [
    #   "Wi-Fi"
    #   "Thunderbolt Bridge"
    #   "Tailscale"
    # ];

    # dns = [
    #   "9.9.9.9" # Quad9
    # ];
  };
  system.defaults.smb.NetBIOSName = hostname;

  time.timeZone = "America/New_York";
  ids.gids.nixbld = 30000;

  # system wide packages (all users)
  environment.systemPath = ["/opt/homebrew/bin"];
  environment.pathsToLink = ["/Applications"];
  environment.systemPackages = with pkgs; [
    (fenix.complete.withComponents [
      "cargo"
      "clippy"
      "rust-src"
      "rustc"
      "rustfmt"
    ])
    rust-analyzer-nightly

    bat
    curl
    coreutils
    darwin.trash
    delta
    devenv
    du-dust # du + rust = dust. Like du but more intuitive.
    eza
    fd
    # fish
    # fzf
    git
    git-lfs
    gnumake
    inetutils
    jq
    jujutsu
    just
    kanata
    # karabiner-elements.driver
    ldns # supplies drill replacement for dig
    libwebp # WebP image format library
    m-cli # A macOS cli tool to manage macOS - a true swis army knife
    mise
    netcat
    nix-index
    nmap
    nurl
    nvim-nightly
    openssl
    unzip
    p7zip
    ripgrep
    starship
    # tmux
    vim
    wget
    yazi
    yq
    zip
    zoxide
    # zsh
    zsh-autosuggestions
    zsh-syntax-highlighting
  ];

  environment.shells = [pkgs.fish pkgs.zsh];
  # environment.shells = [ pkgs.zsh pkgs.fish pkgs.bashInteractive ];

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

    CODE = "/Users/${username}/code";
    DOTS = "/Users/${username}/.dotfiles-nix";

    TMUX_LAYOUTS = "/Users/${username}/.config/tmux/layouts";

    # FZF_DEFAULT_COMMAND = "fd --type f --follow --hidden --color=always --no-ignore-vcs";

    # l = "eza --all --long --color=always --color-scale=all --group-directories-first --sort=type --hyperlink --icons=auto --octal-permissions";
    # # l = "eza --all --long --color-scale=all --group-directories-first --sort=type --hyperlink --icons=auto --octal-permissions";
    # ll = "eza --icons --tree --color=always --color-scale=all --group-directories-first --all --level=2";
    # lt = "eza --tree --color=always --color-scale=all --group-directories-first --all";
    cat = "bat";
    grep = "grep --color=auto";
    get = "wget --continue --progress=bar --timestamping";

    EZA_ICON_SPACING = "2";
    FZF_ALT_C_COMMAND = "$FZF_CTRL_T_COMMAND --type d .";
    FZF_ALT_C_OPTS = "--preview='($FZF_PREVIEW_COMMAND) 2> /dev/null' --walker-skip .git,node_modules";
    FZF_CTRL_R_OPTS = "--preview 'echo {}' --preview-window down:3:wrap:hidden --bind 'ctrl-y:execute-silent(echo -n {2..} | pbcopy)+abort' --header 'Press CTRL-Y to copy command into clipboard'";
    FZF_CTRL_T_COMMAND = "${pkgs.fd}/bin/fd --strip-cwd-prefix --hidden --follow --no-ignore-vcs";
    FZF_CTRL_T_OPTS = "--preview-window right:border-left:60%:hidden --preview='($FZF_PREVIEW_COMMAND)' --walker-skip .git,node_modules";
    FZF_DEFAULT_COMMAND = "$FZF_CTRL_T_COMMAND --type f";
    FZF_DEFAULT_OPTS = "--border thinblock --prompt='» ' --pointer='▶' --marker='✓ ' --reverse --tabstop 2 --multi --color=bg+:-1,marker:010 --separator='' --bind '?:toggle-preview' --info inline-right";
    # https://github.com/sharkdp/bat/issues/634#issuecomment-524525661
    FZF_PREVIEW_COMMAND = "COLORTERM=truecolor previewer {}";

    TMUX_PLUGIN_MANAGER_PATH = "/Users/${username}/.local/share/tmux/plugins";
    TMUX_PLUGINS_HOME = "/Users/${username}/.local/share/tmux/plugins";
  };

  environment.shellAliases = {
    e = "$EDITOR";
    vim = "$EDITOR";
    tmux = "direnv exec / tmux";
  };

  environment.extraInit = ''
    export SSH_AUTH_SOCK=~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock
  '';

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
        "root"
        "${username}"
      ];
      experimental-features = [
        "nix-command"
        "flakes"
        "extra-platforms = aarch64-darwin x86_64-darwin"
        "external-builders"
      ];
      external-builders = [
        {
          systems = ["aarch64-linux" "x86_64-linux"];
          program = "/usr/local/bin/determinate-nixd";
          args = ["builder"];
        }
      ];
      download-buffer-size = 5368709120;
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
    emacs-all-the-icons-fonts
    # joypixels
    fira-code
    fira-mono
    font-awesome
    victor-mono
    maple-mono.NF
    maple-mono.truetype
    maple-mono.variable
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
    nerd-fonts.symbols-only
    noto-fonts-emoji
    nerd-fonts.fantasque-sans-mono
    nerd-fonts.iosevka
    nerd-fonts.victor-mono
    twemoji-color-font
  ];

  services = {
    jankyborders = {
      enable = false;
      blur_radius = 5.0;
      hidpi = true;
      active_color = "0xAAB279A7";
      inactive_color = "0x33867A74";
    };
    # usbmuxd = { enable = true; };
  };

  # services.karabiner-elements.enable = true;
  # services.kanata.enable = true;
  # services.kanata.configFile = "/Users/${username}/.config/kanata/megabookpro.kbd";

  # launchd.user.agents.mbsync = {
  #   script = ''
  #     #!/bin/sh
  #     ${pkgs.mbsync}/bin/mbsync -a
  #     ${pkgs.notmuch}/bin/notmuch new
  #   '';
  #   serviceConfig = {
  #     Label = "mbsync";
  #     ProgramArguments = ["/bin/sh" "-c" "${config.xdg.dataHome}/aerc/launchd-mbsync.sh"];
  #     StartInterval = 300; # Run every 5 minutes
  #     RunAtLoad = true;
  #   };
  #   # Ensure the script directory exists
  #   preStart = ''
  #     mkdir -p ${config.xdg.dataHome}/aerc
  #     cat > ${config.xdg.dataHome}/aerc/launchd-mbsync.sh << 'EOF'
  #     #!/bin/sh
  #     ${pkgs.mbsync}/bin/mbsync -a
  #     ${pkgs.notmuch}/bin/notmuch new
  #     EOF
  #     chmod +x ${config.xdg.dataHome}/aerc/launchd-mbsync.sh
  #   '';
  # };

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "${system}";
}
