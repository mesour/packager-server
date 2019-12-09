dofile("library/Fluid.lua")
dofile("library/rendering/ChartItem.lua")
dofile("library/rendering/MonitorFieldset.lua")
dofile("library/rendering/MonitorButton.lua")
dofile("library/Utils.lua")

TurbineControl = {}
TurbineControl.__index = TurbineControl

function TurbineControl:create(
  name,
  monitor,
  generator1,
  generator2,
  heatExchanger,
  steamGenerator,
  rednetClient
)
  local obj = {}
  setmetatable(obj, self)
  obj.name = name
  obj.monitor = monitor
  obj.generator1 = generator1
  obj.generator2 = generator2
  obj.heatExchanger = heatExchanger
  obj.steamGenerator = steamGenerator
  obj.rednetClient = rednetClient
  obj.maxOutput = 150
  return obj
end

function TurbineControl:run()
  local counter = 0
  local lastWaterAmount = 0
  local lastHotAmount = 0
  local data = {}

  while true
  do
    self.monitor:clear()

    self.monitor:setTextScale(.5)

    local sg = self.steamGenerator
    local waterAmount = sg:getAmount()
    local waterCapacity = sg:getCapacity(1, 10000)

    local he = self.heatExchanger
    local hotAmount = he:getAmount(1)

    local active = self:isActive(data) or lastWaterAmount ~= waterAmount or lastHotAmount ~= hotAmount

    local fieldset = MonitorFieldset:create(self.monitor)

    fieldset:write("Turbine: " .. self.name, 2, 2, 34, 8)

    fieldset:write("Fluid info", 2, 12, 34, 11)

    self:renderChart(he:getAmount(1), he:getCapacity(1, 10000), he:getFluid(1, "ic2:ic2hot_coolant"), 13, 13, 10)
    self.monitor:writePosition("[Hot]", "0", "f", 15, 21)

    self:renderChart(he:getAmount(2), he:getCapacity(2, 10000), he:getFluid(2, "ic2:ic2coolant"), 24, 13, 10)
    self.monitor:writePosition("[Cold]", "0", "f", 26, 21)

    self:renderChart(waterAmount, waterCapacity, sg:getFluid(1, "ic2:ic2distilled_water"), 4, 13, 8)
    self.monitor:writePosition("[Water]", "0", "f", 5, 21)

    local button = MonitorButton:create(self.monitor, 5)
    button:setColor("0", active and "d" or "e")
    button:write(active and "ON" or "OFF", 26, 3, 8)

    gen1Energy = active and "50" or "0"
    gen2Energy = active and "25" or "0"

    self.monitor:writePosition("Fuel:", "0", "f", 4, 4)
    self.monitor:writePosition(0 < hotAmount and "[ OK ]" or "[ DEPLETED ]", 0 < hotAmount and "d" or "e", "f", 11, 4)

    self.monitor:writePosition("Water:", "0", "f", 4, 5)
    self.monitor:writePosition(waterAmount .. " / " .. Utils.getReadableNumber(waterCapacity) .. " mb", "0", "f", 11, 5)

    self.monitor:writePosition("Avg:", "0", "f", 4, 6)
    self.monitor:writePosition(active and "75 EU/t" or "0 EU/t", "0", "f", 11, 6)

    self.monitor:writePosition("[1] " .. gen1Energy .. " EU/t", "0", "f", 11, 7)
    self.monitor:writePosition("[2] " .. gen2Energy .. " EU/t", "0", "f", 11, 8)

    if counter > 10 then
      head = table.remove(data, 1)
    else
      counter = counter + 1
    end

    table.insert(data, {self.generator1:getOfferedEnergy(), self.generator2:getOfferedEnergy()})

    self.monitor:push()

    lastHotAmount = hotAmount
    lastWaterAmount = waterAmount

    sleep(math.random(.6, .2))
    --sleep(math.random(.6))
  end
end

function TurbineControl:renderChart(amount, capacity, fluid, x, y, size)
  local chartItem = ChartItem:create(self.monitor, "vertical", 6, 0, capacity)
  chartItem:setSize(size)
  chartItem:setShowPercent()
  chartItem:setColor(fluid["color"] or "0")
  chartItem:write(amount, x, y)
end

function TurbineControl:isActive(data)
  for key,value in pairs(data) do
    gen1 = value[1]
    gen2 = value[2]
    if gen1 > 0 or gen2 > 0 then
      return true
    end
  end
  return false
end

return TurbineControl
