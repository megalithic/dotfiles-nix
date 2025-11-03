local con = hs.console
local wf = hs.window.filter
local aw = hs.application.watcher

local M = {}
-- local u = require("utils")

hs.allowAppleScript(true)
hs.application.enableSpotlightForNameSearches(false)
hs.autoLaunch(true)
hs.automaticallyCheckForUpdates(true)
hs.menuIcon(true)
hs.dockIcon(true)
hs.logger.defaultLogLevel = "error"
hs.hotkey.setLogLevel("error")
hs.hotkey.setLogLevel(0) ---@diagnostic disable-line: undefined-field https://github.com/Hammerspoon/hammerspoon/issues/3491
hs.keycodes.log.setLogLevel("error")
hs.window.animationDuration = 0.0
hs.window.highlight.ui.overlay = false
hs.window.setShadows(false)
hs.grid.setGrid("60x20")
hs.grid.setMargins("0x0")

---------------------------------------------------------------------------------------------------
DefaultFont = { name = "JetBrainsMono Nerd Font Mono", size = 18 }
function Red(isDark)
  if isDark then
    -- return { red = 1, green = 0, blue = 0 }
    return { hex = "#f6757c", alpha = 1 }
  end
  return { red = 0.7, green = 0, blue = 0 }
end
function Yellow(isDark)
  if isDark then
    return { red = 1, green = 1, blue = 0 }
  end
  return { red = 0.7, green = 0.5, blue = 0 }
end
function Orange(isDark)
  return { hex = "#ef9672", alpha = 1 }
end
function Green(isDark)
  return { hex = "#a7c080", alpha = 1 }
end
function Base(isDark)
  if isDark then
    return { white = 0.6 }
  end
  return { white = 0.1 }
end
function Grey(isDark)
  if isDark then
    -- return { white = 0.45 }
    return { hex = "#444444", alpha = 1 }
  end
  return { white = 0.55 }
end
function Blue(isDark)
  if isDark then
    -- return { red = 0, green = 0.7, blue = 1 }
    return { hex = "#51afef", alpha = 0.65 }
  end
  return { red = 0, green = 0.1, blue = 0.5 }
end
con.titleVisibility("hidden")
con.toolbar(nil)
hs.consoleOnTop(false) -- buggy?
con.darkMode(true)
con.consoleFont(DefaultFont)
con.alpha(0.985)
local darkGrayColor = { red = 26 / 255, green = 28 / 255, blue = 39 / 255, alpha = 1.0 }
local whiteColor = { white = 1.0, alpha = 1.0 }
local lightGrayColor = { white = 1.0, alpha = 0.9 }
local grayColor = { red = 24 * 4 / 255, green = 24 * 4 / 255, blue = 24 * 4 / 255, alpha = 1.0 }
con.outputBackgroundColor(darkGrayColor)
-- con.outputBackgroundColor({ hex = "#2c353d" })
con.consoleCommandColor(whiteColor)
con.consoleResultColor(lightGrayColor)
con.consolePrintColor(grayColor)
---filter console entries, removing logging for enabling/disabling hotkeys,
---useless layout info or warnings, or info on extension loading.
-- HACK to fix https://www.reddit.com/r/hammerspoon/comments/11ao9ui/how_to_suppress_logging_for_hshotkeyenable/
function M.cleanupConsole()
  local col = hs.console
  local consoleOutput = tostring(col.getConsole())
  col.clearConsole()
  local lines = hs.fnutils.split(consoleOutput, "\n+")
  if not lines then
    return
  end

  local isDark = true --U.isDarkMode()

  for _, line in ipairs(lines) do
    -- remove some lines
    local ignore = line:find("Loading extensions?: ")
      or line:find("Lazy extension loading enabled$")
      or line:find("Loading Spoon: RoundedCorners$")
      or line:find("Loading .*/init.lua$")
      or line:find("hs%.canvas:delete")
      or line:find("%-%- Done%.$")
      or line:find("wfilter: .* is STILL not registered") -- FIX https://github.com/Hammerspoon/hammerspoon/issues/3462

    -- colorize timestamp & error levels
    if not ignore then
      local timestamp, msg = line:match("(%d%d%d%d%-%d%d%-%d%d %d%d:%d%d:%d%d: )(.*)")
      if not msg then
        msg = line
      end -- msg without timestamp
      msg = msg
        :gsub("^%s-%d%d:%d%d:%d%d:? ", "") -- remove duplicate timestamp
        :gsub("^%s*", "")

      local color
      local lmsg = msg:lower()
      if msg:find("^> ") then -- user input
        color = Blue(isDark)
      elseif lmsg:find("error") or lmsg:find("fatal") then
        color = Red(isDark)
      elseif lmsg:find("ok") or lmsg:find("success") then
        color = Green(isDark)
      elseif lmsg:find("warn") or lmsg:find("warning") or msg:find("stack traceback") or lmsg:find("abort") then
        color = Orange(isDark)
      else
        color = grayColor
      end

      local coloredLine = hs.styledtext.new(msg, { color = color, font = DefaultFont })
      if timestamp then
        local time = hs.styledtext.new(timestamp, { color = Grey(isDark), font = DefaultFont })
        col.printStyledtext(time, coloredLine)
      else
        col.printStyledtext(coloredLine)
      end
    end
  end
