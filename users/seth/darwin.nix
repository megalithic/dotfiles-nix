{ self, pkgs, lib, currentSystemHostname, currentSystemUsername, ... }:

{
  nix.enable = false;
  nix.extraOptions = ''
    extra-platforms = x86_64-darwin aarch64-darwin
  '';

  nix.linux-builder.enable = true;
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    accept-flake-config = true;
    trusted-users = [ "${currentSystemUsername}" "root" ];
  };
  nix.channel = { enable = false; };
  nix.gc = {
    automatic = true;
    interval = {
      Weekday = 1;
      Hour = 0;
      Minute = 0;
    };
    options = "--delete-older-than 8d";
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowBroken = true;
  nixpkgs.hostPlatform = "aarch64-darwin";

  system.configurationRevision = self.rev or self.dirtyRev or null;

  users.users."${currentSystemUsername}" = {
    home = "/Users/${currentSystemUsername}";
    shell = pkgs.zsh;
  };

  environment.systemPackages = [
    pkgs.just
    pkgs.bat
    pkgs.fzf
    pkgs.git
    pkgs.ripgrep
    pkgs.zoxide
    pkgs.docker
    pkgs.docker-compose
    pkgs.docker-credential-helpers
    pkgs.colima
    pkgs.uv
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

  # environment.extraInit = ''
  #   export SSH_AUTH_SOCK=~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock
  # '';

  # Enable fish and zsh
  programs.zsh.enable = true;
  programs.fish.enable = false;
  programs._1password.enable = true;

  # services = { };

  fonts.packages = [
    pkgs.atkinson-hyperlegible
    pkgs.jetbrains-mono
  ];

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
        mru-spaces = true;
        tilesize = 39;
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
        KeyRepeat = 2;
        AppleInterfaceStyle = "Dark";
      };
      CustomUserPreferences."org.hammerspoon.Hammerspoon" = {
        MJConfigFile = "~/.config/hammerspoon/init.lua";
      };
      loginwindow.LoginwindowText = "${currentSystemHostname}";
    };
    # karabiner-elements.enable = true;
    # keyboard = {
    #   enableKeyMapping = true;
    #   remapCapsLockToControl = true;
    # };
  };

  security.pam.services.sudo_local.touchIdAuth = true;
}
