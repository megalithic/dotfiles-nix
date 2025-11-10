-- Notification Menubar Indicator
-- Shows notifications blocked by focus mode only (not other suppression reasons)

local M = {}
local fmt = string.format

-- Menubar item
M.menubar = nil
M.pulseTimer = nil
M.pulseState = false
M.isShowing = false

-- Initialize menubar indicator
function M.init()
  M.menubar = hs.menubar.new()
  if not M.menubar then
    U.log.e("Failed to create notification menubar")
    return false
  end

  -- Set up dynamic menu (built on each click)
  M.menubar:setMenu(function(modifiers)
    return M.buildMenu()
  end)

  -- Start hidden (will show when there are notifications)
  M.menubar:removeFromMenuBar()
  M.isShowing = false

  -- Initial update
  M.update()

  -- Start pulse animation
  M.startPulse()

  U.log.i("Notification menubar initialized")
  return true
end

-- Update menubar display
function M.update()
  if not M.menubar then return end

  -- Get notifications blocked by focus mode
  local blocked = NotifyDB.getBlockedByFocus()
  local count = #blocked

  if count > 0 then
    -- Show menubar if hidden
    if not M.isShowing then
      M.menubar:returnToMenuBar()
      M.isShowing = true
    end
    -- Show count with pulsing indicator
    M.menubar:setTitle(fmt("🔴 %d", count))
    M.menubar:setTooltip(fmt("%d blocked notification%s", count, count == 1 and "" or "s"))
  else
    -- No blocked notifications - hide menubar completely
    if M.isShowing then
      M.menubar:removeFromMenuBar()
      M.isShowing = false
    end
  end
end

-- Start pulsing animation
function M.startPulse()
  if M.pulseTimer then
    M.pulseTimer:stop()
  end

  M.pulseTimer = hs.timer.doEvery(0.5, function()
    if not M.menubar or not M.isShowing then return end

    local blocked = NotifyDB.getBlockedByFocus()
    local count = #blocked

    if count > 0 then
      -- Alternate between bright and dim red
      M.pulseState = not M.pulseState
      if M.pulseState then
        M.menubar:setTitle(fmt("🔴 %d", count))
      else
        M.menubar:setTitle(fmt("⭕ %d", count))
      end
    end
  end)
end

-- Stop pulsing animation
function M.stopPulse()
  if M.pulseTimer then
    M.pulseTimer:stop()
    M.pulseTimer = nil
  end
end

-- Build menu with notification list
function M.buildMenu()
  local blocked = NotifyDB.getBlockedByFocus()
  local menu = {}

  if #blocked == 0 then
    table.insert(menu, {
      title = "No blocked notifications",
      disabled = true,
    })
  else
    -- Add header
    table.insert(menu, {
      title = fmt("Blocked by Focus Mode (%d)", #blocked),
      disabled = true,
    })
    table.insert(menu, { title = "-" }) -- Separator

    -- Add each notification
    for _, notif in ipairs(blocked) do
      local title = notif.sender or "Unknown"
      local preview = notif.message and notif.message:sub(1, 50) or ""
      if #preview == 50 then preview = preview .. "..." end

      table.insert(menu, {
        title = fmt("%s: %s", title, preview),
        fn = function()
          M.handleNotificationClick(notif)
        end,
      })
    end

    table.insert(menu, { title = "-" }) -- Separator

    -- Add "Clear All" action
    table.insert(menu, {
      title = "Clear All Notifications",
      fn = function()
        M.clearAll()
      end,
    })
  end

  return menu
end

-- Handle clicking on a notification
function M.handleNotificationClick(notif)
  -- Launch the app
  if notif.app_id then
    hs.application.launchOrFocusByBundleID(notif.app_id)
  end

  -- Mark as dismissed
  NotifyDB.dismiss(notif.id)

  -- Update display
  hs.timer.doAfter(0.1, function()
    M.update()
  end)
end

-- Clear all blocked notifications
function M.clearAll()
  NotifyDB.dismiss("all")
  hs.timer.doAfter(0.1, function()
    M.update()
  end)
  U.log.i("Cleared all blocked notifications")
end

-- Cleanup
function M.cleanup()
  M.stopPulse()
  if M.menubar then
    M.menubar:delete()
    M.menubar = nil
  end
end

return M
