CommandHandler = {}
CommandHandler.__index = CommandHandler

function CommandHandler:create()
  local obj = {}
  setmetatable(obj, self)
  obj.directory = "waiting-commands"
  obj.handlers = {}
  obj.defaultHhandler = nil
  return obj
end

function CommandHandler:setDefaultHandler(handler)
  self.defaultHhandler = handler
end

function CommandHandler:addHandler(command, handler)
  if self.handlers[command] == nil then
    self.handlers[command] = {}
  end

  table.insert(self.handlers[command], handler)
end

function CommandHandler:handle(command, parameters)
  if self.handlers[command] ~= nil then
    for key,handler in pairs(self.handlers[command]) do
      handler:handle(command, parameters)
    end
  elseif self.defaultHhandler ~= nil then
    self.defaultHhandler:handle(command, parameters)
  end
end

function CommandHandler:reset()
  self.handlers = {}
  self.defaultHhandler = nil
end

return CommandHandler
