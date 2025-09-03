{ self, pkgs, lib, ... }:

{
  # Enable fish and zsh
  programs.zsh.enable = true;
  programs.fish.enable = false;
  programs._1password.enable = true;

  users.users.evantravers = {
    home = "/Users/seth";
    shell = pkgs.zsh;
  };

  environment.systemPackages = [
    pkgs.bartender
    pkgs.defaultbrowser
    pkgs.firefox
    pkgs.google-chrome
    pkgs.brave-nightly
    pkgs.kanata
    pkgs.karabiner-elements.driver
    pkgs.keycastr
    pkgs.obsidian
  ];

  environment.extraInit = ''
    export SSH_AUTH_SOCK=~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock
  '';

  nix.settings.experimental-features = "nix-command flakes";
  nix.settings.accept-flake-config = true;

  nix.gc = {
    automatic = true;
    interval = {
      Weekday = 1;
      Hour = 0;
      Minute = 0;
    };
    options = "--delete-older-than 8d";
  };
  ix.settings.trusted-users = [ "seth" ];
  system.configurationRevision = self.rev or self.dirtyRev or null;

  system.stateVersion = 4;

  system.defaults.NSGlobalDomain.KeyRepeat = 2;
  system.defaults.NSGlobalDomain.AppleInterfaceStyle = "Dark";
  system.defaults.dock.autohide = true;
  system.defaults.dock.mru-spaces = false;
  system.defaults.dock.show-recents = false;
  system.defaults.dock.tilesize = 39;

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";

  services = {
    # aerospace = {
    #   enable = true;
    #   settings = {
    #     accordion-padding = 0;
    #     on-focused-monitor-changed = [ "move-mouse monitor-lazy-center" ];
    #     on-window-detected = [
    #       {
    #         "if" = {
    #           app-id = "com.flexibits.fantastical2.mac";
    #         };
    #         run = "move-node-to-workspace 2";
    #       }
    #     ];
    #     workspace-to-monitor-force-assignment = {
    #       "1" = [ "main" ];
    #       "2" = [
    #         "secondary"
    #         "main"
    #       ];
    #     };
    #     mode = {
    #       main = {
    #         binding = {
    #           alt-y = "layout tiles horizontal vertical";
    #           alt-t = "layout accordion horizontal vertical";
    #           alt-h = "focus left";
    #           alt-j = "focus down";
    #           alt-k = "focus up";
    #           alt-l = "focus right";
    #           alt-shift-h = "move left";
    #           alt-shift-j = "move down";
    #           alt-shift-k = "move up";
    #           alt-shift-l = "move right";
    #           alt-ctrl-h = "join-with left";
    #           alt-ctrl-j = "join-with down";
    #           alt-ctrl-k = "join-with up";
    #           alt-ctrl-l = "join-with right";
    #           alt-minus = "resize smart -100";
    #           alt-equal = "resize smart +100";
    #           alt-1 = "workspace 1";
    #           alt-2 = "workspace 2";
    #           alt-3 = "workspace 3";
    #           alt-shift-1 = "move-node-to-workspace 1";
    #           alt-shift-2 = "move-node-to-workspace 2";
    #           alt-shift-3 = "move-node-to-workspace 3";
    #           alt-tab = "workspace-back-and-forth";
    #           alt-shift-tab = "move-node-to-monitor --wrap-around next";
    #           alt-shift-semicolon = "mode service";
    #         };
    #       };
    #       service = {
    #         binding = {
    #           esc = [
    #             "reload-config"
    #             "mode main"
    #           ];
    #           r = [
    #             "flatten-workspace-tree"
    #             "mode main"
    #           ];
    #           f = [
    #             "layout floating tiling"
    #             "mode main"
    #           ];
    #           backspace = [
    #             "close-all-windows-but-current"
    #             "mode main"
    #           ];
    #         };
    #       };
    #     };
    #   };
    # };
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
  ];
  system = {
    primaryUser = "seth";
    defaults = {
      dock = {
        autohide = true;
        orientation = "bottom";
        show-process-indicators = true;
        show-recents = false;
        static-only = true;
      };
      finder = {
        AppleShowAllExtensions = true;
        FXDefaultSearchScope = "SCcf";
        FXEnableExtensionChangeWarning = false;
        ShowPathbar = true;
      };
      trackpad = {
        Clicking = true;
        TrackpadRightClick = true;
      };
      NSGlobalDomain = {
        AppleKeyboardUIMode = 3;
        "com.apple.keyboard.fnState" = true;
        NSAutomaticWindowAnimationsEnabled = false;
        NSWindowShouldDragOnGesture = true;
      };
      CustomUserPreferences."org.hammerspoon.Hammerspoon" = {
        MJConfigFile = "~/.config/hammerspoon/init.lua";
      };
    };
    # karabiner-elements.enable = true;
    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToControl = true;
    };
  };

  security.pam.services.sudo_local.touchIdAuth = true;
}
