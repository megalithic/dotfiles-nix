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

  # imports = [ ./packages.nix ];

  programs.home-manager.enable = true;
  home.username = username;
  home.homeDirectory = "/Users/${username}";
  home.stateVersion = version;
  home.sessionPath = [ "$HOME/.local/bin" ];
  home.packages = with pkgs; [
    amber
    unstable.claude-code
    unstable.devenv
    gh
    # ghostty
    gum
    harper
    lua-language-server
    markdown-oxide
    nixd
    unstable.espanso
    nixfmt-rfc-style
    ai-tools.opencode
    ripgrep
    sesh
  ];
  home.file = {
    "code/.keep".text = "";
    "src/.keep".text = "";
    "tmp/.keep".text = "";
    ".local/bin" = {
      recursive = true;
      source = ./bin;
    };
  };


  xdg.enable = true;

  # NOTE: only supported on linux platforms:
  # xdg.mimeApps = {
  #   enable = true;
  #
  #   defaultApplications = lib.mkMerge [
  #     # (config.lib.xdg.mimeAssociations [ pkgs.brave ])
  #     # (config.lib.xdg.mimeAssociations [ pkgs.gnome-text-editor ])
  #     # (config.lib.xdg.mimeAssociations [ pkgs.loupe ])
  #     # (config.lib.xdg.mimeAssociations [ pkgs.totem ])
  #   ];
  # };

  # NOTE: only supported on linux platforms:
  # xdg.userDirs = {
  #   enable = true;
  #   createDirectories = true;
  # };

  # xdg.configFile.ghostty.source = mkOutOfStoreSymlink "/Users/${username}/.dotfiles-nix/users/${username}/config/ghostty";


  xdg.configFile."hammerspoon".source = ./config/hammerspoon;
  xdg.configFile."hammerspoon".recursive = true;

  xdg.configFile."kanata".source = ./config/kanata;
  xdg.configFile."kanata".recursive = true;

  xdg.configFile."nvim".source = ./config/nvim;
  xdg.configFile."nvim".recursive = true;

  # packages managed outside of home-manager
  # xdg.configFile.nvim = {
  #   source = mkOutOfStoreSymlink "/Users/${username}/.dotfiles-nix/users/${username}/config/nvim";
  #   force = true;
  # };

  # xdg.configFile."tmux".source = config/tmux;
  # xdg.configFile."tmux".recursive = true;

  xdg.configFile."ghostty".source = ./config/ghostty;
  xdg.configFile."ghostty".recursive = true;

  # xdg.configFile."opencode".source = ./config/opencode;
  # xdg.configFile."opencode".recursive = true;
  xdg.configFile."opencode/opencode.json".text = ''
    {
      "$schema": "https://opencode.ai/config.json",
      "provider": {
        "ollama": {
          "npm": "@ai-sdk/openai-compatible",
          "name": "Ollama (local)",
          "options": {
            "baseURL": "http://localhost:11434/v1"
          },
          "models": {
            "gpt-oss:20b": {
              "name": "GPT OSS:20b"
            }
          }
        }
      },
      "model": "anthropic/claude-sonnet-4-20250514",
      "small_model": "anthropic/claude-3-5-haiku-20241022"
    }
  '';
  xdg.configFile."jj".source = ./config/jj;
  xdg.configFile."jj".recursive = true;

  xdg.configFile."zsh".source = ./config/zsh;
  xdg.configFile."zsh".recursive = true;


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
      withRuby = true;

      vimdiffAlias = true;
      vimAlias = true;

      extraPackages = with pkgs; [
        black
        bun
        cmake
        gcc # For treesitter compilation
        git
        gnumake # For various build processes
        golangci-lint
        gopls
        gotools
        hadolint
        isort
        lua-language-server
        markdownlint-cli
        nixd
        nixfmt-rfc-style # cannot be installed via Mason on macOS, so installed here instead
        nodejs # required by github copilot
        nodePackages.bash-language-server
        nodePackages.prettier
        npm-check-updates
        pyright
        python3
        ruby
        ruff
        rustup # run `rustup update stable` to get latest rustc, cargo, rust-analyzer etc.
        shellcheck
        shfmt
        stylua
        terraform-ls
        tflint
        tree-sitter
        uv
        vscode-langservers-extracted
        yaml-language-server
        yarn
      ];

      extraConfig = ''
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
    aerc = import ./config/aerc/default.nix { inherit config pkgs lib; };
    fish = {
      # REF: https://github.com/agdral/home-default/blob/main/shell/fish/functions/develop.nix
      enable = true;
      interactiveShellInit = ''
        set fish_greeting # N/A
      '';
      # direnv hook fish | source
      # tv init fish | source
      # ${pkgs.trashy}/bin/trashy completions fish | source
      # ${pkgs.rqbit}/bin/rqbit -v error completions fish | source
      # ${inputs.rimi.packages.${system}.rimi}/bin/rimi completions fish | source
      shellAliases = {
        opencode = "op run --no-masking -- opencode";
      };
    };

    direnv = {
      enable = true;
      enableZshIntegration = true;
      # enableFishIntegration = true;
      nix-direnv.enable = true;
      #config = {
      #global.warn_timeout = "0";
      #global.hide_env_diff = true;
      #};
    };


    tmux = {
      enable = true;
      escapeTime = 10;
      prefix = "
      C-space ";
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

    yazi = import ./config/yazi/default.nix { inherit config pkgs lib; };

    zoxide = {
      enable = true;
      enableFishIntegration = true;
      enableZshIntegration = true;
    };

    ssh = {
      matchBlocks."* \"test -z $SSH_TTY\"".identityAgent = "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock";
    };

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
    eza = {
      enable = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
    };
    bat.enable = true;
    ripgrep.enable = true;
    fd.enable = true;
    mbsync.enable = true;
    notmuch.enable = true;
    himalaya.enable = true;
    k9s.enable = true;
    jq.enable = true;
    # obs-studio = {
    #   enable = true;
    #   plugins = with pkgs.obs-studio-plugins; [
    #     obs-vaapi
    #     obs-pipewire-audio-capture
    #     input-overlay
    #     droidcam-obs
    #     obs-websocket
    #   ];
    # };
  };

  # Disable Spotlight keyboard shortcut (Cmd+Space) to allow Raycast/Alfred usage
  # home.activation.disableSpotlightShortcut = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
  #   echo "Disabling Spotlight shortcut (Cmd+Space)..."
  #
  #   # Disable Spotlight keyboard shortcut (Cmd+Space) to allow Raycast usage
  #   $DRY_RUN_CMD /usr/bin/defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 64 "
  #     <dict>
  #       <key>enabled</key><false/>
  #       <key>value</key><dict>
  #         <key>type</key><string>standard</string>
  #         <key>parameters</key>
  #         <array>
  #           <integer>32</integer>
  #           <integer>49</integer>
  #           <integer>1048576</integer>
  #         </array>
  #       </dict>
  #     </dict>
  #   "
  # '';
}
