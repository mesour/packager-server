dofile("library/FluidTank.lua")

FluidGenerator = {}
FluidGenerator.__index = FluidGenerator

function FluidGenerator:create(fluidGenerator, defaultFluid)
  local obj = {}
  setmetatable(obj, self)
  obj.generator = fluidGenerator
  obj.tank = FluidTank:create(fluidGenerator)
  obj.fluid = defaultFluid
  return obj
end

function FluidGenerator:getOfferedEnergy()
  return self.tank:getAmount() > 0 and self:getFluid()["energy"] or 0
end

function FluidGenerator:getTank()
  return self.tank
end

function FluidGenerator:getAmount()
  return self.tank:getAmount(1)
end

function FluidGenerator:getFluid()
  return self.tank:getFluid(1, self.fluid)
end

return FluidGenerator
