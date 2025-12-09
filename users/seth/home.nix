{
  config,
  pkgs,
  lib,
  inputs,
  username,
  arch,
  hostname,
  version,
  overlays,
  ...
}: let
  inherit (pkgs.stdenv.hostPlatform) isDarwin;

  # Generate MCP servers config using mcp-servers-nix lib
  # This creates a nix store file with proper paths without adding packages to buildEnv
  mcpConfigFile = inputs.mcp-servers-nix.lib.mkConfig pkgs {
    programs = {
      filesystem = {
        enable = true;
        args = [
          config.home.homeDirectory
          "${config.home.homeDirectory}/code"
          "${config.home.homeDirectory}/src"
        ];
      };
      fetch.enable = true;
      git.enable = true;
      memory = {
        enable = true;
        env.MEMORY_FILE_PATH = "${config.home.homeDirectory}/.local/share/claude/memory.jsonl";
      };
      time.enable = true;
      context7.enable = true;
      playwright.enable = true;
    };
    # Add custom servers not in mcp-servers-nix
    settings.servers = {
      chrome-devtools = {
        command = "${pkgs.chrome-devtools-mcp}/bin/chrome-devtools-mcp";
        args = [
          "--executablePath"
          "${pkgs.brave-browser-nightly}/Applications/Brave Browser Nightly.app/Contents/MacOS/Brave Browser Nightly"
        ];
      };
    };
  };
