dofile("library/turtle/TurtleHelper.lua")
dofile("library/turtle/TurtleLogger.lua")

TurtleMover = {}
TurtleMover.__index = TurtleMover

function TurtleMover:create(startingSide)
    local obj = {}
    setmetatable(obj, self)

    obj.side = startingSide
    obj.sides = {"east","south","west","north"}
    obj.sideNums = {east=1, south=2, west=3, north=4}
    return obj
end

function TurtleMover:setSide(side)
  self.side = side
end

function TurtleMover:goToVector(targetVector, side)
    while true
    do
        local currentVector = self:getLocation()
        if currentVector == false then
            return false
        end

        if currentVector.z < targetVector.z then
            self:up()

        elseif currentVector.z > targetVector.z then
            self:down()

        elseif self:turnToNeededSide(currentVector, targetVector, side) then

        elseif currentVector.x == targetVector.x and currentVector.y == targetVector.y and currentVector.z == targetVector.z then
            -- in finish
            print("in finish")
            return true
        else
            self:forward()
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
    self.side = self:getRotatedFace(self.side, 1)
    return turtle.turnRight()
end

function TurtleMover:turnLeft()
    self.side = self:getRotatedFace(self.side, -1)
    return turtle.turnLeft()
end

function TurtleMover:getRotatedFace(side, about)
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

function TurtleMover:getLocation()
    local x, y, z = gps.locate(5)
    if not x then
        TurtleLogger.error("Failed to get my location!")
        return false
    else
        return vector.new(x, y, z)
    end
end

return TurtleMover
