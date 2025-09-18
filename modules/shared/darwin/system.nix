{ pkgs
, lib
, config
, inputs
, username
, ...
}:
# NOTE: docs for nix-darwin found
# https://daiderd.com/nix-darwin/manual/index.html
{
  system = {
    primaryUser = "${username}";
    # Used for backwards compatibility, please read the changelog before changing.
    # $ darwin-rebuild changelog
    stateVersion = 5;
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
        NSGlobalDomain = {
          # Add a context menu item for showing the Web Inspector in web views
          WebKitDeveloperExtras = true;
          # automatically switch to a new space when switching to the application
          AppleSpacesSwitchOnActivate = true;
        };
        # "com.raycast.macos" = {
        #   raycastGlobalHotkey = "Command-15";
        # };
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
    };
    keyboard = {
      enableKeyMapping = true;
      # TODO: do this via kanata instead?
      remapCapsLockToControl = false;
    };
  };
  security.pam.services.sudo_local.touchIdAuth = true;
}
