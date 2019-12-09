dofile("library/RednetClient.lua")
dofile("library/Monitor.lua")
dofile("library/MonitorControl.lua")
dofile("library/FileLoader.lua")

local config = FileLoader.loadConfig("config.json")

local env = setmetatable({shell = shell, multishell = multishell}, {__index = _G})

local rednetClient = RednetClient:create(config["rednet"])

local monitors = {}

for name, monitorDevice in pairs(config["monitors"]) do
  monitor = Monitor:create(peripheral.wrap(monitorDevice))
  monitor:clear()
  monitors[name] = { name = monitorDevice, monitor = monitor }
end

local control = MonitorControl:create(config["name"], rednetClient, monitors, env)

control:run()

rednetClient.close()
