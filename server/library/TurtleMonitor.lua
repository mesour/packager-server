dofile("library/rendering/MonitorButton.lua")
dofile("library/rendering/ChartItem.lua")
dofile("library/rendering/MonitorFieldset.lua")
dofile("library/rendering/RenderHelper.lua")
dofile("library/Utils.lua")

TurtleMonitor = {}
TurtleMonitor.__index = TurtleMonitor

function TurtleMonitor:create(name, turtleName, monitor, rednetClient, env)
    local obj = {}
    setmetatable(obj, self)
    obj.name = name
    obj.turtleName = turtleName
    obj.monitor = monitor
    obj.rednetClient = rednetClient
    obj.env = env
    obj.x = 2
    obj.y = 7
    return obj
end

function TurtleMonitor:run()
    while true
    do
        id,message = self.rednetClient:receive(self.turtleName, "status")

        if message ~= nil then
            local data = textutils.unserialise(message)
            self:printToMonitor(textutils.unserialise(data))
        end

        sleep(1)
    end
end

function TurtleMonitor:printToMonitor(data)
    local state = data["state"]
    local hasTorches = data["hasTorches"]
    local currentFuel = data["fuelLevel"]
    local maxFuel = data["fuelLimit"]
    local fullInventory = data["fullInventory"]
    local needRefuel = data["needRefuel"]
    local row = math.max(data["row"], 0)
    local position = math.max(data["position"], 0)
    local floor = math.ceil(data["floor"] / 3) + 1
    local location = data["location"]
    local rowLength = data["rowLength"]
    local rowCount = data["rowCount"]
    local floorCount = math.ceil(data["floorCount"] / 3)
    local startSide = data["startSide"]
    local maxSlots = 16 - data["minEmptySlots"]
    local fullSlots = maxSlots - data["emptySlots"]

    self.monitor:clear()

    self.monitor:setTextScale(.5)

    -- FIELDSET
    local fieldset = MonitorFieldset:create(self.monitor)

    fieldset:write("Turtle: " .. self.name, 2, 2, 27, 19)

    fieldset:write("INFO", self.x, self.y + 16, 27, 14)

    fieldset:write("PROGRESS", self.x + 28, 2, rowCount + 9, rowLength + 4)

    self.monitor:writePosition("Status", "0", "f", 4, 4)

    local button = MonitorButton:create(self.monitor)
    textColor, backgroundColor = self:getStatusColors(state)
    button:setColor(textColor, backgroundColor)
    button:write(state, 4, 4, 23)

    local color = RenderHelper.getColorByPercentReversed(fullSlots / maxSlots * 100)
    self:insertChart(self.x + 2, self.y + 6, "Chest", fullSlots, maxSlots, color)

    local color = RenderHelper.getColorByPercent(currentFuel / maxFuel * 100)
    self:insertChart(self.x + 2, self.y + 10, "Fuel", currentFuel, maxFuel, color)

    self.monitor:writePosition("Location: z: " .. tostring(location["z"]), "0", "f", 4, self.y + 2)
    self.monitor:writePosition("x: " .. tostring(location["x"]), "0", "f", 4, self.y + 3)
    self.monitor:writePosition("y: " .. tostring(location["y"]), "0", "f", 4, self.y + 4)

    s = Utils.getReadableNumber(currentFuel) .. " / " .. Utils.getReadableNumber(maxFuel)
    self.monitor:writePosition("Fuel:", "0", "f", 4, 25)
    self.monitor:writePosition(RenderHelper.getCharacterTo(s, 15) .. s, "0", "f", 12, 25, 23)

    s = Utils.getReadableNumber(fullSlots) .. " / " .. Utils.getReadableNumber(maxSlots)
    self.monitor:writePosition("Chest:", "0", "f", 4, 26)
    self.monitor:writePosition(RenderHelper.getCharacterTo(s, 15) .. s, "0", "f", 12, 26, 23)

    local counter = 4
    local floorColors = {"0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d", "d"}

    for zPoint = floorCount, 1, -1 do
        self.monitor:writePosition("|", floorColors[zPoint], floorColors[zPoint], 32, 4 + floorCount - zPoint)
    end

    local currentFloor = math.min(floor + 1, floorCount + 1)
    self.monitor:writePosition("<", "0", "f", 33, 4 + floorCount - currentFloor + 1)
    self.monitor:writePosition("-", "0", "f", 34, 4 + floorCount - currentFloor + 1)

    for xPoint = 0, rowCount, 1 do
        for yPoint = 0, rowLength, 1 do
            local color = floorColors[floor]
            if row == xPoint and position == yPoint and state ~= "complete" then
                color = "e" -- turtle color (red)
            elseif xPoint < row or (xPoint == row and ((row % 2 == 0 and yPoint < position) or (row % 2 ~= 0 and yPoint > position))) then
                color = floorColors[currentFloor]
            end
            self.monitor:writePosition("|", color, color, 36 + xPoint, 4 + yPoint)
        end
    end

    if state == "complete" then
        self.monitor:writePosition("|", "e", "e", 36, 4)
    end

    self.monitor:push()
end

function TurtleMonitor:getStatusColors(state)
    textColor = "f"
    if state == "mining" or state ~= "starting" or state ~= "to-start" or state ~= "complete" then
        textColor = "0"
    end

    backgroundColor = "e"
    if state == "mining" then
        backgroundColor = "d"
    elseif state == "starting" then
        backgroundColor = "1"
    end

    return textColor, backgroundColor
end

function TurtleMonitor:insertChart(x, y, name, current, max, color)
    local chartItem = ChartItem:create(self.monitor, "horizontal", 23, 0, max)
    chartItem:setSize(2)
    chartItem:setColor(color)
    self.monitor:writePosition(name, "0", "f", x, y)

    s = Utils.round(current / max * 100) .. "%"
    self.monitor:writePosition(RenderHelper.getCharacterTo(s, 10) .. s, "0", "f", x + 13, y)
    chartItem:write(current, x, y + 1)
end

return TurtleMonitor
