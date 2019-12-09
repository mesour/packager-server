dofile("library/listeners/MonitorTouchListener.lua")

local env = setmetatable({shell = shell, multishell = multishell}, {__index = _G})

MonitorControl = {}
MonitorControl.__index = MonitorControl

function MonitorControl:create(name, rednetClient, monitors, env)
  local obj = {}
  setmetatable(obj, self)
  obj.name = name
  obj.monitors = monitors
  obj.rednetClient = rednetClient
  obj.env = env
  return obj
end

function MonitorControl:run()
  local listener = MonitorTouchListener:create(self.name, self:getMonitorsData(), self.rednetClient:getSide())

  local newTabID = self.env.multishell.launch(self.env, "run-event-listener.lua", listener:toString())
  self.env.multishell.setTitle(newTabID, "TouchEvents")

  while true
  do
    id,message,c = self.rednetClient:receive(self.name, "monitor")

    if message ~= nil then
      local data = textutils.unserialize(message)
      local monitor = self:getMonitor(data["device"])

      if data["device"] == "gg1" then
        print(monitor:batch(data["data"]))
      end

      if monitor ~= nil then
        monitor:batch(data["data"])
      end
    end

  end
end

function MonitorControl:getMonitor(device)
  if self.monitors[device] == nil then
    return nil
  end
  return self.monitors[device]["monitor"]
end

function MonitorControl:getMonitorsData()
  local out = {}
  for key,value in pairs(self.monitors) do
    out[value["name"]] = key
  end
  return out
end

return MonitorControl
