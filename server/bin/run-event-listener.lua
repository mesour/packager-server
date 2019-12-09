args = {...}

local listener = textutils.unserialize(args[1])
if listener == nil then
  error("First parameter must be listener object")
end

dofile("library/listeners/" .. listener["type"] .. ".lua")

local listener = _G[listener["type"]].fromArray(listener)

while true do
  event,monitor,x,y = os.pullEvent(listener:getEvent())
  listener:trigger(monitor, x, y)
end
