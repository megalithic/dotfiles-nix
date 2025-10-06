{
  pkgs,
  lib,
  ...
}: let
  inherit (pkgs.stdenv) isDarwin;
in {
  # If karabiner ever stops working and restarts don't fix the problem, try:
  # /Applications/.Nix-Karabiner/.Karabiner-VirtualHIDDevice-Manager.app/Contents/MacOS/Karabiner-VirtualHIDDevice-Manager deactivate
  # then restarting and re-allowing Karabiner when prompted.

  home.file.".config/karabiner/default.json" = lib.mkIf isDarwin {
    source = ./karabiner.json;
    # onChange = "${pkgs.goku}/bin/goku";
  };
}
