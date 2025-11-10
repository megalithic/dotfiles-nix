local M = {}
M.__index = M
M.name = "notifier"

local config = C.notifier.config

-- Global references to active notification canvas and timer
_G.activeNotificationCanvas = nil
_G.activeNotificationTimer = nil
_G.activeNotificationAnimTimer = nil
_G.notificationOverlay = nil -- Reusable dimming overlay
_G.activeNotificationBundleID = nil -- Track source app for auto-dismiss
_G.notificationAppWatcher = nil -- Application watcher for auto-dismiss

-- Focus mode cache (to avoid repeated subprocess calls)
local focusModeCache = {
  mode = nil, -- Current focus mode name or nil
  timestamp = 0, -- When cached
  ttl = 5, -- Cache for 5 seconds
}

-- Get active program name from Ghostty window title
-- Parses tmux title format: "◫ session:window ◦ command"
function M.getActiveProgram()
  local ghostty = hs.application.get(TERMINAL)
  if not ghostty then return nil end

  local win = ghostty:focusedWindow()
  if not win then return nil end

  local title = win:title()
  if not title then return nil end

  -- Parse tmux title format to extract command
  local command = title:match("◦%s*(.+)$")
  if command then
    -- Clean up command name (remove arguments)
    command = command:match("^(%S+)") or command
    return command
  end

  return nil
end

-- Calculate optimal vertical offset based on active program and config
function M.calculateOffset(options)
  options = options or {}
  local mode = options.positionMode or config.positionMode or "auto"

  -- Fixed mode: use provided offset directly
  if mode == "fixed" then return options.verticalOffset or config.minOffset or 100 end

  -- Auto mode: detect program and use configured offset
  if mode == "auto" then
    local program = M.getActiveProgram()
    local offsets = config.offsets or {}
    local offset = offsets.default or 350

    if program then
      -- Look up program-specific offset
      offset = offsets[program] or offsets.default or 350
    end

    -- Add any additional offset from options
    if options.verticalOffset then offset = offset + options.verticalOffset end

    -- Respect minimum offset
    local minOffset = config.minOffset or 100
    return math.max(offset, minOffset)
  end

  -- Above-prompt mode: estimate based on prompt lines
  if mode == "above-prompt" then
    local promptLines = options.estimatedPromptLines or 2
    local lineHeight = 20 -- approximate px per line
    local offset = promptLines * lineHeight + 40 -- extra padding
    return offset + (options.verticalOffset or 0)
  end

  -- Fallback
  return options.verticalOffset or config.minOffset or 100
end

-- Check if source app is currently focused
-- Returns: true if app is frontmost, false otherwise
function M.isAppFocused(bundleID)
  if not bundleID then return false end

  local frontmost = hs.application.frontmostApplication()
  if not frontmost then return false end

  return frontmost:bundleID() == bundleID
end

-- Check if user is in terminal (Ghostty)
-- Returns: true if Ghostty is frontmost
function M.isInTerminal()
  local frontmost = hs.application.frontmostApplication()
  if not frontmost then return false end

  return frontmost:bundleID() == TERMINAL or frontmost:name() == "Ghostty"
end

-- Get the focused window title for a given application bundle ID
-- Returns: window title string or nil
function M.getFocusedWindowTitle(bundleID)
  if not bundleID then return nil end

  local app = hs.application.get(bundleID)
  if not app then return nil end

  local window = app:focusedWindow()
  if not window then return nil end

  return window:title()
end

-- Determine if high priority notification should be shown
-- Based on app focus state and terminal exception
-- Returns: {shouldShow: boolean, reason: string}
function M.shouldShowHighPriority(bundleID, options)
  options = options or {}
  local alwaysShowInTerminal = options.alwaysShowInTerminal ~= false -- default true
  local showWhenAppFocused = options.showWhenAppFocused or false -- default false

  -- Check if we're in terminal (always show high priority in terminal)
  if alwaysShowInTerminal and M.isInTerminal() then return { shouldShow = true, reason = "in_terminal" } end

  -- Check if source app is focused
  local appIsFocused = M.isAppFocused(bundleID)

  if appIsFocused and not showWhenAppFocused then return { shouldShow = false, reason = "app_already_focused" } end

  return { shouldShow = true, reason = "app_not_focused" }
end

