dofile("library/FuelRod.lua")
dofile("library/FluidTank.lua")

Reactor = {}
Reactor.__index = Reactor

function Reactor:create(reactor, type)
  local obj = {}
  setmetatable(obj, self)
  obj.reactor = reactor
  obj.type = type
  obj.tank = nil
  obj.fuel = {}
  obj.criticalHeatPercent = 20.0
  obj.minColdColantPercent = 60.0
  obj.maxHotColantPercent = 40.0
  return obj
end

function Reactor:refresh()
  local core = self.reactor.getReactorCore()
  self.offeredEnergy = core.getOfferedEnergy()
  local reactorData = core.getMetadata()["reactor"]

  self.heat = reactorData["heat"]
  self.active = reactorData["active"]
  self.maxHeat = reactorData["maxHeat"]
  self.fuel = {}

  self:refreshFuel()
end

function Reactor:refreshFuel()
  for key,value in pairs(self.reactor.list()) do
    for subKey,id in pairs({11, 14, 17, 38, 41, 44}) do
      if id == key then
        self.fuel[subKey] = FuelRod:create(value["name"], value["damage"])
      end
    end
  end
end

function Reactor:isFluid()
  return self.type == "fluid"
end

function Reactor:getType()
  return self.type
end

function Reactor:getColdCoolantAmount()
  return self:getCoolantTank():getAmount(1)
end

function Reactor:getColdCoolantCapacity()
  return self:getCoolantTank():getCapacity(1)
end

function Reactor:getHotCoolantAmount()
  return self:getCoolantTank():getAmount(2)
end

function Reactor:getHotCoolantCapacity()
  return self:getCoolantTank():getCapacity(2)
end

function Reactor:getCoolantTank()
  if self.type ~= "fluid" then
    error("Reactor must be type=fluid for use tanks")
  end
  return self:getOrCreateTank()
end

function Reactor:getOrCreateTank()
  if self.tank == nil then
    self.tank = FluidTank:create(self.reactor.getReactorCore())
  end
  return self.tank
end

function Reactor:getOfferedEnergy()
  return self.offeredEnergy
end

function Reactor:getMaxHeat()
  return self.maxHeat
end

function Reactor:getHeatPercent()
  return self:getHeat() / self:getMaxHeat() * 100
end

function Reactor:getFuel()
  return self.fuel
end

function Reactor:getFuelArray()
  local out = {}
  for key,fuelRod in pairs(self.fuel) do
    out[key] = fuelRod:toArray()
  end
  return out
end

function Reactor:getFuelRemainingPercent()
  local out = {}
  local max = 0
  local remaining = 0

  for key,fuelRod in pairs(self.fuel) do
    if not fuelRod:isDepleted() then
      max = max + fuelRod:getMaxDamage()
      remaining = remaining + fuelRod:getRemaining()
    end
  end
  return remaining / max * 100
end

function Reactor:getCoolantArray()
  local out = {}

  if not self:isFluid() then
    return out
  end
  out["cold"] = {
    amount = self:getColdCoolantAmount(),
    capacity = self:getColdCoolantCapacity()
  }
  out["hot"] = {
    amount = self:getHotCoolantAmount(),
    capacity = self:getHotCoolantCapacity()
  }
  return out
end

function Reactor:getHeat()
  return self.heat
end

function Reactor:getState(criticalState)
  if self:isActive() then
    return "running"
  else
    return criticalState or "waiting"
  end
end

function Reactor:getCriticalState()
  if self:getHeatPercent() >= self.criticalHeatPercent then
    return "critical-heat"
  end

  if self:isFluid() then
    local coldAmount = self:getColdCoolantAmount()
    local coldCapacity = self:getColdCoolantCapacity()

    if (coldAmount / coldCapacity * 100) < self.minColdColantPercent then
      return "low-cold-coolant"
    end

    local hotAmount = self:getHotCoolantAmount()
    local hotCapacity = self:getHotCoolantCapacity()

    if (hotAmount / hotCapacity * 100) > self.maxHotColantPercent then
      return "lot-of-hot-coolant"
    end
  end

  return nil
end

function Reactor:isActive()
  return self.active
end

function Reactor:getStatusText()
  statusText = self:getCriticalState() or "OFF"
  if self:isActive() and self:getOfferedEnergy() == 360 then
    statusText = "OK"
  elseif self:isActive() then
    statusText = "LESS POWER"
  end
  return statusText
end

function Reactor:toString()
  return textutils.serialize({
    heat = self.heat,
    active = self.active,
    criticalState = self:getCriticalState(),
    status = self:getStatusText(),
    output = self.offeredEnergy,
    maxHeat = self.maxHeat,
    type = self.type,
    fuel = self:getFuelArray(),
    fuelRemainingPercent = self:getFuelRemainingPercent(),
    coolant = self:getCoolantArray()
  })
end

return Reactor
