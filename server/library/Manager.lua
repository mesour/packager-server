dofile("library/Utils.lua")

Manager = {}
Manager.__index = Manager

function Manager:create(plugins, args)
  local obj = {}
  setmetatable(obj, self)
  obj.plugins = plugins
  obj.mode = table.remove(args, 1)
  if obj.mode == nil then
    Manager.showUsage()
    error("First argument `mode` is required")
  end

  obj.command = table.remove(args, 1)
  if obj.mode ~= "help" and obj.command == nil then
    Manager.showUsage()
    error("Second argument `command` is required")
  end
  obj.args = args
  return obj
end

function Manager:run()
  local continue = true

  while continue
  do
    if self.mode == "help" then
      self:showHelp()
      break
    end

    continue = not self.plugins[self.mode]:run(self.command, self.args)
    sleep(1)
  end
end

function Manager:showHelp()
  if self.command == nil then
    Manager.showUsage()
    print("")
    self:showAvailableModes()
  else
    self:showModeHelp()
  end
end

function Manager:showAvailableModes()
  print("Allowed modes:")

  for name,plugin in pairs(self.plugins) do
    print(" - " .. name)
  end
end

function Manager:showModeHelp()
  Utils.printColoredString("Help for " .. self.command ..":", colors.blue)
  print("")
  print("Usage:")
  print(" manager " .. self.command .. " <command>")
  print("")

  print("Available commands:")

  if self.plugins[self.command] == nil then
    error("Plugin " .. self.command .. " not found")
  end

  for _,command in pairs(self.plugins[self.command]:getAvailableCommands()) do
    print(" - " .. command)
  end
end

function Manager.showUsage()
  Utils.printColoredString("Help for manager:", colors.blue)
  print("")
  print("Usage:")
  print(" manager help [mode]")
  print(" manager <mode> <command>")
end

return Manager
