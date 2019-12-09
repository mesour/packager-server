dofile("library/rendering/MonitorLine.lua")

MonitorFieldset = {}
MonitorFieldset.__index = MonitorFieldset

function MonitorFieldset:create(monitor)
  local obj = {}
  setmetatable(obj, self)
  obj.name = name
  obj.monitor = monitor
  obj.color = "0"
  obj.bgColor = "8"
  return obj
end

function MonitorFieldset:write(title, x, y, width, height)
  local titleLength = string.len(title)

  local horizontal = MonitorLine:create(self.monitor)
  horizontal:write(x, y, 2)

  self.monitor:writePosition(" " .. title .. " ", "0", "f", x + 2, y)

  horizontal:write(x + 2 + titleLength + 2, y, width - 2 - titleLength - 2)
  local vertical = MonitorLine:create(self.monitor, "vertical")
  vertical:write(x, y, height)
  vertical:write(x + width - 1, y, height)
  horizontal:write(x, y + height, width)
end

function MonitorFieldset:setColor(color, bgColor)
  self.color = color or "0"
  self.bgColor = bgColor or "a"
end

return MonitorFieldset
