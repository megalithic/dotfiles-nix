{ config
, pkgs
, lib
, inputs
, username
, system
, hostname
, version
, overlays
, ...
}:
let
  inherit (config.lib.file) mkOutOfStoreSymlink;
  #
  # # Fetch and extract the Kotlin LSP zip file
  # kotlinLsp =
  #   pkgs.runCommand "kotlin-lsp"
  #     {
  #       buildInputs = [ pkgs.unzip ];
  #     }
  #     ''
  #       mkdir -p $out/lib
  #       unzip ${
  #         pkgs.fetchurl {
  #           url = "https://download-cdn.jetbrains.com/kotlin-lsp/0.252.16998/kotlin-0.252.16998.zip";
  #           sha256 = "bWXvrTm0weirPqdmP/WSLySdsOWU0uBubx87MVvKoDc=";
  #         }
  #       } -d $out/lib
  #     '';
  #
  # # Create a wrapper script to run the Kotlin LSP
  # kotlinLspWrapper = pkgs.writeShellScriptBin "kotlin-lsp" ''
  #   #!/usr/bin/env bash
  #   # Build the classpath with all .jar files in the lib directory
  #   CLASSPATH=$(find ${kotlinLsp}/lib -name "*.jar" | tr '\n' ':')
  #   exec java -cp "$CLASSPATH" com.intellij.internal.statistic.uploader.EventLogUploader "$@"
  # '';
  # mcphub = inputs.mcp-hub.packages."${pkgs.system}".default;
  # nvim-nightly = inputs.neovim-nightly-overlay.packages.${pkgs.system}.default;
in
{
  # imports = [
  #   ./pkgs.nix
  # ];

  programs.home-manager.enable = true;
  home.username = username;
  home.homeDirectory = "/Users/${username}";
  home.stateVersion = version;

  xdg.enable = true;

  # packages managed outside of home-manager
  xdg.configFile.nvim = {
    source = mkOutOfStoreSymlink "/Users/${username}/.dotfiles-nix/users/${username}/config/nvim";
    force = true;
  };
  # xdg.configFile.ghostty.source = mkOutOfStoreSymlink "/Users/${username}/.dotfiles-nix/users/${username}/config/ghostty";


  xdg.configFile."hammerspoon".source = config/hammerspoon;
  xdg.configFile."hammerspoon".recursive = true;

  xdg.configFile."kanata".source = config/kanata;
  xdg.configFile."kanata".recursive = true;

  # xdg.configFile."nvim".source = config/nvim;
  # xdg.configFile."nvim".recursive = true;
  #
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


  homebrew = import ./homebrew.nix { inherit config pkgs lib; };
  packages = import ./pkgs.nix { inherit config pkgs lib; };
  accounts = import ./accounts.nix { inherit config pkgs lib; };

  # applications/programs
  programs = {
    # speed up rebuilds
    # HT: @tmiller
    man.generateCaches = false;
    neovim = {
      enable = true;
      package = pkgs.nvim-nightly;
      defaultEditor = true;

      withPython3 = true;
      withNodeJs = true;

      vimdiffAlias = true;
      vimAlias = true;


      extraPackages = with pkgs; [
        git
        gcc # For treesitter compilation
        gnumake # For various build processes
      ];

      extraConfig = ''
        " Ensure git is in PATH for plugins
        let $PATH = $PATH . ':${pkgs.git}/bin'
      '';
    };

    # zsh = import ./programs/zsh.nix { inherit config pkgs lib; };
    # starship = import ./programs/starship.nix { inherit pkgs; };
    # git = import ./programs/git.nix { inherit username lib; };
    # tmux = import ./programs/tmux.nix { inherit pkgs; };
    # fzf = import ./programs/fzf.nix { inherit pkgs lib; };
    # zoxide = import ./programs/zoxide.nix { inherit pkgs; };
    # go = import ./programs/go.nix { inherit pkgs; };
    # java = import ./programs/java.nix { inherit pkgs; };
    # lazygit = import ./programs/lazygit.nix { inherit pkgs; };
    # lazydocker = import ./programs/lazydocker.nix { inherit pkgs; };
    # gh = import ./programs/gh.nix { inherit pkgs; };
    # ssh = import ./programs/ssh.nix { inherit pkgs; };
    aerc = import ./aerc.nix { inherit config pkgs lib; };
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
      # package = pkgs.unstable.jujutsu;
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
    fd.enable = true;
    mbsync.enable = true;
    notmuch.enable = true;
    himalaya.enable = true;
    k9s.enable = true;
    jq.enable = true;
  };
}
