-- Notification Rule Processing
-- Business logic for handling notification routing, priority, and focus mode checks
--
local M = {}
local fmt = string.format

---Processes a notification according to rule configuration
---Handles pattern matching, focus mode checks, priority logic, and rendering
---@param rule NotificationRule The notification rule configuration
---@param title string Notification title
---@param subtitle string Notification subtitle (may be empty)
---@param message string Notification message body
---@param stackingID string Full stacking identifier from notification center
---@param bundleID string Parsed bundle ID from stacking identifier
function M.processRule(rule, title, subtitle, message, stackingID, bundleID)
  local notify = require("lib.notifications.notifier")
  local db = require("lib.notifications.db")
  local menubar = require("lib.notifications.menubar")
  local timestamp = os.time()

  -- Determine priority based on pattern matching
  local effectivePriority = "normal" -- default

  if rule.patterns and message then
    -- Check each priority level for matching patterns
    -- Iterate in priority order: high -> normal -> low
    for _, priority in ipairs({ "high", "normal", "low" }) do
      local patternList = rule.patterns[priority]
      if patternList then
        for _, pattern in ipairs(patternList) do
          if message:find(pattern) then
            effectivePriority = priority
            goto priority_determined -- exit both loops
          end
        end
      end
    end
    ::priority_determined::
  end

  -- Check focus mode
  -- Default behavior: if no allowedFocusModes defined, block when ANY focus mode is active
  -- If allowedFocusModes is defined, allow only if current focus mode is in the list
  local currentFocus = notify.getCurrentFocusMode and notify.getCurrentFocusMode() or nil
  local focusAllowed = false

  if rule.allowedFocusModes then
    -- Rule explicitly defines allowed focus modes - check if current mode is in the list
    -- Use numeric loop instead of ipairs to handle nil values in the array
    for i = 1, #rule.allowedFocusModes do
      local allowed = rule.allowedFocusModes[i]
      if allowed == currentFocus then
        focusAllowed = true
        break
      end
    end
  else
    -- No allowedFocusModes defined - only allow if NO focus mode is active
    focusAllowed = (currentFocus == nil)
  end

  if not focusAllowed then
    db.log({
      timestamp = timestamp,
      rule_name = rule.name,
      app_id = stackingID,
      sender = title,
      subtitle = subtitle,
      message = message,
      action_taken = "blocked_by_focus",
      focus_mode = currentFocus,
      shown = false,
    })
    -- Update menubar indicator
    menubar.update()
    return
  end

  -- Check priority-based app focus rules (only for high priority)
  if effectivePriority == "high" then
    local priorityCheck = notify.shouldShowHighPriority(bundleID, {
      alwaysShowInTerminal = rule.alwaysShowInTerminal,
      showWhenAppFocused = rule.showWhenAppFocused,
    })

    if not priorityCheck.shouldShow then
      db.log({
        timestamp = timestamp,
        rule_name = rule.name,
        app_id = stackingID,
        sender = title,
        subtitle = subtitle,
        message = message,
        action_taken = "blocked_" .. priorityCheck.reason,
        focus_mode = currentFocus,
        shown = false,
      })
      -- Update menubar indicator
      menubar.update()
      return
    end
  end

  -- Determine notification config based on priority
  local duration = rule.duration or (effectivePriority == "high" and 15 or effectivePriority == "low" and 3 or 10)
  local notifConfig = {}

  -- Fallback chain for icon: appImageID → bundleID → rule.appBundleID
  local iconBundleID = rule.appImageID or bundleID or rule.appBundleID

  -- Fallback chain for launching: bundleID → rule.appBundleID
  local launchBundleID = bundleID or rule.appBundleID

  if effectivePriority == "high" then
    notifConfig = {
      anchor = "window",
      position = "C",
      dimBackground = true,
      dimAlpha = 0.6,
      includeProgram = false,
      appImageID = iconBundleID,
      appBundleID = launchBundleID,
      priority = "high",
    }
  else
    notifConfig = {
      anchor = "screen",
      position = "SW",
      dimBackground = false,
      includeProgram = false,
      appImageID = iconBundleID,
      appBundleID = launchBundleID,
      priority = effectivePriority,
    }
  end

  -- Show notification
  notify.sendCanvasNotification(title, message, duration, notifConfig)

  -- Log to database
  db.log({
    timestamp = timestamp,
    rule_name = rule.name,
    app_id = stackingID,
    sender = title,
    subtitle = subtitle,
    message = message,
    action_taken = effectivePriority == "high" and "shown_center_dimmed" or "shown_bottom_left",
    focus_mode = currentFocus,
    shown = true,
  })
end

return M