-- Get current Focus Mode (with 5-second cache)
-- Returns: focus mode name (string) or nil if no focus active
function M.getCurrentFocusMode()
  local now = os.time()

  -- Return cached value if still valid
  if focusModeCache.timestamp + focusModeCache.ttl > now then return focusModeCache.mode end

  -- Fetch fresh focus mode status
  -- Uses fast JXA script: bin/get-focus-mode
  local output, status = hs.execute(os.getenv("HOME") .. "/.dotfiles-nix/bin/get-focus-mode 2>/dev/null")

  if status then
    local mode = output and output:match("^%s*(.-)%s*$") or nil
    -- Normalize "No focus" or empty string to nil
    if mode == "" or mode == "No focus" then
      focusModeCache.mode = nil
    else
      focusModeCache.mode = mode
    end
  else
    -- If script fails, cache nil
    focusModeCache.mode = nil
  end

  focusModeCache.timestamp = now
  return focusModeCache.mode
end

-- Show dimming overlay (reuses single global canvas for efficiency)
function M.showOverlay(alpha)
  alpha = alpha or 0.6

  -- Reuse existing overlay if present
  if _G.notificationOverlay then
    _G.notificationOverlay:alpha(alpha)
    _G.notificationOverlay:show()
    return
  end

  -- Create overlay canvas first time
  local screen = hs.screen.mainScreen()
  local frame = screen:fullFrame() -- Includes menu bar

  _G.notificationOverlay = hs
    .canvas
    .new(frame)
    :appendElements({
      type = "rectangle",
      action = "fill",
      fillColor = { red = 0.0, green = 0.0, blue = 0.0, alpha = alpha },
      frame = { x = 0, y = 0, h = "100%", w = "100%" },
    })
    :level("overlay") -- Above windows, below notification canvas
    :alpha(alpha)
    :show()
end

-- Hide dimming overlay (keeps canvas for reuse)
function M.hideOverlay()
  if _G.notificationOverlay then _G.notificationOverlay:hide() end
end

-- Dismiss active notification (helper function)
function M.dismissNotification(fadeTime)
  fadeTime = fadeTime or 0.3

  if _G.activeNotificationCanvas then
    _G.activeNotificationCanvas:delete(fadeTime)
    _G.activeNotificationCanvas = nil
  end

  if _G.activeNotificationTimer then
    _G.activeNotificationTimer:stop()
    _G.activeNotificationTimer = nil
  end

  if _G.activeNotificationAnimTimer then
    _G.activeNotificationAnimTimer:stop()
    _G.activeNotificationAnimTimer = nil
  end

  if _G.notificationOverlay then hs.timer.doAfter(fadeTime, function() M.hideOverlay() end) end

  _G.activeNotificationBundleID = nil
end

-- Set up application watcher for auto-dismiss
-- Called once when module is loaded
function M.setupAppWatcher()
  if _G.notificationAppWatcher then return end -- Already set up

  _G.notificationAppWatcher = hs.application.watcher.new(function(appName, eventType, app)
    -- Only care about app activation events
    if eventType ~= hs.application.watcher.activated then return end

    -- Check if there's an active notification
    if not _G.activeNotificationCanvas or not _G.activeNotificationBundleID then return end

    -- Check if the activated app matches the notification source
    if app and app:bundleID() == _G.activeNotificationBundleID then
      M.dismissNotification(0.2) -- Quick fade
    end
  end)

  _G.notificationAppWatcher:start()
end

-- Initialize app watcher on module load
M.setupAppWatcher()

-- Calculate notification position based on mode
-- Returns: {x, y} table with pixel coordinates
function M.calculatePosition(positionMode, width, height)
  local screen = hs.screen.mainScreen()
  local screenFrame = screen:frame()

  if positionMode == "center-window" then
    -- Get focused window (if any)
    local win = hs.window.focusedWindow()

    if win then
      local winFrame = win:frame()
      -- Center within window
      return {
        x = winFrame.x + (winFrame.w - width) / 2,
        y = winFrame.y + (winFrame.h - height) / 2,
      }
    end

    -- Fallback to center-screen if no window
    positionMode = "center-screen"
  end

  if positionMode == "center-screen" then
    return {
      x = screenFrame.x + (screenFrame.w - width) / 2,
      y = screenFrame.y + (screenFrame.h - height) / 2,
    }
  end

  -- Return nil for other modes (will use existing bottom-left logic)
  return nil
end

-- Check if Ghostty is frontmost and display is awake
-- Returns: 'not_ghostty', 'display_asleep', or 'ghostty_active'
function M.checkAttention()
  local frontmost = hs.application.frontmostApplication()
  if not frontmost or frontmost:name() ~= "Ghostty" then return "not_ghostty" end

  local displayIdle = hs.caffeinate.get("displayIdle")
  if displayIdle then return "display_asleep" end

  return "ghostty_active"
