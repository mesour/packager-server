dofile("library/turtle/TurtleInventory.lua")
dofile("library/turtle/TurtleFuel.lua")
dofile("library/turtle/TurtleInspector.lua")
dofile("library/turtle/TurtleMover.lua")
dofile("library/turtle/TurtleHelper.lua")
dofile("library/turtle/TurtleLogger.lua")

Turtle = {}
Turtle.__index = Turtle

function Turtle.init(name, start, finish, storage, torchStorage, stoneStorage, storageSide, rednetClient, args)
    if args[1] == nil or args[1] == "setup" then
        local turtleHelper = Turtle:create(name, start, finish, storage, torchStorage, stoneStorage, storageSide, rednetClient)
        if args[1] == "setup" then
            turtleHelper:setup()
        else
            turtleHelper:run()
        end

    elseif args[1] == "state" then
        Turtle.showState()
    elseif args[1] == "reset" then
        Turtle.resetSettings()
    else
        error("Unknown signal " .. args[1])
    end

    rednetClient:close()
end

function Turtle:create(name, start, finish, storage, torchStorage, stoneStorage, storageSide, rednetClient)
    local obj = {}
    setmetatable(obj, self)

    local row = Turtle.initRow()
    local startSide = TurtleHelper.detectStartSide(start, finish)
    local rowLength, rowCount, floorCount = TurtleHelper.getSize(start, finish, startSide)

    obj.name = name
    obj.rednetClient = rednetClient
    obj.rowLength = rowLength
    obj.rowCount = rowCount
    obj.floorCount = floorCount
    obj.storageStation = storage
    obj.torchStorageStation = torchStorage
    obj.stoneStorageStation = stoneStorage
    obj.storageSide = storageSide
    obj.floor = Turtle.initFloor()
    obj.row = row
    obj.position = 0

    obj:initPosition()

    inspector = TurtleInspector:create()
    obj.inspector = inspector

    obj.mover = TurtleMover:create(inspector, function ()
        obj:pushState()
    end)

    obj.fuel = TurtleFuel:create()
    obj.inventory = TurtleInventory:create()
    obj.startSide = startSide
    obj.startStation = start
    obj.endStation = finish

    obj.state = "starting"

    return obj
end

function Turtle:setup()
    local ok = true
    if self.fuel:emptyFuel() then
        print("Empty fuel! Trying find and use fuel...")
        if self.fuel:findAndUseFuel() then
            print("- Fuel found")
        else
            print("! NO fuel found")
            ok = false
        end
    else
        print("- Fuel OK")
    end

    if self.inventory:equipLeft(16, "minecraft:diamond_pickaxe") then
        print("- Pickaxe at position 16 was equipped to left side")
    end

    print("Waiting for receiving setup file from manager")
    while true
    do
        self.rednetClient:broadcast(self.name, "setup-file", "1")
        id, fileContent = self.rednetClient:receive("manager", "setup-file", 2)
        if fileContent ~= nil then
            fileContent = textutils.unserialize(fileContent)

            print()
            print("Received configuration option")

            local content = "{\n"
            content = content .. "\"name\": \"" .. fileContent.name .. "\",\n"
            content = content .. "\"rednet\": \"" .. fileContent.rednet .. "\",\n"
            content = content .. "\"start\": \"" .. fileContent.start.x .. ", " .. fileContent.start.y .. ", " .. fileContent.start.z .. "\",\n"
            content = content .. "\"end\": \"" .. fileContent.finish.x .. ", " .. fileContent.finish.y .. ", " .. fileContent.finish.z .. "\",\n"
            content = content .. "\"storage\": \"" .. fileContent.storage.x .. ", " .. fileContent.storage.y .. ", " .. fileContent.storage.z .. "\",\n"
            content = content .. "\"stoneStorage\": \"" .. fileContent.stone.x .. ", " .. fileContent.stone.y .. ", " .. fileContent.stone.z .. "\",\n"
            content = content .. "\"torchStorage\": \"" .. fileContent.torch.x .. ", " .. fileContent.torch.y .. ", " .. fileContent.torch.z .. "\",\n"
            content = content .. "\"storageSide\": \"" .. fileContent.storageSide .. "\"\n"
            content = content .. "}"

            print(content)

            local configFile = io.open("config.json", "w")
            configFile.write(configFile, content)
            configFile.close(configFile)

            print("New config file was successfully saved")

            break
        end
        term.write(".")
    end
