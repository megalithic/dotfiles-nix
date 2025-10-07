{
  config,
  pkgs,
  username,
  hostname,
  lib,
  ...
}: let
  # inherit (builtins) readFile;
in {
  accounts = import ./accounts.nix {inherit config pkgs lib;};
  programs = {
    aerc = import ./aerc.nix {inherit config pkgs lib;};
    mbsync.enable = true;
    notmuch = {
      enable = true;
      new = {
        tags = [
          "unread"
          "inbox"
        ];
      };
      search = {
        exclude_tags = [
          "deteled"
          "spam"
        ];
      };
      maildir = {
        synchronize_flags = true;
      };
    };
    himalaya.enable = true;
    thunderbird = {
      enable = true;
      profiles."default" = {
        isDefault = true;
      };
    };
  };
}
