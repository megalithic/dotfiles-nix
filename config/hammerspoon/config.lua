local M = {}

HYPER = "F19"

BROWSER = "com.brave.Browser.nightly"
TERMINAL = "com.mitchellh.ghostty"

---@class NotificationRule
---@field name string                   # Human-readable name for the rule
---@field app string                    # Bundle ID or stacking ID to match
---@field senders? string[]             # Optional: list of sender names to match (exact match)
---@field patterns? table<"low"|"normal"|"high", string[]> # Patterns mapped to priorities (default: normal if no match)
---@field duration? number              # How long to show notification in seconds
---@field alwaysShowInTerminal? boolean # Show even when terminal is focused (high priority only)
---@field showWhenAppFocused? boolean   # Show even when source app is focused (high priority only)
---@field allowedFocusModes? (string|nil)[] # Focus modes where notification is allowed (nil = no focus mode)
---@field appBundleID? string           # Override bundle ID for icon display
---@field action fun(title: string, subtitle: string, message: string, stackingID: string, bundleID: string) # Action to execute when rule matches

M.notifier = {
  rules = {
    -- Notification Routing Rules
    -- Rules are evaluated in order. First match wins.
    -- Rules can be either:
    --   1. A table (for simple static rules)
    --   2. A function that returns a table (for dynamic rules with closures)
    function()
      local rule = {
        name = "Important Messages - Abby",
        app = "com.apple.MobileSMS",
        senders = { "Abby Messer" },
        duration = 15,
        patterns = {
          high = {
            "%?",
            "👋",
            "❓",
            "‼️",
            "⚠️",
            "urgent",
            "asap",
            "emergency",
            "!+$",
            "%?+$",
          },
          low = {
            "brb",
            "k",
            "ok",
            "👍",
            "lol",
          },
          -- Everything else defaults to "normal"
        },
        alwaysShowInTerminal = true,
        showWhenAppFocused = false,
        allowedFocusModes = { nil, "Personal" },
      }
      rule.action = function(title, subtitle, message, stackingID, bundleID)
        local NotificationProcessor = require("notification")
        NotificationProcessor.processRule(rule, title, subtitle, message, stackingID, bundleID)
      end
      return rule
    end,

    -- Example: All other Messages notifications (lower priority)
    {
      name = "Messages - General",
      app = "com.apple.MobileSMS",
      -- No allowedFocusModes = always show, no focus check
      action = function(title, subtitle, message, stackingID, bundleID)
        -- Default behavior: let macOS show the notification
        -- We just log it to the database for tracking
        NotifyDB.log({
          timestamp = os.time(),
          rule_name = "Messages - General",
          app_id = stackingID,
          sender = title,
          subtitle = subtitle,
          message = message,
          action_taken = "macos_default",
          focus_mode = nil,
          shown = true,
        })
      end,
    },

    -- AI Agent Notifications (from bin/notifier via hs.notify)
    function()
      local rule = {
        name = "AI Agent Notifications",
        app = "org.hammerspoon.Hammerspoon",
        duration = 10,
        patterns = {
          high = {
            "error",
            "failed",
            "critical",
            "urgent",
            "question",
            "%?",
            "!!!",
            "‼️",
            "⚠️",
          },
          low = {
            "info",
            "debug",
            "starting",
            "completed",
            "finished",
          },
          -- Everything else defaults to "normal"
        },
        alwaysShowInTerminal = true,
        showWhenAppFocused = false,
        allowedFocusModes = { nil, "Personal", "Work" },
        appBundleID = "hal9000", -- Special marker for HAL icon
      }
      rule.action = function(title, subtitle, message, stackingID, bundleID)
        local NotificationProcessor = require("notification")
        NotificationProcessor.processRule(rule, title, subtitle, message, stackingID, bundleID)
      end
      return rule
    end,

    -- Example: Build notifications with pattern-based priority
    function()
      local rule = {
        name = "Build System Notifications",
        app = "com.example.buildapp",
        duration = 5,
        patterns = {
          high = {
            "failed",
            "error",
            "fatal",
            "broke",
          },
          low = {
            "started",
            "building",
            "compiling",
            "running",
          },
          -- "succeeded", "completed" = normal (default)
        },
        allowedFocusModes = { nil, "Work" },
      }
      rule.action = function(title, subtitle, message, stackingID, bundleID)
        local NotificationProcessor = require("notification")
        NotificationProcessor.processRule(rule, title, subtitle, message, stackingID, bundleID)
      end
      return rule
    end,
  },
  config = {
    -- Notification positioning configuration

    -- Vertical offsets (in pixels) from bottom of screen for different programs
    -- These values account for typical prompt heights in each program
    -- NOTE: Programs with expanding UI (thinking indicators, token counters) need extra padding
    offsets = {
      nvim = 100, -- Neovim: minimal offset (statusline at bottom, no prompt)
      vim = 100, -- Vim: same as neovim
      ["nvim-diff"] = 100,
      fish = 350, -- Fish: multiline prompt with git info
      bash = 300, -- Bash: standard prompt
      zsh = 300, -- Zsh: standard prompt
      claude = 155, -- Claude Code: optimized via screenshot testing with expanding UI (prompt + thinking + tokens)
      ["claude-code"] = 155, -- Claude Code: AI coding assistant with expanding prompt UI
      opencode = 155, -- OpenCode: AI coding assistant with expanding prompt UI
      lazygit = 200, -- Lazygit: status bar at bottom
      htop = 150, -- htop: minimal UI at bottom
      btop = 150, -- btop: minimal UI at bottom
      node = 155, -- Node.js (fallback for claude-code, opencode)
      default = 200, -- Default for unknown programs
    },
    -- Whether to apply offset adjustment when tmux is detected
    tmuxShiftEnabled = true,
    -- Default positioning mode: "auto" | "fixed" | "above-prompt"
    -- "auto": intelligently detects program and applies appropriate offset
    -- "fixed": uses only the verticalOffset parameter from notification call
    -- "above-prompt": estimates prompt height based on terminal dimensions
    positionMode = "auto",
    -- Minimum offset to ensure notification is always visible
    minOffset = 100,
    -- Default notification duration (in seconds)
    defaultDuration = 5,
    -- Animation settings
    animation = {
      enabled = true, -- Enable slide-up animation from bottom of screen
      duration = 0.3, -- Animation duration in seconds (0.3 = smooth, 0.5 = slower)
    },
  },
}

