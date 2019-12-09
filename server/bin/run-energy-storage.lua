dofile("library/RemoteMonitor.lua")
dofile("library/EnergyStorage.lua")
dofile("library/StorageControl.lua")
dofile("library/FileLoader.lua")

local config = FileLoader.loadConfig("config.json")

rednet.open(config["rednet"])

local storage = EnergyStorage:create(peripheral.wrap(config["storage"]))

local monitor = RemoteMonitor:create(config["name"], config["remoteMonitor"])

local control = StorageControl:create(config["name"], storage, monitor)

control:run()

rednet.close(config["rednet"])
