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
