Generator = {}
Generator.__index = Generator

function Generator:create(generator)
  local obj = {}
  setmetatable(obj, self)
  obj.generator = generator
  return obj
end

function Generator:getOfferedEnergy()
  return self.generator.getOfferedEnergy()
end

function Generator:getTank()
  return nil
end

return Generator
