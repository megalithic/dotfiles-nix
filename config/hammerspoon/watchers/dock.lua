local fmt = string.format
local enum = require("hs.fnutils")
local usbWatcher

return function(opts)
  opts = opts or { kill = false }

  local M = {}
  M.is_docked = nil
  M.wifi_device = nil

  local function setWiFi(state)
    hs.execute(fmt("networksetup -setairportpower %s %s", M.wifi_device, state), true)
  end

  local function docked()
    if M.is_docked ~= nil and M.is_docked == true then
      U.log.w("[dock] already docked; skipping setup.")
      return
    end

    M.is_docked = true
    U.log.i("[dock] running docked setup..")
    M.wifi_device = hs.execute("network-status -d wifi &", true)

    if M.wifi_device ~= nil then
      setWiFi(DOCK.docked.wifi)
    end
  end

  local function undocked()
    M.is_docked = false
    U.log.i("[dock] running undocked setup..")
    setWiFi(DOCK.undocked.wifi)
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

  local function keyboardChangedState(state)
    if state == "removed" then
      local status = hs.execute(
        fmt(
          [[/Library/Application Support/org.pqrs/Karabiner-Elements/bin/karabiner_cli --select-profile %s &]],
          DOCK.keyboard.disconnected
        ),
        true
      )

      U.log.of("[dock] %s keyboard profile activated", status)
      -- warn(fmt("[%s.keyboard] leeloo disconnected (%s)", obj.name, DOCK.keyboard.disconnected))
    elseif state == "added" then
      local status = hs.execute(
        fmt(
          [[/Library/Application Support/org.pqrs/Karabiner-Elements/bin/karabiner_cli --select-profile %s &]],
          DOCK.keyboard.connected
        ),
        true
      )
      U.log.of("[dock] %s keyboard profile activated", status)
    else
      U.log.wf("[dock] unknown keyboard state: ", state)
    end
  end

  local function usbWatcherCallback(data)
    if data.vendorID == DOCK.target_alt.vendorID then
      dockChangedState(data.eventType)
    end

    if data.vendorID == DOCK.keyboard.vendorID then
      keyboardChangedState(data.eventType)
    end
  end

  function M.isDocked()
    local usbDevices = hs.usb.attachedDevices()
    for _, device in pairs(usbDevices or {}) do
      if device.vendorID == DOCK.target_alt.vendorID then
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
