dofile("library/rendering/ChartItem.lua")
dofile("library/rendering/MonitorFieldset.lua")
dofile("library/rendering/MonitorButton.lua")
dofile("library/Fluid.lua")
dofile("library/Utils.lua")

GeneratorGridControl = {}
GeneratorGridControl.__index = GeneratorGridControl

function GeneratorGridControl:create(name, monitorWidth, monitorHeight, generators, monitor, fluidId)
  local obj = {}
  setmetatable(obj, self)
  obj.name = name
  obj.monitor = monitor
  obj.monitorWidth = monitorWidth
  obj.monitorHeight = monitorHeight
  obj.generators = generators
  obj.fluidId = fluidId
  return obj
end

function GeneratorGridControl:run()
  while true
  do
    self.monitor:clear()

    self.monitor:setTextScale(.5)

    -- FIELDSET
    local fieldset = MonitorFieldset:create(self.monitor)

    fieldset:write("Generator: " .. self.name, 2, 2, self.monitorWidth - 2, self.monitorHeight - 2)

    if 57 < self.monitorWidth then
      a = 5
      b = 15
    elseif 30 < self.monitorWidth then
      a = 3
      b = 17
    end

    local someActive = false
    local allCapacity = 0
    local allAmount = 0
    local allOfferedEnergy = 0
    local maxOfferedEnergy = 0

    local line = 0
    local about = 0
    for key,generator in pairs(self.generators) do
      local aboutLine = (6 * line)

      if key > 1 and (key - 1) % a == 0 then
        about = 0
      end

      local tank = generator:getTank()

      local fluid = generator:getFluid()
      local amount = tank and tank:getAmount() or 0
      local capacity = tank and tank:getCapacity(1, 8000) or 8000

      allCapacity = allCapacity + capacity
      allAmount = allAmount + amount
      maxOfferedEnergy = maxOfferedEnergy + fluid["energy"]

      local active = amount > 5

      if active then
        someActive = true
        allOfferedEnergy = allOfferedEnergy + generator:getOfferedEnergy()
      end

      local chartColor = fluid["color"] or "5"
      self:renderChart(chartColor, amount, capacity, 4 + about, 10 + aboutLine)

      self.monitor:writePosition("[" .. key .. "]", "0", "f", 10 + about, 12 + aboutLine)
      self.monitor:writePosition("[" .. (active and "ON" or "OFF") .. "]", active and "d" or "e", "f", 10 + about, 13 + aboutLine)
      self.monitor:writePosition(generator:getOfferedEnergy() .. " EU/t", "0", "f", 10 + about, 14 + aboutLine)

      if key > 1 and key % a == 0 then
        line = line + 1
      end

      about = about + b
    end

    local hasMax = someActive and allOfferedEnergy == maxOfferedEnergy
    local lightText = allOfferedEnergy == maxOfferedEnergy or not someActive
    local button = MonitorButton:create(self.monitor, 5)
    button:setColor(lightText and "0" or "f", hasMax and "d" or someActive and "1" or "e")
    button:write(hasMax and "OK" or someActive and "LESS POWER" or "OFF", 4, 3, 14)

    local color = RenderHelper.getColorByPercent(allOfferedEnergy / maxOfferedEnergy * 100)
    self:insertHorizontalChart(19, 4, "Power", allOfferedEnergy, maxOfferedEnergy, color)

    s = allOfferedEnergy .. " EU/t"
    self.monitor:writePosition(RenderHelper.getCharacterTo(s .. "", 11) .. s, "0", "f", 24, 4)

    local color = RenderHelper.getColorByPercent(allAmount / allCapacity * 100)
    self:insertHorizontalChart(19, 7, "Fuel", allAmount, allCapacity, color)
    self.monitor:writePosition(
      RenderHelper.getCharacterTo(allAmount .. "", 9) .. allAmount .. " mb",
      "0", "f", 23, 7
    )

    self.monitor:writePosition("Fluid:    " .. self:getFluidName(), "0", "f", 36, 4)
    self.monitor:writePosition("Capacity: " .. Utils.getReadableNumber(allCapacity) .. " mb", "0", "f", 36, 5)
    self.monitor:writePosition("Max out:  " .. maxOfferedEnergy .. " EU/t", "0", "f", 36, 6)

    self.monitor:push()

    sleep(0.3)
  end
end

function GeneratorGridControl:getFluidName()
  if Fluid.types[self.fluidId] ~= nil then
    return Fluid.types[self.fluidId]["name"]
  end
  return "UNKNOWN"
end

function GeneratorGridControl:renderChart(color, amount, capacity, x, y)
  local chartItem = ChartItem:create(self.monitor, "vertical", 5, 0, capacity)
  chartItem:setShowPercent()
  chartItem:setSize(5)
  chartItem:setColor(color)
  chartItem:write(amount, x, y)
end

function GeneratorGridControl:insertHorizontalChart(x, y, name, current, max, color)
  local chartItem = ChartItem:create(self.monitor, "horizontal", 16, 0, max)
  chartItem:setSize(1)
  chartItem:setColor(color)
  self.monitor:writePosition(name, "0", "f", x, y)
  chartItem:write(current, x, y + 1)
end

return GeneratorGridControl
