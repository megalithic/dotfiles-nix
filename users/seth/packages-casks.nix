{
  inputs,
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (pkgs.stdenv.hostPlatform) isDarwin;
in {
  home.packages =
    # Keep existing nix-casks packages
    (with inputs.nix-casks.packages.${pkgs.system}; [
      # alfred
      brave-browser_nightly
      calibre
      cardhop
      cleanshot
      clickup
      colorsnapper
      contexts
      discord
      # docker
      # espanso
      # fantastical
      figma
      # firefox
      flameshot
      # flux
      # ghostty_tip
      ghostty
      hammerspoon
      homerow
      iina
      # inkscape
      kitty
      macwhisper
      mouseless
      # nimble-commander
      # obs_beta
      orcaslicer
      orion
      podman-desktop
      pop-app
      postbird
      proton-drive
      protonvpn
      qmk-toolbox
      raycast
      signal
      slack
      soundsource_test
      telegram
      tunnelblick
      # vlc
      unnaturalscrollwheels
      vial
      visual-studio-code
      yubico-authenticator
      zed
      # zen
    ])
    # Add custom casks
    ++ [
      # Define custom casks
      # mkCask is available via lib.mkCask
      # Use ./bin/cask-info <name> to get definitions
      # Use ./bin/add-cask <name> to get full instructions
      (lib.mkCask {inherit pkgs lib;} {
        pname = "mailmate";
        version = "5673";
        url = "https://updates.mailmate-app.com/archives/MailMate_r5673.tbz";
        sha256 = "2dc1069207d85a92c3a7000f019f8e4df88f123d2ffce4fdce17256d43c99cba";
        appName = "MailMate.app";
      })

      (lib.mkCask {inherit pkgs lib;} {
        pname = "microsoft-teams";
        version = "25290.302.4044.3989";
        url = "https://statics.teams.cdn.office.net/production-osx/25290.302.4044.3989/MicrosoftTeams.pkg";
        sha256 = "0d7f4ed037e0ed8832e1892f0587e0e336abbc0e6376059bfcb58f278ffcab48";
        appName = "Microsoft Teams.app";
      })
    ];
}