M.displays = {
  internal = "Built-in Retina Display",
  laptop = "Built-in Retina Display",
  external = "LG UltraFine",
}

M.grid = {
  full = "0,0 60x20",
  preview = "0,0 60x2",

  center = {
    large = "6,1 48x18",
    medium = "12,1 36x18",
    small = "16,2 28x16",
    tiny = "18,3 24x12",
    mini = "22,4 16x10",
  },

  sixths = {
    left = "0,0 10x20",
    right = "50,0 10x20",
  },

  thirds = {
    left = "0,0 20x20",
    center = "20,0 20x20",
    right = "40,0 20x20",
  },

  halves = {
    left = "0,0 30x20",
    right = "30,0 30x20",
  },

  twoThirds = {
    left = "0,0 40x20",
    right = "20,0 40x20",
  },

  fiveSixths = {
    left = "0,0 50x20",
    right = "10,0 50x20",
  },
}

M.layouts = {
  --- [bundleID] = { name, bundleID, {{ winTitle, screenNum, gridPosition }} }
  ["com.raycast.macos"] = {
    name = "Raycast",
    bundleID = "com.raycast.macos",
    rules = {
      { nil, 1, M.grid.center.large },
    },
  },
  ["net.kovidgoyal.kitty"] = {
    bundleID = "net.kovidgoyal.kitty",
    name = "kitty",
    rules = {
      { "", 1, M.grid.full },
    },
  },
  ["com.github.wez.wezterm"] = {
    bundleID = "com.github.wez.wezterm",
    name = "wezterm",
    rules = {
      { "", 1, M.grid.full },
    },
  },
  ["com.mitchellh.ghostty"] = {
    bundleID = "com.mitchellh.ghostty",
    name = "ghostty",
    rules = {
      { "Software Update", 1, M.grid.center.small },
      { "", 1, M.grid.full },
    },
  },
  ["com.kagi.kagimacOS"] = {
    bundleID = "com.kagi.kagimacOS",
    name = "Orion",
    rules = {
      { "", 1, M.grid.full },
    },
  },
  ["org.mozilla.floorp"] = {
    bundleID = "org.mozilla.floorp",
    name = "Floorp",
    rules = {
      { "", 1, M.grid.full },
    },
  },
  ["com.brave.Browser.nightly"] = {
    bundleID = "com.brave.Browser.nightly",
    name = "Brave Browser Nightly",
    rules = {
      { "", 1, M.grid.full },
    },
  },
  ["com.brave.Browser.dev"] = {
    bundleID = "com.brave.Browser.dev",
    name = "Brave Browser Dev",
    rules = {
      { "", 1, M.grid.full },
    },
  },
  ["com.apple.Safari"] = {
    bundleID = "com.apple.Safari",
    name = "Safari",
    rules = {
      { "", 2, M.grid.full },
    },
  },
  ["com.apple.SafariTechnologyPreview"] = {
    bundleID = "com.apple.SafariTechnologyPreview",
    name = "Safari Technology Preview",
    rules = {
      { "", 2, M.grid.full },
    },
  },
  ["org.chromium.Thorium"] = {
    bundleID = "org.chromium.Thorium",
    name = "Thorium",
    rules = {
      { "", 1, M.grid.full },
    },
  },
  ["org.chromium.Chromium"] = {
    bundleID = "org.chromium.Chromium",
    name = "Chromium",
    rules = {
      { "", 1, M.grid.full },
    },
  },
  ["org.mozilla.firefoxdeveloperedition"] = {
    bundleID = "org.mozilla.firefoxdeveloperedition",
    name = "Firefox Developer Edition",
    rules = {
      { "", 2, M.grid.full },
    },
  },
  ["com.kapeli.dashdoc"] = {
    bundleID = "com.kapeli.dashdoc",
    name = "Dash",
    rules = {
      { "", 1, M.grid.full },
    },
  },
  ["com.obsproject.obs-studio"] = {
    bundleID = "com.obsproject.obs-studio",
    name = "OBS Studio",
    rules = {
      { "", 2, M.grid.full },
    },
  },
  ["co.detail.mac"] = {
    bundleID = "co.detail.mac",
    name = "Detail",
    rules = {
      { "", 2, M.grid.full },
    },
  },
  ["com.freron.MailMate"] = {
    bundleID = "com.freron.MailMate",
    name = "MailMate",
    rules = {
      { nil, 2, M.grid.halves.left },
      { "Inbox", 2, M.grid.full },
      { "All Messages", 2, M.grid.full },
    },
  },
  ["com.apple.finder"] = {
    bundleID = "com.apple.finder",
    name = "Finder",
    rules = {
      { "", 1, M.grid.center.medium },
    },
  },
  ["com.spotify.client"] = {
    bundleID = "com.spotify.client",
    name = "Spotify",
    rules = {
      { "", 2, M.grid.halves.right },
    },
  },
  ["com.electron.postbird"] = {
    bundleID = "com.electron.postbird",
    name = "Postbird",
    rules = {
      { "", 1, M.grid.center.large },
    },
  },
  ["com.apple.MobileSMS"] = {
    bundleID = "com.apple.MobileSMS",
    name = "Messages",
    rules = {
      -- { "", 2, M.grid.full },
      -- { "", 2, M.grid.thirds.left },
      { "", 2, M.grid.halves.left },
    },
  },
  ["org.whispersystems.signal-desktop"] = {
    bundleID = "org.whispersystems.signal-desktop",
    name = "Signal",
    rules = {
      { "", 2, M.grid.halves.right },
    },
  },
  ["com.tinyspeck.slackmacgap"] = {
    bundleID = "com.tinyspeck.slackmacgap",
    name = "Slack",
    rules = {
      { nil, 2, M.grid.full },
    },
  },
  ["com.agilebits.onepassword7"] = {
    bundleID = "com.1password.1password",
    name = "1Password",
    rules = {
      { nil, 1, M.grid.center.medium },
    },
  },
  ["org.hammerspoon.Hammerspoon"] = {
    bundleID = "org.hammerspoon.Hammerspoon",
    name = "Hammerspoon",
    rules = {
      { nil, 1, M.grid.full },
    },
  },
  ["com.dexterleng.Homerow"] = {
    bundleID = "com.dexterleng.Homerow",
    name = "Homerow",
    rules = {
      { nil, 1, M.grid.center.large },
    },
  },
  ["com.flexibits.fantastical2.mac"] = {
    bundleID = "com.flexibits.fantastical2.mac",
    name = "Fantastical",
    rules = {
      { nil, 1, M.grid.center.large },
    },
  },
  ["com.figma.Desktop"] = {
    bundleID = "com.figma.Desktop",
    name = "Figma",
    rules = {
      { nil, 1, M.grid.full },
    },
  },
  ["com.apple.iphonesimulator"] = {
    bundleID = "com.apple.iphonesimulator",
    name = "iPhone Simulator",
    rules = {
      { nil, 1, M.grid.halves.right },
    },
  },
  ["com.softfever3d.orca-slicer"] = {
    bundleID = "com.softfever3d.orca-slicer",
    name = "OrcaSlicer",
    rules = {
      { "", 1, M.grid.full },
    },
  },
}

