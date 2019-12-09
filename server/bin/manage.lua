dofile("library/RednetClient.lua")

args = {...}

local rednetClient = RednetClient:create("back")

local plugin = args[1]
local command = args[2]

if plugin == nil or command == nil then
  print("ERROR: Required parameters <plugin> <command>")
  return
end

local plugins = {
  electroMeter = {
    enableInput = function (electroMeterName)
      rednet.broadcast("enableInput", electroMeterName)
      return true
    end,
    disableInput = function (electroMeterName)
      rednet.broadcast("disableInput", electroMeterName)
      return true
    end,
    enableOutput = function (electroMeterName)
      rednet.broadcast("enableOutput", electroMeterName)
      return true
    end,
    disableOutput = function (electroMeterName)
      rednet.broadcast("disableOutput", electroMeterName)
      return true
    end,
    status = function (electroMeterName)
      id, message = rednetClient:receive(electroMeterName, "status", 4)

      if message ~= nil then
        message = textutils.unserialize(message)

        local mode = message["mode"]

        if message["input"] then
          input = "ON"
        else
          input = "OFF"
        end

        if message["output"] then
          output = "ON"
        else
          output = "OFF"
        end

        print("[" .. electroMeterName .. "] (" .. mode .. ")")
        print("  Input : " .. input)
        print("  Output: " .. output)
      else
        print("Error: No response from electro meter")
      end

      return true
    end
  },
  reactor = {
    shutdown = function (reactorName)
      rednet.broadcast("shutdown", reactorName)
      id, message = rednetClient:receive(reactorName, "status", 0.4)

      if message ~= nil then
        message = textutils.unserialize(message)

        if message["active"] == false then
          print("Successfuly stopped reactor: " .. reactorName)
          return true
        end

      end

      return false
    end,
    run = function (reactorName)
      rednet.broadcast("continue", reactorName)
      id, message = rednetClient:receive(reactorName, "status", 0.4)

      if message ~= nil then
        message = textutils.unserialize(message)

        if message["active"] == false then
          return false
        end

        print("Successfuly started reactor: " .. reactorName)
      else
        print("Error: No response from reactor")
      end

      return true
    end,
    status = function (reactorName)
      id, message = rednetClient:receive(reactorName, "status", 2)

      if message ~= nil then
        message = textutils.unserialize(message)

        local percentage = message["heat"] / message["maxHeat"] * 100

        if message["active"] then
          state = "running"
        else
          state = "waiting"
        end

        if percentage >= 20 then
          status = "HOT"
        else
          status = "OK"
        end

        print("[" .. reactorName .. "] (" .. state .. ")")
        print("  Heat: " .. message["heat"] .. "/" .. message["maxHeat"] .. " - " .. percentage .. "%")
        print("  Output: " .. message["output"] .. " EU/t")
        print("  Status: " .. status)
      else
        print("Error: No response from reactor")
      end

      return true
    end
  }
}

if plugins[plugin] == nil or plugins[plugin][command] == nil then
  print("ERROR: Unknown plugin or command")
  return
end

continue = true
while continue
do
  continue = not plugins[plugin][command](args[3])
  sleep(1)
end
