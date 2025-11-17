{
  inputs,
  config,
  pkgs,
  ...
}: let
  inherit (pkgs.stdenv.hostPlatform) isDarwin;
in {
  home.packages = with inputs.nix-casks.packages.${pkgs.system}; [
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
    # mailmate
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
    # qutebrowser # exists in nixpkgs land already?
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

    # # "microsoft-office" # Only have installed when needed (has some sinister telemetry).
    # # "monitorcontrol" # Brightness and volume controls for external monitors.
    # # cursor # AI-powered code editor
    # # discord # Voice and text chat for gamers
    # # figma # Collaborative interface design tool
    # # ghostty # Fast, feature-rich, and cross-platform terminal emulator
    # # little-snitch # Network monitor and firewall
    # # linear-linear # Issue tracking and project management
    # # notion # All-in-one workspace
    # # obsidian # Knowledge management and note-taking
    # # ollama-app # Open-source AI model serving platform
    # # orbstack # Fast, light, simple Docker & Linux on macOS
    # # raycast # Launcher and productivity tool
    # # signal # Private messenger
    # # slack # Team communication and collaboration
    # # stats # System monitor for the menu bar
    # # aldente # Battery charge limiter for MacBooks
    # # tableplus # Database management tool
    # # # tunnelblick # OpenVPN client
    # # the-unarchiver # Archive extraction utility
    # # vlc # Media player
    # # whatsapp_beta # WhatsApp messaging (beta version)
    # # protonvpn # VPN service
  ];
}
