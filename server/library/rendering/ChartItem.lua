dofile("library/rendering/MonitorLine.lua")
dofile("library/Utils.lua")
dofile("library/rendering/RenderHelper.lua")

ChartItem = {}
ChartItem.__index = ChartItem

function ChartItem:create(monitor, type, length, min, max)
  local obj = {}
  setmetatable(obj, self)
  obj.type = type or "horizontal"
  obj.monitor = monitor
  obj.total = math.abs(min) + math.abs(max)
  obj.length = length
  obj.color = "0"
  obj.bgColor = "8"
  obj.size = 1
  obj.showPercent = false
  return obj
end

function ChartItem:write(current, x, y)
  local color = self.color

  local full = MonitorLine:create(self.monitor, self.type)
  full:setColor(self.color)

  local empty = MonitorLine:create(self.monitor, self.type)
  empty:setColor(self.bgColor)

  local fullPercent = math.floor(current / self.total * 100)
  local emptyPercent = 100 - fullPercent
  local fullLength = math.ceil(self.length / 100 * fullPercent)
  local emptyLength = self.length - fullLength

  if self.type == "horizontal" then
    for i=0, self.size - 1, 1 do
      full:write(x, y + i, fullLength)
      empty:write(x + fullLength, y + i, emptyLength)
    end
  else
    for i=0, self.size - 1, 1 do
      empty:write(x + i, y, emptyLength)
      full:write(x + i, y + emptyLength, fullLength)
    end
  end

  if self.showPercent and self.type == "vertical" then
    y = y + self.length - 1
    s = self.size - 4
    if 0 < s then
      x = x + math.floor((self.size - 4) / 2)
    end
    bgColor = fullLength < 2 and self.bgColor or self.color

    s = Utils.round(fullPercent) .. "%"
    self.monitor:writePosition(RenderHelper.getCharacterTo(s, 4) .. s, Utils.getTextColor(bgColor), bgColor, x, y)
  end

end

function ChartItem:setShowPercent()
  self.showPercent = true
end

function ChartItem:setSize(size)
  self.size = size or 1
end

function ChartItem:setColor(color, bgColor)
  self.color = color or "7"
  self.bgColor = bgColor or "8"
end

return ChartItem
