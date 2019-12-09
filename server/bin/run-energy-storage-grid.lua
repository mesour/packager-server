dofile("library/RemoteMonitor.lua")
dofile("library/EnergyStorage.lua")
dofile("library/StorageGridControl.lua")
dofile("library/FileLoader.lua")

local config = FileLoader.loadConfig("config.json")

rednet.open(config["rednet"])

local storages = {}

for _, peripheralName in pairs(config["storages"]) do
  local storage = EnergyStorage:create(peripheral.wrap(peripheralName))
  table.insert(storages, storage)
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

local control = StorageGridControl:create(
  config["name"],
  storages,
  monitor,
  sizes[1][config["monitorSize"][1]],
  sizes[2][config["monitorSize"][2]]
)

control:run()

rednet.close(config["rednet"])
