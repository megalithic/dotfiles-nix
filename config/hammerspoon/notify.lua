local M = {}
M.__index = M
M.name = "notify"

-- Global references to active notification canvas and timer
_G.activeNotificationCanvas = nil
_G.activeNotificationTimer = nil
_G.notificationOverlay = nil  -- Reusable dimming overlay

-- Focus mode cache (to avoid repeated subprocess calls)
local focusModeCache = {
  mode = nil,        -- Current focus mode name or nil
  timestamp = 0,     -- When cached
  ttl = 5,          -- Cache for 5 seconds
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
  local config = NOTIFY_CONFIG or {}
  local mode = options.positionMode or config.positionMode or "auto"

  -- Fixed mode: use provided offset directly
  if mode == "fixed" then
    return options.verticalOffset or config.minOffset or 100
  end

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
    if options.verticalOffset then
      offset = offset + options.verticalOffset
    end

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

-- Get current Focus Mode (with 5-second cache)
-- Returns: focus mode name (string) or nil if no focus active
function M.getCurrentFocusMode()
  local now = os.time()

  -- Return cached value if still valid
  if focusModeCache.timestamp + focusModeCache.ttl > now then
    return focusModeCache.mode
  end

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
  local screen = hs.screen.primaryScreen()
  local frame = screen:fullFrame()  -- Includes menu bar

  _G.notificationOverlay = hs.canvas.new(frame)
    :appendElements({
      type = 'rectangle',
      action = 'fill',
      fillColor = {red = 0.0, green = 0.0, blue = 0.0, alpha = alpha},
      frame = {x = 0, y = 0, h = '100%', w = '100%'}
    })
    :level('overlay')  -- Above windows, below notification canvas
    :alpha(alpha)
    :show()
end

-- Hide dimming overlay (keeps canvas for reuse)
function M.hideOverlay()
  if _G.notificationOverlay then
    _G.notificationOverlay:hide()
  end
end

-- Calculate notification position based on mode
-- Returns: {x, y} table with pixel coordinates
function M.calculatePosition(positionMode, width, height)
  local screen = hs.screen.primaryScreen()
  local screenFrame = screen:frame()

  if positionMode == "center-window" then
    -- Get focused window (if any)
    local win = hs.window.focusedWindow()

    if win then
      local winFrame = win:frame()
      -- Center within window
      return {
        x = winFrame.x + (winFrame.w - width) / 2,
        y = winFrame.y + (winFrame.h - height) / 2
      }
    end

    -- Fallback to center-screen if no window
    positionMode = "center-screen"
  end

  if positionMode == "center-screen" then
    return {
      x = screenFrame.x + (screenFrame.w - width) / 2,
      y = screenFrame.y + (screenFrame.h - height) / 2
    }
  end

  -- Return nil for other modes (will use existing bottom-left logic)
  return nil
end

-- Check if Ghostty is frontmost and display is awake
-- Returns: 'not_ghostty', 'display_asleep', or 'ghostty_active'
function M.checkAttention()
  local frontmost = hs.application.frontmostApplication()
  if not frontmost or frontmost:name() ~= 'Ghostty' then
    return 'not_ghostty'
  end

  local displayIdle = hs.caffeinate.get('displayIdle')
  if displayIdle then
    return 'display_asleep'
  end

  return 'ghostty_active'
end

-- Check if display is asleep, screen is locked, or user is logged out
-- Returns: 'display_asleep', 'screen_locked', 'logged_out', or 'awake'
function M.checkDisplayState()
  local displayIdle = hs.caffeinate.get('displayIdle')
  local sessionInfo = hs.caffeinate.sessionProperties()
  local screenLocked = sessionInfo and sessionInfo['CGSSessionScreenIsLocked'] or false
  local onConsole = sessionInfo and sessionInfo['kCGSSessionOnConsoleKey'] or false

  if displayIdle then
    return 'display_asleep'
  elseif screenLocked then
    return 'screen_locked'
  elseif not onConsole then
    return 'logged_out'
  else
    return 'awake'
  end
end

-- Send macOS notification via hs.notify
function M.sendMacOSNotification(title, subtitle, body)
  hs.notify.show(title, subtitle or '', body or '')
end

-- Send iMessage to phone number
function M.sendPhoneNotification(phoneNumber, message)
  if not phoneNumber or phoneNumber == '' then
    return false
  end
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
  local config = NOTIFY_CONFIG or {}
  duration = duration or config.defaultDuration or 5
  options = options or {}

  -- Optionally prepend program name to title
  if options.includeProgram ~= false then  -- default to true
    local program = M.getActiveProgram()
    if program then
      title = "[" .. program .. "] " .. title
    end
  end

  -- Close any existing notification before showing new one
  if _G.activeNotificationCanvas then
    _G.activeNotificationCanvas:delete()
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

  -- Show dimming overlay if requested
  if options.dimBackground then
    M.showOverlay(options.dimAlpha or 0.6)
  end

  -- Limit message to 5 lines, truncate with ellipsis if longer
  local lines = {}
  for line in message:gmatch("[^\n]+") do
    table.insert(lines, line)
  end
  local lineCount = #lines
  if lineCount > 5 then
    lines = {table.unpack(lines, 1, 5)}
    lines[5] = lines[5] .. "..."
    message = table.concat(lines, "\n")
    lineCount = 5
  end

  local screen = hs.screen.primaryScreen()
  local frame = screen:frame()

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
      x = frame.x + padding
      y = frame.h - height - padding
    end
  else
    -- Default: Calculate bottom-left position with padding
    x = frame.x + padding
    y = frame.h - height - padding
  end

  -- Apply intelligent offset calculation (only for bottom-left positioning)
  if not (posMode == "center-window" or posMode == "center-screen") then
    local config = NOTIFY_CONFIG or {}
    local _, tmuxRunning = hs.execute("pgrep -x tmux")
    local frontmost = hs.application.frontmostApplication()
    local inTerminal = frontmost and (frontmost:bundleID() == TERMINAL or frontmost:name() == 'Ghostty')

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
    -- Start from the bottom of the screen for dramatic effect
    y = frame.h - height
  end

  -- Create canvas
  local canvas = hs.canvas.new({x = x, y = y, h = height, w = width})

  -- Shadow layer
  canvas:appendElements({
    type = 'rectangle',
    action = 'fill',
    fillColor = {red = 0.0, green = 0.0, blue = 0.0, alpha = 0.2},
    roundedRectRadii = {xRadius = 14, yRadius = 14},
    frame = {x = '0.5%', y = '1%', h = '99%', w = '99%'},
    shadow = {
      blurRadius = 15,
      color = {red = 0.0, green = 0.0, blue = 0.0, alpha = 0.3},
      offset = {h = 4, w = 0}
    }
  })

  -- Main background
  canvas:appendElements({
    type = 'rectangle',
    action = 'fill',
    fillColor = {red = 0.98, green = 0.98, blue = 0.98, alpha = 0.92},
    roundedRectRadii = {xRadius = 12, yRadius = 12},
    frame = {x = '0%', y = '0%', h = '100%', w = '100%'}
  })

  -- Subtle border
  canvas:appendElements({
    type = 'rectangle',
    action = 'stroke',
    strokeColor = {red = 0.85, green = 0.85, blue = 0.85, alpha = 0.6},
    strokeWidth = 1,
    roundedRectRadii = {xRadius = 12, yRadius = 12},
    frame = {x = 0, y = 0, h = height, w = width}
  })

  -- Title text
  canvas:appendElements({
    type = 'text',
    text = title,
    textColor = {red = 0.1, green = 0.1, blue = 0.1, alpha = 1.0},
    textSize = 17,
    textFont = '.AppleSystemUIFontBold',
    frame = {x = 15, y = 10, h = 25, w = 350},
    textAlignment = 'left'
  })

  -- Message text
  canvas:appendElements({
    type = 'text',
    text = message,
    textColor = {red = 0.3, green = 0.3, blue = 0.3, alpha = 1.0},
    textSize = 15,
    textFont = '.AppleSystemUIFont',
    frame = {x = 15, y = 45, h = height - 60, w = 350},
    textAlignment = 'left'
  })

  -- Close button circle background
  canvas:appendElements({
    type = 'circle',
    action = 'strokeAndFill',
    fillColor = {red = 0.9, green = 0.9, blue = 0.9, alpha = 0.8},
    strokeColor = {red = 0.75, green = 0.75, blue = 0.75, alpha = 0.3},
    strokeWidth = 0.5,
    center = {x = 400, y = 18},
    radius = 12,
    id = 'closeButtonBg',
    trackMouseEnterExit = true,
    trackMouseDown = true
  })

  -- Close button X icon
  canvas:appendElements({
    type = 'text',
    text = '×',
    textColor = {red = 0.4, green = 0.4, blue = 0.4, alpha = 1.0},
    textSize = 22,
    textFont = '.AppleSystemUIFont',
    frame = {x = 388, y = 6, h = 24, w = 24},
    textAlignment = 'center',
    id = 'closeButton'
  })

  -- Timestamp (bottom-right corner, subtle)
  local timestamp = os.date("%I:%M %p")  -- e.g., "02:30 PM"
  canvas:appendElements({
    type = 'text',
    text = timestamp,
    textColor = {red = 0.6, green = 0.6, blue = 0.6, alpha = 0.7},
    textSize = 11,
    textFont = '.AppleSystemUIFont',
    frame = {x = width - 75, y = height - 25, h = 20, w = 70},
    textAlignment = 'right'
  })

  -- Handle mouse events for close button
  canvas:mouseCallback(function(obj, message, id, x, y)
    if message == 'mouseDown' and (id == 'closeButton' or id == 'closeButtonBg') then
      obj:delete(0.3)
      _G.activeNotificationCanvas = nil
      if _G.activeNotificationTimer then
        _G.activeNotificationTimer:stop()
        _G.activeNotificationTimer = nil
      end
      if _G.activeNotificationAnimTimer then
        _G.activeNotificationAnimTimer:stop()
        _G.activeNotificationAnimTimer = nil
      end
      -- Hide overlay if it was shown
      if options.dimBackground then
        hs.timer.doAfter(0.3, function()
          M.hideOverlay()
        end)
      end
      return true
    elseif message == 'mouseEnter' and (id == 'closeButton' or id == 'closeButtonBg') then
      obj[7].fillColor = {red = 0.8, green = 0.8, blue = 0.8, alpha = 1.0}
      return true
    elseif message == 'mouseExit' and (id == 'closeButton' or id == 'closeButtonBg') then
      obj[7].fillColor = {red = 0.9, green = 0.9, blue = 0.9, alpha = 0.8}
      return true
    end
  end)

  -- Show canvas with higher level
  canvas:level('overlay')
  canvas:show()

  -- Store canvas reference globally
  _G.activeNotificationCanvas = canvas

  -- Animate slide-up if enabled
  if animEnabled then
    local animDuration = animConfig.duration or 0.3
    local fps = 60 -- frames per second
    local totalFrames = math.floor(animDuration * fps)
    local currentFrame = 0
    local startY = y
    local slideDistance = startY - finalY

    _G.activeNotificationAnimTimer = hs.timer.doUntil(
      function() return currentFrame >= totalFrames end,
      function()
        currentFrame = currentFrame + 1
        -- Ease-out cubic for smooth deceleration
        local progress = currentFrame / totalFrames
        local eased = 1 - math.pow(1 - progress, 3)
        local newY = startY - (slideDistance * eased)

        canvas:topLeft({x = x, y = newY})
      end,
      1 / fps
    )
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
      if options.dimBackground then
        hs.timer.doAfter(0.5, function()
          M.hideOverlay()
        end)
      end
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
    if not title or title == message then
      title = message:sub(1, 25)
    end

    -- Rest is the body
    local body = message:match("^[^:]+:%s*(.+)")
    if not body or body == message then
      body = message:sub(26)
    end

    M.sendCanvasNotification(title, body, duration)
  else
    M.sendAlert(message, duration)
  end
end

return M
