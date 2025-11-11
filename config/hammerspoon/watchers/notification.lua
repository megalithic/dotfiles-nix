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
  -- DEBUG: Log every callback invocation to verify AX observer is working
  U.log.df("AX callback triggered! Element: %s, Subrole: %s", tostring(element), tostring(element.AXSubrole))

  -- Skip if notification drawer is open (user is already looking at notifications)
  local notificationCenterBundleID = "com.apple.notificationcenterui"
  local notificationCenter = hs.axuielement.applicationElement(notificationCenterBundleID)
  if notificationCenter and notificationCenter:asHSApplication():focusedWindow() then
    U.log.df("Skipping - notification drawer is open")
    return
  end

  -- Process each notification only once
  if not notificationSubroles[element.AXSubrole] or M.processedNotificationIDs[element.AXIdentifier] then return end

  M.processedNotificationIDs[element.AXIdentifier] = true

  -- Get the stacking identifier to determine which app sent the notification
  local stackingID = element.AXStackingIdentifier or "unknown"

  -- Extract bundle ID from stackingID
  -- Format: bundleIdentifier=com.example.app,threadIdentifier=...
  -- Try to extract bundleIdentifier value first, fallback to simple extraction
  local bundleID = stackingID:match("bundleIdentifier=([^,;%s]+)") or stackingID:match("^([^;%s]+)") or stackingID

  -- Extract notification text elements
  local staticTexts = hs.fnutils.imap(
    hs.fnutils.ifilter(element, function(value) return value.AXRole == "AXStaticText" end),
    function(value) return value.AXValue end
  )

  local title, subtitle, message = nil, nil, nil
  if #staticTexts == 2 then
    title, message = table.unpack(staticTexts)
  elseif #staticTexts == 3 then
    title, subtitle, message = table.unpack(staticTexts)
  end

  -- Process routing rules
  local rules = C.notifier.rules or {}

  for _, rule in ipairs(rules) do
    -- Quick app match (plain string search, not pattern)
    if stackingID:find(rule.appBundleID, 1, true) then
      -- Check sender if specified
      if rule.senders then
        local senderMatch = false
        for _, sender in ipairs(rule.senders) do
          if title == sender then -- Exact match, case-sensitive
            senderMatch = true
            break
          end
        end
        if not senderMatch then
          goto continue -- Skip to next rule
        end
      end

      -- Rule matched! Process via notification system
      U.log.nf("%s: %s", rule.name, title or bundleID)

      -- Delegate to unified notification system
      local ok, err = pcall(function() N.process(rule, title, subtitle, message, stackingID, bundleID) end)

      if not ok then U.log.ef("Error processing rule '%s': %s", rule.name, tostring(err)) end

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
    U.log.e("Unable to find Notification Center AX element")
    return
  end

  local ncPID = notificationCenter:pid()
  U.log.df("Notification Center PID: %d", ncPID)

  -- Create observer for layout changes
  M.observer = hs.axuielement.observer
    .new(ncPID)
    :callback(function(observer, element, notification, observerInfo)
      U.log.df("Observer callback: notification=%s", tostring(notification))
      handleNotification(element)
    end)
    :addWatcher(notificationCenter, "AXLayoutChanged")
    :start()

  U.log.df("Observer created and started, watching AXLayoutChanged events")

  -- Periodic cleanup of notification ID cache (every 5 minutes)
  M.cleanupTimer = hs.timer.doEvery(300, function()
    local count = 0
    for _ in pairs(M.processedNotificationIDs) do
      count = count + 1
    end

    if count > MAX_PROCESSED_IDS then M.processedNotificationIDs = {} end
  end)

  U.log.i("started")
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
  U.log.i("stopped")
end

return M