end

-- Check if display is asleep, screen is locked, or user is logged out
-- Returns: 'display_asleep', 'screen_locked', 'logged_out', or 'awake'
function M.checkDisplayState()
  local displayIdle = hs.caffeinate.get("displayIdle")
  local sessionInfo = hs.caffeinate.sessionProperties()
  local screenLocked = sessionInfo and sessionInfo["CGSSessionScreenIsLocked"] or false
  local onConsole = sessionInfo and sessionInfo["kCGSSessionOnConsoleKey"] or false

  if displayIdle then
    return "display_asleep"
  elseif screenLocked then
    return "screen_locked"
  elseif not onConsole then
    return "logged_out"
  else
    return "awake"
  end
end

-- Send macOS notification via hs.notify
function M.sendMacOSNotification(title, subtitle, body) hs.notify.show(title, subtitle or "", body or "") end

-- Send iMessage to phone number
function M.sendPhoneNotification(phoneNumber, message)
  if not phoneNumber or phoneNumber == "" then return false end
  hs.messages.iMessage(phoneNumber, message)
  return true
end

-- Send Hammerspoon alert (short overlay message)
function M.sendAlert(message, duration)
  duration = duration or 5
  hs.alert.show(message, duration)
end

-- Send custom canvas notification at bottom-left with macOS Sequoia styling
-- Options: {
--   positionMode = "auto" | "fixed" | "above-prompt",
--   verticalOffset = number,  -- additional px offset
--   estimatedPromptLines = number,  -- for "above-prompt" mode
--   includeProgram = boolean,  -- whether to prepend program name to title (default: true)
-- }
function M.sendCanvasNotification(title, message, duration, options)
  duration = duration or config.defaultDuration or 5
  options = options or {}

  -- Optionally prepend program name to title
  if options.includeProgram ~= false then -- default to true
    local program = M.getActiveProgram()
    if program then title = "[" .. program .. "] " .. title end
  end

  -- Check if we should redact notification content based on focus mode
  local currentFocus = M.getCurrentFocusMode and M.getCurrentFocusMode() or nil
  local shouldRedact = currentFocus == "Do Not Disturb" or currentFocus == "Work"

  if shouldRedact then
    -- Redact message content only (keep title visible)
    message = "•••••••••••••••••••"
  end

  -- Close any existing notification before showing new one
  if _G.activeNotificationCanvas then
    M.dismissNotification(0) -- Instant dismiss
  end

  -- Show dimming overlay if requested
  if options.dimBackground then M.showOverlay(options.dimAlpha or 0.6) end

  -- Limit message to 3 lines, truncate with ellipsis if longer
  local lines = {}
  for line in message:gmatch("[^\n]+") do
    table.insert(lines, line)
  end
  local lineCount = #lines
  if lineCount > 3 then
    lines = { table.unpack(lines, 1, 3) }
    lines[3] = lines[3] .. "..."
    message = table.concat(lines, "\n")
    lineCount = 3
  end

  local screen = hs.screen.mainScreen()
  local screenFrame = screen:frame()

  -- Calculate dynamic height based on content
  local baseHeight = 70
  local lineHeight = 20
  local height = baseHeight + (lineCount * lineHeight)

  -- Minimum and maximum heights
  if height < 100 then height = 100 end
  if height > 200 then height = 200 end

  local padding = 20
  local width = 420
  local x, y

  -- Check if using center-window or center-screen positioning
  local posMode = options.positionMode
  if posMode == "center-window" or posMode == "center-screen" then
    local pos = M.calculatePosition(posMode, width, height)
    if pos then
      x = pos.x
      y = pos.y
    else
      -- Fallback to default if calculatePosition returns nil
      x = screenFrame.x + padding
      y = screenFrame.h - height - padding
    end
  else
    -- Default: Position at bottom-left of focused window (or screen if no window)
    local focusedWin = hs.window.focusedWindow()
    if focusedWin then
      local winFrame = focusedWin:frame()
      x = winFrame.x + padding
      y = winFrame.y + winFrame.h - height - padding
    else
      -- Fallback to screen if no focused window
      x = screenFrame.x + padding
      y = screenFrame.h - height - padding
    end
  end

  -- Apply intelligent offset calculation (only for bottom-left positioning)
  if not (posMode == "center-window" or posMode == "center-screen") then
    local _, tmuxRunning = hs.execute("pgrep -x tmux")
    local frontmost = hs.application.frontmostApplication()
    local inTerminal = frontmost and (frontmost:bundleID() == TERMINAL or frontmost:name() == "Ghostty")

    -- Only apply offset if in terminal (with or without tmux, depending on config)
    if inTerminal then
      local shouldApplyOffset = true
      if config.tmuxShiftEnabled == false then
        -- If tmuxShiftEnabled is explicitly false, only apply when NOT in tmux
        shouldApplyOffset = not tmuxRunning
      end
      -- If tmuxShiftEnabled is true or nil (default), always apply offset in terminal

      if shouldApplyOffset then
        local offset = M.calculateOffset(options)
        y = y - offset
      end
    end
  end

  -- Store final position for animation
  local finalY = y

  -- Check if animation is enabled and adjust starting position
  local animConfig = config.animation or {}
  local animEnabled = animConfig.enabled ~= false -- default to true

  if animEnabled then
    -- Start from the bottom of the focused window (or screen if no window)
    local focusedWin = hs.window.focusedWindow()
    if focusedWin then
      local winFrame = focusedWin:frame()
      y = winFrame.y + winFrame.h - height
    else
      y = screenFrame.h - height
    end
  end

  -- Create canvas
  local canvas = hs.canvas.new({ x = x, y = y, h = height, w = width })

  -- Shadow layer
  canvas:appendElements({
    type = "rectangle",
    action = "fill",
    fillColor = { red = 0.0, green = 0.0, blue = 0.0, alpha = 0.3 },
    roundedRectRadii = { xRadius = 14, yRadius = 14 },
    frame = { x = "0.5%", y = "1%", h = "99%", w = "99%" },
    shadow = {
      blurRadius = 25,
      color = { red = 0.0, green = 0.0, blue = 0.0, alpha = 0.5 },
      offset = { h = 6, w = 0 },
    },
  })

  -- Main background
  canvas:appendElements({
    type = "rectangle",
    action = "fill",
    fillColor = { red = 0.98, green = 0.98, blue = 0.98, alpha = 0.92 },
    roundedRectRadii = { xRadius = 12, yRadius = 12 },
    frame = { x = "0%", y = "0%", h = "100%", w = "100%" },
    id = "background",
    trackMouseDown = true,
  })

  -- Subtle border
  canvas:appendElements({
    type = "rectangle",
    action = "stroke",
    strokeColor = { red = 0.85, green = 0.85, blue = 0.85, alpha = 0.6 },
    strokeWidth = 1,
    roundedRectRadii = { xRadius = 12, yRadius = 12 },
    frame = { x = 0, y = 0, h = height, w = width },
  })

  -- Layout constants for consistent spacing
  local iconSize = 48
  local leftPadding = 8
  local iconSpacing = 10
  local topPadding = 8
  local rightPadding = 8
  local bottomPadding = 8
  local titleHeight = 22
  local titleToMessageSpacing = 3
  local timestampHeight = 20

  -- All vertical positioning uses topPadding as the base reference
  local contentY = topPadding  -- Single reference point for top alignment
  local textLeftMargin = leftPadding -- Default if no icon

  -- Emoji icon (if provided, takes precedence over app icon)
  if options.emojiIcon then
    canvas:appendElements({
      type = "text",
      text = options.emojiIcon,
      textSize = 40,
      frame = { x = leftPadding + 4, y = contentY + 4, h = iconSize, w = iconSize },
      textAlignment = "center",
      id = "emojiIcon",
    })
    -- Adjust text position to make room for icon
    textLeftMargin = leftPadding + iconSize + iconSpacing
  -- App icon (if bundle ID provided)
  elseif options.appBundleID then
    local appIcon

    -- Handle special icon markers
    if options.appBundleID == "hal9000" then
      local iconPath = hs.configdir .. "/assets/hal9000.png"
      appIcon = hs.image.imageFromPath(iconPath)
    else
      appIcon = hs.image.imageFromAppBundle(options.appBundleID)
    end

    if appIcon then
      canvas:appendElements({
        type = "image",
        image = appIcon,
        frame = { x = leftPadding, y = contentY, h = iconSize, w = iconSize },
        imageScaling = "scaleProportionally",
        imageAlignment = "center",
        id = "appIcon",
        trackMouseDown = true,
        trackMouseEnterExit = true,
      })
      -- Adjust text position to make room for icon
      textLeftMargin = leftPadding + iconSize + iconSpacing
    end
  end

  -- Title text (aligned with icon top)
  canvas:appendElements({
    type = "text",
    text = title,
    textColor = { red = 0.1, green = 0.1, blue = 0.1, alpha = 1.0 },
    textSize = 16,
    textFont = ".AppleSystemUIFontBold",
    frame = { x = textLeftMargin, y = contentY, h = titleHeight, w = width - textLeftMargin - rightPadding - 50 },
    textAlignment = "left",
    textLineBreak = "truncateTail",
    id = "title",
    trackMouseDown = true,
  })

  -- Message text (positioned directly below title)
  local messageY = contentY + titleHeight + titleToMessageSpacing
  local messageBottomSpace = timestampHeight + bottomPadding + 4 -- 4px spacing above timestamp
  canvas:appendElements({
    type = "text",
    text = message,
    textColor = { red = 0.3, green = 0.3, blue = 0.3, alpha = 1.0 },
    textSize = 14,
    textFont = ".AppleSystemUIFont",
    frame = { x = textLeftMargin, y = messageY, h = height - messageY - messageBottomSpace, w = width - textLeftMargin - rightPadding },
    textAlignment = "left",
    textLineBreak = "wordWrap",
    id = "message",
    trackMouseDown = true,
  })

  -- Timestamp (bottom-right corner, subtle)
  local timestamp = os.date("%b %d, %I:%M %p") -- e.g., "Nov 06, 02:30 PM"
  local timestampWidth = 120
  canvas:appendElements({
    type = "text",
    text = timestamp,
    textColor = { red = 0.5, green = 0.5, blue = 0.5, alpha = 0.85 },
    textSize = 11,
    textFont = ".AppleSystemUIFont",
    frame = { x = width - timestampWidth - rightPadding, y = height - timestampHeight - bottomPadding, h = timestampHeight, w = timestampWidth },
    textAlignment = "right",
    id = "timestamp",
    trackMouseDown = true,
  })

  -- Handle mouse events - dismiss on any click except app icon
  canvas:mouseCallback(function(obj, message, id, x, y)
    if message == "mouseDown" then
      if id == "appIcon" then
        -- Click on app icon - activate/focus the app
        if options.appBundleID then hs.application.launchOrFocusByBundleID(options.appBundleID) end
        return true
      else
        -- Click anywhere else - dismiss notification
        M.dismissNotification(0.3)
        return true
      end
    end
  end)

  -- Enable mouse events on entire canvas (including areas not covered by elements)
  canvas:canvasMouseEvents(true, false, false, false)

  -- Show canvas with higher level
  canvas:level("overlay")
  canvas:show()

  -- Store canvas reference globally
  _G.activeNotificationCanvas = canvas

  -- Store source app bundle ID for auto-dismiss
  _G.activeNotificationBundleID = options.appBundleID or nil

  -- Animate slide-up if enabled
  if animEnabled then
    local animDuration = animConfig.duration or 0.3
    local fps = 60 -- frames per second
    local totalFrames = math.floor(animDuration * fps)
    local currentFrame = 0
    local startY = y
    local slideDistance = startY - finalY

    _G.activeNotificationAnimTimer = hs.timer.doUntil(function() return currentFrame >= totalFrames end, function()
      currentFrame = currentFrame + 1
      -- Ease-out cubic for smooth deceleration
      local progress = currentFrame / totalFrames
      local eased = 1 - math.pow(1 - progress, 3)
      local newY = startY - (slideDistance * eased)

      canvas:topLeft({ x = x, y = newY })
    end, 1 / fps)
  end

  -- Auto-hide after duration with fade
  _G.activeNotificationTimer = hs.timer.doAfter(duration, function()
    if canvas then
      canvas:delete(0.5)
      _G.activeNotificationCanvas = nil
      _G.activeNotificationTimer = nil
      if _G.activeNotificationAnimTimer then
        _G.activeNotificationAnimTimer:stop()
        _G.activeNotificationAnimTimer = nil
      end

      -- Hide overlay with slight delay for smooth fadeout
      if options.dimBackground then hs.timer.doAfter(0.5, function() M.hideOverlay() end) end
    end
  end)
end

-- Send smart alert (short messages use alert, long messages use canvas)
function M.sendSmartAlert(message, duration)
  duration = duration or 5

  -- If message is longer than 25 characters, use canvas notification
  if #message > 25 then
    -- Extract title (up to first colon or first 25 chars)
    local title = message:match("^([^:]+)")
    if not title or title == message then title = message:sub(1, 25) end

    -- Rest is the body
    local body = message:match("^[^:]+:%s*(.+)")
    if not body or body == message then body = message:sub(26) end

    M.sendCanvasNotification(title, body, duration)
  else
    M.sendAlert(message, duration)
  end
end

return M
