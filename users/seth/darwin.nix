# NOTE: docs for nix-darwin found
# https://daiderd.com/nix-darwin/manual/index.html

{ inputs, pkgs, currentSystem, currentSystemName, currentSystemUser, ... }:
# { pkgs, lib, ... }:

let
  # For our MANPAGER env var
  # https://github.com/sharkdp/bat/issues/1145
  manpager = pkgs.writeShellScriptBin "manpager" ''
    sh -c 'col -bx | bat -l man -p'
  '';

  lang = "en_US.UTF-8";
in
{
  # Enable fish and zsh
  programs.zsh.enable = true;
  programs.fish.enable = true;
  programs._1password.enable = true;

  users.users.${currentSystemUser} = {
    home = "/Users/${currentSystemUser}";
    shell = pkgs.fish;
  };

  environment.variables = {
    LANG = "${lang}";
    LC_CTYPE = "${lang}";
    LC_ALL = "${lang}";
    EDITOR = "nvim";
    PAGER = "less -FirSwX";
    MANPAGER = "${manpager}/bin/manpager";
  };

  environment.shells = [ pkgs.zsh pkgs.fish pkgs.bashInteractive ];

  environment.systemPackages = [
    pkgs.bat
    pkgs.brave
    pkgs.defaultbrowser
    pkgs.fd
    pkgs.firefox
    pkgs.fzf
    pkgs.git
    pkgs.google-chrome
    pkgs.just
    pkgs.kanata
    # NOTE: see custom kanata driver in packages
    # pkgs.karabiner-elements.driver
    pkgs.ripgrep
    pkgs.sd
    pkgs.vim
    pkgs.zoxide
  ];

  # FIXME: remove?
  # environment.extraInit = ''
  #   export SSH_AUTH_SOCK=~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock
  # '';

  services = {
    kanata = {
      enable = true;
      configFile = "./config/kanata/kanata.kbd";
    };
  };

  homebrew = {
    enable = true;

    onActivation.autoUpdate = false;
    onActivation.upgrade = false;

    casks =
      [
        "1password"
        "calibre"
        "cardhop"
        "discord"
        "docker-desktop"
        "fantastical"
        "figma"
        "ghostty"
        "hammerspoon"
        "homerow"
        "karabiner-elements"
        "macwhisper"
        "mouseless"
        "obs"
        "ollama"
        "pop-app"
        "raycast"
        "signal"
        "slack"
        "steam"
        "telegram"
        "vlc"
        "zoom"
      ];

    masApps = {
      "Parcel" = 639968404;
      "Reeder" = 1529448980;
      "Timery" = 1425368544;
      "Toggl" = 1291898086;
    };
  };

  fonts.packages = [
    pkgs.atkinson-hyperlegible
    pkgs.jetbrains-mono
    pkgs.nerd-fonts.jetbrains-mono
    pkgs.nerd-fonts.fira-code
    pkgs.maple-mono.NF
    pkgs.nerd-fonts.symbols-only
  ];

  networking.hostName = "${currentSystemName}";
  time.timeZone = "America/New_York";

  ids.gids.nixbld = 350;

  system = {
    primaryUser = "seth";
    defaults = {
      dock = {
        autohide = true;
        orientation = "left";
        show-process-indicators = false;
        show-recents = false;
        static-only = true;
        launchanim = false;
        expose-animation-duration = 0.0;
        mineffect = "scale";
        tilesize = 32;
      };
      finder = {
        AppleShowAllExtensions = true;
        AppleShowAllFiles = true;
        FXDefaultSearchScope = "SCcf";
        FXPreferredViewStyle = "Nlsv";
        FXEnableExtensionChangeWarning = false;
        ShowPathbar = true;
        ShowStatusBar = true;
        _FXShowPosixPathInTitle = true;
      };
      trackpad = {
        Clicking = true;
        TrackpadRightClick = true;
      };
      NSGlobalDomain = {
        AppleICUForce24HourTime = true;
        AppleKeyboardUIMode = 3;
        "com.apple.keyboard.fnState" = true;
        NSAutomaticWindowAnimationsEnabled = false;
        NSWindowShouldDragOnGesture = true;
      };
      CustomUserPreferences = {
        # "com.raycast.macos" = {
        #   raycastGlobalHotkey = "Command-15";
        # };

        "org.hammerspoon.Hammerspoon" = {
          MJConfigFile = "~/.config/hammerspoon/init.lua";
        };

        "com.apple.symbolichotkeys" = {
          AppleSymbolicHotKeys = {
            # # Disable input sources shortcuts
            # "60".enabled = false;
            # "61".enabled = false;
            #
            # # Disable Spotlight Shortcuts
            # "64".enabled = false;
            # "65".enabled = false;
          };
        };
      };
      # karabiner-elements.enable = true;
      keyboard = {
        enableKeyMapping = true;
        remapCapsLockToControl = true;
      };
    };

    security.pam.services.sudo_local.touchIdAuth = true;
  };
}
