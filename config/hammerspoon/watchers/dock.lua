local fmt = string.format
local enum = require("hs.fnutils")

local M = {}

M.is_docked = nil
M.defaultWifiDevice = "en0"

local function wifiDevice()
  local device = U.run(U.bin("network-status -f -d wifi", true))

  -- If device is nil or empty, use default
  if device == nil or device == "" then
    U.log.wf("defaulting wifi device to %s", M.defaultWifiDevice)
    return M.defaultWifiDevice
  end

  return device
end

local function setWifi(state) U.run(fmt("networksetup -setairportpower %s %s", wifiDevice(), state), true) end

local function docked()
  if M.is_docked ~= nil and M.is_docked == true then
    U.log.w("already docked; skipping setup.")
    return
  end

  U.log.i("running docked setup..")
  M.is_docked = true
  setWifi(C.dock.docked.wifi)
end

local function undocked()
  U.log.i("running undocked setup..")
  M.is_docked = false
  setWifi(C.dock.undocked.wifi)
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
    local _status = U.run(fmt([[karabiner_cli --select-profile %s &]], C.dock.keyboard.disconnected), true)

    U.log.of("%s keyboard profile activated", C.dock.keyboard.disconnected)
    -- warn(fmt("[%s.keyboard] leeloo disconnected (%s)", obj.name, C.dock.keyboard.disconnected))
  elseif state == "added" then
    local _status = U.run(fmt([[karabiner_cli --select-profile %s &]], C.dock.keyboard.connected), true)
    U.log.of("%s keyboard profile activated", C.dock.keyboard.connected)
  else
    U.log.wf("unknown keyboard state: ", state)
  end
end

local function usbWatcherCallback(data)
  if data.productID == C.dock.target_alt.productID then dockChangedState(data.eventType) end
  if data.productID == C.dock.keyboard.productID then keyboardChangedState(data.eventType) end
end

function M.isDocked()
  return enum.find(
    hs.usb.attachedDevices(),
    function(device) return device.productID == C.dock.target_alt.productID end
  ) ~= nil
end

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
end

function M:stop()
  if M.watcher then M.watcher:stop() end
end

return M
