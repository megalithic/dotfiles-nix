local fmt = string.format
local enum = require("hs.fnutils")
local aw = hs.application.watcher
local uiw = hs.uielement.watcher

return function(opts)
  opts = opts or { kill = false }

  local M = {}

  M.loadedAppContexts = {}
  M.globalAppWatcher = {}
  M.loadedAppWatchers = {}
  --
  -- M.internal = hs.screen("Built%-in")
  -- M.pseudoMax = { x = 0.184, y = 0, w = 0.817, h = 1 }
  -- M.middleHalf = { x = 0.184, y = 0, w = 0.6, h = 1 }
  --
  -- -- negative x to hide useless sidebar
  -- -- M.toTheSide = hs.geometry.rect(-90, 54, 444, 1026)
  -- -- if env.isAtOffice then
  -- --   M.toTheSide = hs.geometry.rect(-90, 54, 466, 1100)
  -- -- end
  -- -- if env.isAtMother then
  -- --   M.toTheSide = hs.geometry.rect(-90, 54, 399, 890)
  -- -- end
  --
  -- --------------------------------------------------------------------------------
  --
  -- ---@param win hs.window
  -- ---@param relSize hs.geometry
  -- ---@nodiscard
  -- ---@return boolean|nil -- nil if no win
  -- function M.winHasSize(win, relSize)
  --   if not win then
  --     return
  --   end
  --   local maxf = win:screen():frame()
  --   local winf = win:frame()
  --   local diffw = winf.w - relSize.w * maxf.w
  --   local diffh = winf.h - relSize.h * maxf.h
  --   local diffx = relSize.x * maxf.w + maxf.x - winf.x -- calculated this way for two screens
  --   local diffy = relSize.y * maxf.h + maxf.y - winf.y
  --
  --   local leeway = 5 -- e.g., terminal cell widths creating some minor inprecision
  --   local widthOkay = (diffw > -leeway and diffw < leeway)
  --   local heightOkay = (diffh > -leeway and diffh < leeway)
  --   local posyOkay = (diffy > -leeway and diffy < leeway)
  --   local posxOkay = (diffx > -leeway and diffx < leeway)
  --
  --   return widthOkay and heightOkay and posxOkay and posyOkay
  -- end
  --
  -- ---@param win hs.window
  -- ---@param pos hs.geometry
  -- function M.moveResize(win, pos)
  --   if not (win and win:isMaximizable() and win:isStandard()) then
  --     return
  --   end
  --
  --   -- resize with safety redundancy
  --   U.defer({ 0, 0.4, 0.8 }, function()
  --     if not M.winHasSize(win, pos) then
  --       win:moveToUnit(pos)
  --     end
  --   end)
  -- end
  --
  -- --------------------------------------------------------------------------------
  -- -- FINDER
  -- M.aw_finder = aw.new(function(appName, event, finder)
  --   if event == aw.activated and appName == "Finder" then
  --     -- finder:selectMenuItem({ "View", "Hide Sidebar" })
  --     -- if not env.isProjector() then
  --     finder:selectMenuItem({ "View", "As List" })
  --     -- end
  --   end
  -- end):start()
  --
  -- --------------------------------------------------------------------------------
  -- -- ZOOM
  -- M.wf_zoom = wf.new("zoom.us"):subscribe(wf.windowCreated, function(newWin)
  --   U.closeBrowserTabsWith("zoom.us") -- remove leftover tabs
  --
  --   local newMeetingWindow = newWin:title() == "Zoom Meeting" or newWin:title() == ""
  --   if newMeetingWindow then
  --     U.defer(2, function()
  --       local zoom = newWin:application()
  --       if not zoom or zoom:findWindow("Update") then
  --         return
  --       end
  --       local mainWin = zoom:findWindow("Zoom Workplace") or zoom:findWindow("Login")
  --       if mainWin then
  --         mainWin:close()
  --       end
  --     end)
  --   end
  -- end)
  --
  -- --------------------------------------------------------------------------------
  -- -- MAILMATE
  --
  -- -- 1st window = mail-list window => pseudo-maximized for more space
  -- -- 2nd window = message-composing window => centered for narrower line length
  -- M.wf_mimestream = wf.new("Mailmate")
  --   :setOverrideFilter({ rejectTitles = { "^Software Update$" } })
  --   :subscribe(wf.windowCreated, function(newWin)
  --     local mimestream = U.app.get("Mailmate")
  --     if not mimestream then
  --       return
  --     end
  --     local winCount = #mimestream:allWindows()
  --     local narrow = { x = 0.184, y = 0, w = 0.45, h = 1 } -- for shorter line width
  --     -- local basesize = env.isProjector() and hs.layout.maximized or M.pseudoMax
  --     local basesize = M.pseudoMax
  --     local newSize = winCount > 1 and narrow or basesize
  --     M.moveResize(newWin, newSize)
  --   end)
  --

  if not opts.kill then
    local appsPath = U.resourcePath("./")
    local iterFn, dirObj = hs.fs.dir(appsPath)
    if iterFn then
      for file in iterFn, dirObj do
        if string.sub(file, -3) == "lua" then
          local basenameAndBundleID = string.sub(file, 1, -5)
          local appContext = dofile(appsPath .. file)

          -- skip the root init.lua
          if basenameAndBundleID ~= "init" then
            if appContext.actions ~= nil then
              -- if appContext.modal then
              appContext.modal = hs.hotkey.modal.new()
              -- end

              for _, value in pairs(appContext.actions) do
                local hotkey = value.hotkey
                if hotkey then
                  local mods, key = table.unpack(hotkey)
                  appContext.modal:bind(mods, key, value.action)
                end
              end
            end

            M.loadedAppContexts[basenameAndBundleID] = appContext
          end
        end
      end
    end

    M.globalAppWatcher = aw.new(function(appName, appEvent, appObj)
      local loadedAppContext = M.loadedAppContexts[appObj:bundleID()]
      local appEventStr = U.eventString(appEvent)
      if loadedAppContext ~= nil then
        local function run(_elementOrAppName, event, app)
          if
            enum.contains({
              hs.application.watcher.activated,
              hs.application.watcher.launched,
              hs.uielement.watcher.windowCreated,
              hs.uielement.watcher.titleChanged,
              hs.uielement.watcher.applicationActivated,
            }, event)
          then
            loadedAppContext:start({
              event = event,
              appObj = app,
              bundleID = appObj:bundleID(),
            })
          elseif
            enum.contains({
              hs.application.watcher.terminated,
              hs.application.watcher.deactivated,
              hs.uielement.watcher.elementDestroyed,
              hs.uielement.watcher.titleChanged,
              hs.uielement.watcher.applicationDeactivated,
            }, event)
          then
            loadedAppContext:stop({
              event = event,
              appObj = app,
              bundleID = app:bundleID(),
            })
          end
          P({ "loaded app context debug: ", app:name(), event, app:bundleID(), loadedAppContext.name })
        end

        local watcher = appObj:newWatcher(function(elementOrAppName, elementEvent, _watcher, elementAppObj)
          run(elementOrAppName, elementEvent, elementAppObj)
        end, appObj)

        M.loadedAppWatchers[appObj:bundleID()] = watcher

        watcher:start({
          hs.uielement.watcher.windowCreated,
          hs.uielement.watcher.mainWindowChanged,
          hs.uielement.watcher.focusedWindowChanged,
          hs.uielement.watcher.titleChanged,
          hs.uielement.watcher.elementDestroyed,
        })

        run(appObj:name(), appEvent, appObj)
      end
      P({ "new app watcher debug: ", appName, appEvent, appEventStr, appObj:bundleID() })
    end):start()
  else
    P("SHOULD STOP", M.globalAppWatcher)
    -- if M.globalAppWatcher then
    --   M.globalAppWatcher:stop()
    --   M.loadedAppContexts = nil
    -- end
  end

  return M
end
