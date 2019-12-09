dofile("library/RednetClient.lua")

MonitorTouchListener = {}
MonitorTouchListener.__index = MonitorTouchListener

function MonitorTouchListener:create(name, monitors, rednetSide)
  local obj = {}
  setmetatable(obj, self)
  obj.name = name
  obj.monitors = monitors
  obj.rednetSide = rednetSide
  obj.rednetClient = RednetClient:create(rednetSide)
  return obj
end

function MonitorTouchListener.fromArray(data)
  return MonitorTouchListener:create(data["name"], data["monitors"], data["rednetSide"])
end

function MonitorTouchListener:trigger(monitor, x, y)
  local remoteName = self.monitors[monitor]

  self.rednetClient:callCommand(remoteName, "monitor-touch", {
    name = self.name,
    x = x,
    y = y
  })
end

function MonitorTouchListener:getEvent()
  return "monitor_touch"
end


function MonitorTouchListener:toString()
  return textutils.serialize({
    type = "MonitorTouchListener",
    name = self.name,
    monitors = self.monitors,
    rednetSide = self.rednetSide
  })
end

return MonitorTouchListener
