TurtleInspector = {}
TurtleInspector.__index = TurtleInspector

function TurtleInspector:create()
    local obj = {}
    setmetatable(obj, self)
    return obj
end

function TurtleInspector:isLavaAbove()
    return isLava(select(2, turtle.inspectUp()))
end

function TurtleInspector:isLavaUnder()
    return isLava(select(2, turtle.inspectDown()))
end

function isLava(data)
    if not data then
      return false
    end
    return data.name == "minecraft:lava"
end

return TurtleInspector
