TurtleInventory = {}
TurtleInventory.__index = TurtleInventory

function TurtleInventory:create()
    local obj = {}
    setmetatable(obj, self)
    obj.minimumEmptySlots = 2
    obj.torchesPlace = 15
    return obj
end

function TurtleInventory:hasFull()
    return self:getEmptySlots() <= self.minimumEmptySlots
end

function TurtleInventory:getEmptySlots()
    local emptyCount = 0
    for i = 1, 16 do
        if turtle.getItemCount(i) == 0 then
            emptyCount = emptyCount + 1
        end
    end
    return emptyCount
end


function TurtleInventory:getMinimumEmptySlots()
    return self.minimumEmptySlots
end

function TurtleInventory:equipLeft(position, tool)
    turtle.select(position)
    item = turtle.getItemDetail()
    if item == nil then
        return false
    elseif tool ~= item.name then
        return false
    end
    return turtle.equipLeft()
end

function TurtleInventory:flushWithIgnore(ignored, ignored1, ignored2)
    for i = 1, 16 do
        if i ~= 15 then
            turtle.select(i)
            local detail = turtle.getItemDetail()
            if detail ~= nil and detail.name ~= ignored and detail.name ~= ignored1 and detail.name ~= ignored2 then
                turtle.dropDown()
            end
        end
    end
end

function TurtleInventory:flushSpecific(specific, specific1, specific2)
    for i = 1, 16 do
        if i ~= 15 then
            turtle.select(i)
            local detail = turtle.getItemDetail()
            if detail ~= nil and (detail.name == specific or detail.name == specific1 or detail.name == specific2) then
                turtle.dropDown()
            end
        end
    end
end

function TurtleInventory:hasTorches()
    turtle.select(self.torchesPlace)
    local detail = turtle.getItemDetail()
    if detail == nil then
        return false
    end

    return detail["name"] == "minecraft:torch" and detail["count"] > 1
end

function TurtleInventory:placeTorch()
    if not self:hasTorches() then
        return false
    end

    turtle.select(self.torchesPlace)
    return turtle.placeDown()
end

function TurtleInventory:takeTorches()
    if self:hasTorches() then
        return true
    end

    turtle.select(self.torchesPlace)
    turtle.dropDown()
    return turtle.suck()
end

return TurtleInventory