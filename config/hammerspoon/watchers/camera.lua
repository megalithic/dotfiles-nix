-- REF: https://github.com/muescha/dotfiles-2/blob/main/tilde/.hammerspoon/system/videoCalls.lua
--
local fmt = string.format
return function(opts)
  opts = opts or { kill = false }
  local kill = opts.kill or false

  -- local function cameraInUse()
  --   hs.shortcuts.run("Meeting Start")
  --
  --   if hs.application.find("Stretchly") ~= nil then
  --     U.log.n("Pausing stretchly")
  --     run.cmd("/Applications/Stretchly.app/Contents/MacOS/Stretchly", { "pause" })
  --   end
  --
  --   Elgato.cameraStart()
  -- end
  --
  -- local function cameraStopped()
  --   hs.shortcuts.run("Meeting End")
  --
  --   if hs.application.find("Stretchly") ~= nil then
  --     U.log.n("Resuming stretchly")
  --     run.cmd("/Applications/Stretchly.app/Contents/MacOS/Stretchly", { "resume" })
  --   end
  --
  --   Elgato.cameraEnd()
  -- end

  local function cameraPropertyCallback(camera, property)
    -- TODO: Think about logging which application has started to use the camera with something like:
    -- https://www.howtogeek.com/289352/how-to-tell-which-application-is-using-your-macs-webcam/
    U.log.n("Camera " .. camera:name() .. " in use status changed.")

    -- Weirdly, "gone" is used as the property  if the camera's use changes: https://www.hammerspoon.org/docs/hs.camera.html#setPropertyWatcherCallback
    if property == "gone" then
      if camera:isInUse() then
        U.log.o("Camera " .. camera:name() .. " active.")
        U.log.o(fmt("%s active", camera:name()))
        -- cameraInUse()
      else
        U.log.o(fmt("%s inactive", camera:name()))
        -- cameraStopped()
      end
    end
  end

  local function cameraWatcherCallback(camera, status)
    U.log.n(fmt("New camera detected: %s (%s)", camera:name(), status))
    if status == "Added" then
      camera:setPropertyWatcherCallback(cameraPropertyCallback)
      camera:startPropertyWatcher()
    end
  end

  local function addCameraOnInit()
    for _, camera in ipairs(hs.camera.allCameras()) do
      U.log.n(fmt("Initial camera detection: %s", camera:name()))
      camera:setPropertyWatcherCallback(cameraPropertyCallback)
      camera:startPropertyWatcher()
    end
  end

  hs.camera.setWatcherCallback(cameraWatcherCallback)

  if not opts.kill then
    hs.camera.startWatcher()
    addCameraOnInit()
  else
    hs.camera.stopWatcher()
  end
end
