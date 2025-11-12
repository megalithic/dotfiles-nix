-- REF: https://github.com/muescha/dotfiles-2/blob/main/tilde/.hammerspoon/system/videoCalls.lua
--
local fmt = string.format
local M = {}

-- Debouncing state to prevent rapid-fire camera events
local lastProcessedTime = 0
local DEBOUNCE_INTERVAL = 1.0 -- 1 second - ignore events within this window

-- Detect which application is using the camera
-- Uses multiple detection methods with fallbacks
-- Returns: bundleID (string or nil), method (string)
local function detectCameraApp()
  -- Method 1: Check for video capture service processes
  -- Teams, Zoom, etc. spawn helper processes with "video_capture" or "VideoCaptureService"
  local output, status = hs.execute("ps aux | grep -E 'video_capture|VideoCaptureService' | grep -v grep 2>/dev/null")

  if status and output and output ~= "" then
    -- First try to match running applications by checking if their names appear in the process output
    -- This handles apps with video capture helper processes
    for _, app in ipairs(hs.application.runningApplications()) do
      local appName = app:name()
      local appPath = app:path()

      -- Check if this app's name or path appears in the video capture process output
      if appName and (output:match(appName) or (appPath and output:match(appPath, 1, true))) then
        -- For helper processes (e.g., "Microsoft Teams WebView Helper"), extract main app
        if appPath and appPath:match("/Contents/") then
          -- Extract main .app path (e.g., /Applications/Microsoft Teams.app)
          local mainAppPath = appPath:match("(.-%.app)")
          if mainAppPath then
            local mainAppInfo = hs.application.infoForBundlePath(mainAppPath)
            if mainAppInfo and mainAppInfo.CFBundleIdentifier then
              U.log.nf("Detected via video_capture process: %s (from %s)", mainAppInfo.CFBundleIdentifier, mainAppPath)
              return mainAppInfo.CFBundleIdentifier, "video_capture_process"
            end
          end
        else
          -- Main app itself (not a helper)
          local bundleID = app:bundleID()
          if bundleID then
            U.log.nf("Detected via video_capture process: %s", bundleID)
            return bundleID, "video_capture_process"
          end
        end
      end
    end
  end

  -- Method 2: Check TCC database for very recent camera access (within last 5 seconds)
  -- This helps identify if an app just started using the camera
  local tccQuery = [[
    sqlite3 ~/Library/Application\ Support/com.apple.TCC/TCC.db \
    "SELECT client, last_modified FROM access WHERE service = 'kTCCServiceCamera' \
     ORDER BY last_modified DESC LIMIT 1" 2>/dev/null
  ]]

  local tccOutput, tccStatus = hs.execute(tccQuery)
  if tccStatus and tccOutput and tccOutput ~= "" then
    local bundleID, timestamp = tccOutput:match("([^|]+)|(%d+)")
    if bundleID and timestamp then
      local now = os.time()
      local accessTime = tonumber(timestamp)
      -- If accessed within last 5 seconds, likely the current user
      if accessTime and math.abs(now - accessTime) < 5 then
        U.log.nf("Detected via recent TCC access: %s", bundleID)
        return bundleID, "tcc_recent"
      end
    end
  end

  -- Method 3: Use frontmost application as heuristic
  -- This is often correct, especially for video calling apps
  local frontmost = hs.application.frontmostApplication()
  if frontmost then
    local bundleID = frontmost:bundleID()
    U.log.nf("Detected via frontmost app heuristic: %s", bundleID)
    return bundleID, "frontmost_heuristic"
  end

  U.log.n("Could not detect which app is using camera")
  return nil, "unknown"
end

