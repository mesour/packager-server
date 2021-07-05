TurtleInspector = {}
TurtleInspector.__index = TurtleInspector

TurtleInspector.UP = "up"
TurtleInspector.DOWN = "down"
TurtleInspector.FRONT = "front"

function TurtleInspector:create()
    local obj = {}
    setmetatable(obj, self)
    return obj
end

function TurtleInspector:isChest(side)
    return isType(select(2, inspectSide(side)), {"minecraft:chest", "minecraft:trapped_chest", "minecraft:barrel", "minecraft:ender_chest"})
end

function TurtleInspector:isLava(side)
    return isType(select(2, inspectSide(side)), {"minecraft:lava"})
end

function inspectSide(side)
    if side == TurtleInspector.UP then
      return turtle.inspectUp()
    elseif side == TurtleInspector.DOWN then
      return turtle.inspectDown()
    end
    return turtle.inspect()
end

function isType(data, types)
    if not data then
        return false
    end
    for i,value in ipairs(types) do
        if data.name == value then
            return true
        end
    end
    return false
end

return TurtleInspector
