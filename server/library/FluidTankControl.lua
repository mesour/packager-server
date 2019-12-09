dofile("library/Fluid.lua")
dofile("library/rendering/ChartItem.lua")
dofile("library/rendering/MonitorFieldset.lua")
dofile("library/Utils.lua")

FluidTankControl = {}
FluidTankControl.__index = FluidTankControl

function FluidTankControl:create(name, fluidTank, monitor)
  local obj = {}
  setmetatable(obj, self)
  obj.name = name
  obj.monitor = monitor
  obj.tank = fluidTank
  return obj
end

function FluidTankControl:run()
  local last = self.tank:getAmount()

  while true
  do
    self.monitor:clear()

    self.monitor:setTextScale(.5)

    local fieldset = MonitorFieldset:create(self.monitor)

    fieldset:write("Fluid tank: " .. self.name, 2, 2, 27, 7)

    local capacity = self.tank:getCapacity()
    local amount = self.tank:getAmount()
    local fluid = self.tank:getFluid()

    -- FLUID
    self:renderLine("Fluid:", 4, 4)
    self:renderLine(fluid and fluid["name"] or "UNKNOWN", 14, 4)

    -- AMOUNT
    self:renderLine("Amount:", 4, 5)
    self:renderLine(Utils.getReadableNumber(amount) .. " mb", 14, 5)

    -- CAPACITY
    self:renderLine("Capacity:", 4, 6)
    self:renderLine(Utils.getReadableNumber(capacity) .. " mb", 14, 6)

    -- INCREASE
    self:renderIncrease(amount, last, 7)

    self:renderChart(amount, capacity, fluid)

    self.monitor:push()

    last = amount

    sleep(1)
  end
end

function FluidTankControl:renderIncrease(amount, last, y)
  self.monitor:writePosition("Increase: ", "0", "f", 4, y)
  if last < amount then
    self.monitor:writePosition("+" .. (amount - last) .. " mb/s", "d", "f", 14, y)
  elseif amount < last then
    self.monitor:writePosition("-" .. (last - amount) .. " mb/s", "e", "f", 14, y)
  else
    self.monitor:writePosition("0 " .. " mb/s", "0", "f", 14, y)
  end
end

function FluidTankControl:renderLine(value, x, y)
  self.monitor:writePosition(value, "0", "f", x, y)
end

function FluidTankControl:renderChart(amount, capacity, fluid)
  local chartItem = ChartItem:create(self.monitor, "vertical", 8, 0, capacity)
  chartItem:setSize(8)
  chartItem:setShowPercent()
  chartItem:setColor(fluid and fluid["color"] or "0")
  chartItem:write(amount, 28, 1)
end

return FluidTankControl
