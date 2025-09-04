_:
{
  homebrew = {
    enable = true;

    onActivation = {
      autoUpdate = true;
      cleanup = "zap";
      upgrade = true;
    };

    brews = [
      "qmk"
      # QMK dependencies
      "avr-binutils"
      "avr-gcc@8"
      "boost"
      "confuse"
      "hidapi"
      "libftdi"
      "libusb-compat"
      "avrdude"
      "bootloadhid"
      "clang-format"
      "dfu-programmer"
      "dfu-util"
      "libimagequant"
      "libraqm"
      "pillow"
      "teensy_loader_cli"
      "osx-cross/arm/arm-none-eabi-binutils"
      "osx-cross/arm/arm-none-eabi-gcc@8"
      "osx-cross/avr/avr-gcc@9"
      "qmk/qmk/hid_bootloader_cli"
      "qmk/qmk/mdloader"
    ];

    casks =
      [
        "1password"
        "calibre"
        "cardhop"
        "discord"
        "docker-desktop"
        "fantastical"
        "figma"
        "ghostty"
        "hammerspoon"
        "homerow"
        "karabiner-elements"
        "macwhisper"
        "mouseless"
        "obs"
        "ollama"
        "pop-app"
        "raycast"
        "signal"
        "slack"
        "steam"
        "telegram"
        "vlc"
        "zoom"

        "balenaetcher"
        "betterdisplay" # Custom fractional scaling resolutions, brightness and volume control for non-Apple external displays.
        "brave-browser"
        "citrix-workspace"
        "discord"
        "firefox"
        "flux"
        "font-jetbrains-mono-nerd-font"
        "ghostty"
        "inkscape"
        "karabiner-elements" # STATE: Rebind right-command to right-option
        "mattermost"
        # "microsoft-office" # Only have installed when needed (has some sinister telemetry).
        "microsoft-teams" # Only have installed when needed (has some sinister telemetry).
        # "monitorcontrol" # Brightness and volume controls for external monitors.
        "mullvad-browser"
        "nextcloud"
        "orcaslicer"
        "orion"
        "qmk-toolbox"
        "qutebrowser"
        "racket"
        "signal"
        "stremio"
        "telegram"
        "transmission"
        "tunnelblick"
        "ukelele"
        "unnaturalscrollwheels"
        "utm"
        "vial"
        "visual-studio-code"
        "whatsapp"
        "zed"
        "zoom"

      ];

    masApps = {
      "Parcel" = 639968404;
      "Reeder" = 1529448980;
      "Timery" = 1425368544;
      "Toggl" = 1291898086;
      "Tailscale" = 1475387142;
    };

    taps = [
      "d12frosted/emacs-plus"
      "osx-cross/arm"
      "osx-cross/avr"
      "qmk/qmk"
    ];
  };
}