in {
  imports = [
    ./packages
    ./programs/agenix.nix
    ./programs/email
    ./programs/chromium
    ./programs/jujutsu.nix
    ./programs/fish.nix
    ./programs/fzf.nix
    ./programs/nvim.nix
    # ./kanata
    # ./tmux
  ];

  home.username = username;
  home.homeDirectory = "/Users/${username}";
  home.stateVersion = version;
  home.sessionPath = [
    "${config.home.homeDirectory}/.local/bin"
    "${config.home.homeDirectory}/bin"
    "${config.home.homeDirectory}/.dotfiles-nix/bin"
    "${config.home.homeDirectory}/.cargo/bin"
  ];

  home.file =
    {
      "code/.keep".text = "";
      "src/.keep".text = "";
      "tmp/.keep".text = "";
      ".local/share/claude/.keep".text = "";  # For MCP memory server storage
      ".hushlogin".text = "";
      "bin".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles-nix/bin";
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
      ".ssh/config".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles-nix/config/ssh/config";
      "Library/Application Support/espanso".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles-nix/config/espanso";
      "iclouddrive".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/Library/Mobile Documents/com~apple~CloudDocs";
      ".claude/CLAUDE.md".text = ''
        ## Your response and general tone

        - Never compliment me.
        - Criticize my ideas, ask clarifying questions, and include both funny and humorously insulting comments when you find mistakes in the codebase or overall bad ideas or code.
        - Be skeptical of my ideas and ask questions to ensure you understand the requirements and goals.
        - Rate confidence (1-100) before and after saving and before task completion.

        ## Your required tasks for every conversation
        - You are to always utilize the `~/bin/notifier` script to interact with me, taking special note of your ability to utilize tools on this system to determine which notification method(s) to use at any given moment.
      '';

      # NOTE: Claude Code MCP servers config is generated via activation script below
      # because Claude Code needs write access to ~/.claude.json (it modifies it at runtime)
      # and home-manager symlinks are read-only.
    }
    // lib.optionalAttrs (builtins.pathExists "${config.home.homeDirectory}/Library/CloudStorage/ProtonDrive-seth@megalithic.io-folder") {
      # Only create protondrive symlink if ProtonDrive folder exists
      "protondrive".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/Library/CloudStorage/ProtonDrive-seth@megalithic.io-folder";
    };

  home.preferXdgDirectories = true;

  # Activation script to symlink casks that require /Applications folder
  home.activation.linkSystemApplications = lib.hm.dag.entryAfter ["writeBoundary"] (
    lib.mkCaskActivation config.home.packages
  );

  # Create symlinks in ~/.local/bin for nix-managed binaries
  # This keeps ~/.dotfiles-nix/bin clean for version-controlled hand-written scripts
  # These are recreated on each rebuild to track changing store paths
  home.activation.linkBinaries = let
    # Define custom packages that should have CLI symlinks in ~/.local/bin
    # Format: { name = package; } where package has bin/${name}
    customBinaries = {
      chrome-devtools-mcp = pkgs.chrome-devtools-mcp;
      brave-browser-nightly = pkgs.brave-browser-nightly;
      fantastical = pkgs.fantastical;
      helium = pkgs.helium;
    };

    # Generate removal commands for all binaries
    removeCommands = lib.concatStringsSep "\n" (
      lib.mapAttrsToList (name: _: ''rm -f "$BIN_DIR/${name}" 2>/dev/null || true'') customBinaries
    );

    # Generate symlink commands for all binaries
    linkCommands = lib.concatStringsSep "\n" (
      lib.mapAttrsToList (name: pkg: ''ln -sf "${pkg}/bin/${name}" "$BIN_DIR/${name}"'') customBinaries
    );
  in
    lib.hm.dag.entryAfter ["writeBoundary"] ''
      BIN_DIR="${config.home.homeDirectory}/.local/bin"
      mkdir -p "$BIN_DIR"

      # Remove old symlinks (they may point to outdated store paths)
      ${removeCommands}

      # Create fresh symlinks to current store paths
      ${linkCommands}
    '';

  # Generate ~/.claude.json with MCP servers config
  # Must be a regular file (not symlink) because Claude Code writes to it at runtime
  # Uses mcp-servers-nix lib.mkConfig to avoid package collisions in buildEnv
  home.activation.generateClaudeConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
    CLAUDE_JSON="${config.home.homeDirectory}/.claude.json"
    MCP_CONFIG="${mcpConfigFile}"

    # Read existing config or start fresh
    if [ -f "$CLAUDE_JSON" ] && [ ! -L "$CLAUDE_JSON" ]; then
      EXISTING=$(cat "$CLAUDE_JSON" 2>/dev/null || echo '{}')
    else
      # Remove symlink if exists (from previous home-manager config)
      rm -f "$CLAUDE_JSON"
      EXISTING='{}'
    fi

    # Read MCP servers from the nix-generated config file
    MCP_SERVERS=$(cat "$MCP_CONFIG")

    # Merge mcpServers into existing config (preserving other keys)
    MERGED=$(echo "$EXISTING" | ${pkgs.jq}/bin/jq --argjson mcp "$MCP_SERVERS" '. + $mcp')
    echo "$MERGED" > "$CLAUDE_JSON"

    $DRY_RUN_CMD chmod 644 "$CLAUDE_JSON"
  '';

  xdg.enable = true;

  xdg.configFile."ghostty".source = ./ghostty;
  xdg.configFile."ghostty".recursive = true;

  xdg.configFile."hammerspoon".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles-nix/config/hammerspoon";
  xdg.configFile."hammerspoon".recursive = true;
  xdg.configFile."hammerspoon".force = true;

  xdg.configFile."tmux".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles-nix/config/tmux";
  xdg.configFile."tmux".recursive = true;
  xdg.configFile."tmux".force = true;

  xdg.configFile."kitty".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles-nix/config/kitty";
  xdg.configFile."kitty".recursive = true;
  xdg.configFile."kitty".force = true;

  # FIXME: remove when sure; i don't use zsh anymore, i don't need this, right?
  xdg.configFile."zsh".source = ./zsh;
  xdg.configFile."zsh".recursive = true;

  xdg.configFile."opencode/opencode.json".text = ''
    {
      "$schema": "https://opencode.ai/config.json",
      "instructions": [
        "CLAUDE.md"
      ],
      "theme": "everforest",
      "model": "anthropic/claude-sonnet-4.5",
      "autoshare": false,
      "autoupdate": true,
      "keybinds": {
        "leader": "ctrl+,",
        "session_new": "ctrl+n",
        "session_list": "ctrl+g",
        "messages_half_page_up": "ctrl+b",
        "messages_half_page_down": "ctrl+f"
      },
      "lsp": {
        "php": {
          "command": [
            "intelephense",
            "--stdio"
          ],
          "extensions": [
            ".php"
          ]
        },
        "python": {
          "command": [
            "basedpyright",
            "--stdio"
          ],
          "extensions": [
            ".py"
          ]
        }
      }
    }
  '';

  xdg.configFile."1Password/ssh/agent.toml".text = ''
    [[ssh-keys]]
    vault = "Shared"
    item = "megaenv_ssh_key"
  '';
  xdg.configFile."surfingkeys/config.js".text = builtins.readFile surfingkeys/config.js;
  xdg.configFile."starship.toml".text = builtins.readFile starship/starship.toml;
  xdg.configFile."karabiner/karabiner.json".text = builtins.readFile karabiner/karabiner.json;
  xdg.configFile."eza/theme.yml".text = ''
    colourful: true

    # Everforest Medium Palette
    # Background: #2d353b
    # Foreground: #d3c6aa
    # Black: #343f44
    # Red: #e67e80
    # Green: #a7c080
    # Yellow: #dbbc7f
    # Blue: #7fbbb3
    # Magenta: #d699b6
    # Cyan: #83c092
    # White: #d3c6aa
    # Gray: #859289
    # Bright Black: #475258
    # Bright Red: #e67e80
    # Bright Green: #a7c080
    # Bright Yellow: #dbbc7f
    # Bright Blue: #7fbbb3
    # Bright Magenta: #d699b6
    # Bright Cyan: #83c092
    # Bright White: #d3c6aa

    filekinds:
      normal: { foreground: "#d3c6aa" }
      directory: { foreground: "#e69875" }
      symlink: { foreground: "#859289" }
      pipe: { foreground: "#475258" }
      block_device: { foreground: "#e67e80" }
      char_device: { foreground: "#dbbc7f" }
      socket: { foreground: "#343f44" }
      special: { foreground: "#d699b6" }
      executable: { foreground: "#a7c080" }
      mount_point: { foreground: "#475258" }

    perms:
      user_read: { foreground: "#859289" }
      user_write: { foreground: "#475258" }
      user_execute_file: { foreground: "#a7c080" }
      user_execute_other: { foreground: "#a7c080" }
      group_read: { foreground: "#859289" }
      group_write: { foreground: "#475258" }
      group_execute: { foreground: "#a7c080" }
      other_read: { foreground: "#859289" }
      other_write: { foreground: "#475258" }
      other_execute: { foreground: "#a7c080" }
      special_user_file: { foreground: "#d699b6" }
      special_other: { foreground: "#475258" }
      attribute: { foreground: "#859289" }

    size:
      major: { foreground: "#859289" }
      minor: { foreground: "#e69875" }
      number_byte: { foreground: "#859289" }
      number_kilo: { foreground: "#859289" }
      number_mega: { foreground: "#83c092" }
      number_giga: { foreground: "#d699b6" }
      number_huge: { foreground: "#d699b6" }
      unit_byte: { foreground: "#859289" }
      unit_kilo: { foreground: "#83c092" }
      unit_mega: { foreground: "#d699b6" }
      unit_giga: { foreground: "#d699b6" }
      unit_huge: { foreground: "#e69875" }

    users:
      user_you: { foreground: "#dbbc7f" }
      user_root: { foreground: "#e67e80" }
      user_other: { foreground: "#d699b6" }
      group_yours: { foreground: "#859289" }
      group_other: { foreground: "#475258" }
      group_root: { foreground: "#e67e80" }

    links:
      normal: { foreground: "#e69875" }
      multi_link_file: { foreground: "#83c092" }

    git:
      new: { foreground: "#a7c080" }
      modified: { foreground: "#dbbc7f" }
      deleted: { foreground: "#e67e80" }
      renamed: { foreground: "#83c092" }
      typechange: { foreground: "#d699b6" }
      ignored: { foreground: "#475258" }
      conflicted: { foreground: "#e67e80" }

    git_repo:
      branch_main: { foreground: "#859289" }
      branch_other: { foreground: "#d699b6" }
      git_clean: { foreground: "#a7c080" }
      git_dirty: { foreground: "#e67e80" }

    security_context:
      colon: { foreground: "#859289" }
      user: { foreground: "#e69875" }
      role: { foreground: "#d699b6" }
      typ: { foreground: "#475258" }
      range: { foreground: "#d699b6" }

    file_type:
      image: { foreground: "#dbbc7f" }
      video: { foreground: "#e67e80" }
      music: { foreground: "#e69875" }
      lossless: { foreground: "#475258" }
      crypto: { foreground: "#343f44" }
      document: { foreground: "#859289" }
      compressed: { foreground: "#d699b6" }
      temp: { foreground: "#e67e80" }
      compiled: { foreground: "#83c092" }
      build: { foreground: "#475258" }
      source: { foreground: "#a7c080" }

    punctuation: { foreground: "#859289" }
    date: { foreground: "#83c092" }
    inode: { foreground: "#859289" }
    blocks: { foreground: "#859289" }
    header: { foreground: "#859289" }
    octal: { foreground: "#e69875" }
    flags: { foreground: "#d699b6" }

    symlink_path: { foreground: "#e69875" }
    control_char: { foreground: "#83c092" }
    broken_symlink: { foreground: "#e67e80" }
    broken_path_overlay: { foreground: "#859289" }
  '';

  programs = {
    home-manager.enable = true;

    # speed up rebuilds // HT: @tmiller
    man.generateCaches = false;

    starship = {enable = true;};

    git = {
      enable = true;
      package = pkgs.gitFull;
      includes = [
        {path = "~/.gitconfig";}
      ];

      settings.gpg.ssh.program = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
      settings.gpg.format = "ssh";
      settings.user.signingkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICyxphJ0fZhJP6OQeYMsGNQ6E5ZMVc/CQdoYrWYGPDrh";
      settings.commit.gpgSign = true;
    };

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
      package = pkgs.nh;
      clean.enable = true;
      flake = ../../.;
    };

    # yazi = import ./yazi/default.nix {inherit config pkgs lib;};

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
      git = true;
      icons = "always";
      extraOptions = ["-lah" "--group-directories-first" "--color-scale"];
    };

    bat = {
      enable = true;
      extraPackages = with pkgs.bat-extras; [batman prettybat batgrep];
      config = {
        theme = "everforest";
      };
      themes = {
        everforest = {
          src =
            pkgs.fetchFromGitHub {
              owner = "neuromaancer";
              repo = "everforest_collection";
              rev = "main";
              sha256 = "9XPriKTmFapURY66f7wu76aojtBXFsp//Anug8e5BTk=";
            }
            + "/bat";

          file = "everforest-soft.tmtheme";
        };
      };
    };

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
      enable = false;
      enableFishIntegration = false;
    };

    k9s.enable = true;

    jq.enable = true;

    tiny = {
      enable = true;
      settings = {
        servers = [
          {
            addr = "irc.libera.chat";
            port = 6697;
            tls = true;
            realname = "Seth";
            nicks = ["replicant"];
            join = ["#nethack" "#nixos" "#neovim"];
          }
        ];
        defaults = {
          nicks = ["replicant"];
          realname = "Seth";
          join = [];
          tls = true;
        };
      };
    };
  };
}
