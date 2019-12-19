dofile("library/Manager.lua")
dofile("library/RednetClient.lua")
dofile("library/managerPlugins/ReactorPlugin.lua")
dofile("library/managerPlugins/EuStoragePlugin.lua")
dofile("library/managerPlugins/TurtlePlugin.lua")

local rednetClient = RednetClient:create("back")

local plugins = {}
plugins["reactor"] = ReactorPlugin:create(rednetClient)
plugins["eu-storage"] = EuStoragePlugin:create(rednetClient)
plugins["turtle"] = TurtlePlugin:create(rednetClient)

local manager = Manager:create(plugins, {...})
manager:run()