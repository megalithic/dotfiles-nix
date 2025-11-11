-- Notification System Controller
-- Unified API and lifecycle management for the notification system
--
local M = {}

-- STATE
M.initialized = false
M.healthCheckTimer = nil
M.lastHealthCheck = nil

-- SUBMODULES (re-exported for direct access: N.db.log(), N.menubar.update(), etc.)
M.types = require("lib.notifications.types")
M.db = require("lib.notifications.db")
M.processor = require("lib.notifications.processor")
M.menubar = require("lib.notifications.menubar")
M.notifier = require("lib.notifications.notifier")

-- LIFECYCLE

-- Initialize all notification subsystems
function M.init()
  if M.initialized then
    U.log.w("Notification system already initialized")
    return true
  end

  U.log.i("Initializing notification system...")

  -- 1. Initialize database first
  local dbOk, dbErr = pcall(function()
    return M.db.init()
  end)

  if not dbOk then
    U.log.ef("CRITICAL: Failed to initialize notification database: %s", tostring(dbErr))
    hs.alert.show("⚠️ Notification Database Failed", 5)
    return false
  end

  if not dbErr then
    U.log.e("CRITICAL: Notification database init returned false")
    hs.alert.show("⚠️ Notification Database Failed", 5)
    return false
  end

  -- 2. Initialize menubar
  local menubarOk, menubarErr = pcall(function()
    return M.menubar.init()
  end)

  if not menubarOk then
    U.log.wf("Failed to initialize notification menubar: %s", tostring(menubarErr))
    -- Continue even if menubar fails
  elseif not menubarErr then
    U.log.w("Notification menubar init returned false (non-fatal)")
  end

  -- 3. Processor and notifier have no initialization

  M.initialized = true
  U.log.i("Notification system initialized ✓")

  -- Start health check (delayed to allow watchers to start)
  hs.timer.doAfter(3, function()
    M.startHealthCheck()
  end)

  return true
end

-- Graceful shutdown
function M.cleanup()
  U.log.i("Cleaning up notification system...")

  -- Stop health check
  if M.healthCheckTimer then
    M.healthCheckTimer:stop()
    M.healthCheckTimer = nil
  end

  if M.menubar then
    M.menubar.cleanup()
  end

  if M.db then
    M.db.close()
  end

  M.initialized = false
  U.log.i("Notification system cleaned up")
end

-- Health check system - runs every 5 minutes to verify notification system is working
function M.startHealthCheck()
  if M.healthCheckTimer then
    M.healthCheckTimer:stop()
  end

  -- Run initial health check
  M.performHealthCheck()

  -- Set up periodic health check (every 5 minutes)
  M.healthCheckTimer = hs.timer.doEvery(300, function()
    M.performHealthCheck()
  end)

  U.log.i("Notification health check started (5 minute interval)")
end

function M.performHealthCheck()
  local issues = {}
  local DB = require("lib.db")
  local isFirstCheck = M.lastHealthCheck == nil

  -- Check 1: Initialized flag
  if not M.initialized then
    table.insert(issues, "System not initialized")
  end

  -- Check 2: Database connection
  if not DB.db then
    table.insert(issues, "Database connection lost")
  end

  -- Check 3: Notification watcher (skip on first check as it might not be started yet)
  if not isFirstCheck then
    local watcherOk, watcher = pcall(require, "watchers.notification")
    if not watcherOk or not watcher.observer then
      table.insert(issues, "Notification watcher not running")
    end
  end

  -- Check 4: Menubar
  if M.menubar and not M.menubar.menubar then
    table.insert(issues, "Menubar indicator lost")
  end

  M.lastHealthCheck = os.time()

  if #issues > 0 then
    local issueStr = table.concat(issues, ", ")
    U.log.ef("⚠️ NOTIFICATION SYSTEM HEALTH CHECK FAILED: %s", issueStr)

    -- Only show alert if this isn't the first check
    if not isFirstCheck then
      hs.alert.show("⚠️ Notification System Issue\n" .. issueStr, 8)

      -- Try to reinitialize (but not on first check)
      U.log.w("Attempting to reinitialize notification system...")
      M.initialized = false
      local success = M.init()
      if success then
        U.log.i("Notification system successfully reinitialized")
        hs.alert.show("✓ Notification System Restored", 3)
      else
        U.log.e("Failed to reinitialize notification system!")
      end
    end
  else
    U.log.d("Notification system health check passed")
  end
end

-- Health check
function M.isReady()
  local DB = require("lib.db")
  return M.initialized and DB.db ~= nil
end

-- MAIN ENTRY POINT (called by watcher)

-- Process a notification according to rule configuration
-- This is the main entry point called by watchers/notification.lua
function M.process(rule, title, subtitle, message, stackingID, bundleID)
  if not M.initialized then
    U.log.e("Notification system not initialized - cannot process notification")
    return
  end

  -- Delegate to processor
  M.processor.processRule(rule, title, subtitle, message, stackingID, bundleID)
end

-- Manual health check trigger (for debugging)
function M.checkHealth()
  U.log.i("Running manual notification system health check...")
  M.performHealthCheck()
  return M.lastHealthCheck
end

-- FACADE METHODS (convenience shortcuts)

-- Log a notification event
function M.log(data)
  return M.db.log(data)
end

-- Get recent notifications
function M.getRecent(hours)
  return M.db.getRecent(hours)
end

-- Get blocked notifications
function M.getBlocked()
  return M.db.getBlockedByFocus()
end

-- Search notifications
function M.search(query, limit)
  return M.db.search(query, limit)
end

-- Get statistics
function M.getStats(hours)
  return M.db.getStats(hours)
end

-- Update menubar
function M.updateMenubar()
  if M.menubar then
    M.menubar.update()
  end
end

return M
