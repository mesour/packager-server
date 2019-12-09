dofile("library/rendering/RenderHelper.lua")
dofile("library/rendering/MonitorFieldset.lua")
dofile("library/rendering/ChartItem.lua")

StorageGridControl = {}
StorageGridControl.__index = StorageGridControl

function StorageGridControl:create(name, storages, monitor, monitorWidth, monitorHeight)
  local obj = {}
  setmetatable(obj, self)
  obj.name = name
  obj.monitor = monitor
  obj.monitorHeight = monitorHeight
  obj.monitorWidth = monitorWidth
  obj.storages = storages
  return obj
end

function StorageGridControl:run()
  local last = self:getFullAmount()

  while true
  do
    self.monitor:clear()

    rednet.broadcast(self:toString(), self.name .. "-status")
    rednet.broadcast(self.name, "ping-storage")

    -- FIELDSET
    local fieldset = MonitorFieldset:create(self.monitor)

    fieldset:write("EU storage: " .. self.name, 2, 2, self.monitorWidth - 2, self.monitorHeight - 2)

    if 57 < self.monitorWidth then
      a = 7
      b = 10
    elseif 30 < self.monitorWidth then
      a = 5
      b = 10
    end

    self.monitor:setTextScale(.5)

    local fullCapacity = 0
    local fullStored = 0
    local counter = 0

    local line = 0
    local about = 0
    for key,storage in pairs(self.storages) do
      local aboutLine = (6 * line)

      if key > 1 and (key - 1) % a == 0 then
        about = 0
      end

      local capacity = storage:getEUCapacity()
      local stored = storage:getEUStored()

      self:renderChart(key, stored, capacity, 4 + about, 10 + aboutLine)

      fullCapacity = fullCapacity + capacity
      fullStored = fullStored + stored

      counter = counter + 1

      if key > 1 and key % a == 0 then
        line = line + 1
      end

      about = about + b
    end

    --self:writeInfo("All", fullCapacity, fullStored, "=")
    self:renderMainChart(fullStored, fullCapacity, 4, 4)


    self.monitor:writePosition("Capacity: " .. Utils.getReadableNumber(fullCapacity) .. " EU", "0", "f", 28, 4)
    self.monitor:writePosition("Stored:   " .. fullStored .. " EU", "0", "f", 28, 5)
    self.monitor:writePosition("Percent:  " .. Utils.round(fullStored / fullCapacity * 100) .. "%", "0", "f", 28, 6)

    self.monitor:writePosition("Increase: ", "0", "f", 28, 7)
    self:renderIncrease(fullStored, last, 38, 7)

    self.monitor:push()

    last = fullStored

    sleep(1)
  end
end

function StorageGridControl:renderIncrease(amount, last, x, y)
  if last < amount and (amount - last) > 2 then
    self.monitor:writePosition(" + ", "f", "d", x, y)
  elseif amount < last and -2 < (last - amount) then
    self.monitor:writePosition(" - ", "f", "e", x, y)
  end
end

function StorageGridControl:toString()
  local out = { capacity = 0, stored = 0 }
  for _,storage in pairs(self.storages) do
    out["capacity"] = out["capacity"] + storage:getEUCapacity()
    out["stored"] = out["stored"] + storage:getEUStored()
  end
  return textutils.serialize(out)
end

function StorageGridControl:getFullAmount()
  local amount = 0
  for key,storage in pairs(self.storages) do
    amount = amount + storage:getEUStored()
  end
  return amount
end

function StorageGridControl:renderMainChart(amount, capacity, x, y)
  local chartItem = ChartItem:create(self.monitor, "horizontal", 23, 0, capacity)
  chartItem:setSize(5)
  chartItem:setColor(RenderHelper.getColorByPercent(amount / capacity * 100))
  chartItem:write(amount, x, y)
end

function StorageGridControl:renderChart(key, amount, capacity, x, y)
  local percent = amount / capacity * 100

  local chartItem = ChartItem:create(self.monitor, "horizontal", 9, 0, capacity)
  chartItem:setSize(3)
  chartItem:setColor(RenderHelper.getColorByPercent(percent))
  chartItem:write(amount, x, y + 1)
  self.monitor:writePosition("[1]", "0", "f", x, y)

  s = math.floor(percent) .. "%"
  self.monitor:writePosition(RenderHelper.getCharacterTo(s, 5) .. s, "0", "f", x + 4, y)
end

return StorageGridControl
