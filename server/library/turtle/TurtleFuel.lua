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
    return turtle.getFuelLevel() == 0
end

function TurtleFuel:needFuel()
    return turtle.getFuelLevel() < self.minimumFuel
end

function TurtleFuel:hasFullFuel()
    local delta = turtle.getFuelLimit() - self.reservedForFoundLava
    return turtle.getFuelLevel() > delta
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

return TurtleFuel
