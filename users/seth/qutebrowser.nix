{
  config,
  pkgs,
  username,
  hostname,
  ...
}: let
  inherit (builtins) readFile;
in {
  programs.qutebrowser = {
    enable = true;
  };
}
