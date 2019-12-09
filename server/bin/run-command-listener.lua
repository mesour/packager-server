dofile("library/listeners/CommandListener.lua")

args = {...}

local name = args[1]
if name == nil then
  error("First parameter must be name")
end

local rednetSide = args[2]
if rednetSide == nil then
  error("Second parameter must be rednet side")
end

local listener = CommandListener:create(name, rednetSide)
listener:listen()
