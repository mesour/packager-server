dofile("library/rendering/MonitorButton.lua")
dofile("library/rendering/ChartItem.lua")
dofile("library/rendering/MonitorFieldset.lua")
dofile("library/rendering/RenderHelper.lua")
dofile("library/handlers/CommandHandler.lua")
dofile("library/Fluid.lua")
dofile("library/Utils.lua")

ReactorMonitor = {}
ReactorMonitor.__index = ReactorMonitor

function ReactorMonitor:create(name, reactorName, monitor, rednetClient, env)
  local obj = {}
  setmetatable(obj, self)
  obj.name = name
  obj.reactorName = reactorName
  obj.monitor = monitor
  obj.rednetClient = rednetClient
  obj.env = env
  obj.enabled = true
  obj.x = 2
  obj.y = 7
  return obj
end

function ReactorMonitor:run()
  local newTabID = self.env.multishell.launch(
    self.env,
    "run-command-listener.lua",
    self.name,
    self.rednetClient:getSide()
  )
  self.env.multishell.setTitle(newTabID, "CommandListener")

  local handler = CommandHandler:create()

  while true
  do
    CommandListener.tryHandle(handler)
    handler:reset()

    id,message = self.rednetClient:receive(self.reactorName, "status")

    local data = textutils.unserialize(message)

    local heat = data["heat"]
    local active = data["active"]
    local maxHeat = data["maxHeat"]
    local output = data["output"]
    local criticalState = data["criticalState"]
    local type = data["type"]
    local maxOutput = 360
    local fuel = data["fuel"]

    self.monitor:clear()

    self.monitor:setTextScale(.5)

    -- FIELDSET
    local fieldset = MonitorFieldset:create(self.monitor)

    fieldset:write("Nuclear reactor: " .. self.name, 2, 2, 27, 19)

    fieldset:write("FUEL INFO", self.x, self.y + 16, 27, 14)

    fieldset:write("NUMBERS", self.x + 28, self.y + 17, 27, 13)

    fieldset:write("CONTROLS", self.x + 28, 2, 27, 6)

    fieldset:write("COOLANT", self.x + 28, 10, 27, 12)

    self.monitor:writePosition("Status", "0", "f", 4, 4)

    local button = MonitorButton:create(self.monitor)

    textColor, backgroundColor = self:getStatusColors(active, output, maxOutput, data)
    button:setColor(textColor, backgroundColor)
    button:write(data["status"], 4, 4, 23)

    local chartItem = ChartItem:create(self.monitor, "horizontal", 23, 0, maxHeat)
    self:insertChart(self.x + 2, self.y + 2, "Heat", heat, maxHeat, "e")

    local color = RenderHelper.getColorByPercent(output / maxOutput * 100)
    self:insertChart(self.x + 2, self.y + 6, "Power", output, maxOutput, color)

    local chartItem = ChartItem:create(self.monitor, "vertical", 9, 0, 20000)
    chartItem:setSize(3)

    local maxFuel = 0
    local currentFuel = 0
    local counter = 1
    for i = self.x + 2, self.x + 22, 4 do
      local fuelRod = fuel[counter]

      local value = fuelRod and fuelRod["remaining"] or 0
      if fuelRod == nil or fuelRod["depleted"] then
        value = 0
      end

      currentFuel = currentFuel + value
      local maxDamage = (fuelRod and fuelRod["maxDamage"] or 20000)
      maxFuel = maxFuel + maxDamage

      local percent = value / maxDamage * 100
      local color = fuelRod == nil and "b" or RenderHelper.getColorByPercent(percent)

      chartItem:setColor(RenderHelper.getColorByPercent(percent))

      chartItem:write(value, i, self.y + 17)
      self.monitor:writePosition("[" .. counter .. "]", "0", "f", i, self.y + 28)

      self.monitor:writePosition("[" .. counter .. "]", "0", "f", self.x + 30, self.y + 22 + counter)

      local s = "--"
      if fuelRod ~= nil then
        s = Utils.round(percent) .. "%"
      end
      self.monitor:writePosition(RenderHelper.getCharacterTo(s, 4) .. s, color, "f", self.x + 37, self.y + 22 + counter)

      local s = "(" .. value .. ")"
      if fuelRod == nil then
        s = "EMPTY SLOT"
      elseif fuelRod["depleted"] then
        s = "DEPLETED"
      end

      self.monitor:writePosition(RenderHelper.getCharacterTo(s, 10) .. s, color, "f", self.x + 43, self.y + 22 + counter)

      counter = counter + 1
    end

    local color = RenderHelper.getColorByPercent(currentFuel / maxFuel * 100)
    self:insertChart(self.x + 2, self.y + 10, "Fuel", currentFuel, maxFuel, color)

    if data["criticalState"] == nil then
      local button = MonitorButton:create(self.monitor)
      button:setColor("0", "a")
      button:write(active and "OFF" or "ON", self.x + 33, 3, 17)
      button:setHandler(handler, function(parameters)
        if active then
          self.rednetClient:callCommand(self.reactorName, "disable")
        else
          self.rednetClient:callCommand(self.reactorName, "enable")
        end
      end)
    else
      self.monitor:writePosition("First resolve problem", "e", "f", self.x + 31, 5)
    end

    self:writeFluidInfo(type, data)

    s = output .. " / " .. maxOutput .. " EU/t"
    self.monitor:writePosition("Output:", "0", "f", 32, 26)
    self.monitor:writePosition(RenderHelper.getCharacterTo(s, 15) .. s, "0", "f", 40, 26)

    s = heat .. " / " .. Utils.getReadableNumber(maxHeat) .. " HU"
    self.monitor:writePosition("Heat:", "0", "f", 32, 27)
    self.monitor:writePosition(RenderHelper.getCharacterTo(s, 15) .. s, "0", "f", 40, 27)

    s = Utils.getReadableNumber(currentFuel) .. " / " .. Utils.getReadableNumber(maxFuel)
    self.monitor:writePosition("Fuel:", "0", "f", 32, 29)
    self.monitor:writePosition(RenderHelper.getCharacterTo(s, 15) .. s, "0", "f", 40, 29)

    self.monitor:push()
    sleep(1)
  end
