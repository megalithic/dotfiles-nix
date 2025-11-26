{
  inputs,
  config,
  pkgs,
  lib,
  ...
}: let
  # Mac App Store applications to install
  # This uses the mkMas function to create an activation script that runs during home-manager switch
  #
  # Usage:
  # 1. Find app IDs with: mas search "App Name"
  # 2. Or use the helper: ./bin/mas-info "App Name"
  # 3. Add apps to the masApps attrset below in the format: "App Name" = <app-id>;
  #
  # Notes:
  # - You must be signed into the Mac App Store
  # - Apps must have been "purchased" (downloaded) at least once before
  # - Free apps can be "purchased" with: mas purchase <app-id>
  # - Already installed apps will be skipped
  # - If an ID is incorrect, mkMas will try to find the app by name
  #
  # Format: "App Name" = <mas app id>
  masApps = {
    "Xcode" = 497799835;
    # "Keynote" = 409183694;
    # "Fantastical" = 435003921;  # Not available via mas CLI (subscription app with restricted API access)
    # Add more apps as needed
    # "Pages" = 409201541;
    # "Numbers" = 409203825;
  };

  # Generate the mas installation script
  masInstaller = lib.mkMas {inherit pkgs lib;} masApps;
in {
  # Add the installation script to home-manager activation
  # This will run during home-manager switch
  home.activation.installMasApps = lib.hm.dag.entryAfter ["writeBoundary"] masInstaller.activationScript;
}
