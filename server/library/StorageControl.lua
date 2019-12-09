dofile("library/rendering/ChartItem.lua")
dofile("library/rendering/MonitorFieldset.lua")
dofile("library/Utils.lua")

StorageControl = {}
StorageControl.__index = StorageControl

function StorageControl:create(name, storage, monitor)
  local obj = {}
  setmetatable(obj, self)
  obj.name = name
  obj.monitor = monitor
  obj.storage = storage
  return obj
end

function StorageControl:run()
  local last = self.storage:getEUStored()

  while true
  do
    rednet.broadcast(self.storage:toString(), self.name .. "-status")
    rednet.broadcast(self.name, "ping-storage")

    self.monitor:clear()

    self.monitor:setTextScale(.5)

    local fieldset = MonitorFieldset:create(self.monitor)

    fieldset:write("EU storage: " .. self.name, 2, 2, 34, 7)

    local capacity = self.storage:getEUCapacity()
    local amount = self.storage:getEUStored()

    -- AMOUNT
    self:renderLine("Amount:", 4, 4)
    self:renderLine(amount .. " EU", 14, 4)

    -- CAPACITY
    self:renderLine("Capacity:", 4, 5)
    self:renderLine(Utils.getReadableNumber(capacity) .. " EU", 14, 5)

    local percent = self.storage:getEuPercent()
    if percent < 30 then
      color = "e"
    elseif percent < 55 then
      color = "1"
    else
      color = "d"
    end

    -- INCREASE
    self:renderLine("Increase:", 4, 6)

    self:renderIncrease(amount, last, 14, 6)

    self:renderChart(color, amount, capacity)

    self.monitor:push()

    last = amount

    sleep(0.25)
  end
end

function StorageControl:renderIncrease(amount, last, x, y)
  if last < amount and (amount - last) > 2 then
    self.monitor:writePosition(" + ", "f", "d", x, y)
  elseif amount < last and -2 < (last - amount) then
    self.monitor:writePosition(" - ", "f", "e", x, y)
  end
end


function StorageControl:renderLine(value, x, y, color)
  color = color or "0"
  self.monitor:writePosition(value, color, "f", x, y)
end

function StorageControl:renderChart(color, amount, capacity)
  local chartItem = ChartItem:create(self.monitor, "vertical", 8, 0, capacity)
  chartItem:setSize(8)
  chartItem:setShowPercent()
  chartItem:setColor(color)
  chartItem:write(amount, 28, 1)
end

return StorageControl
