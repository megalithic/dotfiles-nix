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
  accounts = import ../accounts.nix {inherit config pkgs lib;};
  programs = {
    aerc = import ./aerc.nix {inherit config pkgs lib;};
    mbsync.enable = true;
    notmuch = {
      enable = true;
      new = {
        # TODO:
        # tags: https://github.com/listx/syscfg/blob/master/notmuch/tags
        tags = [
          "unread"
          "inbox"
        ];
      };
      search = {
        excludeTags = [
          "deleted"
          "trash"
          "spam"
        ];
      };
      maildir = {
        synchronizeFlags = true;
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
