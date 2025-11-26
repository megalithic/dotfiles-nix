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
    ./agenix.nix
    ./packages.nix
    ./packages-casks.nix
    ./packages-mas.nix
    ./packages-fonts.nix
    ./packages-langs.nix
    ./email.nix
    ./chromium
    ./jujutsu.nix
    ./qutebrowser.nix
    ./fish.nix
    ./fzf.nix
    ./nvim.nix
    # (import ./hammerspoon.nix {
    #   hs_extra_config = ''
    #     return {}
    #   '';
    # })
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

  home.file = {
    "code/.keep".text = "";
    "src/.keep".text = "";
    "tmp/.keep".text = "";
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
    # ".s3cfg".source = config.age.secrets.s3cfg.path;
  };

  home.file.".claude/CLAUDE.md".text = ''
    ## Your response and general tone

    - Never compliment me.
    - Criticize my ideas, ask clarifying questions, and include both funny and humorously insulting comments when you find mistakes in the codebase or overall bad ideas or code.
    - Be skeptical of my ideas and ask questions to ensure you understand the requirements and goals.
    - Rate confidence (1-100) before and after saving and before task completion.

    ## Your required tasks for every conversation
    - You are to always utilize the `~/bin/notifier` script to interact with me, taking special note of your ability to utilize tools on this system to determine which notification method(s) to use at any given moment.
  '';

  home.preferXdgDirectories = true;

  # FIXME: move these to native-nix mkOutOfStoreSymlink
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

    rm -rf /Users/${username}/.config/kitty > /dev/null 2>&1;
    ln -sf /Users/${username}/.dotfiles-nix/config/kitty /Users/${username}/.config/ > /dev/null 2>&1 &&
      echo "░ ✓ symlinked kitty to /Users/${username}/.config/kitty" ||
      echo "░ x failed to symlink kitty to /Users/${username}/.config/kitty"

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

    command cat << EOF
    ░
    ░ fin.

    EOF

    # Explicit completion signal for activation script
    true
  '';

  xdg.configFile."hammerspoon/extra_config.lua".text = ''
    return {}
  '';

  xdg.enable = true;
  xdg.configFile."ghostty".source = ./ghostty;
  xdg.configFile."ghostty".recursive = true;

  # FIXME: remove when sure; i don't use zsh anymore, i don't need this, right?
  # xdg.configFile."zsh".source = ./zsh;
  # xdg.configFile."zsh".recursive = true;

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
  xdg.configFile."karabiner/karabiner.json" = {
    # NOTE: If karabiner ever stops working and restarts don't fix the problem, try:
    # /Applications/.Nix-Karabiner/.Karabiner-VirtualHIDDevice-Manager.app/Contents/MacOS/Karabiner-VirtualHIDDevice-Manager deactivate
    # then restarting and re-allowing Karabiner when prompted.
    source = ./karabiner/karabiner.json;
  };
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
      package = pkgs.gitAndTools.gitFull;
      includes = [
        {path = "~/.gitconfig";}
      ];

      extraConfig.gpg.ssh.program = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
      extraConfig.gpg.format = "ssh";
      extraConfig.user.signingkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICyxphJ0fZhJP6OQeYMsGNQ6E5ZMVc/CQdoYrWYGPDrh";
      extraConfig.commit.gpgSign = true;
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
      package = pkgs.unstable.nh;
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
