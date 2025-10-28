local fmt = string.format
local M = hs.hotkey.modal.new({}, nil)
_G.Hypers = {}

M.__index = M
M.name = "hyper"
M.hyper = nil
M.key = HYPER

function M:bindPassThrough(key, app)
  self:bind({}, key, nil, function()
    if hs.application.get(app) then
      hs.eventtap.keyStroke({ "cmd", "alt", "shift", "ctrl" }, key)
    else
      hs.application.launchOrFocusByBundleID(app)
      hs.timer.waitWhile(function()
        return not hs.application.get(app) and not hs.application.get(app):isFrontmost()
      end, function()
        hs.eventtap.keyStroke({ "cmd", "alt", "shift", "ctrl" }, key)
      end)
    end
  end)

  return self
end

function M:init(opts)
  opts = opts or {}

  if not opts.id then
    _G.tracingEnabled = true
    error(fmt("[ERROR] %s -> unable to start this hyper; missing id", self.name))
    return
  end

  if _G.Hypers[opts.id] ~= nil then
    warn(fmt("[%s] %s%s (existing)", "INIT", self.name, opts.id))

    return _G["Hypers"][opts.id]
  end

  self.id = opts.id
  self.key = opts.key or HYPER
  self.hyper = hs.hotkey.bind({}, self.key, function()
    self:enter()
  end, function()
    self:exit()
  end)

  _G.Hypers[opts.id] = self

  print(fmt("[%s] %s%s", "INIT", _G.Hypers[opts.id].name, _G.Hypers[opts.id].id))

  return self
end

function M:start(opts)
  return self
end

function M:stop()
  _G.Hypers[self] = nil

  self.hyper:delete()
  self:delete()

  return self
end

return M
