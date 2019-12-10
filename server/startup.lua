dofile("library/PackagerServer.lua")
dofile("library/RednetClient.lua")
dofile("library/Utils.lua")

print("Packager server...")

local rednetClient = RednetClient:create(Utils.findPeripheralSide("modem"))

local server = PackagerServer:create("packager0", "packager-server.json", rednetClient)

server:run()
