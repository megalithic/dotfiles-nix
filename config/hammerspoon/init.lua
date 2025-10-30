_G.DefaultFont = { name = "JetBrainsMono Nerd Font Mono", size = 18 }
hs.console.darkMode(true)
hs.console.consoleFont(DefaultFont)
hs.console.alpha(0.985)
local darkGrayColor = { red = 26 / 255, green = 28 / 255, blue = 39 / 255, alpha = 1.0 }
local whiteColor = { white = 1.0, alpha = 1.0 }
local lightGrayColor = { white = 1.0, alpha = 0.9 }
local grayColor = { red = 24 * 4 / 255, green = 24 * 4 / 255, blue = 24 * 4 / 255, alpha = 1.0 }
hs.console.outputBackgroundColor(darkGrayColor)
hs.console.consoleCommandColor(whiteColor)
hs.console.consoleResultColor(lightGrayColor)
hs.console.consolePrintColor(grayColor)

--- @diagnostic disable-next-line: lowercase-global
function _G.req(mod, ...)
  local function lineTraceHook(event, data)
    local lineInfo = debug.getinfo(2, "Snl")
    print("TRACE: " .. (lineInfo["short_src"] or "<unknown source>") .. ":" .. (lineInfo["linedefined"] or "<??>"))
  end

  local ok, reqmod = pcall(require, mod)
  if not ok then
    debug.sethook(lineTraceHook, "l")
    error(reqmod)

    return false
  else
    -- if there is an init function; invoke it first.
    if type(reqmod) == "table" and reqmod.init ~= nil and type(reqmod.init) == "function" then
      -- if initializedModules[reqmod.name] ~= nil then
      reqmod:init(...)
      -- initializedModules[reqmod.name] = reqmod
      -- end
    end

    -- always return the module.. we typically end up immediately invoking it.
    return reqmod
  end
end

local ok, mod_or_err = pcall(require, "config")
if not ok then
  error("Error loading hammerspork config; unable to continue...\n" .. mod_or_err)
  return
end

_G.U = require("utils")

function _G.P(...)
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
  hs.console.printStyledtext(U.ts() .. " => " .. contents)
end

local watchers = { "audio", "camera" }

hs.timer.doAfter(1, function()
  hs.loadSpoon("EmmyLua")
  req("bindings")
  req("watchers", { watchers = watchers })

  hs.shutdownCallback = function()
    require("watchers"):stop({ watchers = watchers })
    -- require("hyper"):stop()
  end

  hs.timer.doAfter(0.2, function()
    hs.notify.withdrawAll()
    hs.notify.new({ title = "hammerspork", subTitle = "config is loaded.", alwaysPresent = true }):send()
  end)
end)
