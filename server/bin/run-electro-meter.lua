dofile("library/ElectroMeter.lua")
dofile("library/RemoteMonitor.lua")
dofile("library/EnergyStorage.lua")
dofile("library/RedstoneIntegrator.lua")
dofile("library/FileLoader.lua")

local config = FileLoader.loadConfig("config.json")

rednet.open(config["rednet"])

local storage = EnergyStorage:create(peripheral.wrap(config["mfsu"]))

local inputIntegrator = RedstoneIntegrator:create(peripheral.wrap(config["inputIntegrator"][1]), config["inputIntegrator"][2])

local outputIntegrator = RedstoneIntegrator:create(peripheral.wrap(config["outputIntegrator"][1]), config["outputIntegrator"][2])

local monitor = RemoteMonitor:create(config["name"], config["remoteMonitor"])

local meter = ElectroMeter:create(config["name"], monitor, storage, inputIntegrator, outputIntegrator, config["autoMode"])

meter:run()

rednet.close(config["rednet"])
