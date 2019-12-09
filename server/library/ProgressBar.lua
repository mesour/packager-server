ProgressBar = {}
ProgressBar.__index = ProgressBar

function ProgressBar:create(total, pointer, step, type, max)
  local obj = {}
  setmetatable(obj, self)
  obj.total = total or 0
  obj.pointer = pointer or 0
  obj.step = step or 1
  obj.type = type or "default"
  obj.max = max or 10
  return obj
end

function ProgressBar:advance(step)
  step = step or self.step
  self.pointer = self.pointer + step
end

function ProgressBar:blit(monitor, color)
  local current = self.pointer / self.total * 100

  local now = math.floor(self.max / 100 * current)

  for i = 0, self.max, 1 do
    if self.type == "full" then
      if i <= now then
        monitor:blit(".", color, color)
      else
        monitor:blit(".", "f", "f")
      end
    elseif self.type == "reversed" then
      if i < now then
        monitor:blit("=", color)
      elseif i == now then
        monitor:blit("<", color)
      else
        monitor:blit("_", color)
      end
    else
      if i < now then
        monitor:blit("=", color)
      elseif i == now then
        monitor:blit(">", color)
      else
        monitor:blit("-", color)
      end
    end
  end

end

return ProgressBar
