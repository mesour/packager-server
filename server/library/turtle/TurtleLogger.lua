TurtleLogger = {}
TurtleLogger.__index = TurtleLogger

function TurtleLogger.error(message)
    print(message)
end

function TurtleLogger.log(message)
    local h = fs.open("log", "a")
    h.write(message)
    h.write("\n")
    h.close()
end

return TurtleLogger