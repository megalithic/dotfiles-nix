-- Notification System Controller
-- Unified API and lifecycle management for the notification system
--
local M = {}

-- STATE
M.initialized = false

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
  if not M.db.init() then
    U.log.e("Failed to initialize notification database")
    return false
  end

  -- 2. Initialize menubar
  if not M.menubar.init() then
    U.log.w("Failed to initialize notification menubar (non-fatal)")
    -- Continue even if menubar fails
  end

  -- 3. Processor and notifier have no initialization

  M.initialized = true
  U.log.i("Notification system initialized ✓")
  return true
end

-- Graceful shutdown
function M.cleanup()
  U.log.i("Cleaning up notification system...")

  if M.menubar then
    M.menubar.cleanup()
  end

  if M.db then
    M.db.close()
  end

  M.initialized = false
  U.log.i("Notification system cleaned up")
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
