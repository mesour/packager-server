Utils = {}

function Utils.getReadableNumber(number)
  local m = 999999
  number = tonumber(number)

  if number > m then
    return Utils.round(number / 1000000, 2) .. "M"
  elseif number > 999 then
    return Utils.round(number / 1000, 2) .. "k"
  end

  return number
end

function Utils.trim(s)
   return s:match "^%s*(.-)%s*$"
end

function Utils.getTableCount(t)
  local count = 0
  for _ in pairs(t) do count = count + 1 end
  return count
end

function Utils.findPeripheralSide(name, prior)
  local sides = {"top";"front";"left";"right";"back";"bottom"}

  if prior==nil then
    p=1
  else
    p=prior
  end

  for n=1,6 do
    if peripheral.getType(sides[n]) == name then
      if p==1 then
        return sides[n]
      else
        p=p-1
      end
    end
  end

  return "none"
end

function Utils.printColoredString(text, color, defaultColor)
  defaultColor = defaultColor or colors.white
  term.setTextColor(color)
  term.write(text)
  print("")
  term.setTextColor(defaultColor)
end

function Utils.split(str, pat)
   local t = {}  -- NOTE: use {n = 0} in Lua-5.0
   local fpat = "(.-)" .. pat
   local last_end = 1
   local s, e, cap = str:find(fpat, 1)
   while s do
      if s ~= 1 or cap ~= "" then
         table.insert(t,cap)
      end
      last_end = e+1
      s, e, cap = str:find(fpat, last_end)
   end
   if last_end <= #str then
      cap = str:sub(last_end)
      table.insert(t, cap)
   end
   return t
end

function Utils.getTextColor(color)
  num = tonumber(color)
  if num ~= nil and tonumber(color) < 7 then
    return "f"
  end
  return "0"
end

function Utils.random(lenght)
  str=""
  all = {"0","1","2","3","4","5","6","7","8","9","a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"}
  from = from or all
  for i=1, lenght do str = str..from[math.random(1, #all)] end
  return str
end

function Utils.round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end

function Utils:pingAndSearchDevices(rednetClient, type, attempts)
  attempts = attempts or 15
  local counter = 1
  local badCounter = 0
  local out = {}

  print("")
  Utils.printColoredString("Searching " .. type .. "s...", colors.blue)
  print("")

  while true do
    id,message = rednetClient:receive("ping", type, 5)

    if message == nil then
      term.write("-")
      badCounter = badCounter + 1
    else
      out[message] = message
      term.write(".")
      if counter % 26 == 0 then
        print("")
      end
      counter = counter + 1
    end

    if counter > attempts or badCounter > 6 then
      local count = Utils.getTableCount(out)
      print("")
      print("")
      if badCounter > 5 and count == 0 then
        Utils.printColoredString("No " .. type .. " found", colors.red)
      else
        Utils.printColoredString("Found " .. count .. " " .. type .. "s", colors.green)
        for _,storage in pairs(out) do
          print(" - " .. storage)
        end
      end
      break
    end
  end
end

function Utils.printOnOff(monitor, value)
  if value then
    input = "ON"
    color = "d"
  else
    input = "OFF"
    color = "e"
  end

  monitor:write(input, color)
end

return Utils
