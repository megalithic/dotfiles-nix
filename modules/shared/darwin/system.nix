{ pkgs
, lib
, config
, inputs
, username
, ...
}:
# NOTE: docs for nix-darwin found
# https://daiderd.com/nix-darwin/manual/index.html

# macOS user-specific defaults using home-manager's built-in support
#
# VALIDATION BEST PRACTICES:
# 1. Test settings manually first: `defaults write com.apple.finder ShowStatusBar -bool true`
# 2. Check existing settings: `defaults read com.apple.finder`
# 3. Use `defaults domains` to see available domains
# 4. Invalid domains/keys will build but silently fail to apply
# 5. Some settings require logout/restart to take effect
# 6. Case sensitivity matters for both domains and keys
# 7. Not all `defaults` commands have targets.darwin.defaults equivalents
{
  system = {
    primaryUser = "${username}";
    # Used for backwards compatibility, please read the changelog before changing.
    # Darwin state version 6 - defines system configuration schema/compatibility
    # See flake.nix for actual package channel selection (stable vs unstable)
    # Reference: https://github.com/LnL7/nix-darwin/blob/master/modules/system/default.nix
    # $ darwin-rebuild changelog
    stateVersion = 6;
    defaults = {
      dock = {
        autohide = true;
        orientation = "bottom";
        show-process-indicators = true;
        show-recents = false;
        static-only = true;
        launchanim = false;
        expose-animation-duration = 0.0;
        minimize-to-application = true;
        mineffect = "scale";
        magnification = false;
        persistent-apps = [ ];
        tilesize = 34;
        # Mission Control and Spaces behavior
        # Disable automatic rearrangement of spaces based on most recent use
        "mru-spaces" = false;
        # Hot corners configuration
        # Values correspond to specific macOS actions:
        # 0: No-op (disabled)
        # 2: Mission Control - shows all open windows and spaces
        # 3: Application Windows - shows all windows of current app
        # 4: Desktop - shows desktop by hiding all windows
        # 5: Start Screen Saver
        # 6: Disable Screen Saver
        # 7: Dashboard (deprecated in newer macOS versions)
        # 10: Put Display to Sleep
        # 11: Launchpad - shows app launcher grid
        # 12: Notification Center
        # 13: Lock Screen - immediately locks the screen
        # 14: Quick Note - opens Notes app for quick note-taking
        "wvous-tl-corner" = 0; # Top-left: Mission Control (overview of all spaces)
        "wvous-tr-corner" = 0; # Top-right: Desktop (show desktop)
        "wvous-bl-corner" = 0; # Bottom-left: Lock Screen (security)
        "wvous-br-corner" = 0; # Bottom-right: Quick Note (productivity)
        # "wvous-tl-corner" = 2; # Top-left: Mission Control (overview of all spaces)
        # "wvous-tr-corner" = 4; # Top-right: Desktop (show desktop)
        # "wvous-bl-corner" = 13; # Bottom-left: Lock Screen (security)
        # "wvous-br-corner" = 14; # Bottom-right: Quick Note (productivity)
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
        ShowExternalHardDrivesOnDesktop = true;
        ShowHardDrivesOnDesktop = false;
        ShowMountedServersOnDesktop = false;
        ShowRemovableMediaOnDesktop = true;
        _FXSortFoldersFirst = true;
        QuitMenuItem = true;
        NewWindowTarget = "Documents";
        # NewWindowTargetPath = "file://Users/${username}/Desktop/";
      };

      trackpad = {
        Clicking = true;
        TrackpadRightClick = true;
        TrackpadThreeFingerDrag = true;
      };

      NSGlobalDomain = {
        AppleICUForce24HourTime = true;
        AppleKeyboardUIMode = 3;
        "com.apple.keyboard.fnState" = true;
        NSAutomaticWindowAnimationsEnabled = false;
        NSWindowShouldDragOnGesture = true;
      };

      screencapture = {
        location = "/Users/${username}/_screenshots";
        type = "png";
        disable-shadow = true;
      };

      LaunchServices = {
        LSQuarantine = false;
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
        "com.apple.ActivityMonitor" = {
          OpenMainWindow = true;
          IconType = 5;
          SortColumn = "CPUUsage";
          SortDirection = 0;
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
        "com.apple.AdLib".allowApplePersonalizedAdvertising = false;
        # turns on app auto-updating
        "com.apple.commerce".AutoUpdate = true;
        # Prevent Photos from opening automatically when devices are plugged in
        "com.apple.ImageCapture".disableHotPlug = true;
        # Disable animation when switching screens or opening apps
        "com.apple.universalaccess".reduceMotion = true;
        # tell HS where to find its config file
        "org.hammerspoon.Hammerspoon".MJConfigFile = "~/.config/hammerspoon/init.lua";

        "com.apple.SoftwareUpdate" = {
          AutomaticCheckEnabled = true;
          # Check for software updates daily, not just once per week
          ScheduleFrequency = 1;
          # Download newly available updates in background
          AutomaticDownload = 1;
          # Install System data files & security updates
          CriticalUpdateInstall = 1;
        };

        "com.apple.symbolichotkeys" = {
          AppleSymbolicHotKeys = {
            # Disable input sources shortcuts
            # Disable '^ + Space' for selecting the previous input source
            "60".enabled = false;
            # "61".enabled = false;
            # -- or --
            "61" = {
              # Set 'Option + Space' for selecting the next input source
              enabled = 1;
              value = {
                parameters = [
                  32
                  49
                  524288
                ];
                type = "standard";
              };
            };



            # Disable Spotlight Shortcuts
            # Disable 'Cmd + Space' for Spotlight Search
            "64".enabled = false;
            # Disable 'Cmd + Alt + Space' for Finder search window
            "65".enabled = false;
          };
        };

        "com.brave.Browser.nightly" = {
          NSUserKeyEquivalents = {
            "Close Tab" = "^w";
            "Find..." = "^f";
            "New Private Window" = "^$n";
            "New Tab" = "^t";
            "Reload This Page" = "^r";
            "Reopen Closed Tab" = "^$t";
            "Reset zoom" = "^0";
            "Zoom In" = "^=";
            "Zoom Out" = "^-";
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
  security.sudo.extraConfig = "${username}    ALL = (ALL) NOPASSWD: ALL";

  # Settings that require manual defaults commands (not supported by home-manager's targets.darwin.defaults)
  # REF: https://github.com/fredrikaverpil/dotfiles/blob/main/nix/shared/home/darwin.nix
  # home.activation.macosUserDefaults = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
  #   echo "Applying additional MacOS user settings..."
  #
  #   # Disable input source switching (Ctrl+Space) to prevent conflicts with development tools
  #   $DRY_RUN_CMD /usr/bin/defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 60 "
  #     <dict>
  #       <key>enabled</key><false/>
  #       <key>value</key><dict>
  #         <key>type</key><string>standard</string>
  #         <key>parameters</key>
  #         <array>
  #           <integer>32</integer>
  #           <integer>49</integer>
  #           <integer>262144</integer>
  #         </array>
  #       </dict>
  #     </dict>
  #   "
  # '';
}
