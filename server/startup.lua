dofile("library/PackagerServer.lua")
dofile("library/RednetClient.lua")

print("Packager server...")

local rednetClient = RednetClient:create("left")

local server = PackagerServer:create("packager0", "packager-server.json", rednetClient)

server:run()
