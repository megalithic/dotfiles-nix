# NOTE: docs for nix-darwin found
# https://daiderd.com/nix-darwin/manual/index.html

{ inputs, pkgs, currentSystemHostname, currentSystemArch, currentSystemUsername, ... }:

{
  users.users."${currentSystemUsername}" = {
    home = "/Users/${currentSystemUsername}";
    shell = pkgs.fish;
  };

  imports = [
    ./fonts.nix
    ./homebrew.nix
  ];

  environment.systemPackages = with pkgs;
    [
      just
      bat
      fzf
      git
      ripgrep
      fd
      sd
      zoxide
      # docker
      # docker-compose
      # docker-credential-helpers
      # colima
      # uv
      defaultbrowser
      firefox
      chromium
      unstable.brave-nightly
      kanata
      karabiner-elements.driver
      keycastr
      obsidian
    ] ++ [ inputs.agenix.packages.${currentSystemArch}.default ];

  # Enable fish and zsh
  programs.zsh.enable = true;
  programs.fish.enable = true;
  programs._1password.enable = true;

  # services.postgresql = {
  #   enable = true;
  #   package = pkgs.postgresql_17;
  # };

  # extra host specs
  # https://github.com/nix-darwin/nix-darwin/issues/1035
  # networking.extraHosts = ''
  #   127.0.0.1   kubernetes.docker.internal
  #   127.0.0.1   kubernetes.default.svc.cluster.local
  # '';

  networking.hostName = "${currentSystemHostname}";
  time.timeZone = "America/New_York";

  # REF: https://github.com/appaquet/dotfiles/blob/master/darwin/mbpapp/system.nix
  system = {
    primaryUser = "${currentSystemUsername}";
    defaults = {
      # screencapture.location = "~/Library/CloudStorage/ProtonDrive-seth@megalithic.io-folder/screenshots";
      dock = {
        autohide = true;
        orientation = "bottom";
        show-process-indicators = true;
        show-recents = false;
        static-only = true;
        mru-spaces = false;
        tilesize = 30;
      };
      spaces = {
        spans-displays = false; # each screen has their own spaces
      };
      finder = {
        AppleShowAllExtensions = true;
        FXDefaultSearchScope = "SCcf";
        FXEnableExtensionChangeWarning = false;
        ShowPathbar = true;
        QuitMenuItem = true; # enable quit menu item
        ShowStatusBar = true; # show status bar
      };
      trackpad = {
        Clicking = true; # enable tap to click
        TrackpadRightClick = true; # enable two finger right click
        TrackpadThreeFingerDrag = true; # enable three finger drag
      };
      NSGlobalDomain = {
        "com.apple.swipescrolldirection" = false; # enable natural scrolling(default to true)
        "com.apple.sound.beep.feedback" = 0; # disable beep sound when pressing volume up/down key
        "com.apple.keyboard.fnState" = true;
        AppleKeyboardUIMode = 3; # Mode 3 enables full keyboard control.
        AppleInterfaceStyle = "Dark";
        ApplePressAndHoldEnabled = false; # enable press and hold
        NSAutomaticWindowAnimationsEnabled = false;
        NSWindowShouldDragOnGesture = true;
        _HIHideMenuBar = false; # hide menu bar
        # sets how long it takes before it starts repeating.
        InitialKeyRepeat = 15; # normal minimum is 15 (225 ms), maximum is 120 (1800 ms)
        # sets how fast it repeats once it starts.
        KeyRepeat = 2; # normal minimum is 2 (30 ms), maximum is 120 (1800 ms)
      };
      CustomUserPreferences = {
        NSGlobalDomain = {
          # Add a context menu item for showing the Web Inspector in web views
          WebKitDeveloperExtras = true;
          # automatically switch to a new space when switching to the application
          AppleSpacesSwitchOnActivate = true;
        };
        "com.apple.desktopservices" = {
          # Avoid creating .DS_Store files on network or USB volumes
          DSDontWriteNetworkStores = true;
          DSDontWriteUSBStores = true;
        };
        "com.apple.WindowManager" = {
          EnableStandardClickToShowDesktop = 0; # Click wallpaper to reveal desktop
          StandardHideDesktopIcons = 0; # Show items on desktop
          HideDesktop = 0; # Do not hide items on desktop & stage manager
          StageManagerHideWidgets = 0;
          StandardHideWidgets = 0;
        };
        "com.apple.screensaver" = {
          # Require password immediately after sleep or screen saver begins
          askForPassword = 1;
          askForPasswordDelay = 0;
        };
        # "com.apple.screencapture" = {
        #   location = "~/Desktop";
        #   type = "png";
        # };
        "com.apple.AdLib" = {
          allowApplePersonalizedAdvertising = false;
        };
        # Prevent Photos from opening automatically when devices are plugged in
        "com.apple.ImageCapture".disableHotPlug = true;

        "org.hammerspoon.Hammerspoon" = {
          MJConfigFile = "~/.config/hammerspoon/init.lua";
        };
      };

      loginwindow = {
        GuestEnabled = false; # disable guest user
        SHOWFULLNAME = false; # show full name in login window
        LoginwindowText = "${currentSystemHostname}";
      };
    };

    keyboard = {
      enableKeyMapping = true;
      # TODO: does kanata handle this now?
      # remapCapsLockToControl = true;
    };
  };

  security.pam.services.sudo_local.touchIdAuth = true;
}
