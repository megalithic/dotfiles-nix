local fmt = string.format
local enum = require("hs.fnutils")

return function(opts)
  opts = opts or { kill = false }

  local function output()
    local preferred = { "megabose", "LG UltraFine Display Audio", "MacBook Pro Speakers" }
    local device

    local found = enum.find(preferred, function(d)
      device = hs.audiodevice.findOutputByName(d)
      return d and device
    end)

    if found and device then
      device:setDefaultOutputDevice()
      hs.execute(fmt('SwitchAudioSource -t output -s "%s"', device:name()))
      U.log.o("[audio] output device set to " .. device:name())
      return 0
    end

    U.log.w("[audio] unable to set a default output device.")
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
      hs.execute(fmt('SwitchAudioSource -t input -s "%s"', device:name()))
      U.log.o("[audio] input device set to " .. device:name())
      return 0
    end

    U.log.w("[audio] unable to set a default input device.")
    return 1
  end

  local function audioDeviceChanged(arg)
    local oRetval = 1
    local iRetval = 1

    if arg == "dev#" then
      iRetval = input()
      oRetval = output()

      if oRetval == 1 and iRetval == 1 then
        U.log.w("[audio] unable to set input or output devices. input: " .. iRetval .. ", output: " .. oRetval)
      end
    end
  end

  hs.audiodevice.watcher.setCallback(audioDeviceChanged)
  if not opts.kill then
    hs.audiodevice.watcher.start()
    audioDeviceChanged("dev#")
  else
    hs.audiodevice.watcher.stop()
  end
end
