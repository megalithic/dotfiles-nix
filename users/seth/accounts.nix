{
  pkgs,
  config,
  ...
}: let
  inherit (pkgs) lib;
  ca-bundle_path = "${pkgs.cacert}/etc/ssl/certs/";
  ca-bundle_crt = "${ca-bundle_path}/ca-bundle.crt";
in {
  # TODO: lookup attrsets for git/jj/etc account info to share
  # TODO: use go/imapnotify? https://github.com/apeyroux/home.nix/blob/master/nix/gmail.nix

  email = {
    certificatesFile = ca-bundle_crt;
    maildirBasePath = "${config.home.homeDirectory}/.mail";
    accounts = {
      fastmail = {
        primary = true;

        realName = "Seth Messer";
        address = "seth@megalithic.io";

        userName = "sethmesser@fastmail.com";
        passwordCommand = "op read op://Shared/Fastmail/apps/tui";

        flavor = "fastmail.com";
        aliases = [
          "seth@megalithic.io"
          "noreply@megalithic.io"
        ];

        signature = {
          text = ''
            Regards,
            Seth Messer
            seth@megalithic.io
          '';

          showSignature = "append";
        };
        aerc.enable = true;
        thunderbird.enable = true;
        himalaya = {
          enable = true;
          # Don't forget to run `himalaya account sync` first!
          settings.sync = {
            enable = true;
          };
        };
        notmuch.enable = true;
        mbsync = {
          extraConfig.channel = {
            CopyArrivalDate = "yes";
          };
          enable = true;
          create = "both";
          expunge = "both";
          remove = "both";
        };
        # search = {
        #   maildir.path = "search";
        #   realName = "Search Index";
        #   address = "search@local";
        #   aerc.enable = true;
        #   aerc.extraAccounts = {
        #     source = "maildir://~/mail/search";
        #   };
        #   aerc.extraConfig = {
        #     ui = {
        #       index-columns = "flags>4,date<*,to<30,name<30,subject<*";
        #       column-to = "{{(index .To 0).Address}}";
        #     };
        #   };
        # };
      };

      gmail = {
        primary = false;

        realName = "Seth Messer";
        address = "seth.messer@gmail.com";

        userName = "seth.messer@gmail.com";
        passwordCommand = "op read op://Shared/aw6tbw4va5bpnippcdqh2mkfq4/tui";

        folders = {
          inbox = "Inbox";
          # archive = "\[Gmail\]/All\\ Mail";
          sent = "\[Gmail\]/Sent\\ Mail";
          trash = "\[Gmail\]/Trash";
          # spam = "\[Gmail\]/Spam";
          drafts = "\[Gmail\]/Drafts";
        };
        flavor = "gmail.com";

        signature = {
          text = ''
            Regards,
            Seth Messer
            seth.messer@gmail.com
          '';

          showSignature = "append";
        };
        thunderbird.enable = true;
        aerc.enable = true;
        himalaya = {
          enable = true;
          # Don't forget to run `himalaya account sync` first!
          settings.sync = {
            enable = true;
          };
        };
        notmuch.enable = true;
        mbsync = {
          extraConfig.channel = {
            CopyArrivalDate = "yes";
          };
          enable = true;
          create = "both";
          expunge = "both";
          remove = "both";
        };
        # imapnotify = {
        #   enable = true;
        #   boxes = ["Inbox"];
        #   onNotify = "${lib.getExe config.my.services.mbsync.package} -a";
        #   onNotifyPost = ''osascript -e "display notification \"New mail arrived\" with title \"email\""'';
        # };
        # search = {
        #   maildir.path = "search";
        #   realName = "Search Index";
        #   address = "search@local";
        #   aerc.enable = true;
        #   aerc.extraAccounts = {
        #     source = "maildir://~/mail/search";
        #   };
        #   aerc.extraConfig = {
        #     ui = {
        #       index-columns = "flags>4,date<*,to<30,name<30,subject<*";
        #       column-to = "{{(index .To 0).Address}}";
        #     };
        #   };
        # };
      };

      nibuild = {
        primary = false;

        address = "seth@nibuild.com";
        realName = "Seth Messer";

        userName = "seth@nibuild.com";
        passwordCommand = "op read op://Shared/xk72bkenziy7wxjmxkpxze2nsi/password";
        flavor = "plain";
        aliases = ["smesser@nibuild.com"];

        imap = {
          host = "mail.nibuild.com";
          tls.enable = true;
          port = 993;
        };
        smtp = {
          host = "smtp.nibuild.com";
          tls.enable = true;
          port = 465;
        };

        signature = {
          text = ''
            Regards,
            Seth Messer
            seth@nibuild.com
          '';

          showSignature = "append";
        };

        thunderbird.enable = true;
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
        };
      };
    };
  };
}
