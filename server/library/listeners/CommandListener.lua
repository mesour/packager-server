dofile("library/RednetClient.lua")
dofile("library/Utils.lua")

CommandListener = {}
CommandListener.directory = "waiting-commands"
CommandListener.__index = CommandListener

function CommandListener:create(name, rednetSide)
  local obj = {}
  setmetatable(obj, self)
  obj.name = name
  obj.rednetClient = RednetClient:create(rednetSide)
  obj.directory = ""
  return obj
end

function CommandListener:trigger(device, command, parameters)
  self.rednetClient:callCommand(device, command, parameters)
end

function CommandListener:listen()
  while true do
    id,message,a,b = self.rednetClient:receiveCommand(self.name)

    if not fs.exists(CommandListener.directory) then
      fs.makeDir(CommandListener.directory)
    end

    local file = os.day() .. "-" .. os.time() .. Utils.random(6)

    h = fs.open(CommandListener.directory .. "/" .. file, "w")
    h.write(message)
    h.close()
  end
end

function CommandListener.tryHandle(handler)
  if not fs.exists(CommandListener.directory) then
    return
  end

  for _,file in pairs(fs.list(CommandListener.directory)) do
    local path = CommandListener.directory .. "/" .. file

    h = fs.open(path, "r")

    local data = textutils.unserialize(h.readAll())
    h.close()

    fs.delete(path)

    handler:handle(data["command"], data["parameters"])
  end
end

return CommandListener
