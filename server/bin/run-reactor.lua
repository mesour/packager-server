dofile("library/Reactor.lua")
dofile("library/RemoteMonitor.lua")
dofile("library/Monitor.lua")
dofile("library/ReactorControl.lua")
dofile("library/RedstoneIntegrator.lua")
dofile("library/FileLoader.lua")

local config = FileLoader.loadConfig("config.json")

local env = setmetatable({shell = shell, multishell = multishell}, {__index = _G})

local rednetClient = RednetClient:create(config["rednet"])

local reactor = Reactor:create(peripheral.wrap(config["reactor"]), config["type"] or "EU")

local integrator = RedstoneIntegrator:create(peripheral.wrap(config["integrator"][1]), config["integrator"][2])

local monitor
if config["remoteMonitor"] ~= nil then
  monitor = RemoteMonitor:create(config["name"], config["remoteMonitor"])
else
  monitor = Monitor:create(peripheral.wrap(config["monitor"]))
end

local control = ReactorControl:create(config["name"], reactor, monitor, integrator, rednetClient, env)

control:run()

rednetClient.close()
