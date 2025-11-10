-- Notification Database - Track routed notifications for querying
-- Uses Hammerspoon's sqlite3 API to store notification history
--
local M = {}
local fmt = string.format

-- Database path (XDG-compliant)
M.dbPath = os.getenv("XDG_DATA_HOME") or (os.getenv("HOME") .. "/.local/share")
M.dbPath = M.dbPath .. "/hammerspoon/notifications.db"

-- Ensure directory exists
function M.ensureDirectory()
  local dir = M.dbPath:match("(.*/)")
  if dir then os.execute(fmt("mkdir -p '%s'", dir)) end
end

-- Initialize database and create schema
function M.init()
  M.ensureDirectory()

  M.db = hs.sqlite3.open(M.dbPath)

  if not M.db then
    U.log.ef("Failed to open notification database at: %s", M.dbPath)
    return false
  end

  -- Main notifications table
  local schema = [[
    CREATE TABLE IF NOT EXISTS notifications (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      timestamp INTEGER NOT NULL,
      rule_name TEXT NOT NULL,
      app_id TEXT NOT NULL,
      sender TEXT NOT NULL,
      subtitle TEXT,
      message TEXT NOT NULL,
      action_taken TEXT NOT NULL,
      focus_mode TEXT,
      shown INTEGER NOT NULL DEFAULT 1,
      dismissed_at INTEGER
    )
  ]]

  local result = M.db:execute(schema)
  if not result then
    U.log.e("Failed to create notifications table")
    return false
  end

  -- Index for querying by timestamp (most common query)
  M.db:execute([[
    CREATE INDEX IF NOT EXISTS idx_timestamp
    ON notifications(timestamp DESC)
  ]])

  -- Index for querying by sender
  M.db:execute([[
    CREATE INDEX IF NOT EXISTS idx_sender
    ON notifications(sender, timestamp DESC)
  ]])

  -- Index for finding missed important notifications
  M.db:execute([[
    CREATE INDEX IF NOT EXISTS idx_action_timestamp
    ON notifications(action_taken, shown, timestamp DESC)
  ]])

  -- Full-text search on message content
  M.db:execute([[
    CREATE VIRTUAL TABLE IF NOT EXISTS ft_notifications
    USING FTS5(sender, message, content=notifications, content_rowid=id)
  ]])

  -- Trigger to keep FTS in sync
  M.db:execute([[
    CREATE TRIGGER IF NOT EXISTS notifications_ai
    AFTER INSERT ON notifications BEGIN
      INSERT INTO ft_notifications(rowid, sender, message)
      VALUES (new.id, new.sender, new.message);
    END
  ]])

  U.log.f("initialized: %s", M.dbPath)
  return true
end

-- Escape single quotes for SQL safety
local function escapeSql(str)
  if not str then return "" end
  return str:gsub("'", "''")
end

-- Log a notification event
function M.log(data)
  if not M.db then
    U.log.e("Database not initialized - cannot log notification")
    return false
  end

  local timestamp = data.timestamp or os.time()
  local rule_name = escapeSql(data.rule_name or "unknown")
  local app_id = escapeSql(data.app_id or "unknown")
  local sender = escapeSql(data.sender or "")
  local subtitle = escapeSql(data.subtitle or "")
  local message = escapeSql(data.message or "")
  local action_taken = escapeSql(data.action_taken or "unknown")
  local focus_mode = data.focus_mode and escapeSql(data.focus_mode) or "NULL"
  local shown = data.shown and 1 or 0

  local query = fmt(
    [[
    INSERT INTO notifications
    (timestamp, rule_name, app_id, sender, subtitle, message, action_taken, focus_mode, shown)
    VALUES (%d, '%s', '%s', '%s', '%s', '%s', '%s', %s, %d)
  ]],
    timestamp,
    rule_name,
    app_id,
    sender,
    subtitle,
    message,
    action_taken,
    focus_mode == "NULL" and "NULL" or "'" .. focus_mode .. "'",
    shown
  )

  local result = M.db:execute(query)

  if not result then
    U.log.e("Failed to log notification to database")
    return false
  end

  return true
end

-- Query: Get recent notifications (default: last 24 hours)
function M.getRecent(hours)
  hours = hours or 24
  local cutoff = os.time() - (hours * 3600)

  local query = fmt(
    [[
    SELECT
      datetime(timestamp, 'unixepoch', 'localtime') as time,
      rule_name, sender, message, action_taken, focus_mode, shown
    FROM notifications
    WHERE timestamp > %d
    ORDER BY timestamp DESC
  ]],
    cutoff
  )

  local results = {}
  for row in M.db:nrows(query) do
    table.insert(results, row)
  end

  return results
end

