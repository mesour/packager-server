dofile("library/turtle/Turtle.lua")
dofile("library/turtle/TurtleHelper.lua")
dofile("library/FileLoader.lua")
dofile("library/RednetClient.lua")

local config = FileLoader.loadConfig("config.json")

local rednetClient = RednetClient:create(config["rednet"])

Turtle.init(
    config["name"],
    TurtleHelper.createVectorFromString(config["start"]),
    TurtleHelper.createVectorFromString(config["end"]),
    TurtleHelper.createVectorFromString(config["storage"]),
    TurtleHelper.createVectorFromString(config["torchStorage"]),
    config["storageSide"],
    rednetClient,
    {...}
)
