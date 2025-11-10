-- Notification System Type Definitions
-- Shared types, constants, and enums for the notification system
--
local M = {}

---@class NotificationData
---@field title string
---@field subtitle string?
---@field message string
---@field stackingID string
---@field bundleID string

---@class RuleEvaluation
---@field shouldShow boolean
---@field priority "high"|"normal"|"low"
---@field reason string
---@field focusAllowed boolean

---@class NotificationConfig
---@field anchor "screen"|"window"|"app"
---@field position "NW"|"N"|"NE"|"W"|"C"|"E"|"SW"|"S"|"SE"
---@field dimBackground boolean
---@field dimAlpha number?
---@field appImageID string?
---@field appBundleID string?
---@field priority string
---@field includeProgram boolean?
---@field duration number?
---@field verticalOffset number? -- Additional offset for fine-tuning

-- Priority levels
M.PRIORITY = {
  HIGH = "high",
  NORMAL = "normal",
  LOW = "low",
}

-- Actions taken on notifications
M.ACTION = {
  SHOWN_CENTER = "shown_center_dimmed",
  SHOWN_BOTTOM = "shown_bottom_left",
  BLOCKED_FOCUS = "blocked_by_focus",
  BLOCKED_APP = "blocked_app_already_focused",
  BLOCKED_TERMINAL = "blocked_in_terminal",
  MACOS_DEFAULT = "macos_default",
}

-- Anchor points (coordinate system context)
-- Similar to Neovim's 'relative' parameter
M.ANCHOR = {
  SCREEN = "screen", -- Position relative to screen
  WINDOW = "window", -- Position relative to focused window
  APP = "app", -- Position relative to app coordinates
}

-- Position directions (cardinal points)
-- Similar to Neovim's anchor parameter
M.POSITION = {
  NW = "NW", -- Northwest (top-left)
  N = "N", -- North (top-center)
  NE = "NE", -- Northeast (top-right)
  W = "W", -- West (middle-left)
  C = "C", -- Center
  E = "E", -- East (middle-right)
  SW = "SW", -- Southwest (bottom-left)
  S = "S", -- South (bottom-center)
  SE = "SE", -- Southeast (bottom-right)
}

return M
