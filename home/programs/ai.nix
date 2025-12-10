# AI Tools Configuration
#
# Centralizes all AI-related tooling:
#   - Claude Code (CLI, config, MCP servers)
#   - OpenCode (config)
#   - MCP servers (filesystem, git, memory, etc.)
#
# Package definitions remain in pkgs/ - this file handles home-manager config only.
{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: let
  # ===========================================================================
  # MCP Servers Configuration
  # ===========================================================================
  # Generate MCP servers config using mcp-servers-nix lib
  # This creates a nix store file with proper paths without adding packages to buildEnv
  # (MCP server packages conflict due to shared node_modules paths)
  mcpConfigFile = inputs.mcp-servers-nix.lib.mkConfig pkgs {
    programs = {
      filesystem = {
        enable = false;
        args = [
          config.home.homeDirectory
          "${config.home.homeDirectory}/code"
          "${config.home.homeDirectory}/src"
          "${config.home.homeDirectory}/.dotfiles-nix"
        ];
      };
      fetch.enable = false;
      git.enable = false;
      memory = {
        enable = true;
        env.MEMORY_FILE_PATH = "${config.home.homeDirectory}/.local/share/claude/memory.jsonl";
      };
      time.enable = false;
      context7.enable = true;
      playwright.enable = false;
    };
    # Custom servers not in mcp-servers-nix
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
  # ===========================================================================
  # AI Tool Packages
  # ===========================================================================
  home.packages = with pkgs; [
    ai-tools.opencode
    ai-tools.claude-code
    ai-tools.claude-code-acp
    # Note: chrome-devtools-mcp is referenced by path in MCP config, not installed
    # to avoid node_modules conflicts with other MCP servers
  ];

  # ===========================================================================
  # Claude Code Configuration
  # ===========================================================================

  # Directory for MCP memory server storage
  home.file.".local/share/claude/.keep".text = "";

  # Personal instructions for Claude Code
  home.file.".claude/CLAUDE.md".text = ''
    ## Your response and general tone

    - Never compliment me.
    - Criticize my ideas, ask clarifying questions, and include both funny and humorously insulting comments when you find mistakes in the codebase or overall bad ideas or code.
    - Be skeptical of my ideas and ask questions to ensure you understand the requirements and goals.
    - Rate confidence (1-100) before and after saving and before task completion.

    ## Your required tasks for every conversation
    - You are to always utilize the `~/bin/notifier` script to interact with me, taking special note of your ability to utilize tools on this system to determine which notification method(s) to use at any given moment.
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

  # Symlink chrome-devtools-mcp binary to ~/.local/bin
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
