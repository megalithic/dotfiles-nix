local enum = req("hs.fnutils")
local contexts = req("contexts")
local fmt = string.format

local M = {}

M.__index = M
M.name = "watcher.app"
M.debug = false
M.watchers = {
  global = nil,
  app = {},
  context = {},
}
-- obj.lollygagger = req("lollygagger")

-- interface: (element, event, watcher, info)
function M.handleWatchedEvent(elementOrAppName, event, _watcher, app)
  if elementOrAppName ~= nil then
    -- M.runLayoutRulesForAppBundleID(elementOrAppName, event, app)
    M.runContextForAppBundleID(elementOrAppName, event, app)
    if M.lollygagger then
      M.lollygagger:run(elementOrAppName, event, app)
    end
  end
end

-- interface: (app, initializing)
function M.watchApp(app, _)
  if app == nil then
    return
  end
  -- FIXME: do we watch by pid or bundleID?
  if M.watchers.app[app:pid()] then
    return
  end

  local watcher = app:newWatcher(M.handleWatchedEvent, app)
  M.watchers.app[app:pid()] = watcher
  -- M.watchers.app[app:pid()] = {
  --   watcher = watcher,
  -- }

  if watcher == nil then
    return
  end

  watcher:start({
    hs.uielement.watcher.windowCreated,
    hs.uielement.watcher.mainWindowChanged,
    hs.uielement.watcher.focusedWindowChanged,
    hs.uielement.watcher.titleChanged,
    hs.uielement.watcher.elementDestroyed,
  })
end

function M.attachExistingApps()
  enum.each(hs.application.runningApplications(), function(app)
    if app:title() ~= "Hammerspoon" then
      M.watchApp(app, true)
    end
  end)
end

function M.runLayoutRulesForAppBundleID(elementOrAppName, event, app)
  -- NOTE: only certain events are layout-runnable
  local layoutableEvents = {
    hs.application.watcher.launched,
    hs.application.watcher.terminated,
    -- hs.uielement.watcher.windowCreated,
    -- hs.application.watcher.activated,
    -- hs.application.watcher.deactivated,
    -- hs.uielement.watcher.applicationActivated,
    -- hs.uielement.watcher.applicationDeactivated,
  }

  if app and enum.contains(layoutableEvents, event) then
    hs.timer.waitUntil(function()
      return #app:allWindows() > 0 and app:mainWindow() ~= nil
    end, function()
      req("wm").placeApp(elementOrAppName, event, app)
    end)
  end
end

-- NOTE: all events are context-runnable
function M.runContextForAppBundleID(elementOrAppName, event, app, metadata)
  if not M.watchers.context[app:bundleID()] then
    return
  end

  contexts:run({
    context = M.watchers.context[app:bundleID()],
    element = type(elementOrAppName) ~= "string" and elementOrAppName or nil,
    event = event,
    appObj = app,
    bundleID = app:bundleID(),
    metadata = metadata,
  })
end

function M:start()
  self.watchers.app = {}
  self.watchers.context = contexts:start()
  self.watchers.global = hs.application.watcher
    .new(function(appName, event, app)
      M.handleWatchedEvent(appName, event, nil, app)
    end)
    :start()

  -- NOTE: this slows it ALL down
  -- self.attachExistingApps()

  if M.lollygagger then
    self.lollygagger:start()
  end

  U.log.i(fmt("started", self.name))

  return self
end

function M:stop()
  if self.watchers.global then
    self.watchers.global:stop()
    self.watchers.global = nil
  end

  if self.watchers.app then
    P(self.watchers.app)
    enum.each(self.watchers.app, function(w)
      if w and type(w["stop"]) == "function" then
        w:stop()
        U.log.f("stopping app watcher %s", w:bundleID())
      end
      w = nil
    end)
    self.watchers.app = nil
  end

  if self.watchers.context then
    enum.each(self.watchers.context, function(w)
      if w and type(w["stop"]) == "function" then
        w:stop()
        U.log.f("stopping %s", w.name)
      end
      w = nil
    end)
    self.watchers.context = nil
  end

  U.log.i(fmt("stopped", self.name))

  return self
end

return M
