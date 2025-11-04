local fmt = string.format
local enum = require("hs.fnutils")

local M = {}

local function output()
  local preferred = { "megabose", "LG UltraFine Display Audio", "MacBook Pro Speakers" }
  local device

  local found = enum.find(preferred, function(d)
    device = hs.audiodevice.findOutputByName(d)
    return d and device
  end)

  if found and device then
    device:setDefaultOutputDevice()
    local status = hs.execute(fmt("SwitchAudioSource -t output -s '%s' &", device:name()), true)
    local icon = device:name() == "megabose" and "🎧 " or ""

    U.log.of("%s%s", icon, string.gsub(status, "^%s*(.-)%s*$", "%1"))
    device = nil

    return 0
  end

  U.log.w("unable to set a default output device.")
  return 1
end

local function input()
  local preferred = { "Samson GoMic", "megabose", "MacBook Pro Microphone" }
  local device

  local found = enum.find(preferred, function(d)
    device = hs.audiodevice.findInputByName(d)
    return d and device
  end)

  if found and device then
    device:setDefaultInputDevice()
    local status = hs.execute(fmt("SwitchAudioSource -t input -s '%s' &", device:name()), true)
    U.log.of("%s", string.gsub(status, "^%s*(.-)%s*$", "%1"))
    device = nil

    return 0
  end

  U.log.w("unable to set a default input device.")
  return 1
end

local function audioDeviceChanged(arg)
  local oRetval = 1
  local iRetval = 1

  if arg == "dev#" then
    iRetval = input()
    oRetval = output()

    if oRetval == 1 and iRetval == 1 then
      U.log.w("unable to set input or output devices. input: " .. iRetval .. ", output: " .. oRetval)
    end
  end
end

local function showCurrentlyConnected()
  local i = hs.audiodevice.current(true)
  local o = hs.audiodevice.current()

  local icon = o.name == "megabose" and "🎧 " or ""
  U.log.of("input: %s (%s)", i.name, i.muted and "muted" or "unmuted")
  U.log.of("output: %s%s", icon, o.name)
end

function M:start()
  hs.audiodevice.watcher.setCallback(audioDeviceChanged)
  hs.audiodevice.watcher.start()
  showCurrentlyConnected()
end

function M:stop()
  if hs.audiodevice.watcher.isRunning() then
    hs.audiodevice.watcher.stop()
  end
end

return M
