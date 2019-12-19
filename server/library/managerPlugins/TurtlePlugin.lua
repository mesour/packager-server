dofile("library/Utils.lua")

TurtlePlugin = {}
TurtlePlugin.__index = TurtlePlugin

function TurtlePlugin:create(rednetClient)
  local obj = {}
  setmetatable(obj, self)
  obj.rednetClient = rednetClient
  obj.availableCommands = {"list", "listen <turtle>"}
  return obj
end

function TurtlePlugin:run(command, args)
    if command == "list" then
        return self:list(args[1])
    elseif command == "listen" then
        if args[1] == nil then
            error("command listen need first parameter turtle name")
        end
        return self:listen(args[1])
    end
    error("Unknown command `" .. command .. "`")
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

function TurtlePlugin:getAvailableCommands()
    return self.availableCommands
end

return Manager