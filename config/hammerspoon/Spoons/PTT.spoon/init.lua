local obj = {}
obj.__index = obj

-- Metadata
obj.name = "PTT"
obj.version = "1.0"
obj.author = "seth <seth@megalithic.io>"
obj.license = "MIT - https://opensource.org/licenses/MIT"
obj.mode = "ptt" -- or "ptm"
obj.pushed = false
obj.volume = 60
obj.icons = {
  ["hot"] = hs.styledtext.new("◉", {
    color = { hex = "#c43e1f" },
    font = { name = "Symbols Nerd Font Mono", size = 13 },
  }),
  ["ptm"] = hs.styledtext.new("", {
    color = { hex = "#c43e1f" },
    font = { name = "Symbols Nerd Font Mono", size = 16 },
  }),
  ["ptt"] = hs.styledtext.new(" ", {
    color = { hex = "#aaaaaa" },
    font = { name = "Symbols Nerd Font Mono", size = 14 },
  }),
}

function obj:updateMenu()
  if self.mode == "ptt" then
    if self.pushed then
      self.menu:setTitle(self.icons["ptm"] .. "" .. self.icons["hot"] .. " " .. self.mode)
      muted = false
    else
      self.menu:setTitle(self.icons["ptt"] .. " " .. self.mode)
      muted = true
    end
  elseif self.mode == "ptm" then
    if self.pushed then
      self.menu:setTitle(self.icons["ptt"] .. " " .. self.mode)
      muted = true
    else
      self.menu:setTitle(self.icons["ptm"] .. "" .. self.icons["hot"] .. " " .. self.mode)
      muted = false
    end
  end

  self:toggleMicMute(muted)

  return self
end

--- MicMute:toggleMicMute()
--- Method
--- Toggle mic mute on/off
---
function obj:toggleMicMute(mutedState)
  local current = hs.audiodevice.current(true)
  local mic = current.device

  mutedState = mutedState ~= nil and mutedState or not mic:muted()

  mic:setInputMuted(mutedState)
  mic:setInputVolume(mutedState and 0 or self.volume)

  local zoom = hs.application("Zoom")
  if mic:muted() then
    if zoom then
      local ok = zoom:selectMenuItem("Unmute Audio")
      if not ok then
        hs.timer.doAfter(0.5, function()
          zoom:selectMenuItem("Unmute Audio")
        end)
      end
    end
  else
    if zoom then
      local ok = zoom:selectMenuItem("Mute Audio")
      if not ok then
        hs.timer.doAfter(0.5, function()
          zoom:selectMenuItem("Mute Audio")
        end)
      end
    end
  end

  return self
end

--- MicMute:toggleMode()
--- Method
--- Toggle between push-to-talk (ptt) and push-to-mute (ptm)
---
function obj:toggleMode(mode)
  mode = mode and mode or self.mode
  self.mode = mode == "ptt" and "ptm" or "ptt"

  hs.alert.closeAll()
  hs.alert.show("Toggled to -> " .. self.mode)

  self:updateMenu()

  return self
end

--- MicMute:bindHotkeys(mapping, latch_timeout)
--- Method
--- Binds hotkeys for MicMute
---
--- Parameters:
---  * mapping - A table containing hotkey modifier/key details for the following items:
---   * push - This will cause the microphone mute status to be toggled. Hold for momentary, press quickly for toggle.
---   * toggle - This will cause the microphone mute status to be toggled. Hold for momentary, press quickly for toggle.
---  * latch_timeout - Time in seconds to hold the hotkey before momentary mode takes over, in which the mute will be toggled again when hotkey is released. Latch if released before this time. 0.75 for 750 milliseconds is a good value.
function obj:bindHotkeys(mappings, latch_timeout)
  if self.push_hotkey then
    self.push_hotkey:delete()
  end

  if self.toggle_hotkey then
    self.toggle_hotkey:delete()
  end

  local push_mods, push_key = table.unpack(mappings["push"])
  local toggle_mods, toggle_key = table.unpack(mappings["toggle"])

  if push_key == nil then
    hs.eventtap
      .new({ hs.eventtap.event.types.flagsChanged }, function(evt)
        local modifiersMatch = function(modifiers)
          local match = true

          for _, key in ipairs(push_mods) do
            if modifiers[key] ~= true then
              match = false
            end
          end

          return match
        end

        self.pushed = modifiersMatch(evt:getFlags())

        self:updateMenu()
      end)
      :start()
  else
    self.push_hotkey = hs.hotkey.bind(toggle_mods, toggle_key, function()
      print("push_hotkey without nil")
      self:updateMenu()
    end)
  end

  self.toggle_hotkey = hs.hotkey.bind(toggle_mods, toggle_key, function()
    self:toggleMode()
  end)

  -- TODO: implement latch_timeout for the above eventtap impl, too.
  -- if latch_timeout then
  --   self.hotkey = hs.hotkey.bind(toggle_mods, toggle_key, function()
  --     self:toggleMicMute()
  --     self.time_since_mute = hs.timer.secondsSinceEpoch()
  --   end, function()
  --     if hs.timer.secondsSinceEpoch() > self.time_since_mute + latch_timeout then
  --       self:toggleMicMute()
  --     end
  --   end)
  -- else
  --   self.hotkey = hs.hotkey.bind(toggle_mods, toggle_key, function()
  --     self:toggleMicMute()
  --   end)
  -- end

  return self
end

function obj:init()
  self.time_since_mute = 0
  self.menu = hs.menubar.new()

  self.menu:setClickCallback(function()
    self:toggleMode()
  end)

  hs.audiodevice.watcher.setCallback(function(arg)
    print(hs.inspect(arg))
    -- if string.find(arg, "dIn ") then
    --   self:updateMenu()
    -- end
  end)

  hs.audiodevice.watcher.start()

  return self
end

return obj