end

function ReactorMonitor:getStatusColors(active, output, maxOutput, data)
  local hasMax = active and output == maxOutput
  local lightText = output == maxOutput or not active

  textColor = "f"
  if lightText then
    textColor = "0"
  end

  backgroundColor = "e"
  if hasMax then
    backgroundColor = "d"
  elseif active then
    backgroundColor = "1"
  end

  return textColor, backgroundColor
end

function ReactorMonitor:writeFluidInfo(type, data)
  if type ~= "fluid" then
    self.monitor:writePosition("Available only on", "0", "f", 35, 15)
    self.monitor:writePosition("fluid reactor", "0", "f", 37, 16)
    return
  end

  local coldCapacity = data["coolant"]["cold"]["capacity"]
  local coldAmount = data["coolant"]["cold"]["amount"]

  s = Utils.getReadableNumber(coldAmount) .. " / " .. Utils.getReadableNumber(coldCapacity)
  self.monitor:writePosition("Cold:", "0", "f", 32, 12)
  self.monitor:writePosition(RenderHelper.getCharacterTo(s, 15) .. s, "0", "f", 40, 12)

  self:insertFluidChart(Fluid.types["ic2:ic2coolant"]["color"], coldAmount, coldCapacity, 32, 14)

  local hotCapacity = data["coolant"]["hot"]["capacity"]
  local hotAmount = data["coolant"]["hot"]["amount"]

  s = Utils.getReadableNumber(hotAmount) .. " / " .. Utils.getReadableNumber(hotCapacity)
  self.monitor:writePosition("Hot:", "0", "f", 32, 13)
  self.monitor:writePosition(RenderHelper.getCharacterTo(s, 15) .. s, "0", "f", 40, 13)

  self:insertFluidChart(Fluid.types["ic2:ic2hot_coolant"]["color"], hotAmount, hotCapacity, 44, 14)
end

function ReactorMonitor:insertFluidChart(color, amount, capacity, x, y)
  local chartItem = ChartItem:create(self.monitor, "vertical", 6, 0, capacity)
  chartItem:setShowPercent()
  chartItem:setSize(11)
  chartItem:setColor(color)
  chartItem:write(amount, x, y)
end

function ReactorMonitor:insertChart(x, y, name, current, max, color)
  local chartItem = ChartItem:create(self.monitor, "horizontal", 23, 0, max)
  chartItem:setSize(2)
  chartItem:setColor(color)
  self.monitor:writePosition(name, "0", "f", x, y)

  s = Utils.round(current / max * 100) .. "%"
  self.monitor:writePosition(RenderHelper.getCharacterTo(s, 10) .. s, "0", "f", x + 13, y)
  chartItem:write(current, x, y + 1)
end

return ReactorMonitor
