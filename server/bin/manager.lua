dofile("library/Manager.lua")
dofile("library/RednetClient.lua")
dofile("library/managerPlugins/ReactorPlugin.lua")
dofile("library/managerPlugins/EuStoragePlugin.lua")

local rednetClient = RednetClient:create("back")

local plugins = {}
plugins["reactor"] = ReactorPlugin:create(rednetClient)
plugins["eu-storage"] = EuStoragePlugin:create(rednetClient)

local manager = Manager:create(plugins, {...})
manager:run()
