RednetClient = {}
RednetClient.__index = RednetClient

function RednetClient:create(side)
  local obj = {}
  setmetatable(obj, self)
  self.side = side
  rednet.open(side)
  return obj
end

function RednetClient:broadcast(device, protocol, parameters)
  rednet.broadcast(textutils.serialize(parameters), self.createProtocol(device, protocol))
end

function RednetClient:receive(device, protocol, timeout)
  if device == nil then
    return rednet.receive(nil, protocol)
  end
  return rednet.receive(self.createProtocol(device, protocol), timeout)
end

function RednetClient:close()
  rednet.close(self.side)
end

function RednetClient:callCommand(device, command, parameters)
  self:broadcast(device, "command", {
    command = command,
    parameters = parameters or {}
  })
end

function RednetClient:receiveCommand(device, timeout)
  return self:receive(device, "command", timeout)
end

function RednetClient:getSide()
  return self.side
end

function RednetClient:refresh()
  rednet.close(self.side)
  rednet.open(self.side)
end

function RednetClient.createProtocol(device, protocol)
  return string.format("%s-%s", device, protocol)
end

return RednetClient