end

-- clean up console as soon as it is opened
-- M.wf_hsConsole = wf.new("Hammerspoon"):subscribe(wf.windowFocused, function()
--   u.defer(0.1, M.cleanupConsole)
-- end)
-- M.aw_hsConsole = aw.new(function(appName, eventType)
--   if eventType == aw.activated and appName == "Hammerspoon" then
--     u.defer(0.1, M.cleanupConsole)
--   end
-- end):start()
-- Insert a separator in the console log every day at midnight
-- M.timer_dailyConsoleSeparator = hs.timer
--   .doAt("00:01", "01d", function() -- `00:01` to ensure date switched to the next day
--     local date = os.date("%a, %d. %b")
-- 		-- stylua: ignore
-- 		print(("\n------------------------- %s -----------------------------\n"):format(date))
--   end, true)
--   :start()
---------------------------------------------------------------------------------------------------

hs.alert.defaultStyle["textSize"] = 24
hs.alert.defaultStyle["radius"] = 10
hs.alert.defaultStyle["strokeColor"] = {
  white = 1,
  alpha = 0.3,
}
hs.alert.defaultStyle["fillColor"] = {
  red = 9 / 255,
  green = 8 / 255,
  blue = 32 / 255,
  alpha = 0.9,
}
hs.alert.defaultStyle["textColor"] = {
  red = 209 / 255,
  green = 236 / 255,
  blue = 240 / 255,
  alpha = 1,
}
hs.alert.defaultStyle["textFont"] = DefaultFont.name

HYPER = "F19"

BROWSER = "com.brave.Browser.nightly"
TERMINAL = "com.mitchellh.ghostty"

DISPLAYS = {
  internal = "Built-in Retina Display",
  laptop = "Built-in Retina Display",
  external = "LG UltraFine",
}

