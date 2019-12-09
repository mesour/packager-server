RenderHelper = {}

function RenderHelper.printOnOff(monitor, value)
  if value then
    input = "ON"
    color = "d"
  else
    input = "OFF"
    color = "e"
  end

  monitor:write(input, color)
end

function RenderHelper.getColorByPercent(percent)
  if percent < 30 then
    return "e"
  elseif percent < 55 then
    return "1"
  else
    return "d"
  end
end

function RenderHelper.getCharacterTo(string, toCount, suffix, char)
  suffix = suffix or ""
  char = char or " "
  count = toCount - string.len(string)
  if count <= 0 then
    return ""
  end
  return string.rep(char, count) .. suffix
end

function RenderHelper.getCentered(string, toCount, separator)
  separator = separator or " "
  local full = (toCount - string.len(string))
  diff = math.ceil(full / 2);

  local suffix = ""
  if full - diff > 0 then
    suffix = string.rep(separator, full - diff)
  end

  return string.rep(separator, diff), string, suffix;
end

return RenderHelper
