# Uses the official home-manager programs.claude-code module for declarative config.
# MCP servers are passed via --mcp-config flag (wrapper handles this automatically).
{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: let
  # Use mcp-servers-nix evalModule to get the servers attrset directly
  # This gives us the raw config structure we can pass to programs.claude-code.mcpServers
  mcpServersConfig =
    (inputs.mcp-servers-nix.lib.evalModule pkgs {
      programs = {
        memory = {
          enable = true;
          env.MEMORY_FILE_PATH = "${config.home.homeDirectory}/.local/share/claude/memory.jsonl";
        };
        context7.enable = true;
        terraform.enable = false;
        nixos.enable = false;
        codex.enable = false;
        serena = {
          enable = false;
          args = [
            "--context"
            "ide-assistant"
            "--enable-web-dashboard"
            "False"
          ];
        };

        # Disabled servers (kept for reference)
        # filesystem.enable = false;
        # fetch.enable = false;
        # git.enable = false;
        # time.enable = false;
        # playwright.enable = false;
      };
    }).config.settings.servers;

  # Custom MCP servers not in mcp-servers-nix
  customMcpServers = {
    chrome-devtools = {
      command = "${pkgs.chrome-devtools-mcp}/bin/chrome-devtools-mcp";
      args = [
        "--executablePath"
        "${pkgs.brave-browser-nightly}/Applications/Brave Browser Nightly.app/Contents/MacOS/Brave Browser Nightly"
      ];
    };
  };
in {
  # ===========================================================================
  # AI Tool Packages (non-Claude)
  # ===========================================================================
  home.packages = with pkgs; [
    ai-tools.opencode
    ai-tools.claude-code-acp
    # Note: claude-code is managed by programs.claude-code below
    # Note: chrome-devtools-mcp is referenced by path in MCP config
  ];

  # ===========================================================================
  # Claude Code Configuration (via home-manager module)
  # ===========================================================================
  programs.claude-code = {
    enable = true;
    package = pkgs.ai-tools.claude-code;

    # Personal instructions (CLAUDE.md)
    memory.text = ''
      ## Your response and general tone

      - Never compliment me.
      - Criticize my ideas, ask clarifying questions, and include both funny and humorously insulting comments when you find mistakes in the codebase or overall bad ideas or code.
      - Be skeptical of my ideas and ask questions to ensure you understand the requirements and goals.
      - Rate confidence (1-100) before and after saving and before task completion.

      ## Your required tasks for every conversation
      - You are to always utilize the `~/bin/notifier` script to interact with me, taking special note of your ability to utilize tools on this system to determine which notification method(s) to use at any given moment.
    '';

    # Settings (written to ~/.claude/settings.json)
    settings = {
      theme = "dark";
      autoUpdates = false;
      includeCoAuthoredBy = false;
      autoCompactEnabled = false;
      enableAllProjectMcpServers = true;
      feedbackSurveyState.lastShownTime = 1754089004345;
      outputStyle = "Explanatory";
      statusLine = {
        type = "command";
        command = "${config.home.homeDirectory}/bin/claude-statusline";
        padding = 0;
      };
    };

    # env = {
    #   BASH_DEFAULT_TIMEOUT_MS = "300000";
    #   BASH_MAX_TIMEOUT_MS = "1200000";
    #   CLAUDE_BASH_MAINTAIN_PROJECT_WORKING_DIR = "1";
    #   MAX_MCP_OUTPUT_TOKENS = "50000";
    #   MCP_TOOL_TIMEOUT = "120000";
    #   CLAUDE_CODE_MAX_OUTPUT_TOKENS = "32000";
    #   CLAUDE_CODE_AUTO_CONNECT_IDE = "0";
    #   CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC = "1";
    #   CLAUDE_CODE_ENABLE_TELEMETRY = "0";
    #   CLAUDE_CODE_IDE_SKIP_AUTO_INSTALL = "1";
    #   CLAUDE_CODE_IDE_SKIP_VALID_CHECK = "1";
    #   DISABLE_AUTOUPDATER = "1";
    #   DISABLE_ERROR_REPORTING = "1";
    #   DISABLE_INTERLEAVED_THINKING = "1";
    #   DISABLE_MICROCOMPACT = "1";
    #   DISABLE_NON_ESSENTIAL_MODEL_CALLS = "1";
    #   DISABLE_TELEMETRY = "1";
    # };

    # hooks = {
    #   Stop = [
    #     {
    #       hooks = [
    #         {
    #           type = "command";
    #           command = "terminal-notifier -message '🛑 claude-code halted' -title 'Claude Code' -sound Blow";
    #         }
    #       ];
    #     }
    #   ];
    # };

    # MCP servers (passed via --mcp-config flag)
    mcpServers = mcpServersConfig // customMcpServers;

    # ===========================================================================
    # Skills - Specialized capabilities for Claude Code
    # ===========================================================================
    skills = {
      # Nix ecosystem expert for dotfiles, darwin, home-manager, and project flakes
      nix = ''
        ---
        name: nix
        description: Expert help with Nix, nix-darwin, home-manager, flakes, and nixpkgs. Use for dotfiles configuration, package management, module development, hash fetching, debugging evaluation errors, and understanding Nix idioms and patterns.
        tools: Bash, Read, Grep, Glob, Edit, Write, WebFetch, WebSearch
        ---

        # Nix Ecosystem Expert

        ## Overview

        You are a Nix expert specializing in:
        - **nix-darwin** for macOS system configuration
        - **home-manager** for user environment management
        - **Flakes** for reproducible builds and dependency management
        - **nixpkgs** for package definitions and overlays
        - **Development shells** for project-specific environments

        ## User's Environment

        - **Platform**: macOS (aarch64-darwin)
        - **Dotfiles**: `~/.dotfiles-nix/` (flake-based)
        - **Rebuild command**: `sudo darwin-rebuild switch --flake ~/.dotfiles-nix`
        - **Package search**: `nix search nixpkgs#<package>`

        ## Key Paths

        ```
        ~/.dotfiles-nix/
        ├── flake.nix              # Main flake entry point
        ├── flake.lock             # Locked dependencies
        ├── hosts/                 # Per-machine configs
        │   └── megabookpro.nix
        ├── home/                  # Home-manager configs
        │   ├── default.nix        # Entry point
        │   ├── lib.nix            # config.lib.mega helpers
        │   ├── packages.nix       # User packages
        │   └── programs/          # Program-specific configs
        ├── modules/               # System-level darwin modules
        ├── lib/                   # Custom Nix functions
        │   ├── default.nix        # mkApp, mkMas, brew-alias, etc.
        │   └── mkSystem.nix       # System builder
        ├── pkgs/                  # Custom package derivations
        ├── overlays/              # Package overlays
        └── config/                # Out-of-store configs (symlinked)
        ```

        ## Common Tasks

        ### 1. Validate Configuration

        ```bash
        # Quick syntax/eval check (no build)
        nix flake check --no-build

        # Full check with build
        nix flake check

        # Show what would be built
        nix build .#darwinConfigurations.megabookpro.system --dry-run
        ```

        ### 2. Rebuild System

        ```bash
        # Standard rebuild (preferred - clean output)
        sudo darwin-rebuild switch --flake .

        # With verbose output for debugging
        sudo darwin-rebuild switch --flake . --show-trace

        # Build without switching (test)
        darwin-rebuild build --flake .
        ```

        ### 3. Fetch Hashes for Packages

        ```bash
        # For fetchFromGitHub
        nix-prefetch-github owner repo --rev <commit-or-tag>

        # For fetchurl (URLs)
        nix-prefetch-url <url>

        # For fetchzip
        nix-prefetch-url --unpack <url>

        # For any fetcher (using nix hash)
        nix hash to-sri --type sha256 <hash>

        # Quick SRI hash from URL
        nix-prefetch-url <url> 2>/dev/null | xargs nix hash to-sri --type sha256
        ```

        ### 4. Search Packages

        ```bash
        # Search nixpkgs (native)
        nix search nixpkgs#<query>

        # Search with JSON output (for scripting)
        nix search nixpkgs#<query> --json

        # Show package info
        nix eval nixpkgs#<package>.meta.description --raw

        # List package outputs
        nix eval nixpkgs#<package>.outputs --json

        # Using nh (preferred - faster, prettier output)
        nh search <query>
        ```

        ### 5. Using nh (Yet Another Nix Helper)

        `nh` provides a nicer UX for common nix operations:

        ```bash
        # Search packages (faster than nix search)
        nh search <query>

        # Darwin rebuild (equivalent to darwin-rebuild switch --flake .)
        nh darwin switch .
        nh darwin switch ~/.dotfiles-nix

        # Build without switching
        nh darwin build .

        # With diff showing what changed
        nh darwin switch . --diff

        # Home-manager operations
        nh home switch .

        # Clean old generations
        nh clean all          # Clean everything
        nh clean all --keep 5 # Keep last 5 generations
        ```

        ### 6. Using NUR (Nix User Repository)

        NUR provides community packages not in nixpkgs:

        ```bash
        # Search NUR packages online
        # https://nur.nix-community.org/

        # In flake.nix, add NUR input then use:
        # nur.repos.<user>.<package>
        ```

        ### 7. Debug Evaluation Errors

        ```bash
        # Show full trace
        nix eval .#darwinConfigurations.megabookpro.config --show-trace

        # Enter REPL for exploration
        nix repl
        :lf .  # Load flake
        darwinConfigurations.megabookpro.config.<path>

        # Check specific module
        nix eval .#darwinConfigurations.megabookpro.config.home-manager.users.seth.<option>
        ```

        ### 8. Working with Project Flakes

        ```bash
        # Initialize new flake
        nix flake init

        # Enter dev shell
        nix develop

        # Run from flake
        nix run .#<app>

        # Build package
        nix build .#<package>

        # Update flake inputs
        nix flake update

        # Update specific input
        nix flake update <input-name>
        ```

        ## Nix Language Patterns

        ### Option Definitions (for modules)

        ```nix
        options.services.myservice = {
          enable = lib.mkEnableOption "my service";
          port = lib.mkOption {
            type = lib.types.port;
            default = 8080;
            description = "Port to listen on";
          };
        };
        ```

        ### Conditional Attributes

        ```nix
        # mkIf for conditional config
        config = lib.mkIf config.services.myservice.enable {
          # ...
        };

        # optionalAttrs for conditional attrsets
        { } // lib.optionalAttrs condition { key = value; }

        # optional for conditional list items
        [ ] ++ lib.optional condition item
        ++ lib.optionals condition [ item1 item2 ]
        ```

        ### Package Overrides

        ```nix
        # Override package inputs
        pkg.override { dependency = newDep; }

        # Override derivation attributes
        pkg.overrideAttrs (old: {
          version = "2.0";
          src = newSrc;
        })

        # Override python packages
        python3.withPackages (ps: [ ps.requests ps.numpy ])
        ```

        ### Fetchers

        ```nix
        # GitHub
        fetchFromGitHub {
          owner = "owner";
          repo = "repo";
          rev = "v1.0.0";  # or commit SHA
          sha256 = "sha256-AAAA...";  # SRI format
        }

        # URL
        fetchurl {
          url = "https://example.com/file.tar.gz";
          sha256 = "sha256-AAAA...";
        }

        # Git (for specific refs)
        fetchgit {
          url = "https://github.com/owner/repo";
          rev = "abc123";
          sha256 = "sha256-AAAA...";
        }
        ```

        ## Home-Manager Patterns

        ### XDG Config Files

        ```nix
        # In-store (immutable, from nix expression)
        xdg.configFile."app/config".text = "content";
        xdg.configFile."app/config".source = ./path/to/file;

        # Out-of-store (mutable, symlinked)
        xdg.configFile."app".source = config.lib.mega.linkConfig "app";
        ```

        ### Programs Module

        ```nix
        programs.git = {
          enable = true;
          userName = "Name";
          extraConfig = {
            init.defaultBranch = "main";
          };
        };
        ```

        ### Activation Scripts

        ```nix
        home.activation.myScript = lib.hm.dag.entryAfter ["writeBoundary"] '''
          # Shell script here
          mkdir -p $HOME/.local/share/myapp
        ''';
        ```

        ## Darwin-Specific

        ### System Defaults

        ```nix
        system.defaults = {
          dock.autohide = true;
          finder.AppleShowAllFiles = true;
          NSGlobalDomain = {
            AppleKeyboardUIMode = 3;
            InitialKeyRepeat = 15;
            KeyRepeat = 2;
          };
        };
        ```

        ### Homebrew Integration

        ```nix
        homebrew = {
          enable = true;
          onActivation.cleanup = "zap";
          brews = [ "mas" ];
          casks = [ "firefox" ];
          masApps = { "Xcode" = 497799835; };
        };
        ```

        ## User's Custom Helpers (lib.mega namespace)

        All custom helpers are under `lib.mega.*`:

        **In `lib/default.nix` (flake-level):**
        - `lib.mega.mkApp` - Build macOS apps from DMG/ZIP/PKG
        - `lib.mega.mkApps` - Build multiple apps from a list
        - `lib.mega.mkMas` - Install Mac App Store apps
        - `lib.mega.mkAppActivation` - Symlink apps to /Applications
        - `lib.mega.brewAlias` - Create wrappers for Homebrew binaries
        - `lib.mega.capitalize` - Capitalize first letter of string
        - `lib.mega.compactAttrs` - Filter null values from attrset
        - `lib.mega.imports` - Smart module path resolution

        **In `home/lib.nix` (home-manager module, via `config.lib.mega`):**
        - `config.lib.mega.linkConfig "path"` - Symlink to `~/.dotfiles-nix/config/{path}`
        - `config.lib.mega.linkHome "path"` - Symlink to `~/.dotfiles-nix/home/{path}`
        - `config.lib.mega.linkBin` - Symlink to `~/.dotfiles-nix/bin`
        - `config.lib.mega.linkDotfile "path"` - Generic dotfiles symlink

        ## Best Practices

        1. **Use `lib.mkDefault`** for overridable defaults
        2. **Use `lib.mkForce`** sparingly (only when necessary)
        3. **Prefer `lib.mkIf`** over inline conditionals for clarity
        4. **Use SRI hashes** (`sha256-...`) not old hex format
        5. **Pin flake inputs** for reproducibility
        6. **Use overlays** for package modifications, not inline overrides
        7. **Separate concerns**: system config in modules/, user config in home/

        ## Debugging Tips

        1. **Infinite recursion**: Usually caused by self-referential options. Use `--show-trace`
        2. **Attribute not found**: Check spelling, imports, and that module is loaded
        3. **Hash mismatch**: Use `nix-prefetch-*` tools to get correct hash
        4. **Build failures**: Check `nix log /nix/store/<drv>` for build logs

        ## Common Gotchas

        - `home.file` vs `xdg.configFile` - former is `$HOME/`, latter is `~/.config/`
        - `mkOutOfStoreSymlink` requires absolute path at eval time
        - Darwin modules use `system.*`, not `services.*` for most things
        - `environment.systemPackages` is system-wide, `home.packages` is per-user
      '';

      # Smart notification system with deep knowledge of the notifier script
      # and Hammerspoon integration for multi-channel notifications
      smart-notifier = ''
        ---
        name: smart-notifier
        description: Send intelligent notifications via ~/bin/notifier with context-aware channel selection. Use when completing tasks, asking questions, encountering errors, or reaching milestones.
        tools: Bash
        ---

        # Smart Notification System

        ## Overview

        You have access to a sophisticated multi-channel notification system via `~/bin/notifier`. This skill helps you make smart decisions about when and how to notify the user.

        ## Quick Reference

        ```bash
        # Basic notification (requires 'notify' subcommand!)
        notifier notify -t "Title" -m "Message"

        # With urgency levels: normal|high|critical
        notifier notify -t "Title" -m "Message" -u high

        # Send to phone via Pushover (for remote notifications)
        notifier notify -t "Title" -m "Message" -P true

        # Question that may need retry
        notifier notify -t "Question" -m "Should I continue?" -q true
        ```

        ## Notification Channels

        The notifier automatically routes based on user attention:

        1. **Canvas Notification** - On-screen overlay (HAL 9000 icon)
           - Normal: Bottom-left, 5 seconds
           - High/Critical: Center screen with dimmed background

        2. **macOS Notification Center** - Always sent for logging
           - Captured by Hammerspoon watcher
           - Logged to SQLite: `~/.local/share/hammerspoon/hammerspoon.db`

        3. **Pushover** - Remote phone notification
           - Auto-sent on `critical` urgency
           - Or explicitly with `-P true`

        4. **iMessage** - Direct to user's phone
           - Auto-sent on `critical` urgency
           - Or explicitly with `-p true`

        ## Urgency Guidelines

        | Situation | Urgency | Why |
        |-----------|---------|-----|
        | Task completed successfully | `normal` | User will see canvas |
        | Task completed with warnings | `high` | Draw more attention |
        | Task failed/error | `critical` | Sends to phone too |
        | Question needing answer | `high` | Centered, prominent |
        | Security vulnerability found | `critical` | Always notify phone |
        | Long task progress update | `normal` | Non-intrusive |

        ## When to Send Notifications

        **DO send for:**
        - Task completion (especially long-running)
        - Errors requiring user attention
        - Questions needing user input
        - Significant milestones
        - Security findings

        **DON'T send for:**
        - Minor steps completed
        - Info user is actively watching
        - Debugging output
        - Redundant status updates

        ## Message Best Practices

        1. **Titles:** Keep under 50 characters, be specific
        2. **Messages:** Keep under 200 characters, include key details
        3. **Include metrics:** "42 tests passed in 3.2s" not just "Tests passed"
        4. **Be actionable:** "Check logs at /tmp/build.log" not just "Error occurred"

        ## Attention Detection

        The notifier automatically detects if you're paying attention:
        - Checks if terminal app is frontmost
        - Checks current tmux session/window
        - Checks display state (asleep/locked)

        If user IS paying attention → subtle NC notification only
        If user NOT paying attention → canvas overlay + NC + optional remote

        ## Examples

        ```bash
        # Task completed
        notifier notify -t "Build Complete" -m "42 tests passed, 0 failures in 3.2s"

        # Error with high urgency
        notifier notify -t "Build Failed" -m "3 type errors in src/auth.ts:45,78,123" -u high

        # Critical security finding (auto-sends to phone)
        notifier notify -t "Security Alert" -m "Found hardcoded API key in config.js" -u critical

        # Question for user
        notifier notify -t "Clarification Needed" -m "Should I refactor the auth module or just fix the bug?" -u high -q true
        ```

        ## Related Files

        - `~/bin/notifier` - Main notification script
        - `~/.dotfiles-nix/config/hammerspoon/lib/notifications/notifier.lua` - Canvas rendering
        - `~/.dotfiles-nix/config/hammerspoon/watchers/notification.lua` - NC capture
        - `~/.local/share/hammerspoon/hammerspoon.db` - Notification history

        ## Troubleshooting

        If notifications aren't appearing:
        1. Check Hammerspoon is running: `pgrep Hammerspoon`
        2. Check hs CLI works: `hs -c "print('hello')"`
        3. Verify permissions: System Settings → Notifications → Hammerspoon
      '';
    };
  };

  # Directory for MCP memory server storage
  home.file.".local/share/claude/.keep".text = "";

  # Symlink chrome-devtools-mcp binary to ~/.local/bin (for manual use)
  home.activation.linkAiBinaries = lib.hm.dag.entryAfter ["writeBoundary"] ''
    BIN_DIR="${config.home.homeDirectory}/.local/bin"
    mkdir -p "$BIN_DIR"

    # chrome-devtools-mcp
    rm -f "$BIN_DIR/chrome-devtools-mcp" 2>/dev/null || true
    ln -sf "${pkgs.chrome-devtools-mcp}/bin/chrome-devtools-mcp" "$BIN_DIR/chrome-devtools-mcp"
  '';

  # ===========================================================================
  # OpenCode Configuration
  # ===========================================================================
  xdg.configFile."opencode/opencode.json".text = ''
    {
      "$schema": "https://opencode.ai/config.json",
      "instructions": [
        "CLAUDE.md"
      ],
      "theme": "everforest",
      "model": "anthropic/claude-opus-4.5",
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
}
