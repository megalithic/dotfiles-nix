{ config, lib, pkgs, ... }:

{
  programs.aerc = {
    enable = true;

    extraConfig = {
      general = {
        default-save-path = "~/Downloads";
        log-file = "~/tmp/.aerc.log";
        log-level = "debug";
      };

      ui = {
        index-columns = "star:1,name<15%,reply:1,subject,labels>=,size>=,date>=";
        column-star = "{{if .IsFlagged}}★{{end}}";
        column-name = ''{{if eq .Role "sent" }}To: {{.To | names | join ", "}}{{ \
        	else }}{{.From | names | join ", "}}{{ end }}'';
        column-reply = "{{if .IsReplied}}{{end}}";
        column-subject = ''{{.Style .ThreadPrefix "thread"}}{{ \
        	.StyleSwitch .Subject (case `^(\[[\w-]+\]\s*)?\[(RFC )?PATCH` "patch")}}'';
        column-labels = ''{{.StyleMap .Labels \
        	(exclude .Folder) \
        	(exclude "Important") \
        	(default "thread") \
        	| join " "}}'';
        column-size = "{{if .HasAttachment}}📎 {{end}}{{humanReadable .Size}}";
        column-date = "{{.DateAutoFormat .Date.Local}}";
        timestamp-format = "2006 Jan 02";
        this-day-time-format = "15:04";
        this-week-time-format = "Jan 02";
        this-year-time-format = "Jan 02";
        message-view-timestamp-format = "2006 Jan 02, 15:04 GMT-0700";
        sidebar-width = 27;
        mouse-enabled = false;
        new-message-bell = false;
        dirlist-left = ''{{switch .Role \
        	(case "inbox" "") \
        	(case "drafts" "") \
        	(case "sent" "") \
        	(case "trash" "") \
        	(case "junk" "") \
        	(case "archive" "") \
        	(case "all" "") \
        	(default "")}} {{.Folder}}'';
        dirlist-right = "{{if .Unread}}{{humanReadable .Unread}}{{end}}";
        dirlist-tree = true;
        dirlist-collapse = 2;
        next-message-on-delete = false;
        border-char-vertical = " ";
        border-char-horizontal = " ";
        styleset-name = "pink";
        completion-delay = "200ms";
        completion-min-chars = "manual";
        icon-attachment = "📎";
        threading-enabled = true;
        force-client-threads = true;
        client-threads-delay = "150ms";
        sort-thread-siblings = false;
        threading-by-subject = true;
        tab-title-account = ''{{.Account}}{{if .Unread "INBOX"}} ({{.Unread "INBOX"}}){{else if .Unread "Inbox"}} ({{.Unread "Inbox"}}){{end}}'';
        tab-title-composer = "{{if .To}}to:{{index (.To | shortmboxes) 0}} {{end}}{{.SubjectBase}}";
        msglist-scroll-offset = 5;
      };

      "ui:account=work" = {
        styleset-name = "blue";
      };

      statusline = {
        status-columns = "left<*,center:=,right>*";
        column-left = "[{{.Account}}] {{.StatusInfo}}";
        column-center = "{{.PendingKeys}}";
        column-right = ''{{.TrayInfo}} | {{.Style cwd "cyan"}}'';
      };

      viewer = {
        pager = "less -Rc -+S --wordwrap";
        alternatives = "text/plain,text/html";
        header-layout = "From,To,Cc,Bcc,Date,Subject,Labels";
        parse-http-links = true;
      };

      compose = {
        editor = "nvim +/^$ +nohl ++1";
        header-layout = "To,From,Cc,Bcc,Subject";
        reply-to-self = false;
        no-attachment-warning = "^[^>]*attach(ed|ment)";
        file-picker-cmd = "fd -t file . ~ | fzf";
      };

      multipart-converters = {
        "text/html" = "pandoc -f gfm -t html --self-contained";
      };

      filters = {
        "text/html" = "! html-unsafe";
        "text/plain" = "! wrap -w 88 | colorize | delta --color-only --diff-highlight";
        "text/calendar" = "calendar | colorize";
        "text/*" = ''test -n "$AERC_FILENAME" && bat -fP --file-name="$AERC_FILENAME" --style=plain || colorize'';
        "application/pgp-keys" = "gpg";
        "application/x-*" = ''bat -fP --file-name="$AERC_FILENAME" --style=auto'';
        "message/delivery-status" = "wrap | colorize";
        "message/rfc822" = "wrap | colorize";
        ".headers" = "colorize";
      };

      openers = {
        "x-scheme-handler/http*" = "brave-browser";
      };

      hooks = {};
    };
  };
}
