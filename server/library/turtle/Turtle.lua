dofile("library/turtle/TurtleInventory.lua")
dofile("library/turtle/TurtleFuel.lua")
dofile("library/turtle/TurtleMover.lua")
dofile("library/turtle/TurtleHelper.lua")
dofile("library/turtle/TurtleLogger.lua")

Turtle = {}
Turtle.__index = Turtle

function Turtle.init(start, finish, storage, storageSide, args)
    if args[1] == nil then
        local turtleHelper = Turtle:create(start, finish, storage, storageSide)
        turtleHelper:run()
    elseif args[1] == "state" then
        Turtle.showState()
    elseif args[1] == "reset" then
        Turtle.resetSettings()
    else
        error("Unknown signal " .. args[1])
    end
end

function Turtle:create(start, finish, storage, storageSide)
    local obj = {}
    setmetatable(obj, self)

    local row = Turtle.initRow()
    local rowLength, rowCount, floorCount = TurtleHelper.getSize(start, finish)

    obj.rowLength = rowLength
    obj.rowCount = rowCount
    obj.floorCount = floorCount
    obj.storageStation = storage
    obj.storageFace = storageSide
    obj.floor = Turtle.initFloor()
    obj.row = row

    obj:initPosition()

    obj.mover = TurtleMover:create()
    obj.fuel = TurtleFuel:create()
    obj.inventory = TurtleInventory:create()
    obj.startSide = TurtleHelper.detectStartSide(start, finish)
    obj.startStation = start
    obj.endStation = finish

    obj.isStartingSequence = true

    return obj
end

function Turtle:detectSide()
    local currentVector = self.mover:getLocation()
    if currentVector == false then
        return false
    end

    self.mover:forward()

    local frontVector = self.mover:getLocation()
    if currentVector == false then
        return false
    end
    return TurtleHelper.getNeededSide(currentVector, frontVector)
end

function Turtle:run()
  self.mover:setSide(self:detectSide())

    while true
    do
        if self.fuel:emptyFuel() then
            TurtleLogger.error("Empty fuel! Need manual refuel.")
            break

        elseif self.inventory:hasFull() then
            if self.mover:goToVector(self.storageStation, self.storageFace) then
                self.inventory:flush()
            end

        elseif self.fuel:needFuel() then
            if self.mover:goToVector(self.storageStation, self.storageFace) then
                self.fuel:refuel()
            end

        elseif self:continuePlan() == false then
            break
        end
    end

  -- rednet.close(side)
end

function Turtle:continuePlan()
    local currentVector = self.mover:getLocation()
    if currentVector == false then
        return false
    end

    local targetVector = self:findTargetVector()
    if self.isStartingSequence then
        local side = self:getCurrentStartSide()
        if self.mover:goToVector(targetVector, side) == false then
            print("can not move to start position!")
            return false
        end
        self:updatePosition()
        self.isStartingSequence = false
        return true
    end

    if currentVector.z < targetVector.z then
        self.mover:up()
        if self.mover:goToVector(targetVector, self.startSide) == false then
            print("can not move to start position!")
            return false
        end

    elseif currentVector.z > targetVector.z then
        self.mover:down()

    elseif self.mover:turnToNeededSide(currentVector, targetVector) then

    elseif currentVector.x == targetVector.x and currentVector.y == targetVector.y and currentVector.z == targetVector.z then
        if self.startStation.x == targetVector.x and self.startStation.y == targetVector.y and self.startStation.z == targetVector.z then
            print("COMPLETE")
            return false
        else
            self.position = 1
        end

    else
        self:forward()
    end
end

function Turtle:forward()
    if self.mover:forward() then
        self:updatePosition()
    end
end

function Turtle:getCurrentStartSide()
    if self.startSide == nil then
        error("Start side is required")
    end

    if self:isIncreasing() then
      return self.startSide
    end
    return self.mover:getRotatedFace(self.startSide, 2)
end

function Turtle:findTargetVector()
    if (self:isIncreasing() and self.position > self.rowLength) or (self:isIncreasing() == false and self.position <= -1) then
        self:increaseRow()
        self:initPosition()
    end

    if self.row >= self.rowCount + 1 then
        self.position = 0
        self:resetRow()
        self:increaseFloor()
    end

    if self.floor >= self.floorCount + 1 then
        return self.startStation
    end

    local x, y
    local z = self.startStation.z + self.floor

    if self.startSide == "south" then
        x = self.startStation.x - self.row
        y = self.startStation.y + self.position
    elseif self.startSide == "west" then
        x = self.startStation.x - self.position
        y = self.startStation.y - self.row
    elseif self.startSide == "north" then
        x = self.startStation.x + self.row
        y = self.startStation.y - self.position
    elseif self.startSide == "east" then
        x = self.startStation.x + self.position
        y = self.startStation.y + self.row
    else
        error("Start side is required")
    end

    return vector.new(x, y, z)
end

function Turtle:isIncreasing()
    return self.row % 2 == 0
end

function Turtle:saveRow()
    settings.set("row", self.row)
end

function Turtle:saveFloor()
    settings.set("floor", self.floor)
end

function Turtle.initRow()
    return settings.get("row", 0)
end

function Turtle.initFloor()
    return settings.get("floor", 0)
end

function Turtle.showState()
    print("Row: " .. Turtle.initRow())
    print("Floor: " .. Turtle.initFloor())

    local fuel = TurtleFuel:create()
    print("Fuel: " .. turtle.getFuelLevel() .. "/" .. turtle.getFuelLimit())
    if fuel:needFuel() then
        print("Need refuel: yes")
    else
        print("Need refuel: no")
    end
    local inventory = TurtleInventory:create()
    if inventory:hasFull() then
        print("Full inventory: yes")
    else
        print("Full inventory: no")
    end
end

function Turtle.resetSettings()
    settings.set("row", 0)
    settings.set("floor", 0)
    print("Reset was successful")
end

function Turtle:increaseFloor()
    self.floor = self.floor + 1
    self:saveFloor()
end

function Turtle:increaseRow()
    self.row = self.row + 1
    self:saveRow()
end

function Turtle:resetRow()
    self.row = 0
    self:saveRow()
end

function Turtle:updatePosition()
    if self:isIncreasing() then
        self.position = self.position + 1
    else
        self.position = self.position - 1
    end
end

function Turtle:initPosition()
    if self:isIncreasing() then
        self.position = 0
    else
        self.position = self.rowLength
    end
end

return Turtle
