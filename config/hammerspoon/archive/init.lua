-- Trace all Lua code
function lineTraceHook(event, data)
  lineInfo = debug.getinfo(2, "Snl")
  print("TRACE: " .. (lineInfo["short_src"] or "<unknown source>") .. ":" .. (lineInfo["linedefined"] or "<??>"))
end

-- Uncomment the following line to enable tracing
if _G.tracingEnabled == true then
  debug.sethook(lineTraceHook, "l")
end

_G["hypers"] = {}
_G.DefaultFont = { name = "JetBrainsMono Nerd Font Mono", size = 16 }

--- @diagnostic disable-next-line: lowercase-global
function req(mod, ...)
  local ok, reqmod = pcall(require, mod)
  if not ok then
    error(reqmod)
  else
    -- if there is an init function; invoke it first.
    if type(reqmod) == "table" and reqmod.init ~= nil and type(reqmod.init) == "function" then
      -- if initializedModules[reqmod.name] ~= nil then
      reqmod:init(...)
      -- initializedModules[reqmod.name] = reqmod
      -- end
    end

    -- always return the module.. we typically end up immediately invoking it.
    return reqmod
  end
end

hs.allowAppleScript(true)
hs.application.enableSpotlightForNameSearches(false)
hs.autoLaunch(true)
hs.consoleOnTop(false)
hs.automaticallyCheckForUpdates(true)
hs.menuIcon(true)
hs.dockIcon(true)
hs.logger.defaultLogLevel = "error"
hs.hotkey.setLogLevel("error")
hs.keycodes.log.setLogLevel("error")

hs.window.animationDuration = 0.0
hs.window.highlight.ui.overlay = false
hs.window.setShadows(false)

hs.grid.setGrid("60x20")
hs.grid.setMargins("0x0")

-- [ CONSOLE SETTINGS ] --------------------------------------------------------

local con = require("hs.console")
con.darkMode(true)
con.consoleFont(DefaultFont)
con.alpha(0.985)
local darkGrayColor = { red = 26 / 255, green = 28 / 255, blue = 39 / 255, alpha = 1.0 }
local whiteColor = { white = 1.0, alpha = 1.0 }
local lightGrayColor = { white = 1.0, alpha = 0.9 }
local grayColor = { red = 24 * 4 / 255, green = 24 * 4 / 255, blue = 24 * 4 / 255, alpha = 1.0 }
con.outputBackgroundColor(darkGrayColor)
con.consoleCommandColor(whiteColor)
con.consoleResultColor(lightGrayColor)
con.consolePrintColor(grayColor)

-- [ ALERT SETTINGS ] ----------------------------------------------------------

