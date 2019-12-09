RemoteMonitor = {}
RemoteMonitor.__index = RemoteMonitor

function RemoteMonitor:create(pusherName, device)
  local obj = {}
  setmetatable(obj, self)
  obj.pusherName = pusherName
  obj.device = device
  obj.data = {}
  obj.data["device"] = pusherName
  return obj
end

function RemoteMonitor:setTextScale(value)
  if value < 0.5 then
    error("Value can not be lower than 0.5")
  end
  self:insert("setTextScale", {
    message = value
  })
end

function RemoteMonitor:setBackgroundColor(value)
  self:insert("setBackgroundColor", {
    message = value
  })
end

function RemoteMonitor:write(message, color, background)
  self:insert("write", {
    message = message,
    color = color,
    background = background
  })
end

function RemoteMonitor:blit(message, color, background)
  self:insert("write", {
    message = message,
    color = color,
    background = background
  })
end

function RemoteMonitor:writeln(message, color, background)
  self:insert("writeln", {
    message = message,
    color = color,
    background = background
  })
end

function RemoteMonitor:writePosition(message, color, background, x, y)
  self:insert("writePosition", {
    message = message,
    color = color,
    background = background,
    x = x,
    y = y
  })
end

function RemoteMonitor:clear()
  self:insert("clear")
end

function RemoteMonitor:insert(method, parameters)
  table.insert(self.data, {
    method = method,
    parameters = parameters or {}
  })
end

function RemoteMonitor:push()
  local out = {}
  out["data"] = self.data
  out["device"] = self.pusherName
  rednet.broadcast(textutils.serialize(out), self.device .. "-monitor")
  self.data = {}
end

function RemoteMonitor:isLocal()
  return false
end

return RemoteMonitor
