dofile("library/Utils.lua")
dofile("library/handlers/CommandHandler.lua")
dofile("library/listeners/CommandListener.lua")

ReactorControl = {}
ReactorControl.__index = ReactorControl

function ReactorControl:create(name, reactor, monitor, integrator, rednetClient, env)
  local obj = {}
  setmetatable(obj, self)
  obj.name = name
  obj.monitor = monitor
  obj.reactor = reactor
  obj.rednetClient = rednetClient
  obj.env = env
  obj.active = true
  obj.integrator = integrator
  return obj
end

function ReactorControl:run()
  self.reactor:refresh()
  if self.reactor:getCriticalState() == nil then
    self.integrator:enable()
  end

  self.monitor:clear()

  self:openCommandListener()

  local handler = CommandHandler:create()

  while true
  do
    CommandListener.tryHandle(handler)
    handler:reset()

    self.monitor:setTextScale(.5)
    self.monitor:setBackgroundColor("b")

    self.reactor:refresh()

    rednet.broadcast(self.reactor:toString(), self.name .. "-status")
    rednet.broadcast(self.name, "ping-reactor")

    handler:setDefaultHandler(self)

    self:control()
  end
end

function ReactorControl:handle(command, parameters)
  if command == "enable" then
    self.integrator:enable()
  elseif command == "disable" then
    self.integrator:disable()
  end
end

function ReactorControl:openCommandListener()
  local newTabID = self.env.multishell.launch(
    self.env,
    "run-command-listener.lua",
    self.name,
    self.rednetClient:getSide()
  )
  self.env.multishell.setTitle(newTabID, "CommandListener")
end

function ReactorControl:control()
  id,message = rednet.receive(self.name, 0.5)

  if not self.monitor:isLocal() then
    self.monitor:clear()
  end
  self.monitor:writePosition("Nuclear reactor: " .. self.name, "0", "b", 1, 1)
  self.monitor:writePosition(string.rep("-", 36), "0", "b", 1, 2)

  local criticalState = self.reactor:getCriticalState()
  if self.reactor:isActive() and (message == "shutdown" or criticalState ~= nil) then
    self.integrator:disable()
  end

  sleep(0.5)

  value = " Heat:   " .. self.reactor:getHeat() .. " / " .. self.reactor:getMaxHeat() .. " - " .. self.reactor:getHeatPercent() .. "%         "
  self.monitor:writePosition(value, "0", "b", 1, 4)

  if self.reactor:isFluid() then
    value = " Output: " .. ((self.reactor:getOfferedEnergy() / 60) * 3860) .. " HU/t         "
  else
    value = " Output: " .. self.reactor:getOfferedEnergy() .. " EU/t         "
  end
  self.monitor:writePosition(value, "0", "b", 1, 5)

  self.monitor:writePosition(" State:  ", "0", "b", 1, 6)

  state = self.reactor:getState(criticalState)
  if state == "running" then
    fgColor = "5"
    bgColor = "b"
  elseif state == "waiting" then
    fgColor = "f"
    bgColor = "1"
  else
    fgColor = "0"
    bgColor = "e"
  end

  stat = "[" .. state .. "]"
  self.monitor:writePosition(stat, fgColor, bgColor, 10, 6)
  self.monitor:writePosition("        ", "0", "b", 10 + string.len(stat), 6)

  value = " Type:   " .. (self.reactor:getType() == "fluid" and "HU" or "EU") .. "         "
  self.monitor:writePosition(value, "0", "b", 1, 7)

  if self.reactor:isFluid() then
    local coldAmount = self.reactor:getColdCoolantAmount()
    local coldCapacity = self.reactor:getColdCoolantCapacity()

    percent = Utils.round(coldAmount / coldCapacity * 100)
    value = " Cold:   " .. coldAmount .. " / " .. Utils.getReadableNumber(coldCapacity) .. " - " .. percent .. "%         "
    self.monitor:writePosition(value, "0", "b", 1, 8)

    local hotAmount = self.reactor:getHotCoolantAmount()
    local hotCapacity = self.reactor:getHotCoolantCapacity()

    percent = Utils.round(hotAmount / hotCapacity * 100)

    value = " Hot:    " .. hotAmount .. " / " .. Utils.getReadableNumber(hotCapacity) .. " - " .. percent .. "%         "
    self.monitor:writePosition(value, "0", "b", 1, 9)
  end

  self.monitor:push()
end

return ReactorControl
