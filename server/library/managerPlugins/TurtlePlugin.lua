dofile("library/Utils.lua")

TurtlePlugin = {}
TurtlePlugin.__index = TurtlePlugin

function TurtlePlugin:create(rednetClient)
    local obj = {}
    setmetatable(obj, self)
    obj.rednetClient = rednetClient
    obj.availableCommands = {"list", "setup <turtle>", "listen <turtle>"}
    return obj
end

function TurtlePlugin:run(command, args)
    if command == "list" then
        return self:list(args[1])
    elseif command == "setup" then
        if args[1] == nil then
            error("command `setup` need first parameter turtle name")
        end
        return self:setup(args[1])
    elseif command == "listen" then
        if args[1] == nil then
            error("command `listen` need first parameter turtle name")
        end
        return self:listen(args[1])
    end
    error("Unknown command `" .. command .. "`")
end

function TurtlePlugin:setup(turtleName)
    print("Searching turtle " .. turtleName .. " and check if is in setup mode")
    local counter = 0
    while message == nil
    do
        id, message = self.rednetClient:receive(turtleName, "setup-file", 2)
        term.write(".")
        counter = counter + 1

        if counter > 3 then
            print("Turtle" .. turtleName .. " is not in setup mode")
            return
        end
    end
    print("Found turtle in setup mode")
    print()

    local result = {}

    print("Insert turtle name and press enter")
    result['name'] = Utils.trim(io.read())
    print("Name is: " .. result['name'])

    print("Insert turtle rednet side and press enter")
    result['rednet'] = Utils.trim(io.read())
    print("Rednet side is: " .. result['rednet'])

    print("Go to starting location and press enter")
    io.read()
    local startLocation = TurtlePlugin.getLocation()
    result['start'] = {
        x = math.floor(startLocation.x),
        y = math.floor(startLocation.y),
        z = math.floor(startLocation.z - 1)
    }
    print("Start location is")
    TurtlePlugin.printLocation(result['start'])

    print("\nGo to finish location and press enter")
    io.read()
    local endLocation = TurtlePlugin.getLocation()
    result['finish'] = {
        x = math.floor(endLocation.x),
        y = math.floor(endLocation.y),
        z = math.floor(endLocation.z - 1)
    }
    print("Finish location is")
    TurtlePlugin.printLocation(result['finish'])

    print("\nGo to storage location and press enter")
    io.read()
    local storageLocation = TurtlePlugin.getLocation()
    result['storage'] = {
        x = math.floor(storageLocation.x),
        y = math.floor(storageLocation.y),
        z = math.floor(storageLocation.z - 1)
    }
    print("Storage location is")
    TurtlePlugin.printLocation(result['storage'])

    print("\nGo to torch storage location and press enter")
    io.read()
    local torchLocation = TurtlePlugin.getLocation()
    result['torch'] = {
        x = math.floor(torchLocation.x),
        y = math.floor(torchLocation.y),
        z = math.floor(torchLocation.z - 1)
    }
    print("Torch location is")
    TurtlePlugin.printLocation(result['torch'])

    print("\nGo to cobblestone location and press enter")
    io.read()
    local cobbleStoneLocation = TurtlePlugin.getLocation()
    result['stone'] = {
        x = math.floor(cobbleStoneLocation.x),
        y = math.floor(cobbleStoneLocation.y),
        z = math.floor(cobbleStoneLocation.z - 1)
    }
    print("Cobblestone location is")
    TurtlePlugin.printLocation(result['stone'])

    print("Storage side")
    result['storageSide'] = TurtlePlugin.getStorageSize()
    print("Storage side is: " .. result['storageSide'])

    self.rednetClient:broadcast("manager", "setup-file", result)

    print("OK : Config file has been written to turtle")

    return true
end

function TurtlePlugin.getStorageSize()
    local storageSide = Utils.trim(io.read())
    if storageSide ~= "west" and storageSide ~= "east" and storageSide ~= "north" and storageSide ~= "south" then
        print("Side " .. storageSide .. " is not valid. Enter valid side (west|north|east|south).")
        return TurtlePlugin.getStorageSize()
    end
    return storageSide
end

function TurtlePlugin.printLocation(vector)
    print(vector.x .. ", " .. vector.y .. ", " .. vector.z)
end

function TurtlePlugin:list(attempts)
    Utils:pingAndSearchDevices(self.rednetClient, "turtle", attempts)
    return true
end

function TurtlePlugin:listen(turtleName)
    print("Listening turtle " .. turtleName .. "...")
    print("")

    while true
    do
        id, message = self.rednetClient:receive(turtleName, "status", 2)
        if message ~= nil then
            message = textutils.unserialize(message)

            print(message)
        end
    end
    return true
end

function TurtlePlugin.getLocation(counter)
    counter = counter or 0
    local x, y, z = gps.locate(5)
    if not x then
        if counter < 5 then
            sleep(5)
            return TurtleMover.getLocation(counter + 1)
        end
        TurtleLogger.error("Failed to get my location!")
        return false
    else
        return vector.new(x, y, z)
    end
end

function TurtlePlugin:getAvailableCommands()
    return self.availableCommands
end

return TurtlePlugin