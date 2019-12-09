Monitor = {}
Monitor.__index = Monitor

Monitor.colors = {}
Monitor.colors["0"] = colors.white
Monitor.colors["1"] = colors.orange
Monitor.colors["2"] = colors.magenta
Monitor.colors["3"] = colors.lightBlut
Monitor.colors["4"] = colors.yellow
Monitor.colors["5"] = colors.lime
Monitor.colors["6"] = colors.pink
Monitor.colors["7"] = colors.gray
Monitor.colors["8"] = colors.lightGray
Monitor.colors["9"] = colors.cyan
Monitor.colors["a"] = colors.purple
Monitor.colors["b"] = colors.blue
Monitor.colors["c"] = colors.brown
Monitor.colors["d"] = colors.green
Monitor.colors["e"] = colors.red
Monitor.colors["f"] = colors.black

function Monitor:create(monitor)
  local obj = {}
  setmetatable(obj, self)
  obj.monitor = monitor
  obj.topPosition = 1
  obj.backgroundColor = "f"
  return obj
end

function Monitor:setTextScale(value)
  self.monitor.setTextScale(value)
end

function Monitor:setBackgroundColor(color)
  self.monitor.setBackgroundColor(Monitor.toHex(color))
  self.backgroundColor = color
end

function Monitor:write(message, color, background)
  local length = string.len(message)
  color = color or "0"
  background = background or self.backgroundColor
  self.monitor.blit(message, string.rep(color, length), string.rep(background, length))
end

function Monitor.toHex(str)
  return Monitor.colors[str]
end

function Monitor:blit(message, color, background)
  self:write(message, color, background)
end

function Monitor:writeln(message, color, background)
  self:write(message, color, background)
  self.topPosition = self.topPosition + 1
  self.monitor.setCursorPos(1, self.topPosition)
end

function Monitor:writePosition(message, color, background, x, y)
  x = x or 1
  y = y or 1
  self.monitor.setCursorPos(x, y)
  self:write(message, color, background)
end

function Monitor:clear()
  self.topPosition = 1
  self.monitor.setCursorPos(1, 1)
  self.monitor.clear()
end

function Monitor:insert(method, parameters)
  if parameters == nil then
    self[method](self)
    return
  end

  self[method](
    self,
    parameters["message"],
    parameters["color"],
    parameters["background"],
    parameters["x"],
    parameters["y"]
  )
end

function Monitor:batch(batch)
  for key,value in pairs(batch) do
    if value["method"] ~= nil then
      self:insert(value["method"], value["parameters"])
    end
  end
end

function Monitor:push()
  --do nothing (only for RemoteMonitor)
end

function Monitor:isLocal()
  return true
end

return Monitor
