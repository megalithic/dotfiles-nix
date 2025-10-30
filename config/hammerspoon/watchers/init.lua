local enum = require("hs.fnutils")

local M = {}

function M:init(opts)
  enum.each(opts.watchers or {}, function(watcher)
    local ok, mod = pcall(require, string.format("watchers.%s", watcher))
    if ok then
      mod({ kill = false })
      U.log.i(string.format("[watcher] %s started", watcher))
    else
      U.log.e(string.format("[watcher] %s failed to start", watcher))
      U.log.e(string.format("[watcher] %s %s", watcher, mod))
    end
  end)

  return self
end

function M:stop(opts)
  enum.each(opts.watchers or {}, function(watcher)
    local ok, mod = pcall(require, string.format("watchers.%s", watcher))
    if ok then
      mod({ kill = true })
      U.log.i(string.format("[watcher] %s stopped", watcher))
    else
      U.log.e(string.format("[watcher] %s failed to stop", watcher))
      U.log.e(string.format("[watcher] %s %s", watcher, mod))
    end
  end)

  return self
end

return M