hs.alert.defaultStyle["textSize"] = 24
hs.alert.defaultStyle["radius"] = 20
hs.alert.defaultStyle["strokeColor"] = {
  white = 1,
  alpha = 0,
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
hs.alert.defaultStyle["textFont"] = "JetBrainsMono Nerd Font Mono"

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

-- bundleID, global, local
Bindings = {
  -- -- {'com.agiletortoise.Drafts-OSX', 'd', {'x', 'n'}},
  -- {'com.apple.MobileSMS', 'q', nil},
  -- {'com.apple.finder', 'f', nil},
  -- {'com.apple.mail', 'e', nil},
  -- {'com.flexibits.cardhop.mac', nil, {'u'}},
  -- {'com.flexibits.fantastical2.mac', 'y', {'/'}},
  -- {'com.mitchellh.ghostty', 'j', nil},
  -- {'com.toggl.daneel', 'r', nil},
  -- {'com.raycast.macos', nil, {'c', 'n', 'space', ';'}},
  -- {'com.superultra.Homerow', nil, {'return', 'tab'}},
  -- {'com.surteesstudios.Bartender', nil, {'b'}},
  -- {'md.obsidian', 'g', nil},
  -- {'notion.id', 'w', nil}

  { "com.brave.Browser.nightly", "j", nil },
  { "com.mitchellh.ghostty", "k", { "`" } },
  -- { "net.kovidgoyal.kitty", "k", nil },
  { "com.apple.MobileSMS", "m", nil }, -- NOOP for now.. TODO: implement a binding feature that let's us require n-presses before we execute
  { "com.apple.finder", "f", nil },
  { "com.spotify.client", "p", nil },
  -- { "com.apple.Mail", "e", nil },
  -- { "org.nixos.thunderbird", "e", nil },
  { "com.freron.MailMate", "e", nil },
  { "com.flexibits.fantastical2.mac", "y", { "'" } },
  { "com.raycast.macos", "space", { "c" } },
  { "com.superultra.Homerow", nil, { ";" } },
  { "com.tinyspeck.slackmacgap", "s", nil },
  { "com.microsoft.teams2", "t", nil },
  { "org.hammerspoon.Hammerspoon", "r", nil },
  { "com.apple.dt.Xcode", "x", nil },
  { "com.google.android.studio", "x", nil },
  { "com.obsproject.obs-studio", "o", nil },
  { "com.microsoft.VSCode", "v", nil },
  -- { "com.kapeli.dashdoc", { { "shift" }, "d" }, { "d" } },
  { "com.electron.postbird", { { "shift" }, "p" }, nil },
  { "com.1password.1password", "1", nil },
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

-- hs.settings.set("secrets", hs.json.read(".secrets.json"))

--- Created by muescha.
--- DateTime: 15.10.24
---
--- See: https://github.com/Hammerspoon/hammerspoon/issues/3224#issuecomment-2155567633
--- https://github.com/Hammerspoon/hammerspoon/issues/3277

local function axHotfix(win, infoText)
  if not win then
    win = hs.window.frontmostWindow()
  end
  if not infoText then
    infoText = "?"
  end

  local axApp = hs.axuielement.applicationElement(win:application())
  local wasEnhanced = axApp.AXEnhancedUserInterface
  axApp.AXEnhancedUserInterface = false
  -- print(" enable hotfix: " .. infoText)

  return function()
    hs.timer.doAfter(hs.window.animationDuration * 2, function()
      -- print("disable hotfix: " .. infoText)
      axApp.AXEnhancedUserInterface = wasEnhanced
    end)
  end
end

local function withAxHotfix(fn, position, infoText)
  if not position then
    position = 1
  end
  return function(...)
    local revert = axHotfix(select(position, ...), infoText)
    fn(...)
    revert()
  end
end

local windowMT = hs.getObjectMetatable("hs.window")
windowMT.setFrame = withAxHotfix(windowMT.setFrame, 1, "setFrame")

local wm = req("wm")
local summon = req("summon")
local chain = req("chain")
local enum = req("hs.fnutils")
local utils = require("utils")

-- hs.loadSpoon("SpoonInstall")
hs.loadSpoon("EmmyLua")
hs.loadSpoon("HyperModal")
hs.loadSpoon("Hyper")
hs.loadSpoon("PTT")

Hyper = spoon.Hyper
Hyper:bindHotkeys({ hyperKey = { {}, HYPER } })

hs.fnutils.each(Bindings, function(bindingTable)
  local bundleID, globalBind, localBinds = table.unpack(bindingTable)
  if globalBind then
    local mod = {}
    local key = globalBind
    if type(globalBind) == "table" then
      mod, key = table.unpack(globalBind)
    end

    Hyper:bind(mod, key, function()
      hs.application.launchOrFocusByBundleID(bundleID)
    end)
  end
  if localBinds then
    hs.fnutils.each(localBinds, function(key)
      Hyper:bindPassThrough(key, bundleID)
    end)
  end
end)

local wmModality = spoon.HyperModal
wmModality
  :start()
  :bind({}, "r", req("wm").placeAllApps, function()
    wmModality:exit(0.1)
  end)
  :bind({}, "escape", function()
    wmModality:exit()
  end)
  -- :bind({}, "space", function() wm.place(POSITIONS.preview) end, function() wmModality:exit(0.1) end)
  :bind(
    {},
    "space",
    chain({
      POSITIONS.full,
      POSITIONS.center.large,
      POSITIONS.center.medium,
      POSITIONS.center.small,
      POSITIONS.center.tiny,
      POSITIONS.center.mini,
      POSITIONS.preview,
    }, wmModality, 1.0)
  )
  :bind({}, "return", function()
    wm.place(POSITIONS.full)
  end, function()
    wmModality:exit(0.1)
  end)
  :bind({ "shift" }, "return", function()
    wm.toNextScreen()
    wm.place(POSITIONS.full)
  end, function()
    wmModality:exit()
  end)
  :bind(
    {},
    "h",
    chain(
      enum.map({ "halves", "thirds", "twoThirds", "fiveSixths", "sixths" }, function(size)
        if type(POSITIONS[size]) == "string" then
          return POSITIONS[size]
        end
        return POSITIONS[size]["left"]
      end),
      wmModality,
      1.0
    )
  )
  :bind(
    {},
    "l",
    chain(
      enum.map({ "halves", "thirds", "twoThirds", "fiveSixths", "sixths" }, function(size)
        if type(POSITIONS[size]) == "string" then
          return POSITIONS[size]
        end
        return POSITIONS[size]["right"]
      end),
      wmModality,
      1.0
    )
  )
  :bind({ "shift" }, "h", function()
    wm.toPrevScreen()
    chain(
      enum.map({ "halves", "thirds", "twoThirds", "fiveSixths", "sixths" }, function(size)
        if type(POSITIONS[size]) == "string" then
          return POSITIONS[size]
        end
        return POSITIONS[size]["left"]
      end),
      wmModality,
      1.0
    )
  end)
  :bind({ "shift" }, "l", function()
    wm.toNextScreen()
    chain(
      enum.map({ "halves", "thirds", "twoThirds", "fiveSixths", "sixths" }, function(size)
        if type(POSITIONS[size]) == "string" then
          return POSITIONS[size]
        end
        return POSITIONS[size]["right"]
      end),
      wmModality,
      1.0
    )
  end)
  -- :bind({}, "j", function() wm.toNextScreen() end, function() wmModality:delayedExit(0.1) end)
  :bind(
    {},
    "j",
    function()
      wm.place(POSITIONS.center.large)
    end,
    -- chain({
    --   POSITIONS.center.mini,
    --   POSITIONS.center.tiny,
    --   POSITIONS.center.small,
    --   POSITIONS.center.medium,
    --   POSITIONS.center.large,
    -- }, wmModality, 1.0)
    function()
      wmModality:exit()
    end
  )
  :bind(
    {},
    "k",
    function()
      wm.place(POSITIONS.center.medium)
    end,
    -- chain({
    --   POSITIONS.center.large,
    --   POSITIONS.center.medium,
    --   POSITIONS.center.small,
    --   POSITIONS.center.tiny,
    --   POSITIONS.center.mini,
    -- }, wmModality, 1.0)
    function()
      wmModality:exit()
    end
  )
  :bind({}, "v", function()
    require("wm").tile()
    wmModality:exit()
  end)
  :bind({}, "s", function()
    req("browser"):splitTab()
    wmModality:exit()
  end)
  :bind({ "shift" }, "s", function()
    req("browser"):splitTab(true)
    wmModality:exit()
  end)
  :bind({}, "m", function()
    local app = hs.application.frontmostApplication()
    local menuItemTable = { "Window", "Merge All Windows" }
    if app:findMenuItem(menuItemTable) then
      app:selectMenuItem(menuItemTable)
    else
      warn("Merge All Windows is unsupported for " .. app:bundleID())
    end

    wmModality:exit()
  end)
  :bind({}, "f", function()
    local focused = hs.window.focusedWindow()
    enum.map(focused:otherWindowsAllScreens(), function(win)
      win:application():hide()
    end)
    wmModality:exit()
  end)
  :bind({}, "c", function()
    local win = hs.window.focusedWindow()
    local screenWidth = win:screen():frame().w
    hs.window.focusedWindow():move(hs.geometry.rect(screenWidth / 2 - 300, 0, 600, 400))
    -- resizes to a small console window at the top middle

    wmModality:exit()
  end)
  :bind({}, "b", function()
    local wip = require("wip")
    wip.bowser()
  end)
-- :bind({}, "b", function()
--   hs.timer.doAfter(5, function()
--     local focusedWindow = hs.window.focusedWindow()

--     if focusedWindow then
--       local axWindow = hs.axuielement.windowElement(focusedWindow)

--       function printAXElements(element, indent)
--         indent = indent or ""

--         print(indent .. "Element: " .. tostring(element))

--         local attributes = element:attributeNames()
--         for _, attr in ipairs(attributes) do
--           local value = element:attributeValue(attr)
--           print(indent .. "  " .. attr .. ": " .. tostring(value))
--         end

--         local children = element:childElements()
--         if children then
--           for _, child in ipairs(children) do
--             printAXElements(child, indent .. "  ")
--           end
--         end
--       end

--       print("AX Elements for Focused Window:")
--       printAXElements(axWindow)
--     else
--       print("No focused window found.")
--     end
--   end)
-- end)

Hyper:bind({}, "l", function()
  wmModality:toggle()
end)

Hyper
  :bind({ "shift" }, "r", nil, function()
    hs.notify.new({ title = "hammerspork", subTitle = "config is reloading..." }):send()
    hs.reload()
  end)
  -- :bind({ "shift", "ctrl" }, "l", nil, req("wm").placeAllApps)
  -- focus daily notes; splitting it 30/70 with currently focused app window
  :bind(
    { "shift" },
    "o",
    nil,
    function()
      utils.tmux.focusDailyNote(true)
    end
  )
  -- focus daily note; window layout untouched
  :bind({ "ctrl" }, "o", nil, function()
    utils.tmux.focusDailyNote()
  end)
  :bind({ "ctrl" }, "d", nil, function()
    utils.dnd()
  end)

-- -- Our listing of *.watcher based modules; the core of the automation that takes place.
-- -- NOTE: `app` contains the app layout and app context logic.
-- local watchers = {
--   "bluetooth",
--   "usb",
--   "dock",
--   "app",
--   "url",
--   "files",
-- }
--
-- req("config")
-- req("libs")
-- req("bindings")
-- -- req("spotify"):start()
-- req("browser"):start()
-- req("ptt"):start({ mode = "push-to-talk" })
-- req("quitter"):start({ mode = "double" })

-- req("watchers"):start(watchers)
-- hs.shutdownCallback = function()
--   req("watchers"):stop(watchers)
-- end

-- PTT = spoon.PTT
-- PTT:bindHotkeys({ push = { { "cmd", "alt" }, nil }, toggle = { { "cmd", "alt" }, "p" } })

hs.timer.doAfter(0.2, function()
  hs.notify.withdrawAll()
  hs.notify.new({ title = "hammerspork", subTitle = "config is loaded." }):send()
end)
