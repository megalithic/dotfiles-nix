-- Notification Watcher - Intercepts macOS Notification Center notifications
-- Uses accessibility API (AXUIElement) to monitor notification banners/alerts
-- Based on proven approach: https://stackoverflow.com/questions/45593529
--
local fmt = string.format
local M = {}

M.observer = nil
M.processedNotificationIDs = {}
M.cleanupTimer = nil

-- Maximum number of stored notification IDs before cleanup
local MAX_PROCESSED_IDS = 100

-- Notification subroles we care about
local notificationSubroles = {
  AXNotificationCenterAlert = true,
  AXNotificationCenterBanner = true,
}

-- Process a notification that appeared in Notification Center
local function handleNotification(element)
  -- Skip if notification drawer is open (user is already looking at notifications)
  local notificationCenterBundleID = "com.apple.notificationcenterui"
  local notificationCenter = hs.axuielement.applicationElement(notificationCenterBundleID)
  if notificationCenter and notificationCenter:asHSApplication():focusedWindow() then
    return
  end

  -- Process each notification only once
  if not notificationSubroles[element.AXSubrole] or
     M.processedNotificationIDs[element.AXIdentifier] then
    return
  end

  M.processedNotificationIDs[element.AXIdentifier] = true

  -- Get the stacking identifier to determine which app sent the notification
  local stackingID = element.AXStackingIdentifier or "unknown"

  -- Extract bundle ID (everything before first semicolon or space)
  local bundleID = stackingID:match("^([^;%s]+)") or stackingID

  -- Extract notification text elements
  local staticTexts = hs.fnutils.imap(
    hs.fnutils.ifilter(element, function(value)
      return value.AXRole == "AXStaticText"
    end),
    function(value)
      return value.AXValue
    end
  )

  local title, subtitle, message = nil, nil, nil
  if #staticTexts == 2 then
    title, message = table.unpack(staticTexts)
  elseif #staticTexts == 3 then
    title, subtitle, message = table.unpack(staticTexts)
  end

  -- Process routing rules
  local rules = NOTIFY_RULES or {}
  local ruleMatched = false

  for _, rule in ipairs(rules) do
    -- Quick app match (plain string search, not pattern)
    if stackingID:find(rule.app, 1, true) then

      -- Check sender if specified
      if rule.senders then
        local senderMatch = false
        for _, sender in ipairs(rule.senders) do
          if title == sender then  -- Exact match, case-sensitive
            senderMatch = true
            break
          end
        end
        if not senderMatch then
          goto continue  -- Skip to next rule
        end
      end

      -- Rule matched!
      ruleMatched = true
      U.log.d(fmt("→ %s: %s", rule.name, title or bundleID))

      -- Execute rule action with bundle ID
      local ok, err = pcall(function()
        rule.action(title, subtitle, message, stackingID, bundleID)
      end)

      if not ok then
        U.log.e(fmt("Error executing rule '%s': %s", rule.name, tostring(err)))
      end

      -- First match wins - stop processing rules
      return
    end

    ::continue::
  end
end

function M:start()
  -- Get Notification Center UI element
  local notificationCenterBundleID = "com.apple.notificationcenterui"
  local notificationCenter = hs.axuielement.applicationElement(notificationCenterBundleID)

  if not notificationCenter then
    U.log.e("Notification watcher: Unable to find Notification Center AX element")
    return
  end

  -- Create observer for layout changes
  M.observer = hs.axuielement.observer.new(notificationCenter:pid())
    :callback(function(_, element)
      handleNotification(element)
    end)
    :addWatcher(notificationCenter, "AXLayoutChanged")
    :start()

  -- Periodic cleanup of notification ID cache (every 5 minutes)
  M.cleanupTimer = hs.timer.doEvery(300, function()
    local count = 0
    for _ in pairs(M.processedNotificationIDs) do
      count = count + 1
    end

    if count > MAX_PROCESSED_IDS then
      M.processedNotificationIDs = {}
    end
  end)

  U.log.i("Notification watcher started")
end

function M:stop()
  if M.observer then
    pcall(function() M.observer:stop() end)
    M.observer = nil
  end

  if M.cleanupTimer then
    M.cleanupTimer:stop()
    M.cleanupTimer = nil
  end

  M.processedNotificationIDs = {}
  U.log.i("Notification watcher stopped")
end

return M
