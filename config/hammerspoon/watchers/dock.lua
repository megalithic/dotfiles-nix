local fmt = string.format
local enum = require("hs.fnutils")

local M = {}

M.is_docked = nil
M.wifi_device = nil

local function setWiFi(state)
  U.run(fmt("networksetup -setairportpower %s %s", M.wifi_device, state), true)
end

local function docked()
  if M.is_docked ~= nil and M.is_docked == true then
    U.log.w("already docked; skipping setup.")
    return
  end

  M.is_docked = true
  U.log.i("running docked setup..")
  M.wifi_device = U.run("network-status -d wifi", true)

  if M.wifi_device ~= nil then
    setWiFi(DOCK.docked.wifi)
  end
end

local function undocked()
  M.is_docked = false
  U.log.i("running undocked setup..")
  setWiFi(DOCK.undocked.wifi)
end

local function dockChangedState(state)
  if state == "removed" then
    undocked()
  elseif state == "added" then
    docked()
  else
    U.log.wf("unknown dock state: ", state)
  end
end

local function keyboardChangedState(state)
  if state == "removed" then
    local status = U.run(fmt([[karabiner_cli --select-profile %s &]], DOCK.keyboard.disconnected), true)

    U.log.of("%s keyboard profile activated", status)
    -- warn(fmt("[%s.keyboard] leeloo disconnected (%s)", obj.name, DOCK.keyboard.disconnected))
  elseif state == "added" then
    local status = U.run(fmt([[karabiner_cli --select-profile %s &]], DOCK.keyboard.connected), true)
    U.log.of("%s keyboard profile activated", status)
  else
    U.log.wf("unknown keyboard state: ", state)
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

-- local initStart = os.clock()
-- ethernetMenubar = hs.menubar.new()
function M:start()
  if M.isDocked() == true then
    dockChangedState("added")
    M.is_docked = true
    U.log.of("%s %s mode active", "🖥️", "desktop")
  else
    dockChangedState("removed")
    M.is_docked = false
    U.log.of("%s %s mode active", "💻", "laptop")
  end

  -- Set up watcher for future dock connects/disconnects
  M.watcher = hs.usb.watcher.new(usbWatcherCallback)
  M.watcher:start()

  -- U.log.n(debug.getinfo(1, "S").short_src:gsub(".*/", "") .. " loaded in " .. (os.clock() - initStart) .. " seconds.")
end

function M:stop()
  if M.watcher then
    M.watcher:stop()
  end
end

return M
