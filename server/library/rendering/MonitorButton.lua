dofile("library/rendering/MonitorLine.lua")
dofile("library/rendering/RenderHelper.lua")

MonitorButton = {}
MonitorButton.__index = MonitorButton

function MonitorButton:create(monitor, size)
  local obj = {}
  setmetatable(obj, self)
  obj.name = name
  obj.monitor = monitor
  obj.printed = false
  obj.x = 0
  obj.y = 0
  obj.width = 0
  obj.size = size or 3
  obj.color = "0"
  obj.bgColor = "a"
  return obj
end

function MonitorButton:write(title, x, y, width)

  if self.printed then
    error("Button can not be printed again")
  end

  self.x = x
  self.y = y
  self.width = width

  local horizontal = MonitorLine:create(self.monitor)
  horizontal:setColor(self.bgColor)

  prefix,title,suffix = RenderHelper.getCentered(title, width, ".")

  local prefixLen = string.len(prefix)
  local titleLen = string.len(title)

  local center = math.floor(self.size / 2) + 1

  for i = 1, self.size, 1 do
    if i == center then
      self.monitor:writePosition(prefix, self.bgColor, self.bgColor, x, y + i)
      self.monitor:writePosition(title, self.color, self.bgColor, x + prefixLen, y + i)
      self.monitor:writePosition(suffix, self.bgColor, self.bgColor, x + prefixLen + titleLen, y + i)
    else
      horizontal:write(x, y + i, width)
    end
  end

  self.printed = true
end

function MonitorButton:setHandler(handler, callback)
  if not self.printed then
    error("Button must be printed before set handler")
  end

  self.callback = callback
  handler:addHandler("monitor-touch", self)
end

function MonitorButton:setColor(color, bgColor)
  self.color = color or "0"
  self.bgColor = bgColor or "a"
end

function MonitorButton:handle(command, parameters)
  local x = parameters["x"]
  local y = parameters["y"]

  if not self:isInButton(x, y) then
    return nil
  end

  if self.callback ~= nil then
    self.callback(parameters)
  end
end

function MonitorButton:isInButton(x, y)
  local maxWidth = self.x + self.width - 1
  local maxSize = self.y + self.size - 1

  if x < self.x then
    return false
  end

  if maxWidth < x then
    return false
  end

  if y < self.y then
    return false
  end

  if maxSize < y then
    return false
  end

  return true
end

return MonitorButton
