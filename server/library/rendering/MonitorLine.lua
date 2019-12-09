MonitorLine = {}
MonitorLine.__index = MonitorLine

function MonitorLine:create(monitor, type)
  local obj = {}
  setmetatable(obj, self)
  obj.type = type or "horizontal"
  obj.monitor = monitor
  obj.color = "7"
  return obj
end

function MonitorLine:setColor(color)
  self.color = color
end

function MonitorLine:write(x, y, length)
  local color = self.color

  if self.type == "horizontal" then
    self.monitor:writePosition(string.rep("-", length), color, color, x, y)
  else
    for i = 1, length, 1 do
       self.monitor:writePosition("|", color, color, x, y + i)
    end
  end

end

return MonitorLine
