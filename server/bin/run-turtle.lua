dofile("library/turtle/Turtle.lua")
dofile("library/turtle/TurtleHelper.lua")
dofile("library/FileLoader.lua")

local config = FileLoader.loadConfig("config.json")
-- dofile("library/RednetClient.lua")

-- local rednetClient = RednetClient:create("right")

Turtle.init(
    TurtleHelper.createVectorFromString(config["start"]),
    TurtleHelper.createVectorFromString(config["end"]),
    TurtleHelper.createVectorFromString(config["storage"]),
    config["storageSide"],
    {...}
)
