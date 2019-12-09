FuelRod = {}
FuelRod.__index = FuelRod

FuelRod.types = {}
FuelRod.types["ic2:quad_uranium_fuel_rod"] = {
  name = "4x uran fuel rod"
}
FuelRod.types["ic2:nuclear"] = {
  name = "depleted fuel"
}

function FuelRod:create(type, damage)
  local obj = {}
  setmetatable(obj, self)
  obj.type = type
  obj.damage = damage
  obj.maxDamage = 20000
  return obj
end

function FuelRod:getType()
  return self.type
end

function FuelRod:isDepleted()
  return self.type == "ic2:nuclear"
end

function FuelRod:getDamage()
  return self.damage
end

function FuelRod:getMaxDamage()
  return self.maxDamage
end

function FuelRod:getDamagePercent()
  return self:getDamage() / self:getMaxDamage() * 100
end

function FuelRod:getRemaining()
  return self.maxDamage - self.damage
end

function FuelRod:toArray()
  return {
    damage = self.damage,
    remaining = self.maxDamage - self.damage,
    maxDamage = self.maxDamage,
    depleted = self:isDepleted(),
    type = self.type
  }
end

return FuelRod