-- Query: Get missed important notifications (blocked by focus mode)
function M.getMissed(hours)
  hours = hours or 24
  local cutoff = os.time() - (hours * 3600)

  local query = fmt(
    [[
    SELECT
      datetime(timestamp, 'unixepoch', 'localtime') as time,
      rule_name, sender, message, focus_mode
    FROM notifications
    WHERE timestamp > %d
      AND action_taken = 'blocked_by_focus'
      AND shown = 0
    ORDER BY timestamp DESC
  ]],
    cutoff
  )

  local results = {}
  for row in M.db:nrows(query) do
    table.insert(results, row)
  end

  return results
end

-- Query: Search notifications by sender
function M.getBySender(sender, limit)
  limit = limit or 50
  sender = escapeSql(sender)

  local query = fmt(
    [[
    SELECT
      datetime(timestamp, 'unixepoch', 'localtime') as time,
      rule_name, message, action_taken, focus_mode, shown
    FROM notifications
    WHERE sender = '%s'
    ORDER BY timestamp DESC
    LIMIT %d
  ]],
    sender,
    limit
  )

  local results = {}
  for row in M.db:nrows(query) do
    table.insert(results, row)
  end

  return results
end

-- Query: Full-text search on message content
function M.search(searchTerm, limit)
  limit = limit or 50
  searchTerm = escapeSql(searchTerm)

  local query = fmt(
    [[
    SELECT
      datetime(n.timestamp, 'unixepoch', 'localtime') as time,
      n.rule_name, n.sender, n.message, n.action_taken, n.shown
    FROM notifications n
    JOIN ft_notifications ft ON n.id = ft.rowid
    WHERE ft_notifications MATCH '%s'
    ORDER BY n.timestamp DESC
    LIMIT %d
  ]],
    searchTerm,
    limit
  )

  local results = {}
  for row in M.db:nrows(query) do
    table.insert(results, row)
  end

  return results
end

-- Query: Get statistics
function M.getStats(hours)
  hours = hours or 24
  local cutoff = os.time() - (hours * 3600)

  local query = fmt(
    [[
    SELECT
      COUNT(*) as total,
      SUM(CASE WHEN shown = 1 THEN 1 ELSE 0 END) as shown,
      SUM(CASE WHEN shown = 0 THEN 1 ELSE 0 END) as blocked,
      COUNT(DISTINCT sender) as unique_senders
    FROM notifications
    WHERE timestamp > %d
  ]],
    cutoff
  )

  for row in M.db:nrows(query) do
    return row
  end

  return nil
end

-- Cleanup: Delete old notifications (default: older than 30 days)
function M.cleanup(days)
  days = days or 30
  local cutoff = os.time() - (days * 86400)

  local query = fmt(
    [[
    DELETE FROM notifications WHERE timestamp < %d
  ]],
    cutoff
  )

  local result = M.db:execute(query)

  if result then U.log.f("Cleaned up notifications older than %d days", days) end

  return result
end

-- Query: Get undismissed notifications blocked by focus mode only
function M.getBlockedByFocus()
  local query = [[
    SELECT
      id, timestamp,
      datetime(timestamp, 'unixepoch', 'localtime') as time,
      rule_name, app_id, sender, message
    FROM notifications
    WHERE dismissed_at IS NULL
      AND shown = 0
      AND action_taken = 'blocked_by_focus'
    ORDER BY timestamp DESC
    LIMIT 50
  ]]

  local results = {}
  for row in M.db:nrows(query) do
    table.insert(results, row)
  end

  return results
end

-- Mark notification(s) as dismissed
function M.dismiss(notificationId)
  if not M.db then return false end

  local dismissTime = os.time()
  local query

  if notificationId == "all" then
    -- Dismiss all undismissed blocked notifications
    query = fmt([[
      UPDATE notifications
      SET dismissed_at = %d
      WHERE dismissed_at IS NULL
        AND shown = 0
        AND (action_taken LIKE 'blocked%%')
    ]], dismissTime)
  else
    -- Dismiss specific notification
    query = fmt([[
      UPDATE notifications
      SET dismissed_at = %d
      WHERE id = %d
    ]], dismissTime, notificationId)
  end

  return M.db:execute(query)
end

-- Print query results in a readable format
function M.printResults(results, title)
  if not results or #results == 0 then
    print("No results found")
    return
  end

  print("\n" .. (title or "Query Results") .. ":")
  print(string.rep("━", 80))

  for i, row in ipairs(results) do
    print(fmt("%d. %s", i, row.time or ""))
    if row.sender then print(fmt("   From: %s", row.sender)) end
    if row.rule_name then print(fmt("   Rule: %s", row.rule_name)) end
    if row.message then print(fmt("   Msg: %s", row.message:sub(1, 60))) end
    if row.action_taken then print(fmt("   Action: %s", row.action_taken)) end
    if row.focus_mode then print(fmt("   Focus: %s", row.focus_mode)) end
    if row.shown ~= nil then print(fmt("   Shown: %s", row.shown == 1 and "Yes" or "No")) end
    print("")
  end

  print(string.rep("━", 80))
end

return M
