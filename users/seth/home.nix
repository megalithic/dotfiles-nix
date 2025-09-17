# { pkgs
# , lib
# , inputs
# , ...
# }:

#
{ inputs
, overlays
, arch
, hostname
, username
, version
, ...
}:

{ config
, inputs
, lib
, pkgs
, ...
}:

let
  # For our MANPAGER env var
  # https://github.com/sharkdp/bat/issues/1145
  # manpager = pkgs.writeShellScriptBin "manpager" (if pkgs.stdenv.isDarwin then ''
  #   sh -c 'col -bx | bat -l man -p'
  # '' else ''
  #   cat "$1" | col -bx | bat --language man --style plain
  # '');

  manpager = pkgs.writeShellScriptBin "manpager" ''
    sh -c 'col -bx | bat -l man -p'
  '';


  lang = "en_US.UTF-8";
in

{
  imports = [
    ./packages.nix
    #   ./git.nix
    #   ./helix.nix
    #   ./himalaya.nix
    #   ./nvim.nix
    #   ./starship.nix
    #   ./tmux.nix
  ];

  home = {
    stateVersion = "25.05"; # Please read the comment before changing.

    # The home.packages option allows you to install Nix packages into your
    # environment.
    packages = with pkgs; [
      amber
      unstable.claude-code
      unstable.devenv
      gh
      gum
      fd
      harper
      lua-language-server
      markdown-oxide
      nixd
      nixfmt-rfc-style
      ai-tools.opencode
      ripgrep
      sd
      sesh
    ];


    file = {
      # create our `~/code` directory
      "code/.keep" = { text = ""; };
      #
      # ".config/starship.toml" = {
      #   recursive = true;
      #   source = ./config/starship.toml;
      # };
      #
      # ".config/surfingkeys/config.js" = {
      #   recursive = true;
      #   source = ./config/surfingkeys/config.js;
      # };
    };

    sessionVariables = {
      LANG = "${lang}";
      LC_CTYPE = "${lang}";
      LC_ALL = "${lang}";
      EDITOR = "nvim";
      PAGER = "less -FirSwX";
      MANPAGER = "${manpager}/bin/manpager";
      # ANTHROPIC_API_KEY = "op://Shared/Claude/credential";
      CLAUDE_CODE_OAUTH_TOKEN = "op://Shared/megaenv/CLAUDE_CODE_OAUTH_TOKEN";
    };
  };

  xdg.enable = true;

  xdg.configFile."hammerspoon" = lib.mkIf pkgs.stdenv.isDarwin {
    source = config/hammerspoon;
    recursive = true;
  };

  xdg.configFile."kanata" = lib.mkIf pkgs.stdenv.isDarwin {
    source = config/kanata;
    recursive = true;
  };

  xdg.configFile."nvim".source = config/nvim;
  xdg.configFile."nvim".recursive = true;

  # xdg.configFile."tmux".source = config/tmux;
  # xdg.configFile."tmux".recursive = true;

  xdg.configFile."ghostty".source = config/ghostty;
  xdg.configFile."ghostty".recursive = true;

  xdg.configFile."opencode".source = config/opencode;
  xdg.configFile."opencode".recursive = true;

  xdg.configFile."jj".source = config/jj;
  xdg.configFile."jj".recursive = true;

  xdg.configFile."zsh".source = config/zsh;
  xdg.configFile."zsh".recursive = true;

  # xdg.configFile."opencode/opencode.json".text = ''
  #   {
  #     "$schema": "https://opencode.ai/config.json",
  #     "provider": {
  #       "ollama": {
  #         "npm": "@ai-sdk/openai-compatible",
  #         "name": "Ollama (local)",
  #         "options": {
  #           "baseURL": "http://localhost:11434/v1"
  #         },
  #         "models": {
  #           "gpt-oss:20b": {
  #             "name": "GPT OSS:20b"
  #           }
  #         }
  #       }
  #     },
  #     "model": "anthropic/claude-sonnet-4-20250514",
  #     "small_model": "anthropic/claude-3-5-haiku-20241022"
  #   }
  # '';
  accounts.email = {
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

  # Configure Hammerspoon only on Darwin systems
  # HT: again, @tmiller
  # REF: https://src.bhamops.com/tom/nix/src/branch/master/modules/homeManager/hammerspoon/default.nix
  # homeModules.hammerspoon = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
  #   enable = true;
  #   enableCli = true;
  #   enableReload = true;
  #   packageBinary = "/opt/homebrew/bin/hs";
  #   initLua = builtins.readFile ./config/hammerspoon/init.lua;
  #   spoons = [
  #     {
  #       owner = "evantravers";
  #       repo = "MoveWindows.spoon";
  #       rev = "0.9.2";
  #       hash = "sha256-Z1lm+2jMh8Ybkgdn3/TLppKtu6/DIcUf1BNShHGnClI=";
  #     }
  #   ];
  # };

  programs = {
    # speed up rebuilds
    # HT: @tmiller
    man.generateCaches = false;

    home-manager.enable = true;
    mbsync.enable = true;
    notmuch.enable = true;

    aerc = {
      enable = true;
      extraAccounts = {
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
          from = "<noreply@megalithic.io>";

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
        viewer = { pager = "${pkgs.less}/bin/less -R"; };
        filters = {
          "text/plain" = "${pkgs.aerc}/libexec/aerc/filters/colorize";
          "text/calendar" = "${pkgs.aerc}/libexec/aerc/filters/calendar";
          "text/html" = "! ${pkgs.aerc}/libexec/aerc/filters/html";
          "message/delivery-status" = "${pkgs.aerc}/libexec/aerc/filters/colorize";
          "message/rfc822" = "${pkgs.aerc}/libexec/aerc/filters/colorize";
          ".headers" = "${pkgs.aerc}/libexec/aerc/filters/colorize";
        };
        ui = {
          threading-enabled = true;
          show-thread-context = true;
          styleset-name = "nord";
          border-char-vertical = "┃";
          fuzzy-complete = true;
          sidebar-width = 30;
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
          "<C-c>" = ":prompt 'Quit?' quit<Enter>";
          "<C-q>" = ":prompt 'Quit?' quit<Enter>";
          "<C-z>" = ":suspend<Enter>";
        };

        "messages" = {
          "q" = ":prompt 'Quit?' quit<Enter>";

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

          "C" = ":compose<Enter>";
          "m" = ":compose<Enter>";

          "b" = ":bounce<space>";

          "rr" = ":reply -a<Enter>";
          "rq" = ":reply -aq<Enter>";
          "Rr" = ":reply<Enter>";
          "Rq" = ":reply -q<Enter>";

          "c" = ":cf<space>";
          "$" = ":term<space>";
          "!" = ":term<space>";
          "|" = ":pipe<space>";

          "/" = ":search<space>";
          "\\" = ":filter<space>";
          "n" = ":next-result<Enter>";
          "N" = ":prev-result<Enter>";
          "<Esc>" = ":clear<Enter>";

          "s" = ":split<Enter>";
          "S" = ":vsplit<Enter>";

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
    };
    himalaya.enable = true;

    fish = {
      enable = true;
      interactiveShellInit = ''
        set fish_greeting # N/A
      '';
      shellAliases = {
        opencode = "op run --no-masking -- opencode";
      };
    };

    direnv = {
      enable = true;
      enableFishIntegration = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
      config = {
        global.warn_timeout = "0";
        global.hide_env_diff = true;
      };
    };

    neovim = {
      enable = true;
      package = inputs.neovim-nightly-overlay.packages.${pkgs.system}.default;
      defaultEditor = true;
      # Use init.lua for standard neovim settings
      # extraLuaConfig = lib.fileContents config/nvim/init.lua;
      # Ensure git and other tools are available to Neovim plugins
      extraPackages = with pkgs; [
        git
        gcc # For treesitter compilation
        gnumake # For various build processes
      ];

      # Wrapper to ensure neovim has access to git
      withNodeJs = true;
      withPython3 = true;

      # Set up wrapper to ensure PATH includes git
      extraConfig = ''
        " Ensure git is in PATH for plugins
        let $PATH = $PATH . ':${pkgs.git}/bin'
      '';
    };


    tmux = {
      enable = true;
      escapeTime = 10;
      prefix = "C-space";
      sensibleOnTop = false;
      # shell = "${pkgs.fish}/bin/fish";
      terminal = "xterm-ghostty";
      extraConfig = lib.fileContents config/tmux/tmux.conf;
      plugins = with pkgs.tmuxPlugins; [
        pain-control
        sessionist
        yank
      ];
    };

    jujutsu = {
      enable = true;
      package = pkgs.unstable.jujutsu;
      settings = {
        user = {
          name = "Seth Messer";
          email = "seth@megalithic.io";
        };
        signing = {
          behavior = "own";
          backend = "gpg";
        };
      };
    };

    nh = {
      enable = true;
      package = pkgs.unstable.nh;
      clean.enable = true;
      flake = ../../.;
    };

    yazi = {
      enable = true;
      enableFishIntegration = true;
      enableZshIntegration = true;
    };

    zoxide = {
      enable = true;
      enableFishIntegration = true;
      enableZshIntegration = true;
    };

    ssh = { matchBlocks."* \"test -z $SSH_TTY\"".identityAgent = "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"; };

    mise = {
      enable = true;
      enableFishIntegration = true;
      enableZshIntegration = true;

      settings = {
        auto_install = true;
      };

      globalConfig = {
        tools = {
          elixir = "1.18.4-otp-27"; # alts: 1.18.4-otp-28
          erlang = "27.3.4.1"; # alts: 28.0.1
          python = "3.13.4";
          rust = "beta";
          node = "lts";
          pnpm = "latest";
          aws-cli = "2";
          claude = "latest";
          gemini-cli = "latest";
        };
      };
    };

    bat.enable = true;

    ripgrep.enable = true;

    jq.enable = true;
    fd.enable = true;
    sd.enable = true;

    # services.ollama.enable = true;
  };
}
