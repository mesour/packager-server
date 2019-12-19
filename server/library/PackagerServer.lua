dofile("library/FileLoader.lua")

PackagerServer = {}
PackagerServer.__index = PackagerServer

function PackagerServer:create(name, configFile, rednetClient)
  local obj = {}
  setmetatable(obj, self)

  obj.name = name
  obj.configFile = configFile
  obj.rednetClient = rednetClient

  return obj
end

function PackagerServer:run()
  print("Packager server name: " .. self.name)

  while true
  do
    id,message = self.rednetClient:receive(self.name, "update")

    local data = textutils.unserialize(message)

    local id = data["id"]
    local library = data["library"]
    local required = data["required"]

    local loader = FileLoader:create(FileLoader.loadConfig(self.configFile), required, library)

    self:sendFiles(id, loader:getLibraries())

  end
end

function PackagerServer:sendFiles(id, libraries)
  local waiting = false

  while true
  do
    if waiting then
        print('- sendFiles')
        break
    else
      self.rednetClient:broadcast(id, "send", libraries)
      waiting = true
    end

  end
end

return PackagerServer
