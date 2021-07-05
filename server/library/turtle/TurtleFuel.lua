TurtleFuel = {}
TurtleFuel.__index = TurtleFuel

function TurtleFuel:create()
    local obj = {}
    setmetatable(obj, self)
    obj.reservedForFoundLava = 60000
    obj.minimumFuel = 20000
    return obj
end

function TurtleFuel:emptyFuel()
    return self:getFuelLevel() == 0
end

function TurtleFuel:getFuelLevel()
    return turtle.getFuelLevel()
end

function TurtleFuel:getFuelLimit()
    return turtle.getFuelLimit()
end

function TurtleFuel:needFuel()
    return self:getFuelLevel() < self.minimumFuel
end

function TurtleFuel:hasFullFuel()
    local delta = turtle.getFuelLimit() - self.reservedForFoundLava
    return self:getFuelLevel() > delta
end

function TurtleFuel:refuel()
    while self:hasFullFuel() == false
    do
        turtle.select(16)
        turtle.dropDown()
        if turtle.suck() == false then
            return false
        end
        turtle.refuel()
        turtle.dropDown()
    end
    return true
end

function TurtleFuel:findAndUseFuel()
    if self:hasFullFuel() then
        return true
    end

    success = false
    for i = 1, 16 do
        if i ~= 15 then
            turtle.select(i)
            if turtle.refuel() then
                success = true
            end
        end
    end
    return success
end

return TurtleFuel
