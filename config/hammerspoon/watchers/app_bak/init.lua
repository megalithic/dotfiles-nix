local fmt = string.format
local enum = require("hs.fnutils")
local aw = hs.application.watcher
local uiw = hs.uielement.watcher

local M = {}

M.loadedAppContexts = {}
M.globalAppWatcher = {}
M.loadedAppWatchers = {}

M.startEvents = {
  hs.application.watcher.launched,
  hs.application.watcher.activated,
  hs.uielement.watcher.applicationActivated,
  hs.uielement.watcher.windowCreated,
  hs.uielement.watcher.titleChanged,
}
M.startModalEvents = {
  hs.application.watcher.activated,
  hs.uielement.watcher.applicationActivated,
  -- hs.uielement.watcher.mainWindowChanged,
  -- hs.uielement.watcher.focusedWindowChanged,
}
M.stopEvents = {
  hs.application.watcher.terminated,
  hs.application.watcher.deactivated,
  hs.uielement.watcher.elementDestroyed,
  hs.uielement.watcher.titleChanged,
  hs.uielement.watcher.applicationDeactivated,
}
M.stopModalEvents = {
  hs.application.watcher.terminated,
  hs.application.watcher.deactivated,
  hs.uielement.watcher.elementDestroyed,
  hs.uielement.watcher.titleChanged,
  hs.uielement.watcher.applicationDeactivated,
}

function M:start()
  if U.tlen(M.loadedAppContexts) == 0 then
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
  end

  -- if M.globalAppWatcher then
  --   return
  -- end

  M.globalAppWatcher = aw.new(function(appName, appEvent, appObj)
    local loadedAppContext = M.loadedAppContexts[appObj:bundleID()]
    local appEventStr = U.eventString(appEvent)

    if loadedAppContext ~= nil then
      local function run(_elementOrAppName, event, app)
        local opts = {
          event = event,
          appObj = app,
          bundleID = appObj:bundleID(),
        }

        if enum.contains(M.startEvents, event) then
          U.log.i({ ":: start events debug: ", app:name(), event, app:bundleID(), loadedAppContext.name })

          if enum.contains(M.startModalEvents, event) then
            if loadedAppContext.modal ~= nil then
              loadedAppContext.modal:enter()
            end
          end

          loadedAppContext:start(opts)
        elseif enum.contains(M.stopEvents, event) then
          U.log.i({ ":: stop events debug: ", app:name(), event, app:bundleID(), loadedAppContext.name })

          -- if enum.contains(M.stopModalEvents, event) then
          if loadedAppContext.modal ~= nil then
            loadedAppContext.modal:exit()
          end
          -- end

          loadedAppContext:stop(opts)
        else
          U.log.w({ "loaded unknown events debug: ", app:name(), event, app:bundleID(), loadedAppContext.name })
        end
      end

      if M.loadedAppWatchers[appObj:bundleID()] ~= nil then
        return M.loadedAppWatchers[appObj:bundleID()]
      end

      run(appObj:name(), appEvent, appObj)

      local watcher = appObj:newWatcher(function(elementOrAppName, elementEvent, _watcher, elementAppObj)
        run(elementOrAppName, elementEvent, elementAppObj)
      end, appObj)

      -- local combinedEvents = enum.filter(enum.concat(M.startEvents, M.stopEvents), function(el)
      --   return type(el) ~= "number"
      -- end)

      watcher:start({
        hs.uielement.watcher.windowCreated,
        -- hs.uielement.watcher.mainWindowChanged,
        -- hs.uielement.watcher.focusedWindowChanged,
        hs.uielement.watcher.titleChanged,
        hs.uielement.watcher.elementDestroyed,
      })

      M.loadedAppWatchers[appObj:bundleID()] = watcher
    else
    end
  end):start()
end

function M:stop()
  if M.globalAppWatcher then
    M.globalAppWatcher:stop()
    M.loadedAppContexts = nil
  end
end

return M
