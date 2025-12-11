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
