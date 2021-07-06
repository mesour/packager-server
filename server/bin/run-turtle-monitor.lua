dofile("library/RemoteMonitor.lua")
dofile("library/RednetClient.lua")
dofile("library/TurtleMonitor.lua")
dofile("library/FileLoader.lua")

local config = FileLoader.loadConfig("config.json")

local env = setmetatable({shell = shell, multishell = multishell}, {__index = _G})

local rednetClient = RednetClient:create(config["rednet"])

local monitor = RemoteMonitor:create(config["name"], config["remoteMonitor"])

local control = TurtleMonitor:create(config["name"], config["turtleName"], monitor, rednetClient, env)

control:run()

rednetClient.close()