end

function Turtle:run()
    if self.fuel:emptyFuel() then
        TurtleLogger.error("Empty fuel! Need manual refuel.")
        return nil
    end

    self.mover:start()

    while true
    do
        if self.fuel:emptyFuel() then
            TurtleLogger.error("Empty fuel! Need manual refuel.")
            break

        elseif self.fuel:needFuel() then
            self:setState("need-fuel")
            if self.mover:goToVector(self.storageStation, self.storageSide) then
                if not self.fuel:refuel() then
                    TurtleLogger.error("Empty fuel storage! Manual intervention is required. (or maybe bad storage side in settings?)")
                    break
                end

                self:setState("starting")
            end

        elseif self.inventory:hasFull() then
            self:setState("full-inventory")
            if self.mover:goToVector(self.storageStation, self.storageSide) then
                self.inventory:flushWithIgnore("minecraft:cobblestone", "minecraft:cobbled_deepslate", "minecraft:tuff")
                if self.mover:goToVector(self.stoneStorageStation, self.storageSide) then
                    self.inventory:flushSpecific("minecraft:cobblestone", "minecraft:cobbled_deepslate", "minecraft:tuff")
                end

                if self.inventory:hasFull() then
                    self:setState("full-storages")
                    TurtleLogger.error("Full storages can not empty turtle inventory! Manual intervention is required.")
                    break
                end

                self:setState("starting")
            end

        elseif not self.inventory:hasTorches() then
            self:setState("need-torches")
            if self.mover:goToVector(self.torchStorageStation, self.storageSide) then
                if not self.inventory:takeTorches() then
                    TurtleLogger.error("Empty torches storage! Manual intervention is required. (or maybe bad storage side in settings?)")
                    break
                end

                self:setState("starting")
            end

        elseif self:continuePlan() == false then
            self:pushState()
            break
        end

        self:pushState()
    end
end

function Turtle:continuePlan()
    local currentVector = TurtleMover.getLocation()
    if currentVector == false then
        return false
    end

    local targetVector = self:findTargetVector()
    if self.state == "starting" then
        local side = self:getCurrentStartSide()
        if self.mover:goToVector(targetVector, side) == false then
            print("can not move to start position!")
            return false
        end
        self:updatePosition()
        self:setState("running")
        return true
    end

    if currentVector.z < targetVector.z then
        self.mover:up()
        self:setState("to-start")
        if self.mover:goToVector(targetVector, self.startSide) == false then
            print("can not move to start position!")
            return false
        end

    elseif currentVector.z > targetVector.z then
        self.mover:down()

    elseif self.mover:turnToNeededSide(currentVector, targetVector) then

    elseif currentVector.x == targetVector.x and currentVector.y == targetVector.y and currentVector.z == targetVector.z then
        if self.startStation.x == targetVector.x and self.startStation.y == targetVector.y and self.startStation.z == targetVector.z then
            self:setState("complete")
            print("COMPLETE")
            self:pushState()
            return false
        else
            self.position = 1
        end

    else
        if self.state ~= "complete" then
            self:setState("mining")
        end

        local remainingFloors = self:getRemainingFloors()
        if remainingFloors >= 3 then
            self:digUp()
            if self.inspector:isLava(TurtleInspector.UP) then
                self.mover:up()
                self.mover:down()
            end
        end

        self:forward()

        if self:getRemainingFloors() > 1 then
            self:digDown()
            if self.inspector:isLava(TurtleInspector.DOWN) then
                self.mover:down()
                self.mover:up()
            end
        end

        if self:needPlaceTorch() then
            self.inventory:placeTorch()
        end
    end
end

function Turtle:digUp()
    if self.inspector:detect(TurtleInspector.UP) then
        turtle.digUp()
    end
end

function Turtle:digDown()
    if self.inspector:detect(TurtleInspector.DOWN) then
        turtle.digDown()
    end
end

function Turtle:forward()
    if self.inspector:isChest() then
        TurtleLogger.error("Chest is in front of a turtle. Turtle waiting for manual destroy chest and restart turtle.")
        error("Error: Chest is in front of a turtle.")
    end
    if self.mover:forward() then
        self:updatePosition()
    end
end

function Turtle:setState(state)
    self.state = state
    self:pushState()
end

function Turtle:pushState()
    self.rednetClient:broadcast(self.name, "status", textutils.serialise(self:toArray()))
    self.rednetClient:broadcast("ping", "turtle", self.name)
