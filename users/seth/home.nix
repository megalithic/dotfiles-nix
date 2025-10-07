{
  config,
  pkgs,
  lib,
  inputs,
  username,
  system,
  hostname,
  version,
  overlays,
  ...
}: let
  inherit (pkgs.stdenv.hostPlatform) isDarwin;
in {
  imports = [
    # ./packages.nix
    ./mail
    ./jujutsu
    ./qutebrowser.nix
    ./chromium
    # ./karabiner
    # ./kanata
    # ./zen-browser.nix
    # ./tmux
    # ./nvim
  ];

  home.username = username;
  home.homeDirectory = "/Users/${username}";
  home.stateVersion = version;
  home.sessionPath = [
    "${config.home.homeDirectory}/.local/bin"
    "${config.home.homeDirectory}/bin"
    "${config.home.homeDirectory}/.cargo/bin"
  ];
  home.packages = with pkgs; [
    # [for neovim] --------------------------------------------------------------------------------
    par
    hadolint # Docker linter
    dotenv-linter
    shfmt # Doesn't work with zsh, only sh & bash
    vscode-langservers-extracted # HTML, CSS, JSON & ESLint LSPs
    # vscode-json-languageserver
    nodePackages.prettier
    deno
    biome
    bash-language-server
    vtsls # js/ts LSP
    yaml-language-server
    tailwindcss-language-server
    statix
    # emmylua_ls
    # emmylua_check
    tree-sitter # required for treesitter "auto-install" option to work
    nixd # nix lsp
    actionlint
    taplo # TOML linter and formatter
    # neovim luarocks support requires lua 5.1
    # https://github.com/folke/lazy.nvim/issues/1570#issuecomment-2194329169
    lua51Packages.luarocks
    typos
    typos-lsp
    copilot-language-server
    pngpaste # For Obsidian paste_img command
    stylelint-lsp

    # [ai] ----------------------------------------------------------------------------------------
    ai-tools.opencode
    ai-tools.claude-code
    # [langs] --------------------------------------------------------------------------------------
    cargo
    harper
    k9s
    kubectl
    kubernetes-helm
    kubie
    lua-language-server
    markdown-oxide
    podman
    shellcheck
    shfmt
    stylua
    # docker --------------------------------------------------------------------------------------
    colima
    docker
    docker-compose
    docker-compose-language-service
    dockerfile-language-server-nodejs
    # node/js/ts ----------------------------------------------------------------------------------
    nodejs_22
    # nodePackages_latest.nodejs
    # nodePackages_latest.prettier
    # nodePackages_latest.vscode-json-languageserver
    pnpm
    vue-language-server
    # python --------------------------------------------------------------------------------------
    basedpyright
    # python3
    python313
    python313Packages.pip
    python313Packages.websockets
    python313Packages.websocket-client
    python313Packages.ipython
    python313Packages.sqlfmt
    uv
    # nix -----------------------------------------------------------------------------------------
    nixfmt-rfc-style
    alejandra
    nix-direnv
    nil
    # terraform -----------------------------------------------------------------------------------
    # terraform
    # terraform-docs
    # terraform-ls
    # tflint
    # tfsec
    # trivy
    # atlas
    # typst
    # [rest] ----------------------------------------------------------------------------------------
    _1password-cli
    amber
    argc
    aws-sam-cli
    awscli2
    cachix
    curlie
    delta
    devbox
    difftastic
    ffmpeg
    flyctl
    gh
    git-lfs
    gum
    helium
    jwt-cli
    poppler
    pre-commit
    procs
    # qutebrowser
    ripgrep
    sqlite
    # terminal-notifier FIXME: not working with nixpkgs (arch not supported?)
    tmux
    unstable.devenv
    yubikey-manager
    yubikey-personalization
  ];

  home.file = {
    "code/.keep".text = "";
    "src/.keep".text = "";
    "tmp/.keep".text = "";
    ".hushlogin".text = "";
    "bin".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles-nix/bin";
    ".vimrc".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles-nix/users/${username}/nvim/.vimrc";
    ".editorconfig".text = ''
      root = true

      [*]
      indent_style = space
      indent_size = 2
      end_of_line = lf
      insert_final_newline = true
      trim_trailing_whitespace=true
      # max_line_length = 80
      charset = utf-8
    '';
    ".ignore".source = git/tool_ignore;
    ".gitignore".source = git/gitignore;
    ".gitconfig".source = git/gitconfig;
    ".config/1Password/ssh/agent.toml".text = ''
      [[ssh-keys]]
      vault = "Shared"
      item = "megaenv"
    '';
    ".config/surfingkeys/config.js".text = builtins.readFile surfingkeys/config.js;
    ".config/starship.toml".text = builtins.readFile starship/starship.toml;
    ".config/karabiner/karabiner.json" = {
      # NOTE: If karabiner ever stops working and restarts don't fix the problem, try:
      # /Applications/.Nix-Karabiner/.Karabiner-VirtualHIDDevice-Manager.app/Contents/MacOS/Karabiner-VirtualHIDDevice-Manager deactivate
      # then restarting and re-allowing Karabiner when prompted.
      source = ./karabiner/karabiner.json;
      # onChange = "${pkgs.goku}/bin/goku";
    };
  };

  xdg.enable = true;
  home.preferXdgDirectories = true;

  home.activation.symlinkAdditionalConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
    command cat << EOF

    ░       ▗   ▘    ▗   ▜ ▜
    ░ ▛▌▛▌▛▘▜▘▄▖▌▛▌▛▘▜▘▀▌▐ ▐
    ░ ▙▌▙▌▄▌▐▖  ▌▌▌▄▌▐▖█▌▐▖▐▖
    ░ ▌
    EOF

    rm -rf /Users/${username}/.ssh/config > /dev/null 2>&1;
    ln -sf /Users/${username}/.dotfiles-nix/config/ssh/config /Users/${username}/.ssh/ > /dev/null 2>&1 &&
      echo "░ ✓ symlinked ssh_config to /Users/${username}/.ssh/config" ||
      echo "░ x failed to symlink ssh_config to /Users/${username}/.ssh/config"

    rm -rf /Users/${username}/.config/hammerspoon > /dev/null 2>&1;
    ln -sf /Users/${username}/.dotfiles-nix/config/hammerspoon /Users/${username}/.config/ > /dev/null 2>&1 &&
      echo "░ ✓ symlinked hammerspoon to /Users/${username}/.config/hammerspoon" ||
      echo "░ x failed to symlink hammerspoon to /Users/${username}/.config/hammerspoon"

    rm -rf /Users/${username}/.config/tmux > /dev/null 2>&1;
    ln -sf /Users/${username}/.dotfiles-nix/config/tmux /Users/${username}/.config/ > /dev/null 2>&1 &&
      echo "░ ✓ symlinked tmux to /Users/${username}/.config/tmux" ||
      echo "░ x failed to symlink tmux to /Users/${username}/.config/tmux"

    # (pushd "/Users/${username}/.local/share/tmux/plugins/tmux-thumbs" > /dev/null 2>&1 &&
    #   ${pkgs.cargo}/bin/cargo build --release > /dev/null 2>&1 &&
    #   popd > /dev/null 2>&1) &&
    #   echo "░ ✓ compiled tmux-thumbs" ||
    #   echo "░ x failed to compile tmux-thumbs"

    if [[ -d "/Users/${username}/Library/CloudStorage/ProtonDrive-seth@megalithic.io-folder" ]]; then
      rm -rf /Users/${username}/protondrive > /dev/null 2>&1;
      ln -sf /Users/${username}/Library/CloudStorage/ProtonDrive-seth@megalithic.io-folder /Users/${username}/protondrive > /dev/null 2>&1 &&
        echo "░ ✓ symlinked proton drive to /Users/${username}/protondrive" ||
        echo "░ x failed to symlink proton drive to /Users/${username}/protondrive"
    fi

    rm -rf /Users/${username}/iclouddrive > /dev/null 2>&1;
    ln -sf /Users/seth/Library/Mobile\ Documents/com~apple~CloudDocs /Users/${username}/iclouddrive > /dev/null 2>&1 &&
      echo "░ ✓ symlinked iCloud drive to /Users/${username}/iclouddrive" ||
      echo "░ x failed to symlink iCloud drive to /Users/${username}/iclouddrive"

    rm -rf /Users/${username}/Library/Application\ Support/espanso > /dev/null 2>&1;
    ln -sf /Users/${username}/.dotfiles-nix/config/espanso /Users/${username}/Library/Application\ Support/ > /dev/null 2>&1 &&
      echo "░ ✓ symlinked espanso to /Users/${username}/Library/Application\ Support/espanso" ||
      echo "░ x failed to symlink espanso to /Users/${username}/Library/Application\ Support/espanso"
  '';
  xdg.configFile."nvim".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles-nix/users/${username}/nvim";
  xdg.configFile."ghostty".source = ./ghostty;
  xdg.configFile."ghostty".recursive = true;
  xdg.configFile."zsh".source = ./zsh;
  xdg.configFile."zsh".recursive = true;
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

  # applications/programs
  programs.home-manager.enable = true;
  programs = {
    # speed up rebuilds
    # HT: @tmiller
    man.generateCaches = false;

    neovim = {
      enable = true;
      package = pkgs.nvim-nightly;
      # defaultEditor = true;
      # # extraLuaConfig = lib.fileContents config/nvim/init.lua;
      # plugins = [
      #   {
      #     plugin = pkgs.vimPlugins.sqlite-lua;
      #     config = "let g:sqlite_clib_path = '${pkgs.sqlite.out}/lib/libsqlite3${pkgs.stdenv.hostPlatform.extensions.sharedLibrary}'";
      #   }
      # ];
    };
    #
    #   withPython3 = true;
    #   withNodeJs = true;
    #   withRuby = true;
    #
    #   vimdiffAlias = true;
    #   vimAlias = true;
    #   # extraLuaConfig = lib.fileContents config/nvim/init.lua;
    #   extraPackages = with pkgs; [
    #     black
    #     bun
    #     cmake
    #     gcc # For treesitter compilation
    #     git
    #     gnumake # For various build processes
    #     golangci-lint
    #     gopls
    #     gotools
    #     hadolint
    #     isort
    #     lua-language-server
    #     markdownlint-cli
    #     nixd
    #     nixfmt-rfc-style # cannot be installed via Mason on macOS, so installed here instead
    #     nodejs # required by github copilot
    #     nodePackages.bash-language-server
    #     nodePackages.prettier
    #     npm-check-updates
    #     pyright
    #     python3
    #     ruby
    #     ruff
    #     rustup # run `rustup update stable` to get latest rustc, cargo, rust-analyzer etc.
    #     shellcheck
    #     shfmt
    #     stylua
    #     terraform-ls
    #     tflint
    #     tree-sitter
    #     uv
    #     vscode-langservers-extracted
    #     yaml-language-server
    #     yarn
    #   ];
    #
    #   extraConfig = ''
    #     let $PATH = $PATH . ':${pkgs.git}/bin'
    #   '';
    # };

    starship = {enable = true;};
    fish = {
      # REF: https://github.com/agdral/home-default/blob/main/shell/fish/functions/develop.nix
      enable = true;
      # shellInit = ''
      #   export PATH="/etc/profiles/per-user/${username}/bin:$PATH"
      #   set -g fish_prompt_pwd_dir_length 20
      # '';
      interactiveShellInit = ''
        # fish_add_path /opt/homebrew/bin
        # fish_default_key_bindings

        set fish_cursor_default     block      blink
        set fish_cursor_insert      line       blink
        set fish_cursor_replace_one underscore
        set fish_cursor_visual      underscore blink

        # fish_vi_key_bindings
        # fish_vi_key_bindings insert
        # quickly open text file
        # bind -M insert \cd '${pkgs.fd}/bin/fd -d | fzf | xargs -r cd'
        bind -M insert ctrl-o '${pkgs.fzf}/bin/fzf | xargs -r $EDITOR'

        bind -M insert ctrl-a beginning-of-line
        bind -M insert ctrl-e end-of-line
        bind -M insert ctrl-y accept-autosuggestion
        bind ctrl-y accept-autosuggestion

        # NOTE: using fzf for this:
        # bind -M insert ctrl-r history-pager
        # bind ctrl-r history-pager


        # edit command in $EDITOR
        bind -M insert ctrl-v edit_command_buffer

        # Rerun previous command
        bind -M insert ctrl-s 'commandline $history[1]' 'commandline -f execute'

        # restore old ctrl+c behavior; it should not clear the line in case I want to copy it or something
        # the new default behavior is stupid and bad, it just clears the current prompt
        # https://github.com/fish-shell/fish-shell/issues/11327
        bind -M insert -m insert ctrl-c cancel-commandline

        # I like to keep the prompt at the bottom rather than the top
        # of the terminal window so that running `clear` doesn't make
        # me move my eyes from the bottom back to the top of the screen;
        # keep the prompt consistently at the bottom
        # _prompt_move_to_bottom # call function manually to load it since event handlers don't get autoloaded

        set -gx EZA_COLORS "\
        di=#7fbbb3:\
        ex=#e67e80:\
        fi=#d3c6aa:\
        ln=#83c092:\
        or=#e67e80:\
        ow=#7fbbb3:\
        pi=#d699b6:\
        so=#e69875:\
        bd=#dbbc7f:\
        cd=#dbbc7f:\
        su=#e67e80:\
        sg=#e67e80:\
        tw=#7fbbb3:\
        st=#9da9a0:\
        *.tar=#e69875:\
        *.zip=#e69875:\
        *.7z=#e69875:\
        *.gz=#e69875:\
        *.bz2=#e69875:\
        *.xz=#e69875:\
        *.jpg=#d699b6:\
        *.jpeg=#d699b6:\
        *.png=#d699b6:\
        *.gif=#d699b6:\
        *.svg=#d699b6:\
        *.pdf=#a7c080:\
        *.txt=#d3c6aa:\
        *.md=#a7c080:\
        *.json=#dbbc7f:\
        *.yml=#dbbc7f:\
        *.yaml=#dbbc7f:\
        *.xml=#dbbc7f:\
        *.toml=#dbbc7f:\
        *.ini=#dbbc7f:\
        *.cfg=#dbbc7f:\
        *.conf=#dbbc7f:\
        *.log=#9da9a0:\
        *.tmp=#9da9a0:\
        *.bak=#9da9a0:\
        *.swp=#9da9a0:\
        *.lock=#9da9a0:\
        *.js=#dbbc7f:\
        *.ts=#7fbbb3:\
        *.jsx=#7fbbb3:\
        *.tsx=#7fbbb3:\
        *.py=#7fbbb3:\
        *.rb=#e67e80:\
        *.go=#83c092:\
        *.rs=#e69875:\
        *.c=#7fbbb3:\
        *.cpp=#7fbbb3:\
        *.h=#d699b6:\
        *.hpp=#d699b6:\
        *.java=#e69875:\
        *.class=#e69875:\
        *.sh=#a7c080:\
        *.bash=#a7c080:\
        *.zsh=#a7c080:\
        *.fish=#a7c080:\
        *.vim=#a7c080:\
        *.nvim=#a7c080"
      '';
      functions = {
        fish_greeting = "";
        _prompt_move_to_bottom = {
          onEvent = "fish_postexec";
          body = "tput cup $LINES";
        };
        # nix-shell = {
        #   wraps = "nix-shell";
        #   body = ''
        #     for ARG in $argv
        #         if [ "$ARG" = --run ]
        #             command nix-shell $argv
        #             return $status
        #         end
        #     end
        #     command nix-shell $argv --run "exec fish"
        #   '';
        # };
        pr = ''
          set -l PROJECT_PATH (git config --get remote.origin.url)
          set -l PROJECT_PATH (string replace "git@github.com:" "" "$PROJECT_PATH")
          set -l PROJECT_PATH (string replace "https://github.com/" "" "$PROJECT_PATH")
          set -l PROJECT_PATH (string replace ".git" "" "$PROJECT_PATH")
          set -l GIT_BRANCH (git branch --show-current || echo "")
          set -l MASTER_BRANCH (git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@')

          if test -z "$GIT_BRANCH"
              set GIT_BRANCH (jj log -r @- --no-graph --no-pager -T 'self.bookmarks()')
          end

          if test -z "$GIT_BRANCH"
              echo "Error: not a git repository"
              return 1
          end
          ${
            if isDarwin
            then "open"
            else "xdg-open"
          } "https://github.com/$PROJECT_PATH/compare/$MASTER_BRANCH...$GIT_BRANCH"
        '';
        ghb = ''
          set -l PROJECT_PATH (git config --get remote.origin.url)
          set -l PROJECT_PATH (string replace "git@github.com:" "" "$PROJECT_PATH")
          set -l PROJECT_PATH (string replace "https://github.com/" "" "$PROJECT_PATH")
          set -l PROJECT_PATH (string replace ".git" "" "$PROJECT_PATH")
          set -l GIT_BRANCH (git branch --show-current || echo "")
          set -l MASTER_BRANCH (git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@')

          if test -z "$GIT_BRANCH"
              set GIT_BRANCH (jj log -r @- --no-graph --no-pager -T 'self.bookmarks()')
          end

          if test -z "$GIT_BRANCH"
              echo "Error: not a git repository"
              return 1
          end
          ${
            if isDarwin
            then "open"
            else "xdg-open"
          } "https://github.com/$PROJECT_PATH/compare/$MASTER_BRANCH...$GIT_BRANCH"
        '';
      };

      # direnv hook fish | source
      # tv init fish | source
      # ${pkgs.trashy}/bin/trashy completions fish | source
      # ${pkgs.rqbit}/bin/rqbit -v error completions fish | source
      # ${inputs.rimi.packages.${system}.rimi}/bin/rimi completions fish | source

      shellAliases = {
        ls = "${pkgs.eza}/bin/eza -a --group-directories-first";
        l = "${pkgs.eza}/bin/eza -lahF";
        ll = "${pkgs.eza}/bin/eza -lahF";
        tree = "${pkgs.eza}/bin/eza --tree";
        opencode = "op run --no-masking -- opencode";
        rm = "${pkgs.darwin.trash}/bin/trash -v";
        q = "exit";
        ",q" = "exit";
        mega = "ftm mega";
        copy =
          if isDarwin
          then "pbcopy"
          else "xclip -selection clipboard";
        paste =
          if isDarwin
          then "pbpaste"
          else "xlip -o -selection clipboard";
        cat = "bat";
        "!!" = "eval \\$history[1]";
        clear = "clear && _prompt_move_to_bottom";
        # inspect $PATH
        pinspect = ''echo "$PATH" | tr ":" "\n"'';
        brew = "op plugin run -- brew";
        cachix = "op plugin run -- cachix";
        # doctl = "op plugin run -- doctl";
        gh = "op plugin run -- gh";
        git = "op plugin run -- git";
        tmux = "op plugin run -- tmux";
        pulumi = "op plugin run -- pulumi";
      };

      shellAbbrs = {
        nvim = "nvim -O";
        vim = "nvim -O";
        j = "just";
      };

      plugins = [
        {
          name = "autopair";
          inherit (pkgs.fishPlugins.autopair) src;
        }
        {
          name = "nix-env";
          src = pkgs.fetchFromGitHub {
            owner = "lilyball";
            repo = "nix-env.fish";
            rev = "7b65bd228429e852c8fdfa07601159130a818cfa";
            hash = "sha256-RG/0rfhgq6aEKNZ0XwIqOaZ6K5S4+/Y5EEMnIdtfPhk";
          };
        }
        {
          name = "done";
          src = pkgs.fetchFromGitHub {
            owner = "franciscolourenco";
            repo = "done";
            rev = "d6abb267bb3fb7e987a9352bc43dcdb67bac9f06";
            sha256 = "6oeyN9ngXWvps1c5QAUjlyPDQwRWAoxBiVTNmZ4sG8E=";
          };
        }
      ];
    };

    fzf = {
      enable = true;
      enableFishIntegration = true; # broken
      fileWidgetCommand = "${pkgs.fd}/bin/fd --type f --hidden --no-ignore-vcs --follow --exclude .git --exclude .jj --exclude .direnv . \\$dir";
      fileWidgetOptions = [
        "--preview '${pkgs.bat}/bin/bat --color=always --style=numbers --line-range :300 {}'"
        "--style=minimal"
      ];
      defaultCommand = "${pkgs.fd}/bin/fd --type f --hidden  --no-ignore-vcs --follow --exclude .git --exclude .jj --exclude .direnv .";
      defaultOptions = [
        "--style=minimal"
        "--height 20%"
      ];
      tmux.enableShellIntegration = true;
      tmux.shellIntegrationOptions = ["-d 40%"];
    };

    ghostty = {
      enable = true;
      enableFishIntegration = true;
      enableBashIntegration = false;
      enableZshIntegration = false;
      installBatSyntax = !isDarwin;
      # FIXME: Remove this hack when the nixpkgs pkg works again
      package =
        if isDarwin
        then lib.brew-alias pkgs "ghostty"
        else pkgs.ghostty;
      settings = {
        quit-after-last-window-closed = true;
      };
    };

    git = {
      enable = true;
      package = pkgs.gitAndTools.gitFull;
      userName = "Seth Messer";
      userEmail = "seth@megalithic.io";
      includes = [
        {path = "~/.gitconfig";}
      ];
      # extraConfig = {
      #   gpg.format = "ssh";
      #   "gpg \"ssh\"".program = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
      #   commit.gpgSign = true;
      #   # user.signingKey = builtins.readFile /Users/${username}/.ssh/${username}-${hostname}.pub;
      #   # user.signingKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPqAEvgo0iyCrzXC2i03sTHQIAgSbzwPp9U44fIOGXMu";
      # };
      # extraConfig.gpg.ssh.program = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
      # extraConfig.gpg.format = "ssh";
      # extraConfig.commit.gpgSign = true;
    };

    #   // lib.optionalAttrs isDarwin {
    #   extraConfig = {
    #     gpg.format = "ssh";
    #     "gpg \"ssh\"".program = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
    #     commit.gpgSign = true;
    #     # user.signingKey = builtins.readFile /Users/${username}/.ssh/${username}-${hostname}.pub;
    #     # user.signingKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPqAEvgo0iyCrzXC2i03sTHQIAgSbzwPp9U44fIOGXMu";
    #   };
    # };

    direnv = {
      enable = true;
      enableZshIntegration = true;
      # NOTE: can't set this on my setup; it's readonly?
      # enableFishIntegration = true;
      nix-direnv.enable = true;
      mise.enable = true;
      config = {
        global.load_dotenv = true;
        global.warn_timeout = 0;
        global.hide_env_diff = true;
        whitelist.prefix = [config.home.homeDirectory];
      };
    };

    nh = {
      enable = true;
      package = pkgs.unstable.nh;
      clean.enable = true;
      flake = ../../.;
    };

    yazi = import ./yazi/default.nix {inherit config pkgs lib;};
    htop = {
      enable = true;
      settings = {
        sort_direction = true;
        sort_key = "PERCENT_CPU";
      };
    };
    zoxide = {
      enable = true;
      enableFishIntegration = true;
      enableZshIntegration = true;
    };

    ssh = {
      matchBlocks."* \"test -z $SSH_TTY\"".identityAgent = "~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock";
    };

    mise = {
      enable = true;
      enableFishIntegration = true;
      enableZshIntegration = true;
      settings = {
        auto_install = true;
        experimental = true;
        verbose = false;
      };
      # globalConfig = {
      #   tools = {
      #     elixir = "1.18.4-otp-27"; # alts: 1.18.4-otp-28
      #     erlang = "27.3.4.1"; # alts: 28.0.1
      #     python = "3.13.4";
      #     rust = "beta";
      #     node = "lts";
      #     pnpm = "latest";
      #     aws-cli = "2";
      #   };
      # };
    };

    eza = {
      enable = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
      colors = "always";
    };

    bat.enable = true;
    ripgrep = {
      enable = true;
    };
    fd = {
      enable = true;
      ignores = [
        ".git"
        ".jj"
        ".direnv"
        "pkg"
        "Library"
        ".Trash"
      ];
    };
    television = {
      enable = true;
      enableFishIntegration = false;
    };
    k9s.enable = true;
    jq.enable = true;

    # espanso.enable = {
    #   enable = true;
    #   package = lib.brew-alias pkgs "espanso";
    # };
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
}
