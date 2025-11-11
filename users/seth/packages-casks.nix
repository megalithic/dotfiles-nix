{
  inputs,
  config,
  pkgs,
  ...
}: let
  inherit (pkgs.stdenv.hostPlatform) isDarwin;
in {
  home.packages = with inputs.nix-casks.packages.${pkgs.system}; [
    alfred
    brave-browser_nightly
    calibre
    cardhop
    cleanshot
    clickup
    cloudflare-warp
    colorsnapper
    contexts
    discord
    docker-desktop
    espanso
    # fantastical
    figma
    firefox
    flameshot
    # flux
    ghostty_tip
    hammerspoon
    homerow
    iina
    inkscape
    kitty_nightly
    macwhisper
    mailmate_beta
    microsoft-teams # Only have installed when needed (has some sinister telemetry).
    mouseless
    nimble-commander
    obs_beta
    orcaslicer-beta
    orion
    podman-desktop
    pop-app
    postbird
    proton-drive
    protonvpn
    qmk-toolbox
    qutebrowser
    raycast
    signal
    slack
    soundsource
    spotify
    steam
    telegram
    tunnelblick
    vlc
    unnaturalscrollwheels
    vial
    visual-studio-code
    whatsapp
    yubico-authenticator
    zed
    zen
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
