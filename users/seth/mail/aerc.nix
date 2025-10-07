# REF: https://github.com/jeffa5/nix-home/blob/main/home/modules/aerc.nix
{
  pkgs,
  config,
  ...
}: let
  aerc-filters = "${pkgs.aerc}/libexec/aerc/filters";
in {
  enable = true;
  stylesets.everforest = builtins.readFile ./stylesets/everforest;
  extraAccounts = {
    combined = {
      from = "<noreply@megalithic.io>";
      source = "notmuch://${config.accounts.email.maildirBasePath}";
      maildir-store = config.accounts.email.maildirBasePath;
      # query-map = pkgs.writeText "querymap" ''
      #   # Unified inbox queries across all accounts
      #   Inbox=path:fastmail/INBOX/** or path:gmail/Inbox/** or path:nibuild/INBOX/**
      #   Sent=path:fastmail/Sent/** or path:"gmail/[Gmail]/Sent\ Mail/**" or path:nibuild/Sent/**
      #   Drafts=path:fastmail/Drafts/** or path:"gmail/[Gmail]/Drafts/**" or path:nibuild/Drafts/**
      #   Archive=path:fastmail/Archive/** or path:"gmail/[Gmail]/Archive/**" or path:nibuild/Archive/**
      #   # Archive=path:fastmail/Archive/** or path:"gmail/[Gmail]/All\ Mail/**" or path:nibuild/Archive/**
      #   Trash=path:fastmail/Trash/** or path:"gmail/[Gmail]/Trash/**" or path:nibuild/Trash/**
      #   Spam=path:fastmail/Spam/** or path:"gmail/[Gmail]/Spam/**" or path:nibuild/Spam/**
      # '';
      query-map = builtins.readFile ./query-map;
      default = "Inbox";

      # check-mail-cmd = ''
      #   #!/bin/sh
      #   #
      #   # MBSYNC=$(pgrep mbsync)
      #   # NOTMUCH=$(pgrep notmuch)
      #   #
      #   # if [ -n "$MBSYNC" -o -n "$NOTMUCH" ]; then
      #   #     echo "Already running one instance of mbsync or notmuch. Exiting..."
      #   #     exit 0
      #   # fi
      #
      #   # Actually delete the emails tagged as deleted
      #   notmuch search --format=text0 --output=files tag:deleted | xargs -0 --no-run-if-empty rm -v
      #
      #   mbsync -a
      #   notmuch new
      # '';

      check-mail-cmd = "notmuch search --format=text0 --output=files tag:deleted | xargs -0 --no-run-if-empty rm -v; mbsync -a && notmuch new";
      # check-mail = "2m";
      # check-mail-timeout = "30s";
      cache-headers = true;
    };

    gmail = {
      from = "<noreply@gmail.com>";

      source = "notmuch://${config.accounts.email.maildirBasePath}";
      maildir-store = config.accounts.email.maildirBasePath;
      maildir-account-path = "gmail";
      multi-file-strategy = "act-dir";
      default = "Inbox";
      # check-mail-cmd = "mbsync gmail && notmuch new";
      # check-mail = "2m";
      # check-mail-timeout = "30s";
      postpone = "[Gmail]/Drafts";
      cache-headers = true;
      folder-map = builtins.readFile ./folder-map;
    };

    fastmail = {
      from = "<noreply@megalithic.io>";

      source = "notmuch://${config.accounts.email.maildirBasePath}";

      maildir-store = config.accounts.email.maildirBasePath;
      maildir-account-path = "fastmail";
      multi-file-strategy = "act-dir";
      default = "Inbox";
      use-labels = true;
      cache-state = true;
      cache-blobs = true;
      use-envelope-from = true;
      # check-mail-cmd = "mbsync fastmail && notmuch new";
      # check-mail = "2m";
      # check-mail-timeout = "30s";
      cache-headers = true;
    };

    nibuild = {
      from = "<noreply@nibuild.com>";

      source = "notmuch://${config.accounts.email.maildirBasePath}";

      maildir-store = config.accounts.email.maildirBasePath;
      maildir-account-path = "nibuild";
      multi-file-strategy = "act-dir";
      default = "Inbox";

      # check-mail-cmd = "mbsync nibuild && notmuch new";
      # check-mail = "2m";
      # check-mail-timeout = "30s";
      cache-headers = true;
    };
  };

  extraConfig = {
    general = {
      default-save-path = "~/Downloads/_email";
      log-file = "~/.cache/aerc/aerc.log";
      unsafe-accounts-conf = true;
    };
    viewer = {
      pager = "${pkgs.less}/bin/less -Rc -+S --wordwrap";
      header-layout = "From,To,Cc,Bcc,Date,Subject,Labels";
      alternatives = "text/plain,text/html";
      always-show-mime = true;
      parse-http-links = true;
    };
    filters = {
      "subject,~^\\[PATCH" = "${aerc-filters}/hldiff";
      # "text/plain" = "${pkgs.aerc}/libexec/aerc/filters/colorize";

      "text/plain" = "! wrap -w 88 | ${pkgs.aerc}/libexec/aerc/filters/colorize | ${pkgs.delta}/bin/delta --color-only --diff-highlight";
      "text/calendar" = "${pkgs.aerc}/libexec/aerc/filters/calendar | ${pkgs.aerc}/libexec/aerc/filters/colorize";
      "text/html" = "! ${pkgs.aerc}/libexec/aerc/filters/html";
      "text/*" = ''test -n "$AERC_FILENAME" && ${pkgs.bat}/bin/bat -fP --file-name="$AERC_FILENAME" --style=plain || ${pkgs.aerc}/libexec/aerc/filters/colorize'';
      "application/pgp-keys" = "gpg";
      "application/x-*" = ''${pkgs.bat}/bin/bat -fP --file-name="$AERC_FILENAME" --style=auto'';
      "message/delivery-status" = "wrap | ${pkgs.aerc}/libexec/aerc/filters/colorize";
      "message/rfc822" = "wrap | ${pkgs.aerc}/libexec/aerc/filters/colorize";
      ".headers" = "${pkgs.aerc}/libexec/aerc/filters/colorize";
    };
    multipart-converters = {
      "text/html" = "pandoc -f gfm -t html --self-contained";
    };
    compose = {
      # address-book-cmd = "khard email --remove-first-line --parsable '%s'";
      # editor = "${pkgs.nvim-nightly}/bin/nvim-nightly +/^$ +nohl ++1";
      editor = "$EDITOR +/^$ +nohl ++1";
      header-layout = "To,From,Cc,Bcc,Subject";
      edit-headers = true;
      reply-to-self = false;
      empty-subject-warning = true;
      no-attachment-warning = "^[^>]*attach(ed|ment)";
      file-picker-cmd = "${pkgs.fd}/bin/fd -t file . ~ | ${pkgs.fzf}/bin/fzf";
    };

    ui = {
      threading-enabled = true;
      show-thread-context = true;
      sort-thread-siblings = false;
      threading-by-subject = true;
      #
      # Thread prefix customization:
      #
      # Customize the thread prefix appearance by selecting the arrow head.
      #
      # Default: ">"
      #thread-prefix-tip = ">"
      thread-prefix-tip = "";

      #
      # Customize the thread prefix appearance by selecting the arrow indentation.
      #
      # Default: " "
      thread-prefix-indent = "";

      #
      # Customize the thread prefix appearance by selecting the vertical extension of
      # the arrow.
      #
      # Default: "│"
      thread-prefix-stem = "│";

      #
      # Customize the thread prefix appearance by selecting the horizontal extension
      # of the arrow.
      #
      # Default: ""
      thread-prefix-limb = "─";

      #
      # Customize the thread prefix appearance by selecting the folded thread
      # indicator.
      #
      # Default: "+"
      thread-prefix-folded = "+";

      #
      # Customize the thread prefix appearance by selecting the unfolded thread
      # indicator.
      #
      # Default: ""
      thread-prefix-unfolded = "";

      #
      # Customize the thread prefix appearance by selecting the first child connector.
      #
      # Default: ""
      thread-prefix-first-child = "┬";

      #
      # Customize the thread prefix appearance by selecting the connector used if
      # the message has siblings.
      #
      # Default: "├─"
      thread-prefix-has-siblings = "├";

      #
      # Customize the thread prefix appearance by selecting the connector used if the
      # message has no parents and no children.
      #
      # Default: ""
      thread-prefix-lone = "";

      #
      # Customize the thread prefix appearance by selecting the connector used if the
      # message has no parents and has children.
      #
      # Default: ""
      thread-prefix-orphan = "┌";

      #
      # Customize the thread prefix appearance by selecting the connector for the last
      # sibling.
      #
      # Default: "└─"
      thread-prefix-last-sibling = "╰";

      #
      # Customize the reversed thread prefix appearance by selecting the connector for
      # the last sibling.
      #
      # Default: "┌─"
      #thread-prefix-last-sibling-reverse = "┌─"

      #
      # Customize the thread prefix appearance by selecting the connector for dummy
      # thread.
      #
      # Default: "┬─"
      thread-prefix-dummy = "┬";

      #
      # Customize the reversed thread prefix appearance by selecting the connector for
      # dummy thread.
      #
      # Default: "┴─"
      #thread-prefix-dummy-reverse = "┴─"

      #
      # Customize the reversed thread prefix appearance by selecting the first child
      # connector.
      #
      # Default: ""
      #thread-prefix-first-child-reverse = ""

      #
      # Customize the reversed thread prefix appearance by selecting the connector
      # used if the message has no parents and has children.
      #
      # Default: ""
      #thread-prefix-orphan-reverse = ""
      styleset-name = "everforest";
      border-char-vertical = "┃";
      # border-char-vertical = "│";
      # border-char-horizontal = "─";
      dirlist-tree = true;
      auto-mark-read = false;
      fuzzy-complete = true;
      sidebar-width = 35;
      mouse-enabled = true;
      sort = "-r arrival";
      message-view-timestamp-format = "2006 Jan 02, 15:04 GMT-0700";
      index-columns = "star:1,name<15%,reply:1,subject,labels>=,size>=,date>=";
      column-star = "{{if .IsFlagged}}  {{end}}";
      column-name = ''        {{if eq .Role "sent" }}To: {{.To | names | join ", "}}{{ \
                	else }}{{.From | names | join ", "}}{{ end }}'';
      column-reply = "{{if .IsReplied}}{{end}}";
      column-subject = ''        {{.Style .ThreadPrefix "thread"}}{{ \
                	.StyleSwitch .Subject (case `^(\[[\w-]+\]\s*)?\[(RFC )?PATCH` "patch")}}'';
      column-labels = ''        {{.StyleMap .Labels \
                	(exclude .Folder) \
                	(exclude "Important") \
                	(default "thread") \
                	| join " "}}'';
      column-size = "{{if .HasAttachment}}  {{end}}{{humanReadable .Size}}";
      column-date = "{{.DateAutoFormat .Date.Local}}";
      timestamp-format = "Jan 02, 2006";
      this-day-time-format = "15:04";
      # tab-title-account = "{{.Account}} {{if .Unread \"Inbox\"}}({{.Unread \"Inbox\"}}){{end}}";
      tab-title-account = "{{.Account}}/{{.Folder}} {{if .Exists .Folder}}[  {{if .Unread .Folder}}{{.Unread .Folder | humanReadable}}{{else}}0{{end}}/{{.Exists .Folder| humanReadable}}]{{end}}";
      tab-title-composer = ''To:{{(.To | shortmboxes) | join ","}}{{ if .Cc }}|Cc:{{(.Cc | shortmboxes) | join ","}}{{end}}|{{.Subject}}'';
      # dirlist-left = "{{compactDir .Folder}}";
      dirlist-left = ''
        {{switch .Folder \
          (case "Inbox" "󰚇 ") \
          (case "INBOX" "󰚇 ") \
          (case "Archive" "󰀼 ") \
          (case "Drafts" "󰙏 ") \
          (case "Spam" "󱚝 ") \
          (case "Sent" "󰑚 ") \
          (case "Trash" "󰩺 ") \
        (default "󰓼 ")}} {{.Folder}}
      '';
      # REF: https://github.com/ash-project/igniter/blob/main/installer/lib/loading.ex#L6
      spinner = "⠁,⠂,⠄,⡀,⡁,⡂,⡄,⡅,⡇,⡏,⡗,⡧,⣇,⣏,⣗,⣧,⣯,⣷,⣿,⢿,⣻,⢻,⢽,⣹,⢹,⢸,⠸,⢘,⠘,⠨,⢈,⠈,⠐,⠠,⢀";
      # default:
      # spinner = "[ ⡿ ],[ ⣟ ],[ ⣯ ],[ ⣷ ],[ ⣾ ],[ ⣽ ],[ ⣻ ],[ ⢿ ]";

      icon-new = "  ";
      icon-attachment = "  ";
      icon-old = " 󰔟 ";
      icon-replied = "  ";
      icon-flagged = "  ";
      icon-deleted = "  ";

      icon-unencrypted = "";
      icon-encrypted = "";
      icon-signed = "";
      icon-signed-encrypted = "";
      # icon-new = "";
      # icon-old = "";
      icon-marked = "✔";
      icon-unknown = "󱎘";
      icon-invalid = "⚠";
      # icon-attachment = "";
      # icon-replied = "⮪";
      icon-forwarded = "⮫";
      # icon-flagged = "";
      icon-draft = "󰙏";
      icon-inbox = "";
      # icon-deleted = "";
      # icon-spam=
      # icon-sent=
      # icon-calendar=
      # icon-list=
    };

    "ui:account=combined" = {
      sort = "-r date";
    };

    statusline = {
      status-columns = "left<*,center:=,right>*";
      column-left = "[{{.Account}}] {{.StatusInfo}}";
      column-center = "{{.PendingKeys}}";
      column-right = ''{{.TrayInfo}} | {{.Style cwd "cyan"}}'';
    };
  };

  extraBinds = {
    # Custom (taken from @tmiller to start)

    view = {
      Y = ":archive flat<enter>";
      D = ":mv Trash<enter>";
    };

    "view:folder=Trash" = {
      D = ":delete<enter>";
    };

    messages = {
      y = ":archive flat<enter>";
      Y = ":unmark -a<enter>:mark -T<enter>:archive flat<enter>";
      d = ":mv Trash<enter>";
      D = ":unmark -a<enter>:mark -T<enter>:move Trash<enter>";
    };

    "messages:folder=Trash" = {
      d = ":choose -o y 'Really delete this message' delete-message<enter>";
      D = ":delete<enter>";
    };

    # Defaults

    global = {
      "<C-p>" = ":prev-tab<Enter>";
      "<C-PgUp>" = ":prev-tab<Enter>";
      "<C-n>" = ":next-tab<Enter>";
      "<C-PgDn>" = ":next-tab<Enter>";
      "\\[t" = ":prev-tab<Enter>";
      "\\]t" = ":next-tab<Enter>";
      "<C-t>" = ":term<Enter>";
      "?" = ":help keys<Enter>";
      "<C-c>" = ":prompt 'Quit? ' quit<Enter>";
      "<C-q>" = ":prompt 'Quit? ' quit<Enter>";
      "<C-z>" = ":suspend<Enter>";
      "<C-r>" = ":check-mail<Enter>";
    };

    "messages" = {
      "q" = ":prompt 'Quit? ' quit<Enter>";

      "j" = ":next<Enter>";
      "<Down>" = ":next<Enter>";
      "<C-d>" = ":next 50%<Enter>";
      "<C-f>" = ":next 100%<Enter>";
      "<PgDn>" = ":next 100%<Enter>";

      "k" = ":prev<Enter>";
      "<Up>" = ":prev<Enter>";
      "<C-u>" = ":prev 50%<Enter>";
      "<C-b>" = ":prev 100%<Enter>";
      "<PgUp>" = ":prev 100%<Enter>";
      "gg" = ":select 0<Enter>";
      "G" = ":select -1<Enter>";

      "J" = ":next-folder<Enter>";
      "<C-Down>" = ":next-folder<Enter>";
      "K" = ":prev-folder<Enter>";
      "<C-Up>" = ":prev-folder<Enter>";
      "H" = ":collapse-folder<Enter>";
      "<C-Left>" = ":collapse-folder<Enter>";
      "L" = ":expand-folder<Enter>";
      "<C-Right>" = ":expand-folder<Enter>";

      "v" = ":mark -t<Enter>";
      "<Space>" = ":mark -t<Enter>:next<Enter>";
      "V" = ":mark -v<Enter>";

      "T" = ":toggle-threads<Enter>";
      "zc" = ":fold<Enter>";
      "zo" = ":unfold<Enter>";
      "za" = ":fold -t<Enter>";
      "zM" = ":fold -a<Enter>";
      "zR" = ":unfold -a<Enter>";
      "<tab>" = ":fold -t<Enter>";

      "zz" = ":align center<Enter>";
      "zt" = ":align top<Enter>";
      "zb" = ":align bottom<Enter>";

      "<Enter>" = ":view<Enter>";
      # "d" = ":choose -o y 'Really delete this message' delete-message<Enter>";
      # "D" = ":delete<Enter>";

      "x" = ":move Trash<Enter>";
      "e" = ":move Archive<Enter>";
      "a" = ":archive flat<Enter>";
      "A" = ":unmark -a<Enter>:mark -T<Enter>:archive flat<Enter>";

      "c" = ":compose<Enter>";
      # "C" = ":compose<Enter>";
      "m" = ":compose<Enter>";

      "b" = ":bounce<space>";

      "rr" = ":reply -a<Enter>";
      "rq" = ":reply -aq<Enter>";
      "Rr" = ":reply<Enter>";
      "Rq" = ":reply -q<Enter>";

      # "c" = ":cf<space>";
      "$" = ":term<space>";
      "!" = ":term<space>";
      "|" = ":pipe<space>";

      "/" = ":search<space>";
      "\\" = ":filter<space>";
      "n" = ":next-result<Enter>";
      "N" = ":prev-result<Enter>";
      "<Esc>" = ":clear<Enter>";

      # "s" = ":split<Enter>";
      # "S" = ":vsplit<Enter>";

      "pl" = ":patch list<Enter>";
      "pa" = ":patch apply <Tab>";
      "pd" = ":patch drop <Tab>";
      "pb" = ":patch rebase<Enter>";
      "pt" = ":patch term<Enter>";
      "ps" = ":patch switch <Tab>";
    };
    "messages:folder=Drafts" = {
      "<Enter>" = ":recall<Enter>";
    };
    "view" = {
      "/" = ":toggle-key-passthrough<Enter>/";
      "q" = ":close<Enter>";
      "x" = ":move Trash<Enter>";
      "e" = ":move Archive<Enter>";
      "O" = ":open<Enter>";
      "o" = ":open<Enter>";
      "S" = ":save<space>";
      "|" = ":pipe<space>";
      # "D" = ":delete<Enter>";
      "A" = ":archive flat<Enter>";

      "<C-l>" = ":open-link <space>";

      "f" = ":forward<Enter>";
      "rr" = ":reply -a<Enter>";
      "rq" = ":reply -aq<Enter>";
      "Rr" = ":reply<Enter>";
      "Rq" = ":reply -q<Enter>";

      "H" = ":toggle-headers<Enter>";
      "<C-k>" = ":prev-part<Enter>";
      "<C-Up>" = ":prev-part<Enter>";
      "<C-j>" = ":next-part<Enter>";
      "<C-Down>" = ":next-part<Enter>";
      "J" = ":next<Enter>";
      "<C-Right>" = ":next<Enter>";
      "K" = ":prev<Enter>";
      "<C-Left>" = ":prev<Enter>";
    };
    "view::passthrough" = {
      "$noinherit" = "true";
      "$ex" = "<C-x>";
      "<Esc>" = ":toggle-key-passthrough<Enter>";
    };
    "compose" = {
      "$noinherit" = "true";
      "$ex" = "<C-x>";
      "$complete" = "<C-o>";
      "<C-k>" = ":prev-field<Enter>";
      "<C-Up>" = ":prev-field<Enter>";
      "<C-j>" = ":next-field<Enter>";
      "<C-Down>" = ":next-field<Enter>";
      "<A-p>" = ":switch-account -p<Enter>";
      "<C-Left>" = ":switch-account -p<Enter>";
      "<A-n>" = ":switch-account -n<Enter>";
      "<C-Right>" = ":switch-account -n<Enter>";
      "<tab>" = ":next-field<Enter>";
      "<backtab>" = ":prev-field<Enter>";
      "<C-p>" = ":prev-tab<Enter>";
      "<C-PgUp>" = ":prev-tab<Enter>";
      "<C-n>" = ":next-tab<Enter>";
      "<C-PgDn>" = ":next-tab<Enter>";
    };
    "compose::editor" = {
      "$noinherit" = "true";
      "$ex" = "<C-x>";
      "<C-k>" = ":prev-field<Enter>";
      "<C-Up>" = ":prev-field<Enter>";
      "<C-j>" = ":next-field<Enter>";
      "<C-Down>" = ":next-field<Enter>";
      "<C-p>" = ":prev-tab<Enter>";
      "<C-PgUp>" = ":prev-tab<Enter>";
      "<C-n>" = ":next-tab<Enter>";
      "<C-PgDn>" = ":next-tab<Enter>";
    };
    "compose::review" = {
      "y" = ":send<Enter>";
      "n" = ":abort<Enter>";
      "v" = ":preview<Enter>";
      "p" = ":postpone<Enter>";
      "q" = ":choose -o d discard abort -o p postpone postpone<Enter>";
      "e" = ":edit<Enter>";
      "a" = ":attach<space>";
      "d" = ":detach<space>";
    };
    "terminal" = {
      "$noinherit" = "true";
      "$ex" = "<C-x>";

      "<C-p>" = ":prev-tab<Enter>";
      "<C-n>" = ":next-tab<Enter>";
      "<C-PgUp>" = ":prev-tab<Enter>";
      "<C-PgDn>" = ":next-tab<Enter>";
    };
  };
}
