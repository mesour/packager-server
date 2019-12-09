dofile("library/RemoteMonitor.lua")
dofile("library/RednetClient.lua")
dofile("library/Generator.lua")
dofile("library/FluidTank.lua")
dofile("library/TurbineControl.lua")
dofile("library/FileLoader.lua")

local config = FileLoader.loadConfig("config.json")

local rednetClient = RednetClient:create(config["rednet"])

local monitor = RemoteMonitor:create(config["name"], config["remoteMonitor"])

local generator1 = Generator:create(peripheral.wrap(config["generator1"]))
local generator2 = Generator:create(peripheral.wrap(config["generator2"]))

local heatExchanger = FluidTank:create(peripheral.wrap(config["heatExchanger"]))
local steamGenerator = FluidTank:create(peripheral.wrap(config["steamGenerator"]))

local control = TurbineControl:create(
  config["name"],
  monitor,
  generator1,
  generator2,
  heatExchanger,
  steamGenerator,
  rednetClient
)

control:run()

rednetClient.close()
