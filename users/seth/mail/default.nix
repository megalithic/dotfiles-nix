{
  config,
  pkgs,
  username,
  hostname,
  lib,
  ...
}: {
  accounts = import ../accounts.nix {inherit config pkgs lib;};
  programs = {
    aerc = import ./aerc.nix {inherit config pkgs lib;};
    mbsync.enable = true;
    msmtp.enable = true;
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
      # query = {
      #   # inbox=tag:inbox and tag:unread
      #   # sent=tag:sent
      #   # archive=not tag:inbox
      #   # github=tag:github or from:notifications@github.com
      #   # urgent=tag:urgent
      # };
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
    khard = {
      enable = true;
      settings = {
        "contact table" = {
          display = "formatted_name";
          preferred_phone_number_type = [
            "pref"
            "cell"
          ];
          preferred_email_address_type = [
            "pref"
            "work"
            "home"
          ];
        };
      };
    };
  };
}
