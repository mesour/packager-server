dofile("library/Utils.lua")

ReactorPlugin = {}
ReactorPlugin.__index = ReactorPlugin

function ReactorPlugin:create(rednetClient)
  local obj = {}
  setmetatable(obj, self)
  obj.rednetClient = rednetClient
  obj.availableCommands = {"list", "status <reactor>"}
  return obj
end

function ReactorPlugin:run(command, args)
  if command == "list" then
    return self:list(args[1])
  elseif command == "status" then
    if args[1] == nil then
      error("command status need first parameter reactor name")
    end
    return self:status(args[1])
  end
  error("Unknown command `" .. command .. "`")
end

function ReactorPlugin:list(attempts)
  Utils:pingAndSearchDevices(self.rednetClient, "reactor", attempts)

  return true
end

function ReactorPlugin:status(reactorName)
  print("Downloading info...")
  print("")

  id, message = self.rednetClient:receive(reactorName, "status", 2)

  if message ~= nil then
    message = textutils.unserialize(message)

    local percentage = Utils.round(message["heat"] / message["maxHeat"] * 100)

    print("[" .. reactorName .. "] (" .. message["status"] .. ")")
    print("  Heat: " .. message["heat"] .. "/" .. message["maxHeat"] .. " - " .. percentage .. "%")
    print("  Power: " .. Utils.round(message["output"] / 360 * 100) .. "%")
    print("  Type: " .. (message["type"] == "fluid" and "HU" or "EU"))
    print("  Fuel: " .. message["fuelRemainingPercent"] .. "%")
  else
    print("Error: No response from reactor")
  end

  return true
end

function ReactorPlugin:getAvailableCommands()
  return self.availableCommands
end

return Manager
