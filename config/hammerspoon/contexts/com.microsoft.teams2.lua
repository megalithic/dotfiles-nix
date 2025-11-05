local obj = {}
local _appObj = nil
local enum = require("hs.fnutils")
local fmt = string.format

obj.__index = obj
obj.name = "context.teams"
obj.debug = true
obj.actions = {}
obj.stopComplete = false
obj.startComplete = false

function obj:start(opts)
  opts = opts or {}
  local event = opts.event
  local appObj = opts.appObj

  if obj.modal then obj.modal:enter() end

  if
    enum.contains({
      hs.application.watcher.launched,
      hs.application.watcher.activated,
      hs.uielement.watcher.applicationActivated,
      hs.uielement.watcher.windowCreated,
    }, event)
  then
    hs.timer.waitUntil(function() return appObj:findWindow("Meeting|Launch Deck Standup") end, function()
      -- actions to only run at app startup and if it's a video-related window
      U.dnd(true, "meeting")
      hs.spotify.pause()
      require("ptt").setState("push-to-talk")
    end)
  end

  return self
end

function obj:stop(opts)
  opts = opts or {}
  local event = opts.event
  local appObj = opts.appObj

  if obj.modal then obj.modal:exit() end

  if event == hs.application.watcher.terminated or event == hs.uielement.watcher.elementDestroyed then
    hs.timer.waitUntil(
      function()
        return appObj == nil
          or not appObj:isRunning()
          or not appObj:findWindow("Meeting|Launch Deck Standup") and not obj.stopComplete
      end,
      function()
        U.dnd(false)
        require("ptt").setState("push-to-talk")
        obj.stopComplete = true
        -- local browser = hs.application.get(BROWSER)
        -- if browser ~= nil then
        --   local browser_win = browser:mainWindow()
        --   if browser_win ~= nil then browser_win:moveToUnit(hs.layout.maximized) end
        -- end
        --
        -- local term = hs.application.get(TERMINAL)
        -- if term ~= nil then
        --   local term_win = term:mainWindow()
        --   if term_win ~= nil then term_win:moveToUnit(hs.layout.maximized) end
        -- end
        --
      end
    )
  end

  return self
end

return obj