POSITIONS = {
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

LAYOUTS = {
  --- [bundleID] = { name, bundleID, {{ winTitle, screenNum, gridPosition }} }
  ["com.raycast.macos"] = {
    name = "Raycast",
    bundleID = "com.raycast.macos",
    rules = {
      { nil, 1, POSITIONS.center.large },
    },
  },
  ["net.kovidgoyal.kitty"] = {
    bundleID = "net.kovidgoyal.kitty",
    name = "kitty",
    rules = {
      { "", 1, POSITIONS.full },
    },
  },
  ["com.github.wez.wezterm"] = {
    bundleID = "com.github.wez.wezterm",
    name = "wezterm",
    rules = {
      { "", 1, POSITIONS.full },
    },
  },
  ["com.mitchellh.ghostty"] = {
    bundleID = "com.mitchellh.ghostty",
    name = "ghostty",
    rules = {
      { "Software Update", 1, POSITIONS.center.small },
      { "", 1, POSITIONS.full },
    },
  },
  ["com.kagi.kagimacOS"] = {
    bundleID = "com.kagi.kagimacOS",
    name = "Orion",
    rules = {
      { "", 1, POSITIONS.full },
    },
  },
  ["org.mozilla.floorp"] = {
    bundleID = "org.mozilla.floorp",
    name = "Floorp",
    rules = {
      { "", 1, POSITIONS.full },
    },
  },
  ["com.brave.Browser.nightly"] = {
    bundleID = "com.brave.Browser.nightly",
    name = "Brave Browser Nightly",
    rules = {
      { "", 1, POSITIONS.full },
    },
  },
  ["com.brave.Browser.dev"] = {
    bundleID = "com.brave.Browser.dev",
    name = "Brave Browser Dev",
    rules = {
      { "", 1, POSITIONS.full },
    },
  },
  ["com.apple.Safari"] = {
    bundleID = "com.apple.Safari",
    name = "Safari",
    rules = {
      { "", 2, POSITIONS.full },
    },
  },
  ["com.apple.SafariTechnologyPreview"] = {
    bundleID = "com.apple.SafariTechnologyPreview",
    name = "Safari Technology Preview",
    rules = {
      { "", 2, POSITIONS.full },
    },
  },
  ["org.chromium.Thorium"] = {
    bundleID = "org.chromium.Thorium",
    name = "Thorium",
    rules = {
      { "", 1, POSITIONS.full },
    },
  },
  ["org.chromium.Chromium"] = {
    bundleID = "org.chromium.Chromium",
    name = "Chromium",
    rules = {
      { "", 1, POSITIONS.full },
    },
  },
  ["org.mozilla.firefoxdeveloperedition"] = {
    bundleID = "org.mozilla.firefoxdeveloperedition",
    name = "Firefox Developer Edition",
    rules = {
      { "", 2, POSITIONS.full },
    },
  },
  ["com.kapeli.dashdoc"] = {
    bundleID = "com.kapeli.dashdoc",
    name = "Dash",
    rules = {
      { "", 1, POSITIONS.full },
    },
  },
  ["com.obsproject.obs-studio"] = {
    bundleID = "com.obsproject.obs-studio",
    name = "OBS Studio",
    rules = {
      { "", 2, POSITIONS.full },
    },
  },
  ["co.detail.mac"] = {
    bundleID = "co.detail.mac",
    name = "Detail",
    rules = {
      { "", 2, POSITIONS.full },
    },
  },
  ["com.freron.MailMate"] = {
    bundleID = "com.freron.MailMate",
    name = "MailMate",
    rules = {
      { nil, 2, POSITIONS.halves.left },
      { "Inbox", 2, POSITIONS.full },
      { "All Messages", 2, POSITIONS.full },
    },
  },
  ["com.apple.finder"] = {
    bundleID = "com.apple.finder",
    name = "Finder",
    rules = {
      { "", 1, POSITIONS.center.medium },
    },
  },
  ["com.spotify.client"] = {
    bundleID = "com.spotify.client",
    name = "Spotify",
    rules = {
      { "", 2, POSITIONS.halves.right },
    },
  },
  ["com.electron.postbird"] = {
    bundleID = "com.electron.postbird",
    name = "Postbird",
    rules = {
      { "", 1, POSITIONS.center.large },
    },
  },
  ["com.apple.MobileSMS"] = {
    bundleID = "com.apple.MobileSMS",
    name = "Messages",
    rules = {
      -- { "", 2, POSITIONS.full },
      -- { "", 2, POSITIONS.thirds.left },
      { "", 2, POSITIONS.halves.left },
    },
  },
  ["org.whispersystems.signal-desktop"] = {
    bundleID = "org.whispersystems.signal-desktop",
    name = "Signal",
    rules = {
      { "", 2, POSITIONS.halves.right },
    },
  },
  ["com.tinyspeck.slackmacgap"] = {
    bundleID = "com.tinyspeck.slackmacgap",
    name = "Slack",
    rules = {
      { nil, 2, POSITIONS.full },
    },
  },
  ["com.agilebits.onepassword7"] = {
    bundleID = "com.1password.1password",
    name = "1Password",
    rules = {
      { nil, 1, POSITIONS.center.medium },
    },
  },
  ["org.hammerspoon.Hammerspoon"] = {
    bundleID = "org.hammerspoon.Hammerspoon",
    name = "Hammerspoon",
    rules = {
      { nil, 1, POSITIONS.full },
    },
  },
  ["com.dexterleng.Homerow"] = {
    bundleID = "com.dexterleng.Homerow",
    name = "Homerow",
    rules = {
      { nil, 1, POSITIONS.center.large },
    },
  },
  ["com.flexibits.fantastical2.mac"] = {
    bundleID = "com.flexibits.fantastical2.mac",
    name = "Fantastical",
    rules = {
      { nil, 1, POSITIONS.center.large },
    },
  },
  ["com.figma.Desktop"] = {
    bundleID = "com.figma.Desktop",
    name = "Figma",
    rules = {
      { nil, 1, POSITIONS.full },
    },
  },
  ["com.apple.iphonesimulator"] = {
    bundleID = "com.apple.iphonesimulator",
    name = "iPhone Simulator",
    rules = {
      { nil, 1, POSITIONS.halves.right },
    },
  },
  ["com.softfever3d.orca-slicer"] = {
    bundleID = "com.softfever3d.orca-slicer",
    name = "OrcaSlicer",
    rules = {
      { "", 1, POSITIONS.full },
    },
  },
}

QUITTERS = {
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

LOLLYGAGGERS = {
  --- [bundleID] = { hideAfter, quitAfter }
  ["org.hammerspoon.Hammerspoon"] = { 1, nil },
  ["com.flexibits.fantastical2.mac"] = { 1, nil },
  ["com.1password.1password"] = { 1, nil },
  ["com.spotify.client"] = { 1, nil },
}

LAUNCHERS = {
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

DOCK = {
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

if not hs.ipc.cliStatus() then
  hs.ipc.cliInstall()
end
require("hs.ipc")

pcall(require, "nix_path")
NIX_PATH = NIX_PATH or nil
if NIX_PATH then
  PATH = table.concat({ NIX_PATH, "/opt/homebrew/bin", os.getenv("PATH") }, ":")
else
  PATH = table.concat({ "/opt/homebrew/bin", os.getenv("PATH") }, ":")
end

--- Created by muescha.
--- DateTime: 15.10.24
--- See: https://github.com/Hammerspoon/hammerspoon/issues/3224#issuecomment-2155567633
--- https://github.com/Hammerspoon/hammerspoon/issues/3277
-- local function axHotfix(win, infoText)
--   if not win then
--     win = hs.window.frontmostWindow()
--   end
--   if not infoText then
--     infoText = "?"
--   end
--
--   local axApp = hs.axuielement.applicationElement(win:application())
--   local wasEnhanced = axApp.AXEnhancedUserInterface
--   axApp.AXEnhancedUserInterface = false
--   -- print(" enable hotfix: " .. infoText)
--
--   return function()
--     hs.timer.doAfter(hs.window.animationDuration * 2, function()
--       -- print("disable hotfix: " .. infoText)
--       axApp.AXEnhancedUserInterface = wasEnhanced
--     end)
--   end
-- end
--
-- local function withAxHotfix(fn, position, infoText)
--   if not position then
--     position = 1
--   end
--   return function(...)
--     local revert = axHotfix(select(position, ...), infoText)
--     fn(...)
--     revert()
--   end
-- end
--
-- local windowMT = hs.getObjectMetatable("hs.window")
-- windowMT.setFrame = withAxHotfix(windowMT.setFrame, 1, "setFrame")

--- REF: https://github.com/skrypka/hammerspoon_config/blob/master/init.lua#L26C1-L51C56
local function axHotfix(win)
  if not win then
    win = hs.window.frontmostWindow()
  end

  local axApp = hs.axuielement.applicationElement(win:application())
  local wasEnhanced = axApp.AXEnhancedUserInterface
  axApp.AXEnhancedUserInterface = false

  return function()
    hs.timer.doAfter(hs.window.animationDuration * 2, function()
      axApp.AXEnhancedUserInterface = wasEnhanced
    end)
  end
end

local function withAxHotfix(fn, position)
  if not position then
    position = 1
  end
  return function(...)
    local revert = axHotfix(select(position, ...))
    fn(...)
    revert()
  end
end

local windowMT = hs.getObjectMetatable("hs.window")
windowMT.maximize = withAxHotfix(windowMT.maximize)
windowMT.moveToUnit = withAxHotfix(windowMT.moveToUnit)

return M
