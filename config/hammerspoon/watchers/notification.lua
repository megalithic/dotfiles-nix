-- Notification Watcher - Intercepts macOS Notification Center notifications
-- Uses accessibility API (AXUIElement) to monitor notification banners/alerts
-- Based on proven approach: https://stackoverflow.com/questions/45593529
--
local fmt = string.format
local M = {}

M.observer = nil
M.processedNotificationIDs = {}
M.cleanupTimer = nil
M.processWatcher = nil
M.currentPID = nil

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

  U.log.df("Processing notification - stackingID: %s, bundleID: %s, title: %s",
    tostring(stackingID), tostring(bundleID), tostring(title))
  U.log.df("Total rules to check: %d", #rules)

  for _, rule in ipairs(rules) do
    U.log.df("Checking rule '%s' (appBundleID: %s)", rule.name, rule.appBundleID)
    -- Quick app match (plain string search, not pattern)
    if stackingID:find(rule.appBundleID, 1, true) then
      U.log.df("Rule '%s' MATCHED!", rule.name)
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

      -- Delegate to unified notification system via clean API
      local ok, err = pcall(function() N.process(rule, title, subtitle, message, stackingID, bundleID) end)

      if not ok then U.log.ef("Error processing rule '%s': %s", rule.name, tostring(err)) end

      -- First match wins - stop processing rules
      return
    end

    ::continue::
  end
end

-- Helper to start/restart the AX observer
local function startObserver()
  local notificationCenterBundleID = "com.apple.notificationcenterui"
  local notificationCenter = hs.axuielement.applicationElement(notificationCenterBundleID)

  if not notificationCenter then
    U.log.e("Unable to find Notification Center AX element")
    return false
  end

  local ncPID = notificationCenter:pid()

  -- Check if we're already watching this PID
  if M.currentPID == ncPID and M.observer then
    U.log.df("Already watching NC PID %d", ncPID)
    return true
  end

  -- Stop old observer if it exists
  if M.observer then
    U.log.wf("NC PID changed: %d → %d, recreating observer", M.currentPID or 0, ncPID)
    pcall(function() M.observer:stop() end)
    M.observer = nil
  end

  M.currentPID = ncPID
  U.log.df("Starting observer for NC PID: %d", ncPID)

  -- Create observer for layout changes
  -- NOTE: Using both AXLayoutChanged and AXCreated for maximum compatibility
  -- AXCreated was mentioned as more reliable in some cases
  M.observer = hs.axuielement.observer
    .new(ncPID)
    :callback(function(observer, element, notification, observerInfo)
      U.log.df("Observer callback: notification=%s, element=%s", tostring(notification), tostring(element))
      handleNotification(element)
    end)
    :addWatcher(notificationCenter, "AXLayoutChanged")
    :addWatcher(notificationCenter, "AXCreated")
    :start()

  U.log.df("Observer created and started, watching AXLayoutChanged and AXCreated events")
  return true
end

function M:start()
  -- Start the observer
  if not startObserver() then
    U.log.e("Failed to start notification observer")
    return
  end

  -- Monitor Notification Center process for restarts
  -- Check every 30 seconds if NC has restarted (PID changed)
  M.processWatcher = hs.timer.doEvery(30, function()
    local nc = hs.axuielement.applicationElement("com.apple.notificationcenterui")
    if nc then
      local currentPID = nc:pid()
      if currentPID ~= M.currentPID then
        U.log.wf("Notification Center restarted (PID %d → %d), recreating observer", M.currentPID or 0, currentPID)
        startObserver()
      end
    else
      U.log.w("Notification Center not found during health check")
    end
  end)

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

  if M.processWatcher then
    M.processWatcher:stop()
    M.processWatcher = nil
  end

  if M.cleanupTimer then
    M.cleanupTimer:stop()
    M.cleanupTimer = nil
  end

  M.currentPID = nil
  M.processedNotificationIDs = {}
  U.log.i("stopped")
end

return M
