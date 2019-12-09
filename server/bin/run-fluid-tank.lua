dofile("library/RemoteMonitor.lua")
dofile("library/FluidTank.lua")
dofile("library/FluidTankControl.lua")
dofile("library/FileLoader.lua")

local config = FileLoader.loadConfig("config.json")

rednet.open(config["rednet"])

local fluidTank = FluidTank:create(peripheral.wrap(config["tank"]))

local monitor = RemoteMonitor:create(config["name"], config["remoteMonitor"])

local control = FluidTankControl:create(config["name"], fluidTank, monitor)

control:run()

rednet.close(config["rednet"])
