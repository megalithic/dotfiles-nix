local fmt = string.format
local enum = require("hs.fnutils")
local usbWatcher

return function(opts)
  opts = opts or { kill = false }

  local M = {}
  M.is_docked = nil

  local function docked()
    U.log.n(string.format("Docked is: %s", M.is_docked))
    if M.is_docked == true then
      U.log.w("[dock] already docked; skipping setup.")
      return
    end

    M.is_docked = true
    U.log.i("[dock] docked; running setup.")

    -- networking.disableWifiSlowly()
    -- networking.networkReconnect(secrets.networking.homeDNS)
    -- run.brewcmd("blueutil", { "--connect", secrets.dock.mouseID })

    -- local lan = networking.checkForLAN()
    -- ethernetMenubar:returnToMenuBar()
    -- if lan == "lan" then
    --   ethernetMenubar:setTitle(hs.styledtext.new("", menubarLargeStyle))
    -- elseif lan == "none" then
    --   ethernetMenubar:setTitle(hs.styledtext.new("", menubarLargeStyle))
    -- end
    --
    -- for _, app in ipairs(secrets.dock.dockedApps) do
    --   run.startApp(app, true)
    -- end
  end

  local function undocked()
    U.log.n("Undocked")
    M.is_docked = false
    hs.wifi.setPower(true)

    U.log.i("[dock] undocked; running setup.")
    -- run.brewcmd("blueutil", { "--disconnect", secrets.dock.mouseID })
    --
    -- ethernetMenubar:removeFromMenuBar()

    -- for _, app in ipairs(secrets.dock.dockedApps) do
    --   run.closeApp(app)
    -- end
  end

  local function dockChangedState(state)
    if state == "removed" then
      undocked()
    elseif state == "added" then
      docked()
    else
      U.log.wf("[dock] unknown dock state: ", state)
    end
  end

  local function usbWatcherCallback(data)
    -- CalDigit 4 Pro Thunderbolt Dock
    if data.vendorName == "CalDigit, Inc" then
      dockChangedState(data.eventType)
    end
  end

  function M.isDocked()
    local usbDevices = hs.usb.attachedDevices()
    for _, device in pairs(usbDevices or {}) do
      if device.vendorName == "CalDigit, Inc" then
        return true
      end
    end
    return false
  end

  function M.init()
    local initStart = os.clock()
    -- ethernetMenubar = hs.menubar.new()

    if M.isDocked() == true then
      dockChangedState("added")
      M.is_docked = true
      U.log.of("[dock] %s %s mode active", "🖥️", "desktop")
    else
      dockChangedState("removed")
      M.is_docked = false
      U.log.of("[dock] %s %s mode active", "💻", "laptop")
    end

    -- Set up watcher for future dock connects/disconnects
    usbWatcher = hs.usb.watcher.new(usbWatcherCallback)
    usbWatcher:start()

    U.log.n(debug.getinfo(1, "S").short_src:gsub(".*/", "") .. " loaded in " .. (os.clock() - initStart) .. " seconds.")
  end

  M.init()

  return M
end
