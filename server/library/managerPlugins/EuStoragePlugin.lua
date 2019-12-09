dofile("library/Utils.lua")

EuStoragePlugin = {}
EuStoragePlugin.__index = EuStoragePlugin

function EuStoragePlugin:create(rednetClient)
  local obj = {}
  setmetatable(obj, self)
  obj.rednetClient = rednetClient
  obj.availableCommands = {"list", "status <storage>"}
  return obj
end

function EuStoragePlugin:run(command, args)
  if command == "list" then
    return self:list(args[1])
  elseif command == "status" then
    if args[1] == nil then
      error("command status need first parameter storage name")
    end
    return self:status(args[1])
  end
  error("Unknown command `" .. command .. "`")
end

function EuStoragePlugin:list(attempts)
  attempts = attempts or 30
  Utils:pingAndSearchDevices(self.rednetClient, "storage", attempts)

  return true
end

function EuStoragePlugin:status(storageName)
  print("Downloading info...")
  print("")

  id, message = self.rednetClient:receive(storageName, "status", 5)

  if message ~= nil then
    message = textutils.unserialize(message)

    local percentage = message["stored"] / message["capacity"] * 100

    print("[" .. storageName .. "]")
    print("  Stored:  " .. Utils.round(percentage, 2) .. "%")
    print("  Max:     " .. Utils.getReadableNumber(message["capacity"]) .. " EU")
    print("  Current: " .. Utils.getReadableNumber(message["stored"]) .. " EU")

    term.write("  Status:  ")
    if 30 > percentage then
      Utils.printColoredString("LOW", colors.red)
    elseif 70 > percentage then
      Utils.printColoredString("AVAILABLE", colors.orange)
    elseif percentage == 100 then
      Utils.printColoredString("FULL", colors.blue)
    else
      Utils.printColoredString("HIGH", colors.green)
    end
  else
    print("Error: No response from storage")
  end

  return true
end

function EuStoragePlugin:getAvailableCommands()
  return self.availableCommands
end

return Manager
