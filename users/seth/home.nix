{ inputs
, currentSystemVersion
, ...
}:

{ pkgs
, lib
, system
, ...
}:

let
  inherit (pkgs.stdenv) isDarwin;
  inherit (pkgs.stdenv) isLinux;

  # For our MANPAGER env var
  # https://github.com/sharkdp/bat/issues/1145
  manpager = pkgs.writeShellScriptBin "manpager" (if isDarwin then ''
    sh -c 'col -bx | bat -l man -p'
  '' else ''
    cat "$1" | col -bx | bat --language man --style plain
  '');

  lang = "en_US.UTF-8";
in
{
  # environment.systemPackages = [ inputs.agenix.packages.${system}.default ];

  imports = [
    ./packages.nix
    #   ./git.nix
    #   ./helix.nix
    #   ./himalaya.nix
    #   ./nvim.nix
    #   ./starship.nix
    #   ./tmux.nix
  ];



  xdg.enable = true;

  xdg.configFile."hammerspoon" = lib.mkIf pkgs.stdenv.isDarwin {
    source = config/hammerspoon;
  };

  xdg.configFile."kanata" = lib.mkIf pkgs.stdenv.isDarwin {
    source = config/kanata;
  };

  xdg.configFile."nvim".source = config/nvim;

  xdg.configFile."tmux".source = config/tmux;

  xdg.configFile."ghostty".source = config/ghostty;

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

  home = {
    # create our `code` directory
    file."code/.keep".text = "";
    # Necessary for home-manager to work with flakes, otherwise it will
    # look for a nixpkgs channel.
    stateVersion =
      if pkgs.stdenv.isDarwin
      then currentSystemVersion
      else system.stateVersion;


    sessionVariables = {
      LANG = "${lang}";
      LC_CTYPE = "${lang}";
      LC_ALL = "${lang}";
      EDITOR = "nvim";
      PAGER = "less -FirSwX";
      MANPAGER = "${manpager}/bin/manpager";
      ANTHROPIC_API_KEY = "op://Shared/Claude/credential";
    };

    file = {
      ".config/starship.toml" = {
        source = ./config/starship.toml;
      };
      ".config/surfingkeys/config.js" = {
        source = ./config/surfingkeys/config.js;
      };
    };
  };

  programs = {
    # Let Home Manager install and manage itself.
    home-manager.enable = true;

    # get nightly
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

    # xdg.configFile."nvim" = {
    #   source = ./config/nvim;
    #   recursive = true;
    # };

    # REF: https://github.com/gbroques/dotfiles/blob/main/fish/.config/fish/config.fish
    fish = {
      enable = true;
      interactiveShellInit = ''
        set fish_greeting # N/A
      '';
      shellAliases = {
        opencode = "op run --no-masking -- opencode";
      };
    };


    chromium = {
      enable = true;
      package = pkgs.unstable.brave-nightly;
      extensions = [
        { id = "cjpalhdlnbpafiamejdnhcphjbkeiagm"; } # ublock origin
      ];
      commandLineArgs = [
        "--disable-features=WebRtcAllowInputVolumeAdjustment"
      ];
    };

    # alts: https://github.com/nmattia/niv?tab=readme-ov-file#getting-started
    nh = {
      enable = true;
      package = pkgs.unstable.nh;
      clean.enable = true;
      flake = ../../.;
    };

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    jujutsu = {
      enable = true;
      package = pkgs.unstable.jujutsu;
      settings = {
        user = {
          name = "Seth Messer";
          email = "seth@megalithic.io";
        };
        ui.default-command = "log";
        fix.tools.nixfmt = {
          command = [ "${lib.getExe pkgs.nixfmt-rfc-style}" "$path" ];
          patterns = [ "glob:'**/*.nix'" ];
        };
        templates.draft_commit_description = ''
          concat(
            coalesce(description, default_commit_description, "\n"),
            surround(
              "\nJJ: This commit contains the following changes:\n", "",
              indent("JJ:     ", diff.stat(72)),
            ),
            "\nJJ: ignore-rest\n",
            diff.git(),
          )
        '';
      };
    };

    tmux = {
      enable = true;
      escapeTime = 10;
      prefix = "C-space";
      sensibleOnTop = false;
      shell = "${pkgs.fish}/bin/fish";
      # shell = "${pkgs.zsh}/bin/zsh";
      terminal = "xterm-ghostty";

      extraConfig = lib.fileContents config/tmux/tmux.conf;

      plugins = with pkgs.tmuxPlugins; [
        pain-control
        sessionist
        yank
      ];
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

}
