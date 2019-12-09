dofile("library/RemoteMonitor.lua")
dofile("library/generators/FluidGenerator.lua")
dofile("library/GeneratorGridControl.lua")
dofile("library/FileLoader.lua")

local config = FileLoader.loadConfig("config.json")

rednet.open(config["rednet"])

local generators = {}

for _, peripheralName in pairs(config["generators"]) do
  local generator = FluidGenerator:create(
    peripheral.wrap(peripheralName),
    config["fuel"]
  )
  table.insert(generators, generator)
end

local monitor = RemoteMonitor:create(config["name"], config["remoteMonitor"])

local sizes = {}
sizes[1] = {
  big = 79,
  medium = 57
}
sizes[2] = {
  big = 51,
  medium = 37,
  small = 23
}

if config["monitorSize"][1] == "small" then
  error("Can not use small for width, only (medium|big)")
end

local control = GeneratorGridControl:create(
  config["name"],
  sizes[1][config["monitorSize"][1]],
  sizes[2][config["monitorSize"][2]],
  generators,
  monitor,
  config["fuel"]
)

control:run()

rednet.close(config["rednet"])
