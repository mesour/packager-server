dofile("library/RemoteMonitor.lua")
dofile("library/FileLoader.lua")

local config = FileLoader.loadConfig("config.json")

local integrator = peripheral.wrap(config["integrator"][1])
integrator.setAnalogOutput(config["integrator"][2], 0)

local monitor = RemoteMonitor:create(config["name"], config["remoteMonitor"])
monitor:clear()

monitor:writeln("Nuclear reactor: " .. config["name"])
monitor:writeln(string.rep("-", 29))
monitor:writeln("Terminated by command...")
monitor:push()
