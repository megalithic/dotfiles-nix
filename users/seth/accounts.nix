{ pkgs, config, ... }: {
  accounts = {
    email = {
      maildirBasePath = "${config.home.homeDirectory}/.mail";
      accounts = {
        gmail = {
          primary = false;

          realName = "Seth Messer";
          address = "seth.messer@gmail.com";

          userName = "seth.messer@gmail.com";
          passwordCommand = "op read op://Shared/aw6tbw4va5bpnippcdqh2mkfq4/Passwd";

          folders = { inbox = "INBOX"; sent = "\[Gmail\]/Sent\ Mail"; trash = "\[Gmail\]/Trash"; };
          flavor = "gmail.com";

          aerc.enable = true;
          himalaya.enable = true;
        };

        fastmail = {
          primary = true;

          realName = "Seth Messer";
          address = "seth@megalithic.io";

          userName = "seth.messer@fastmail.com";
          passwordCommand = "op read op://Shared/Fastmail/apps/tui";
          imap = {
            host = "imap.fastmail.com";
            tls.enable = true;
          };

          aerc.enable = true;
          himalaya.enable = true;
          notmuch.enable = true;
          mbsync = {
            extraConfig.channel = {
              CopyArrivalDate = "yes";
            };
            enable = true;
            create = "both";
            expunge = "both";
            remove = "both";
            # expunge = "none";
            # remove = "none";
          };
        };

        nibuild = {
          primary = false;

          address = "seth@nibuild.com";
          realName = "Seth Messer";

          userName = "seth@nibuild.com";
          passwordCommand = "op read op://Shared/nibuild/password";

          imap = {
            host = "mail.nibuild.com";
            tls.enable = true;
          };

          aerc.enable = true;
          himalaya.enable = true;
          notmuch.enable = true;
          mbsync = {
            extraConfig.channel = {
              CopyArrivalDate = "yes";
            };
            enable = true;
            create = "both";
            expunge = "both";
            remove = "both";
            # expunge = "none";
            # remove = "none";
          };
        };
      };
    };
  };
}
