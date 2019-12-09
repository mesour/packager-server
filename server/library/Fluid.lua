Fluid = {}
Fluid.__index = Fluid

Fluid.types = {}
Fluid.types["minecraft:water"] = {
  name = "Water",
  color = "b",
  id = "minecraft:water",
  energy = 0
}
Fluid.types["minecraft:lava"] = {
  name = "Lava",
  color = "1",
  id = "minecraft:lava",
  energy = 20
}
Fluid.types["ic2:ic2biogas"] = {
  name = "Biogas",
  color = "4",
  id = "ic2:ic2biogas",
  energy = 16
}
Fluid.types["ic2:ic2coolant"] = {
  name = "Coolant",
  color = "9",
  id = "ic2:ic2coolant",
  energy = 0
}
Fluid.types["ic2:ic2hot_coolant"] = {
  name = "Hot coolant",
  color = "e",
  id = "ic2:ic2hot_coolant",
  energy = 0
}
Fluid.types["ic2:ic2distilled_water"] = {
  name = "Distilled water",
  color = "3",
  id = "ic2:ic2distilled_water",
  energy = 0
}

function Fluid.getFluidByid(id)
  return Fluid.types[id]
end

function Fluid.isWater(fluid)
  return fluid["id"] == "minecraft:water"
end

return Fluid
