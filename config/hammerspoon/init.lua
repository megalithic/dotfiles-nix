local ok, mod_or_err = pcall(require, "config")
if not ok then
  error("Error loading hammerspork config; unable to continue...\n" .. mod_or_err)
  return
end

_G.U = require("utils")
function _G.P(...)
  local function getFnLocation()
    local w = debug.getinfo(3, "S")
    return w.short_src:gsub(".*/", "") .. ":" .. w.linedefined
  end

  if ... == nil then
    hs.console.printStyledtext(U.ts() .. " => " .. "")
    -- TODO: add line debugging so we can see where blank P statements are

    return
  end

  local contents = ...

  if type(...) == "table" then
    contents = hs.inspect(...)
  else
    contents = string.format(...)
  end

  -- hs.rawprint(...)
  -- hs.console.printStyledtext(ts() .. " => " .. contents)
  -- hs.console.printStyledtext("%s (%s) => %s", ts(), getFnLocation(), contents))
  hs.console.printStyledtext(ts() .. " (" .. getFnLocation() .. ") " .. " => " .. contents)
end

local watchers = { "audio", "camera", "dock" }

hs.timer.doAfter(1, function()
  hs.loadSpoon("EmmyLua")
  req("bindings")
  req("watchers", { watchers = watchers })
  req("ptt", { push = { { "cmd", "alt" }, nil }, toggle = { { "cmd", "alt" }, "p" } }):start()

  hs.shutdownCallback = function()
    require("watchers"):stop({ watchers = watchers })
    -- require("hyper"):stop()
  end

  hs.timer.doAfter(0.2, function()
    hs.notify.withdrawAll()
    hs.notify.new({ title = "hammerspork", subTitle = "config is loaded.", alwaysPresent = true }):send()
  end)
end)
