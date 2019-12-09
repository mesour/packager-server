dofile("library/RemoteMonitor.lua")
dofile("library/RednetClient.lua")
dofile("library/ReactorMonitor.lua")
dofile("library/FileLoader.lua")

local config = FileLoader.loadConfig("config.json")

local env = setmetatable({shell = shell, multishell = multishell}, {__index = _G})

local rednetClient = RednetClient:create(config["rednet"])

local monitor = RemoteMonitor:create(config["name"], config["remoteMonitor"])

local control = ReactorMonitor:create(config["name"], config["reactorName"], monitor, rednetClient, env)

control:run()

rednetClient.close()
