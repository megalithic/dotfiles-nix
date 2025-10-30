local enum = require("hs.fnutils")
local M = {}

-- M.audio_watcher = hs.audiodevice.watcher

function M.watch_audio(opts)
  opts = opts or { kill = false }
  local kill = opts.kill or false

  -- Avoid automatically setting a bluetooth audio input device
  lastChangeTime = os.time()
  lastInputDevice = hs.audiodevice.defaultInputDevice()
  lastOutputDevice = hs.audiodevice.defaultOutputDevice()

  local function output()
    local default = hs.audiodevice.findOutputByName("MacBook Pro Speakers")
    local headphones = hs.audiodevice.findOutputByName("megabose")
    local monitor = hs.audiodevice.findOutputByName("LG UltraFine Display Audio")

    if headphones then
      headphones:setDefaultOutputDevice()
      U.log.o("Output device changed to " .. headphones:name())
      return 0
    end

    if monitor then
      monitor:setDefaultOutputDevice()
      U.log.o("Output device changed to " .. monitor:name())
      return 0
    end

    if default then
      default:setDefaultOutputDevice()
      U.log.o("Output device changed to " .. default:name())
      return 0
    end

    U.log.w("Unable to set a default output device.")
    return 1
  end

  local function input()
    local default = hs.audiodevice.findInputByName("MacBook Pro Microphone")
    local external = hs.audiodevice.findInputByName("Samson GoMic")
    local headphones = hs.audiodevice.findInputByName("megabose")

    if external then
      external:setDefaultInputDevice()
      U.log.o("Input device changed to " .. external:name())
      return 0
    end

    if headphones and not external then
      headphones:setDefaultInputDevice()
      U.log.o("Input device changed to " .. headphones:name())
      return 0
    end

    if not headphones and not external then
      default:setDefaultInputDevice()
      U.log.o("Input device changed to " .. default:name())
      return 0
    end

    U.log.w("Unable to set a default input device.")
    return 1
  end

  local function audioDeviceChanged(arg)
    local oRetval = 1
    local iRetval = 1
    if arg == "dev#" and os.time() - lastChangeTime > 2 then
      oRetval = output()
      iRetval = input()

      if oRetval == 0 and iRetval == 0 then
        lastSetOutputTime = os.time()
      else
        U.log.w("Unable to set input or output devices. input: " .. iRetval .. ", output: " .. oRetval)
      end
    end
  end

  -- local initStart = os.clock()
  hs.audiodevice.watcher.setCallback(audioDeviceChanged)
  hs.audiodevice.watcher.start()
  -- U.log.i(debug.getinfo(1, "S").short_src:gsub(".*/", "") .. " loaded in " .. (os.clock() - initStart) .. " seconds.")

  -- trapVolumeControls()
  -- hs.hotkey.bind({ "cmd", "shift" }, "k", function()
  --   audioControl.mediaControls("PLAY")
  -- end)
  -- hs.hotkey.bind({ "cmd", "shift" }, "j", function()
  --   audioControl.mediaControls("PREVIOUS")
  -- end)
  -- hs.hotkey.bind({ "cmd", "shift" }, "l", function()
  --   audioControl.mediaControls("NEXT")
  -- end)

  -- -- ~/.hammerspoon/init.lua
  -- local function update_input_device()
  --   -- add a delay to allow the system to fully switch devices
  --   hs.timer.doAfter(2, function()
  --     local device = hs.audiodevice.defaultInputDevice():name()
  --
  --     local logFile = "/tmp/hs_input_log.log"
  --     hs.execute("switch_audio_input " .. device .. " > " .. logFile .. " 2>&1 &")
  --
  --     U.log.i("[watcher] audio: input updated")
  --   end)
  -- end
  --
  -- local function update_output_device()
  --   -- add a delay to allow tchthe system to fully switch devices
  --   hs.timer.doAfter(2, function()
  --     local device = hs.audiodevice.defaultOutputDevice():name()
  --
  --     local logFile = "/tmp/hs_audio_output.log"
  --     hs.execute("switch_audio_output " .. device .. " > " .. logFile .. " 2>&1 &")
  --
  --     U.log.i("[watcher] audio: output updated")
  --   end)
  -- end
  --
  -- hs.audio.setCallback(function(event)
  --   -- trigger the script when an input device changes
  --   if event == "dIn " then
  --     update_input_device()
  --   elseif event == "dOut" then
  --     update_output_device()
  --   else
  --     U.log.i("[watcher] audio device event: " .. event)
  --   end
  -- end)
  --
  -- if not kill then
  --   M.audio_watcher.start()
  -- else
  --   M.audio_watcher.stop()
  -- end

  return M
end

function M:init(opts)
  enum.each(opts.watchers, function(watcher)
    local fn = string.format("watch_%s", watcher)
    M[fn]()
    U.log.o(string.format("[watcher] %s started", fn))
  end)

  return self
end

function M:stop(opts)
  enum.each(opts.watchers, function(watcher)
    local fn = string.format("watch_%s", watcher)
    M[fn]({ kill = true })
    U.log.o(string.format("[watcher] %s stopped", fn))
  end)

  return self
end

return M
