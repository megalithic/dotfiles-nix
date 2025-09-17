# { pkgs
# , lib
# , inputs
# , ...
# }:


{ inputs
, currentSystem
, currentSystemName
, currentSystemUser
, currentSystemVersion
, ...
}:

{ config
, lib
, pkgs
, system
, ...
}:

let
  # For our MANPAGER env var
  # https://github.com/sharkdp/bat/issues/1145
  manpager = pkgs.writeShellScriptBin "manpager" (if pkgs.stdenv.isDarwin then ''
    sh -c 'col -bx | bat -l man -p'
  '' else ''
    cat "$1" | col -bx | bat --language man --style plain
  '');

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

  accounts.email.accounts.gmail = {
    primary = true;
    aerc.enable = true;
    himalaya.enable = true;
    address = "seth.messer@gmail.com";
    userName = "seth.messer@gmail.com";
    realName = "Seth Messer";
    folders = { inbox = "INBOX"; sent = "\[Gmail\]/Sent\ Mail"; trash = "\[Gmail\]/Trash"; };
    passwordCommand = "op read op://Shared/aw6tbw4va5bpnippcdqh2mkfq4/password";
    flavor = "gmail.com";
  };

  programs = {
    aerc = {
      enable = true;
      extraConfig = {
        general.unsafe-accounts-conf = true;
        viewer = { pager = "${pkgs.less}/bin/less -R"; };
        filters = {
          "text/plain" = "${pkgs.aerc}/libexec/aerc/filters/colorize";
          "text/calendar" = "${pkgs.aerc}/libexec/aerc/filters/calendar";
          "text/html" = "${pkgs.aerc}/libexec/aerc/filters/html";
          "message/delivery-status" = "${pkgs.aerc}/libexec/aerc/filters/colorize";
          "message/rfc822" = "${pkgs.aerc}/libexec/aerc/filters/colorize";
        };
        ui = {
          threading-enabled = true;
          show-thread-context = true;
          styleset-name = "nord";
          border-char-vertical = "┃";
          # REF: https://github.com/ash-project/igniter/blob/main/installer/lib/loading.ex#L6
          spinner = "⠁,⠂,⠄,⡀,⡁,⡂,⡄,⡅,⡇,⡏,⡗,⡧,⣇,⣏,⣗,⣧,⣯,⣷,⣿,⢿,⣻,⢻,⢽,⣹,⢹,⢸,⠸,⢘,⠘,⠨,⢈,⠈,⠐,⠠,⢀";
          # default:
          # spinner = "[ ⡿ ],[ ⣟ ],[ ⣯ ],[ ⣷ ],[ ⣾ ],[ ⣽ ],[ ⣻ ],[ ⢿ ]";
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
      # settings = {
      #   user = {
      #     name = "Seth Messer";
      #     email = "seth@megalithic.io";
      #   };
      #   ui.default-command = "log";
      #   fix.tools.nixfmt = {
      #     command = [ "${lib.getExe pkgs.nixfmt-rfc-style}" "$path" ];
      #     patterns = [ "glob:'**/*.nix'" ];
      #   };
      #   templates.draft_commit_description = ''
      #     concat(
      #       coalesce(description, default_commit_description, "\n"),
      #       surround(
      #         "\nJJ: This commit contains the following changes:\n", "",
      #         indent("JJ:     ", diff.stat(72)),
      #       ),
      #       "\nJJ: ignore-rest\n",
      #       diff.git(),
      #     )
      #   '';
      # };
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
  };

  # services.ollama.enable = true;
}