end

function Turtle:getCurrentStartSide()
    if self.startSide == nil then
        error("Start side is required")
    end

    if self:isIncreasing() then
        return self.startSide
    end
    return self.mover:getRotatedSide(self.startSide, 2)
end

function Turtle:getRemainingFloors()
    return self.floorCount + 1 - self.floor
end

function Turtle:findTargetVector()
    if (self:isIncreasing() and self.position > self.rowLength)
            or (self:isIncreasing() == false and self.position <= -1) then
        self:increaseRow()
        self:resetPosition()
    end

    local remainingFloors = self.floorCount + 1 - self.floor
    if self.row >= self.rowCount + 1 then
        self.position = 0
        self:resetRow(true)
        self:increaseFloor(math.min(self:getRemainingFloors(), 3))
    end

    if self.floor >= self.floorCount + 1 then
        self:setState("complete")
        return self.startStation
    end

    remainingFloors = self:getRemainingFloors()

    local x, y
    local z = self.startStation.z + self.floor

    if self:getRemainingFloors() > 1 then
        z = z + 1
    end

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

function Turtle:needPlaceTorch()
    return self.floor == 0
            and ((self.rowLength > 9 and self.position % 5 == 0) or math.ceil(self.rowLength / 2) == self.position)
            and (self.row % 5 == 0 or math.ceil(self.rowCount / 2) == self.row)
end

function Turtle:isIncreasing()
    return self.row % 2 == 0
end

function Turtle:saveRow(disableSaveSettings)
    settings.set("row", self.row)
    Turtle.saveSettings(disableSaveSettings)
end

function Turtle:saveFloor(disableSaveSettings)
    settings.set("floor", self.floor)
    Turtle.saveSettings(disableSaveSettings)
end

function Turtle.saveSettings(disableSaveSettings)
    if not disableSaveSettings then
        settings.save(".settings")
    end
end

function Turtle:savePosition(disableSaveSettings)
    if self.position % 10 == 0 then
        settings.set("position", self.position)
        Turtle.saveSettings(disableSaveSettings)
    end
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
    print("Fuel: " .. self.fuel:getFuelLevel() .. "/" .. self.fuel:getFuelLimit())
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

function Turtle:toArray()
    local out = {
        position = self.position,
        row = self.row,
        floor = self.floor,
        rowLength = self.rowLength,
        rowCount = self.rowCount,
        floorCount = self.floorCount,
        startSide = self.startSide,
        emptySlots = self.inventory:getEmptySlots()
    }

    out["fuelLevel"] = self.fuel:getFuelLevel()
    out["fuelLimit"] = self.fuel:getFuelLimit()
    out["needRefuel"] = self.fuel:needFuel()

    out["fullInventory"] = self.inventory:hasFull()
    out["hasTorches"] = self.inventory:hasTorches()
    out["location"] = self.mover:getCurrentVector()
    out["state"] = self.state

    return out
end

function Turtle.resetSettings()
    settings.set("row", 0)
    settings.set("floor", 0)
    settings.set("position", 0)
    Turtle.saveSettings()
    print("Reset was successful")
end

function Turtle:increaseFloor(about, disableSaveSettings)
    if about <= 0 then
        about = 1
    end
    self.floor = self.floor + about
    self:saveFloor(disableSaveSettings)
end

function Turtle:increaseRow(disableSaveSettings)
    self.row = self.row + 1
    self:saveRow(disableSaveSettings)
end

function Turtle:decreaseRow(disableSaveSettings)
    self.row = self.row - 1
    if self.row < 0 then
        self.row = 0
    end
    self:saveRow(disableSaveSettings)
end

function Turtle:resetRow(disableSaveSettings)
    self.row = 0
    self:saveRow(disableSaveSettings)
end

function Turtle:updatePosition(disableSaveSettings)
    if self:isIncreasing() then
        self.position = self.position + 1
    else
        self.position = self.position - 1
    end
    self.mover:refreshCurrentVector()
    self:savePosition(disableSaveSettings)
end

function Turtle:initPosition()
    local position = settings.get("position", -10)
    if position > -10 then
        return position
    end
    self:resetPosition()
end

function Turtle:resetPosition()
    if self:isIncreasing() then
        self.position = 0
    else
        self.position = self.rowLength
    end
    self:savePosition()
end

return Turtle
