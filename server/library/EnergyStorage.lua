EnergyStorage = {}
EnergyStorage.__index = EnergyStorage

function EnergyStorage:create(energyStorage)
  local obj = {}
  setmetatable(obj, self)
  obj.storage = energyStorage
  return obj
end

function EnergyStorage:getEUStored()
  return self.storage.getEUStored()
end

function EnergyStorage:getEUCapacity()
  return self.storage.getEUCapacity()
end

function EnergyStorage:toString()
  return textutils.serialize({
    capacity = self:getEUCapacity(),
    stored = self:getEUStored()
  })
end

function EnergyStorage:getReadableCapacity()
  local capacity = self:getEUCapacity()
  local m = 999999

  if capacity > m then
    return math.floor(capacity / 1000000) .. "M"
  elseif capacity > 999 then
    return math.floor(capacity / 1000) .. "k"
  end

  return capacity
end

function EnergyStorage:getEUOutput()
  return self.storage.getEUOutput()
end

function EnergyStorage:getEuPercent()
  return self:getEUStored() / self:getEUCapacity() * 100
end

return EnergyStorage
