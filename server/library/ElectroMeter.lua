dofile("library/Utils.lua")
dofile("library/rendering/MonitorFieldset.lua")

ElectroMeter = {}
ElectroMeter.__index = ElectroMeter

ElectroMeter.positions = {
  input = 4,
  reading = 5,
  enableOutput = 6,
  output = 7,
  enableInput = 8
}

function ElectroMeter:create(name, monitor, storage, inputIntegrator, outputIntegrator, autoMode)
  local obj = {}
  setmetatable(obj, self)
  obj.name = name
  obj.monitor = monitor
  obj.storage = storage
  obj.inputIntegrator = inputIntegrator
  obj.outputIntegrator = outputIntegrator
  obj.logFile = "metter.log"
  obj.autoMode = autoMode or false
  obj.mode = "enableInput"
  obj.current = 0
  obj.lastStored = 0
  return obj
end

function ElectroMeter:run()
  local lastInputEnabled = false

  self.outputIntegrator:enable()
  self.inputIntegrator:enable()

  self:refreshStatus()

  while true
  do
    self.monitor:setTextScale(.5)

    if self.mode == "input" then
      if not self.autoMode then
        id,message = rednet.receive(self.name, 3)
      else
        message = "disableInput"
      end

      if message == "disableInput" then
        self.inputIntegrator:enable()
        self.mode = "reading"
      end

    elseif self.mode == "output" then
      if not self.autoMode then
        id,message = rednet.receive(self.name, 3)
      else
        message = "disableOutput"
      end

      if message == "disableOutput" then
        self.outputIntegrator:enable()
        self.mode = "enableInput"
        self.lastStored = 0
      end
    elseif self.mode == "reading" then
      local current = self:readFile()

      h = fs.open(self.logFile, "w")

      self.lastStored = self.storage:getEUStored() - self.current

      self:refreshStatus()

      h.write(current + self.lastStored)

      h.close()

      self.mode = "enableOutput"
    else
      if not self.autoMode then
        id,message = rednet.receive(self.name, 3)
      elseif lastInputEnabled then
        message = "enableOutput"
      else
        message = "enableInput"
      end

      if message == "enableInput" then
        self.outputIntegrator:enable()
        self.inputIntegrator:disable()
        self.mode = "input"
        self.current = self.storage:getEUStored()
        lastInputEnabled = true
      elseif message == "enableOutput" then
        self.outputIntegrator:disable()
        self.inputIntegrator:enable()
        self.mode = "output"
        lastInputEnabled = false
      end

      if self.autoMode then
        self:refreshStatus()
        sleep(10)
      end
    end

    self:refreshStatus()

    sleep(1)
  end
end

function ElectroMeter:readFile()
  local default = 0
  local h = fs.open(self.logFile, "r")
  if h ~= nil then
    content = h.readAll()
    if content == nil or Utils.trim(content) == "" then
        return default
    end
    h.close()
    return tonumber(content)
  end
  return tonumber(default)
end

function ElectroMeter:toArray()
  return {
    mode = self.mode,
    input = not self.inputIntegrator:isEnabled(),
    output = not self.outputIntegrator:isEnabled()
  }
end

function ElectroMeter:refreshStatus()
  self.monitor:clear()

  rednet.broadcast(textutils.serialize(self:toArray()), self.name .. "-status")

  local value = self:readFile()

  local fieldset = MonitorFieldset:create(self.monitor)

  fieldset:write("EU metter: " .. self.name, 2, 2, 34, 7)

  self.monitor:writePosition("EU: " .. Utils.getReadableNumber(value), "0", "f", 4, 4)

  self.monitor:writePosition("Last: " .. self.lastStored .. " EU", "0", "f", 4, 5)

  self.monitor:writePosition("Mode: " .. self.mode, "0", "f", 4, 6)

  local position = ElectroMeter.positions[self.mode]
  self.monitor:writePosition("->", "b", "f", 25, position)

  self.monitor:writePosition("[ ++ ]", "0", position == 4 and "b" or "8", 28, 4)
  self.monitor:writePosition("[read]", "0", position == 5 and "b" or "7", 28, 5)
  self.monitor:writePosition("[ EO ]", "0", position == 6 and "b" or "8", 28, 6)
  self.monitor:writePosition("[ -- ]", "0", position == 7 and "b" or "7", 28, 7)
  self.monitor:writePosition("[ EI ]", "0", position == 8 and "b" or "8", 28, 8)

  self.monitor:push()
end

return ElectroMeter
