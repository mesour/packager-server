dofile("library/turtle/TurtleHelper.lua")
dofile("library/turtle/TurtleLogger.lua")

TurtleMover = {}
TurtleMover.__index = TurtleMover

function TurtleMover:create(inspector, callback)
    local obj = {}
    setmetatable(obj, self)

    obj.side = nil
    obj.sides = {"east","south","west","north"}
    obj.inspector = inspector
    obj.sideNums = {east=1, south=2, west=3, north=4}
    obj.currentVector = {x=-1, y=-1, z=-1}
    obj.callback = callback or function() end
    return obj
end

function TurtleMover:start()
    self.side = self:detectSide()
end

function TurtleMover:getCurrentVector()
    return self.currentVector
end

function TurtleMover:refreshCurrentVector()
    self.currentVector = TurtleMover.getLocation()
end

function TurtleMover:goToVector(targetVector, side)
    callback = callback or function () end
    while true
    do
        local currentVector = TurtleMover.getLocation()
        if currentVector == false then
            return false
        end

        self.currentVector = currentVector
        if currentVector.z < targetVector.z then
            self:up()

        elseif currentVector.z > targetVector.z and targetVector.z ~= (currentVector.z - 1) then
            self:down()

        elseif self:turnToNeededSide(currentVector, targetVector, side) then

        elseif currentVector.x == targetVector.x and currentVector.y == targetVector.y then
            if currentVector.z > targetVector.z then
                self:down()
            elseif currentVector.z == targetVector.z then
                return true
            end

        else
            self:forward()
            self:callback()
        end
    end
end

function TurtleMover:turnToNeededSide(currentVector, targetVector, side)
    local neededSide = TurtleHelper.getNeededSide(currentVector, targetVector, side)
    if self.side == nil then
        error("Side is required")
    end

    if neededSide ~= nil and neededSide ~= self.side then
        local currentNum = self.sideNums[self.side]
        local num = self.sideNums[neededSide]
        local about = math.abs(currentNum - num)

        if num < currentNum and about <= 2 then
            for i = 1, about do
                self:turnLeft()
            end
        elseif num < currentNum and about > 2 then
            self:turnRight()
        elseif num > currentNum and about <= 2 then
            for i = 1, about do
                self:turnRight()
            end
        else
            self:turnLeft()
        end
        return true
    end
    return false
end

function Turtle:detectSide()
    local currentVector = TurtleMover.getLocation()
    if currentVector == false then
        return false
    end

    if self.inspector:isChest() then
        turtle.turnLeft()
    end

    self:forward()

    local frontVector = TurtleMover.getLocation()
    if currentVector == false then
        return false
    end
    return TurtleHelper.getNeededSide(currentVector, frontVector)
end

function TurtleMover:back()
    print("back")
    return turtle.back()
end

function TurtleMover:up()
    if turtle.detectUp() then
        if turtle.digUp() == false then
            self:attackUp()
        end
    end

    if turtle.up() then
        return true
    else
        self:attackUp()
        self:up()
    end
end

function TurtleMover:down()
    if turtle.detectDown() then
        if turtle.digDown() == false then
            self:attackDown()
        end
    end

    if turtle.down() then
        return true
    else
        self:attackDown()
        self:down()
    end
end

function TurtleMover:forward()
    if turtle.detect() then
        if turtle.dig() == false then
            self:attack()
        end
    end

    if turtle.forward() then
        return true
    else
        self:attack()
        return self:forward()
    end
end

function TurtleMover:attack()
    while turtle.attack()
    do
        print ("Turtle attacked in front.")
    end
end

function TurtleMover:attackUp()
    while turtle.attackUp()
    do
        print ("Turtle attacked up.")
    end
end

function TurtleMover:attackDown()
    while turtle.attackDown()
    do
        print ("Turtle attacked down.")
    end
end

function TurtleMover:turnRight()
    self.side = self:getRotatedSide(self.side, 1)
    return turtle.turnRight()
end

function TurtleMover:turnLeft()
    self.side = self:getRotatedSide(self.side, -1)
    return turtle.turnLeft()
end

function TurtleMover:getRotatedSide(side, about)
    local currentNum = self.sideNums[side]
    return self.sides[self:correctSideNum(currentNum + about)]
end

function TurtleMover:correctSideNum(num)
    if num > 4 then
        return 1
    elseif num < 1 then
        return 4
    end
    return num
end

function TurtleMover.getLocation(counter)
    counter = counter or 0
    local x, y, z = gps.locate(5)
    if not x then
        if counter < 5 then
            sleep(5)
            return TurtleMover.getLocation(counter + 1)
        end
        TurtleLogger.error("Failed to get my location!")
        return false
    else
        return vector.new(x, y, z)
    end
end

return TurtleMover