M.quitters = {
  "org.chromium.Thorium",
  "org.chromium.Chromium",
  "Brave Browser Nightly",
  "com.pop.pop.app",
  "com.kagi.kagimacOS",
  "com.brave.Browser.nightly",
  "com.brave.Browser.dev",
  "com.brave.Browser",
  "com.raycast.macos",
  "com.runningwithcrayons.Alfred",
  "net.kovidgoyal.kitty",
  "org.mozilla.firefoxdeveloperedition",
  "com.apple.SafariTechnologyPreview",
  "com.apple.Safari",
  "com.mitchellh.ghostty",
  "com.github.wez.wezterm",
}

M.lollygaggers = {
  --- [bundleID] = { hideAfter, quitAfter }
  ["org.hammerspoon.Hammerspoon"] = { 1, nil },
  ["com.flexibits.fantastical2.mac"] = { 1, nil },
  ["com.1password.1password"] = { 1, nil },
  ["com.spotify.client"] = { 1, nil },
}

M.launchers = {
  { "com.brave.Browser.nightly", "j", nil },
  { "com.mitchellh.ghostty", "k", { "`" } },
  -- { "net.kovidgoyal.kitty", "k", nil },
  { "com.apple.MobileSMS", "m", nil }, -- NOOP for now.. TODO: implement a binding feature that let's us require n-presses before we execute
  { "com.apple.finder", "f", nil },
  { "com.spotify.client", "p", nil },
  { "com.freron.MailMate", "e", nil },
  { "com.flexibits.fantastical2.mac", "y", { "'" } },
  { "com.raycast.macos", "space", { "c" } },
  { "com.superultra.Homerow", nil, { ";" } },
  { "com.tinyspeck.slackmacgap", "s", nil },
  { "com.microsoft.teams2", "t", nil },
  { "org.hammerspoon.Hammerspoon", "r", nil },
  { "com.apple.dt.Xcode", "x", nil },
  -- { "com.kapeli.dashdoc", { { "shift" }, "d" }, { "d" } },
  { "com.electron.postbird", { { "shift" }, "p" }, nil },
  { "com.1password.1password", "1", nil },

  { "com.google.android.studio", "x", nil, true },
  { "com.obsproject.obs-studio", "o", nil, true },
  { "com.microsoft.VSCode", "v", nil, true },
}

M.dock = {
  target = {
    productID = 39536,
    productName = "LG UltraFine Display Controls",
    vendorID = 1086,
    vendorName = "LG Electronics Inc.",
  },
  target_alt = {
    productID = 21760,
    productName = "TS4 USB3.2 Gen2 HUB",
    vendorID = 8584,
    vendorName = "CalDigit, Inc",
  },
  keyboard = {
    connected = "leeloo",
    disconnected = "internal",
    productID = 24926,
    productName = "Leeloo",
    vendorID = 7504,
    vendorName = "ZMK Project",
  },
  docked = {
    wifi = "off",
    input = "Samson GoMic",
    output = "megabose",
  },
  undocked = {
    wifi = "on",
    input = "megabose",
    output = "megabose",
  },
}

return M
