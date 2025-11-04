local ok, mod_or_err = pcall(require, "config")
if not ok then
  error("Error loading hammerspork config; unable to continue...\n" .. mod_or_err)
  return
end
_G.C = mod_or_err

--- @diagnostic disable-next-line: lowercase-global
function _G.req(mod, ...)
  -- local function lineTraceHook(event, data)
  --   local lineInfo = debug.getinfo(2, "Snl")
  --   print("TRACE: " .. (lineInfo["short_src"] or "<unknown source>") .. ":" .. (lineInfo["linedefined"] or "<??>"))
  -- end

  local ok, reqmod = pcall(require, mod)
  -- G[mod:sub(5)] = reqmod
  -- print(hs.inspect(G[mod:sub(5)]))

  if not ok then
    -- debug.sethook(lineTraceHook, "l")
    -- hs.alert(reqmod, 5)
    error(reqmod)

    return false
  else
    -- if there is an init function; invoke it first.
    if type(reqmod) == "table" and reqmod.init ~= nil and type(reqmod.init) == "function" then
      reqmod:init(...)
    end

    -- always return the module.. we typically end up immediately invoking it.
    return reqmod
  end
end

_G.U = req("utils")
_G.I = hs.inspect -- `i()` to easier inspect in the console

function _G.P(...)
  -- local function getFnLocation()
  --   local w = debug.getinfo(3, "S")
  --   return w.short_src:gsub(".*/", "") .. ":" .. w.linedefined
  -- end

  local function getLocation()
    local info = debug.getinfo(2, "Snl")
    return string.format("%s:%s", info.short_src, info.currentline)
  end

  if ... == nil then
    hs.console.printStyledtext(U.ts() .. " => " .. "")
    -- TODO: add line debugging so we can see where blank P statements are

    return
  end

  local contents = ...

  if type(...) ~= "string" then
    contents = hs.inspect(...)
  else
    if select("#", ...) > 1 then
      contents = string.format(...)
    else
      contents = ...
    end
  end

  hs.console.printStyledtext(U.ts() .. " (" .. getLocation() .. ")" .. " => " .. contents)
end

local watchers = { "audio", "camera", "dock", "app" }

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
