local enum = require("hs.fnutils")
local M = {}

M.audio_watcher = hs.audiodevice.watcher

function M.watch_audio()
  -- ~/.hammerspoon/init.lua
  local log = hs.logger.new("audio_watcher", "info")

  local function update_input_device()
    -- add a delay to allow the system to fully switch devices
    hs.timer.doAfter(2, function()
      local device = hs.audiodevice.defaultInputDevice():name()

      local logFile = "/tmp/hs_input_log.log"
      hs.execute("switch_audio_input " .. device .. " > " .. logFile .. " 2>&1 &")

      log.i("[watcher] audio: input updated")
    end)
  end

  local function update_output_device()
    -- add a delay to allow the system to fully switch devices
    hs.timer.doAfter(2, function()
      local device = hs.audiodevice.defaultOutputDevice():name()

      local logFile = "/tmp/hs_audio_output.log"
      hs.execute("switch_audio_output " .. device .. " > " .. logFile .. " 2>&1 &")

      log.i("[watcher] audio: output updated")
    end)
  end

  M.audio_watcher.setCallback(function(event)
    -- trigger the script when an input device changes
    if event == "dev#" then
      update_input_device()
      update_output_device()
    end
  end)

  M.audio_watcher.start()

  return M
end

function M:init(opts)
  enum.each(opts.watchers, function(watcher)
    local watcher_fn = string.format("watch_%s", watcher)

    pcall(M[watcher_fn])
  end)

  return self
end

return M
