RedstoneIntegrator = {}
RedstoneIntegrator.__index = RedstoneIntegrator

function RedstoneIntegrator:create(redstoneIntegrator, side)
  local obj = {}
  setmetatable(obj, self)
  obj.redstoneIntegrator = redstoneIntegrator
  obj.side = side
  return obj
end

function RedstoneIntegrator:enable()
  self.redstoneIntegrator.setAnalogOutput(self.side, 1)
end

function RedstoneIntegrator:disable()
  self.redstoneIntegrator.setAnalogOutput(self.side, 0)
end

function RedstoneIntegrator:isEnabled()
  return self.redstoneIntegrator.getAnalogInput(self.side) == 1
end

return RedstoneIntegrator