local function cameraActive(camera, property)
  -- Detect which app is using the camera
  local appBundleID, detectionMethod = detectCameraApp()

  if appBundleID then
    -- Get app name for display
    local app = hs.application.get(appBundleID)
    local appName = app and app:name() or appBundleID

    U.log.of("%s active: %s (%s)", camera:name(), appName, detectionMethod)
  else
    U.log.of("%s active", camera:name())
  end

  U.dnd(true, "meeting")
  hs.spotify.pause()
  require("ptt").setState("push-to-talk")

  -- hs.shortcuts.run("Meeting Start")
  --
  -- if hs.application.find("Stretchly") ~= nil then
  --   U.log.n("Pausing stretchly")
  --   run.cmd("/Applications/Stretchly.app/Contents/MacOS/Stretchly", { "pause" })
  -- end
  --
  -- Elgato.cameraStart()
end
--
local function cameraInactive(camera, property)
  P({ property, camera })
  U.dnd(false)
  require("ptt").setState("push-to-talk")

  -- hs.shortcuts.run("Meeting End")
  --
  -- if hs.application.find("Stretchly") ~= nil then
  --   U.log.n("Resuming stretchly")
  --   run.cmd("/Applications/Stretchly.app/Contents/MacOS/Stretchly", { "resume" })
  -- end
  --
  -- Elgato.cameraEnd()
end

local function watchCameraProperty(camera, property)
  -- Weirdly, "gone" is used as the property  if the camera's use changes: https://www.hammerspoon.org/docs/hs.camera.html#setPropertyWatcherCallback
  if property == "gone" then
    local now = hs.timer.secondsSinceEpoch()
    local timeSinceLastProcess = now - lastProcessedTime

    -- Debounce: ignore events that occur too soon after the last one
    if timeSinceLastProcess < DEBOUNCE_INTERVAL then
      U.log.d(fmt("[camera] debounced %s (%.2fs since last, threshold: %.2fs)", camera:name(), timeSinceLastProcess, DEBOUNCE_INTERVAL))
      return
    end

    lastProcessedTime = now
    P({ camera:name(), property })

    if camera:isInUse() then
      cameraActive(camera, property)
    else
      cameraInactive(camera, property)
      U.log.of("%s inactive", camera:name())
    end
  end
end

local function watchCamera(camera, status)
  U.log.i(fmt("camera detected: %s (%s)", camera:name(), status))
  if status == "Added" then
    if not camera:isPropertyWatcherRunning() then
      camera:setPropertyWatcherCallback(watchCameraProperty)
      camera:startPropertyWatcher()
    end
  end
end

local function addCameraOnInit()
  for _, camera in ipairs(hs.camera.allCameras() or {}) do
    U.log.n(fmt("initial detection: %s", camera:name()))
    camera:setPropertyWatcherCallback(watchCameraProperty)
    camera:startPropertyWatcher()
  end
end

function M:start()
  -- Stop existing watcher first to avoid duplicates
  if hs.camera.isWatcherRunning() then hs.camera.stopWatcher() end

  -- Stop and clean up any existing property watchers
  for _, camera in ipairs(hs.camera.allCameras() or {}) do
    if camera:isPropertyWatcherRunning() then camera:stopPropertyWatcher() end
  end

  hs.camera.setWatcherCallback(watchCamera)
  hs.camera.startWatcher()

  -- Start property watchers for existing cameras
  -- While startWatcher() may fire "Added" events, it's not always reliable,
  -- so we explicitly set up watchers for cameras that are already present
  for _, camera in ipairs(hs.camera.allCameras() or {}) do
    if not camera:isPropertyWatcherRunning() then
      U.log.n(fmt("initial detection: %s", camera:name()))
      camera:setPropertyWatcherCallback(watchCameraProperty)
      camera:startPropertyWatcher()
    end
  end
end

function M:stop()
  if hs.camera.isWatcherRunning() then
    for _, camera in ipairs(hs.camera.allCameras() or {}) do
      if camera:isPropertyWatcherRunning() then camera:stopPropertyWatcher() end
    end

    hs.camera.stopWatcher()
  end
end

return M
