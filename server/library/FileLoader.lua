dofile("library/JsonDecoder.lua")

FileLoader = {}
FileLoader.__index = FileLoader

function FileLoader:create(config, required, library)
  local obj = {}
  setmetatable(obj, self)

  obj.library = library
  obj.packages = config["packages"]
  obj.dependencies = config["dependencies"]
  obj.required = required
  obj.libraries = {}

  return obj
end

function FileLoader.loadConfig(path)
  return decodeFromFile(path)
end

function FileLoader:getLibraries()
  if self.required ~= nil then
    for key,value in pairs(self.required) do
      if self.packages[key] == nil then
        error("Package not found in packager-server.json")
      end

      local config = self.packages[key]

      self:loadSection(config, "library", "library/", "library/")

      self:loadSection(config, "bin", "bin/", "")

      self:loadSection(config, "config", "config/", "", ".json")

      if config["startup"] ~= nil then
        self:loadFile(config["startup"], "bin/", "", "startup")
      end

    end
  end

  if self.library ~= nil then
    for key,value in pairs(self.library) do
      self:loadFile(value, "library/", "library/")
    end
  end

  return self.libraries
end

function FileLoader:loadSection(config, name, folder, outFolder, extension)
  if config[name] ~= nil then
    for key,library in pairs(config[name]) do
      self:loadFile(library, folder, outFolder, nil, extension)
    end
  end
end

function FileLoader:loadFile(name, directory, finalDirectory, finalName, extension)
  extension = extension or ".lua"
  local h = fs.open(directory .. name .. extension, "r")
  if h == nil then
    error("Library " .. name .. " not found")
  end

  finalName = finalName or name
  self.libraries[name] = {
    content = h.readAll(),
    location = finalDirectory .. finalName .. extension
  }

  h.close()

  self:loadDependencies(name, directory, finalDirectory, extension)
end

function FileLoader:loadDependencies(name, directory, finalDirectory, extension)
  if self.dependencies[name] == nil then
    return
  end

  for _, library in pairs(self.dependencies[name]) do
    self:loadFile(library, directory, finalDirectory, nil, extension)
  end
end

return FileLoader
