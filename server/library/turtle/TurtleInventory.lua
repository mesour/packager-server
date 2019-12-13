TurtleInventory = {}
TurtleInventory.__index = TurtleInventory

function TurtleInventory:create()
    local obj = {}
    setmetatable(obj, self)
    obj.minimumEmptySlots = 2
    return obj
end

function TurtleInventory:hasFull()
    local emptyCount = 0
    for i = 1, 16 do
        if turtle.getItemCount(i) == 0 then
            emptyCount = emptyCount + 1
        end
    end
    return emptyCount <= self.minimumEmptySlots
end

function TurtleInventory:flush()
    for i = 1, 16 do
        turtle.select(i)
        turtle.dropDown()
    end
end

return TurtleInventory
