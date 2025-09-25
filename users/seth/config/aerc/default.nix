# REF: https://github.com/jeffa5/nix-home/blob/main/home/modules/aerc.nix
{ pkgs, config, ... }:

let
  aerc-filters = "${pkgs.aerc}/libexec/aerc/filters";
in
{
  enable = true;
  extraAccounts = {
    gmail = {
      from = "<noreply@gmail.com>";

      source = "notmuch://${config.accounts.email.maildirBasePath}";

      maildir-store = config.accounts.email.maildirBasePath;
      maildir-account-path = "gmail";
      multi-file-strategy = "act-dir";
      default = "Inbox";

      check-mail-cmd = "mbsync gmail && notmuch new";
      check-mail = "2m";
      check-mail-timout = "30s";
      postpone = "[Gmail]/Drafts";
      cache-headers = true;
    };

    fastmail = {
      from = "<noreply@megalithic.io>";

      source = "notmuch://${config.accounts.email.maildirBasePath}";

      maildir-store = config.accounts.email.maildirBasePath;
      maildir-account-path = "fastmail";
      multi-file-strategy = "act-dir";
      default = "Inbox";

      check-mail-cmd = "mbsync fastmail && notmuch new";
      check-mail = "2m";
      check-mail-timout = "30s";
      cache-headers = true;
    };

    nibuild = {
      from = "<noreply@nibuild.com>";

      source = "notmuch://${config.accounts.email.maildirBasePath}";

      maildir-store = config.accounts.email.maildirBasePath;
      maildir-account-path = "nibuild";
      multi-file-strategy = "act-dir";
      default = "Inbox";

      check-mail-cmd = "mbsync nibuild && notmuch new";
      check-mail = "2m";
      check-mail-timout = "30s";
      cache-headers = true;
    };
  };

  extraConfig = {
    general = {
      default-save-path = "~/Downloads";
      unsafe-accounts-conf = true;
    };
    viewer = {
      pager = "${pkgs.less}/bin/less -R";
      header-layout = "From,To,Cc,Bc,Date,Subject";
      always-show-mime = true;
    };
    filters = {
      "subject,~^\\[PATCH" = "${aerc-filters}/hldiff";
      "text/plain" = "${pkgs.aerc}/libexec/aerc/filters/colorize";
      "text/calendar" = "${pkgs.aerc}/libexec/aerc/filters/calendar";
      "text/html" = "! ${pkgs.aerc}/libexec/aerc/filters/html";
      "message/delivery-status" = "${pkgs.aerc}/libexec/aerc/filters/colorize";
      "message/rfc822" = "${pkgs.aerc}/libexec/aerc/filters/colorize";
      ".headers" = "${pkgs.aerc}/libexec/aerc/filters/colorize";
    };
    compose = {
      # address-book-cmd = "khard email --remove-first-line --parsable '%s'";
      edit-headers = true;
      empty-subject-warning = true;
      no-attachment-warning = "^[^>]*attach(ed|ment)";
    };
    ui = {
      threading-enabled = true;
      show-thread-context = true;
      styleset-name = "nord";
      border-char-vertical = "┃";
      dirlist-tree = true;
      auto-mark-read = false;
      fuzzy-complete = true;
      sidebar-width = 30;
      mouse-enabled = true;
      sort = "-r date";
      timestamp-format = "Jan 02, 2006";
      this-day-time-format = "15:04";
      tab-title-account = "{{.Account}} {{if .Unread \"Inbox\"}}({{.Unread \"Inbox\"}}){{end}}";
      dirlist-left = "{{compactDir .Folder}}";
      # REF: https://github.com/ash-project/igniter/blob/main/installer/lib/loading.ex#L6
      spinner = "⠁,⠂,⠄,⡀,⡁,⡂,⡄,⡅,⡇,⡏,⡗,⡧,⣇,⣏,⣗,⣧,⣯,⣷,⣿,⢿,⣻,⢻,⢽,⣹,⢹,⢸,⠸,⢘,⠘,⠨,⢈,⠈,⠐,⠠,⢀";
      # default:
      # spinner = "[ ⡿ ],[ ⣟ ],[ ⣯ ],[ ⣷ ],[ ⣾ ],[ ⣽ ],[ ⣻ ],[ ⢿ ]";

      ## This broke in wezterm + tmux when swapping windows
      # icon-new = "✨";
      # icon-attachment = "📎";
      # icon-old = "🕰️";
      # icon-replied = "📝";
      # icon-flagged = "🚩";
      # icon-deleted = "🗑️";
    };

    "ui:account=nibuild" = {
      sort = "-r date";
    };
    # "ui:account=All" = {
    #   sort = "-r date";
    # };
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
      "g" = ":select 0<Enter>";
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
