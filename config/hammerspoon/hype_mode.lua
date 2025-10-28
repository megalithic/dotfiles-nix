-- hs.loadSpoon("Hyper")
-- Hyper = spoon.Hyper
-- Hyper:bindHotkeys({ hyperKey = { {}, HYPER } })

hype_mode = hs.hotkey.modal.new({}, HYPER)

-- disable leader mode when the last key is not pressed in 1 second
local last_defer_time = 0
local function defer_exit_leader(second)
  local current_time = hs.timer.absoluteTime()
  -- this current time is bind to this specific callback
  -- would only exit when the leader key is not pressed in the next 1 second
  ---@diagnostic disable-next-line: cast-local-type
  last_defer_time = current_time
  hs.timer.doAfter(second, function()
    if last_defer_time == current_time then
      hype_mode:exit()
    end
  end)
end

function hype_mode:entered()
  defer_exit_leader(1)
end

local bound_keys = {}

---@class LeaderBindOpts
---@field repeatable boolean

---@param modifiers string
---@param key string
---@param callback function
---@param opts LeaderBindOpts?
local function hyper(modifiers, key, callback, opts)
  opts = opts or {}
  opts.repeatable = opts.repeatable or false
  local key_str = modifiers .. "+" .. key
  if bound_keys[key_str] then
    local error_msg
    if modifiers == "" then
      error_msg = "key '" .. key .. "' is already bound"
    else
      error_msg = "key '" .. modifiers .. " " .. key .. "' is already bound"
    end
    error(error_msg)
    return
  end
  hype_mode:bind(modifiers, key, function()
    last_defer_time = 0
    callback()
    if not opts.repeatable then
      hype_mode:exit()
    end
  end)
  bound_keys[key_str] = true
end

hyper("", "escape", function()
  hype_mode:exit()
end)

---@param win hs.window
---@param delta_ratio number
local function relative_resize_keep_aspect(win, delta_ratio)
  local frame = win:frame()
  local new_w = frame.w * (1 + delta_ratio)
  local new_h = frame.h * (1 + delta_ratio)
  local new_x = frame.x - (new_w - frame.w) / 2
  local new_y = frame.y - (new_h - frame.h) / 2
  win:setFrame(hs.geometry.rect(new_x, new_y, new_w, new_h))
end

---@return hs.window
local function focused_window()
  local app = hs.application.frontmostApplication()
  local win = app:focusedWindow()
  return win
end

hyper("", "-", function()
  relative_resize_keep_aspect(focused_window(), -0.1)
end, { repeatable = true })
hyper("shift", "=", function()
  relative_resize_keep_aspect(focused_window(), 0.1)
end, { repeatable = true })
hyper("", "=", function()
  relative_resize_keep_aspect(focused_window(), 0.1)
end, { repeatable = true })
hyper("", "c", function()
  local win = focused_window()
  local new_geometry = hs.geometry.size(1350, 900)
  if win:size():equals(new_geometry) then
    win:centerOnScreen()
    return
  end
  while not win:size():equals(new_geometry) do
    win:setSize(new_geometry)
    hs.timer.usleep(100 * 1000)
    win:centerOnScreen()
  end
end)
hyper("shift", "c", function()
  focused_window():centerOnScreen()
end)

-- lock mode to avoid triggering shift-space
-- ocal lock_mode = hs.hotkey.modal.new("ctrl-shift", HYPER)
--
-- function lock_mode:entered()
--   hs.alert("entered lock mode")
--   hype_mode:exit()
-- end
-- function lock_mode:exited()
--   hs.alert("exited lock mode")
-- end
--
-- lock_mode:bind({ "ctrl", "shift" }, "space", function()
--   lock_mode:exit()
-- end)
--
-- -- shadow leader mode keybinding
-- lock_mode:bind({ "shift" }, "space", function()
--   hs.alert("lock mode activated")
-- end)
