dofile("library/Fluid.lua")

FluidTank = {}
FluidTank.__index = FluidTank

function FluidTank:create(fluidTank)
  local obj = {}
  setmetatable(obj, self)
  obj.tank = fluidTank
  return obj
end

function FluidTank:getAmount(key, default)
  default = default or 0
  local item = self:getItem(key)
  if item == nil then
    return default
  end
  return item["amount"] and tonumber(item["amount"]) or default
end

function FluidTank:getCapacity(key, default)
  local item = self:getItem(key)
  if item == nil then
    return default
  end
  return item["capacity"] and tonumber(item["capacity"]) or default
end

function FluidTank:getId(key)
  local item = self:getItem(key)
  if item == nil then
    return nil
  end
  return item["id"]
end

function FluidTank:getFluid(key, default)
  local id = self:getId(key) or default
  if id == nil then
    return nil
  end
  return Fluid.getFluidByid(id)
end

function FluidTank:getItem(key)
  key = key or 1
  return self:getTankData() and self:getTankData()[key]
end

function FluidTank:getTankData()
  return self.tank.getTanks("up")
end

return FluidTank
