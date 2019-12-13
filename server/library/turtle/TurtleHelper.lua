dofile("library/Utils.lua")

TurtleHelper = {}
TurtleHelper.__index = TurtleHelper

function TurtleHelper.getNeededSide(currentVector, targetVector, side)
    local sideX = TurtleHelper.getNeededSideX(currentVector, targetVector)
    if sideX ~= nil then
        return sideX
    end
    return TurtleHelper.getNeededSideY(currentVector, targetVector, side);
end

function TurtleHelper.getNeededSideDesc(currentVector, targetVector, side)
    local sideY = TurtleHelper.getNeededSideY(currentVector, targetVector)
    if sideY ~= nil then
        return sideY
    end
    return TurtleHelper.getNeededSideX(currentVector, targetVector, side);
end

function TurtleHelper.getNeededSideX(currentVector, targetVector, side)
    if targetVector.x < currentVector.x then
        return "west"
    elseif targetVector.x > currentVector.x then
        return "east"
    end
    return side
end

function TurtleHelper.getNeededSideY(currentVector, targetVector, side)
    if targetVector.y < currentVector.y then
        return "north"
    elseif targetVector.y > currentVector.y then
        return "south"
    end
    return side
end

function TurtleHelper.detectStartSide(startVector, endVector)
    local asc = TurtleHelper.getNeededSide(startVector, endVector)
    local desc = TurtleHelper.getNeededSideDesc(startVector, endVector)

    if asc == "west" and desc == "south" then
        return "south"
    elseif asc == "east" and desc == "south" then
        return "east"
    elseif asc == "west" and desc == "north" then
        return "west"
    elseif asc == "east" and desc == "north" then
        return "north"
    end
    return nil
end

function TurtleHelper.getSize(startStation, endStation)
    local s = startStation
    local e = endStation
    return TurtleHelper.getSizePart(s.x, e.x), TurtleHelper.getSizePart(s.y, e.y), TurtleHelper.getSizePart(s.z, e.z)
end

function TurtleHelper.getSizePart(s, e)
    if s < e then
        return e - s
    else
        return s - e
    end
end

function TurtleHelper.createVectorFromString(s)
    local splited = Utils.split(s, ", ")
    return vector.new(splited[1], splited[2], splited[3])
end

return TurtleHelper
