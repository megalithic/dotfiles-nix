{username, ...}: {
  homebrew = {
    enable = true;
    onActivation = {
      cleanup = "zap";
      upgrade = false;
      autoUpdate = true;
    };

    caskArgs.no_quarantine = true;

    global.autoUpdate = true;
    global.brewfile = true;

    brews = [
      "vfkit" # for podman
      "openconnect"
      #   # libvterm is not available in nix for aarch64 so we
      #   # install it from homebrew
      "libvterm"
      #   # this is required for mise be able to install erlang,
      #   # mise cannot identify openssl version installed in nix so
      #   # we need to use homebrew version to be able to use erlang
      #   # with no issues
      "openssl@3"
      #   # "qmk"
      #   # # QMK dependencies
      #   # "avr-binutils"
      #   # "avr-gcc@8"
      #   # "boost"
      #   # "confuse"
      #   # "hidapi"
      #   # "libftdi"
      #   # "libusb-compat"
      #   # "avrdude"
      #   # "bootloadhid"
      #   # "clang-format"
      #   # "dfu-programmer"
      #   # "dfu-util"
      #   # "libimagequant"
      #   # "libraqm"
      #   # "pillow"
      #   # "teensy_loader_cli"
      #   # "osx-cross/arm/arm-none-eabi-binutils"
      #   # "osx-cross/arm/arm-none-eabi-gcc@8"
      #   # "osx-cross/avr/avr-gcc@9"
      #   # "qmk/qmk/hid_bootloader_cli"
      #   # "qmk/qmk/mdloader"
    ];

    casks = [
      "1password"
      "1password-cli"
      #"alfred"
      "betterdisplay" # Custom fractional scaling resolutions, brightness and volume control for non-Apple external displays.
      "brave-browser@nightly"
      "calibre"
      "cardhop"
      "cleanshot"
      "clickup"
      "cloudflare-warp"
      "colorsnapper"
      "contexts"
      "discord"
      "docker-desktop"
      "espanso"
      # "fantastical"
      "figma"
      "firefox"
      "flameshot"
      # "flux"
      "ghostty@tip"
      "hammerspoon"
      "homerow"
      "iina"
      "inkscape"
      "karabiner-elements"
      "kitty@nightly"
      "macwhisper"
      "mailmate@beta"
      "microsoft-teams" # Only have installed when needed (has some sinister telemetry).
      "mouseless"
      "nimble-commander"
      "obs@beta"
      # "orcaslicer-beta"
      "orion"
      "podman-desktop"
      "pop-app"
      "postbird"
      "proton-drive"
      "qmk-toolbox"
      "qutebrowser"
      "raycast"
      "signal"
      "slack"
      "soundsource"
      "spotify"
      "steam"
      "telegram"
      "thunderbird"
      "tunnelblick"
      "vlc"
      "zoom"
      "unnaturalscrollwheels"
      "vial"
      "visual-studio-code"
      "whatsapp"
      "yubico-authenticator"
      "zed"
      "zen"
      "zoom"
      # "microsoft-office" # Only have installed when needed (has some sinister telemetry).
      # "monitorcontrol" # Brightness and volume controls for external monitors.
    ];

    taps = [];

    masApps = {
      #"Parcel" = 639968404;
      #"Reeder" = 1529448980;
      #"Timery" = 1425368544;
      #"Toggl" = 1291898086;
      #"Tailscale" = 1475387142;
      # "" = 1466976675; Rollo app

      # https://flexibits.com/fantastical/faq#faq_81 -- in case we need to download older versions
      # "Fantastical" = 975937182;
      # mas "Signal Shifter", id: 6446061552
      # mas "Fantastical", id: 975937182
      # # mas "Mayday", id: 1473168024
      # # mas "Spark", id: 1176895641
      # # mas "Canary Mail", id: 1236045954
      # # mas "Tweetbot", id: 557168941
      # # mas "Drafts", id: 1435957248
      # mas "Battery Indicator", id: 1206020918
      # mas "Brother iPrint&Scan", id: 1193539993
      # # mas "RocketSim", id: 1504940162
      # # mas "Vimari", id: 1480933944
      #
      # # mas "Things", id: 904280696 # might be bailing from this
      # # mas "Xcode", id: 497799835
      # # NOTE: turns out, i _HATE_ these applications. burn them to the ground.
      # # mas "Affinity Photo", id: 824183456
      # # mas "Affinity Designer", id: 824171161
    };
  };

  # homebrew.taps = builtins.attrNames config.nix-homebrew.taps;
  # taps = [
  #   # "osx-cross/arm"
  #   # "osx-cross/avr"
  #   # "qmk/qmk"
  # ];

  # homebrew = {
  #   enable = true;
  #
  #   onActivation = {
  #     autoUpdate = true;
  #     cleanup = "zap";
  #     upgrade = true;
  #   };
  #
  #   brews = [
  #     "qmk"
  #     # QMK dependencies
  #     "avr-binutils"
  #     "avr-gcc@8"
  #     "boost"
  #     "confuse"
  #     "hidapi"
  #     "libftdi"
  #     "libusb-compat"
  #     "avrdude"
  #     "bootloadhid"
  #     "clang-format"
  #     "dfu-programmer"
  #     "dfu-util"
  #     "libimagequant"
  #     "libraqm"
  #     "pillow"
  #     "teensy_loader_cli"
  #     "osx-cross/arm/arm-none-eabi-binutils"
  #     "osx-cross/arm/arm-none-eabi-gcc@8"
  #     "osx-cross/avr/avr-gcc@9"
  #     "qmk/qmk/hid_bootloader_cli"
  #     "qmk/qmk/mdloader"
  #   ];
  #
  #   casks =
  #     [
  #       "1password"
  #       "calibre"
  #       "cardhop"
  #       "discord"
  #       "docker-desktop"
  #       "fantastical"
  #       "figma"
  #       "ghostty"
  #       "hammerspoon"
  #       "homerow"
  #       "karabiner-elements"
  #       "macwhisper"
  #       "mouseless"
  #       "obs"
  #       "ollama"
  #       "pop-app"
  #       "raycast"
  #       "signal"
  #       "slack"
  #       "steam"
  #       "telegram"
  #       "vlc"
  #       "zoom"
  #
  #       "balenaetcher"
  #       "betterdisplay" # Custom fractional scaling resolutions, brightness and volume control for non-Apple external displays.
  #       "brave-browser"
  #       "citrix-workspace"
  #       "discord"
  #       "firefox"
  #       "flux"
  #       "font-jetbrains-mono-nerd-font"
  #       "ghostty"
  #       "inkscape"
  #       "karabiner-elements" # STATE: Rebind right-command to right-option
  #       "mattermost"
  #       # "microsoft-office" # Only have installed when needed (has some sinister telemetry).
  #       "microsoft-teams" # Only have installed when needed (has some sinister telemetry).
  #       # "monitorcontrol" # Brightness and volume controls for external monitors.
  #       "mullvad-browser"
  #       "nextcloud"
  #       "orcaslicer"
  #       "orion"
  #       "qmk-toolbox"
  #       "qutebrowser"
  #       "racket"
  #       "signal"
  #       "stremio"
  #       "telegram"
  #       "transmission"
  #       "tunnelblick"
  #       "ukelele"
  #       "unnaturalscrollwheels"
  #       "utm"
  #       "vial"
  #       "visual-studio-code"
  #       "whatsapp"
  #       "zed"
  #       "zoom"
  #
  #     ];
  #
  #   masApps = {
  #     "Parcel" = 639968404;
  #     "Reeder" = 1529448980;
  #     "Timery" = 1425368544;
  #     "Toggl" = 1291898086;
  #     "Tailscale" = 1475387142;
  #   };
  #
  #   taps = [
  #     "d12frosted/emacs-plus"
  #     "osx-cross/arm"
  #     "osx-cross/avr"
  #     "qmk/qmk"
  #   ];
  # };
}
