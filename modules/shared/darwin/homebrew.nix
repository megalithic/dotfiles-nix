# homebrew for all users
_:
{
  enable = true;
  onActivation = {
    cleanup = "zap";
    autoUpdate = true;
    upgrade = false;
  };
  global.autoUpdate = true;
  brews = [ ];
  casks = [
    "1password"
    "brave-nightly"
    "figma"
    "ghostty"
    "hammerspoon"
    "mouseless"
    "obs"
    "pop-app"
    "qutebrowser"
    "raycast"
    "signal"
    "slack"
    "spotify"
    "tunnelblick"
    "vial"
    "zoom"
  ];
  taps = [ ];
  masApps = {
    # "Parcel" = 639968404;
    # "Reeder" = 1529448980;
    # "Timery" = 1425368544;
    # "Toggl" = 1291898086;
  };
}

