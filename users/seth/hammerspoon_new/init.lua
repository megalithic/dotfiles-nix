hs.loadSpoon("SpoonInstall")
spoon.SpoonInstall.use_syncinstall = true

hs.ipc.cliInstall()

-- Print helper
function dump(o)
  if type(o) == "table" then
    local s = "{ "
    for k, v in pairs(o) do
      if type(k) ~= "number" then k = "\"" .. k .. "\"" end
      s = s .. "[" .. k .. "] = " .. dump(v) .. ","
    end
    return s .. "} "
  else
    return tostring(o)
  end
end

require("ptt")
