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
      orcaslicer
      orion
      podman-desktop
      pop-app
      postbird
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
    ++ [
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
        pname = "proton-drive";
        version = "2.10.1";
        url = "https://proton.me/download/drive/macos/ProtonDrive-2.10.1.dmg";
        sha256 = "531367fcf2ff50bd5b2443c38e46d9a5cd80d054c1e28d5cbb68f5a070bded7c";
        appName = "Proton Drive.app";
      })

      (lib.mkCask {inherit pkgs lib;} {
        pname = "microsoft-teams";
        version = "25290.302.4044.3989";
        url = "https://statics.teams.cdn.office.net/production-osx/25290.302.4044.3989/MicrosoftTeams.pkg";
        sha256 = "0d7f4ed037e0ed8832e1892f0587e0e336abbc0e6376059bfcb58f278ffcab48";
        appName = "Microsoft Teams.app";
      })

      # Helium now managed by programs.helium module in chromium/default.nix
      # Using overlay from packages/helium.nix instead of cask
      # (lib.mkCask {inherit pkgs lib;} {
      #   pname = "helium";
      #   version = "0.4.13.1";
      #   url = "https://github.com/imputnet/helium-macos/releases/download/0.4.13.1/helium_0.4.13.1_arm64-macos.dmg";
      #   sha256 = "sha256-3j4souWY+4EGPSQR6uURjyqu3bkB5G9xuJbvOk9cZd8=";
      #   appName = "Helium.app";
      # })

      # (lib.mkCask {inherit pkgs lib;} {
      #   pname = "obs";
      #   version = "32.0.2";
      #   url = "https://cdn-fastly.obsproject.com/downloads/obs-studio-32.0.2-macos-apple.dmg";
      #   sha256 = "5c8f0e2349e45b57512e32312b053688e0b2bb9f0e8de8e7e24ee392e77a7cb3";
      #   appName = "OBS Studio.app";
      # })
    ];
}
