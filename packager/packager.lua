------------------------------------------------------------------ utils
local controls = {["\n"]="\\n", ["\r"]="\\r", ["\t"]="\\t", ["\b"]="\\b", ["\f"]="\\f", ["\""]="\\\"", ["\\"]="\\\\"}

local whites = {['\n']=true; ['\r']=true; ['\t']=true; [' ']=true; [',']=true; [':']=true}
function removeWhite(str)
	while whites[str:sub(1, 1)] do
		str = str:sub(2)
	end
	return str
end

local decodeControls = {}
for k,v in pairs(controls) do
	decodeControls[v] = k
end

function parseBoolean(str)
	if str:sub(1, 4) == "true" then
		return true, removeWhite(str:sub(5))
	else
		return false, removeWhite(str:sub(6))
	end
end

function parseNull(str)
	return nil, removeWhite(str:sub(5))
end

local numChars = {['e']=true; ['E']=true; ['+']=true; ['-']=true; ['.']=true}
function parseNumber(str)
	local i = 1
	while numChars[str:sub(i, i)] or tonumber(str:sub(i, i)) do
		i = i + 1
	end
	local val = tonumber(str:sub(1, i - 1))
	str = removeWhite(str:sub(i))
	return val, str
end

function parseString(str)
	str = str:sub(2)
	local s = ""
	while str:sub(1,1) ~= "\"" do
		local next = str:sub(1,1)
		str = str:sub(2)
		assert(next ~= "\n", "Unclosed string")

		if next == "\\" then
			local escape = str:sub(1,1)
			str = str:sub(2)

			next = assert(decodeControls[next..escape], "Invalid escape character")
		end

		s = s .. next
	end
	return s, removeWhite(str:sub(2))
end

function parseArray(str)
	str = removeWhite(str:sub(2))

	local val = {}
	local i = 1
	while str:sub(1, 1) ~= "]" do
		local v = nil
		v, str = parseValue(str)
		val[i] = v
		i = i + 1
		str = removeWhite(str)
	end
	str = removeWhite(str:sub(2))
	return val, str
end

function parseObject(str)
	str = removeWhite(str:sub(2))

	local val = {}
	while str:sub(1, 1) ~= "}" do
		local k, v = nil, nil
		k, v, str = parseMember(str)
		val[k] = v
		str = removeWhite(str)
	end
	str = removeWhite(str:sub(2))
	return val, str
end

function parseMember(str)
	local k = nil
	k, str = parseValue(str)
	local val = nil
	val, str = parseValue(str)
	return k, val, str
end

function parseValue(str)
	local fchar = str:sub(1, 1)
	if fchar == "{" then
		return parseObject(str)
	elseif fchar == "[" then
		return parseArray(str)
	elseif tonumber(fchar) ~= nil or numChars[fchar] then
		return parseNumber(str)
	elseif str:sub(1, 4) == "true" or str:sub(1, 5) == "false" then
		return parseBoolean(str)
	elseif fchar == "\"" then
		return parseString(str)
	elseif str:sub(1, 4) == "null" then
		return parseNull(str)
	end
	return nil
end

function decode(str)
	str = removeWhite(str)
	t = parseValue(str)
	return t
end

function decodeFromFile(path)
	local file = assert(fs.open(path, "r"))
	local decoded = decode(file.readAll())
	file.close()
	return decoded
end

------------------------------------------------------------------ / utils

local args = {...}

Packager = {}
Packager.__index = Packager

function Packager:create(configFile)
  local obj = {}
  setmetatable(obj, self)

  obj.name = name
  obj.config = decodeFromFile(configFile)
  obj.server = "packager0"
  obj.waiting = false
  obj.updateUrl = "https://raw.githubusercontent.com/mesour/packager-server/master/packager/packager.lua"

  return obj
end

function Packager.random(lenght)
  str=""
  all = {"0","1","2","3","4","5","6","7","8","9","a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"}
  from = from or all
  for i=1, lenght do str = str..from[math.random(1, #all)] end
  return str
end

function Packager.findSide(name, prior)
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

function Packager:selfUpgrade()
	print("Downloading latest version...")
	print("")

	fs.delete("packager.lua")

	shell.run("wget " .. self.updateUrl)

	print("")
	print("Packager sucessfully upgraded")
end

function Packager:run()
  local side = self.findSide("modem")
  if side == "none" then
    error("Can not find Wireless modem")
  end

  rednet.open(side)
  local id = self.random(6)

  while true
  do
    if self.waiting == false then
      local data = self.config
      data["id"] = id

      rednet.broadcast(textutils.serialize(data), self.server .. "-update")

      self.waiting = true
    else
			a,message = rednet.receive(id .. "-send")

			print("Installing files...")
			print("")

			self:writeFiles(textutils.unserialize(message))

			print("")
			print("Packages are sucessfully installed")
			break
    end
  end

  rednet.close(side)
end

function Packager:writeFiles(libraries)
	for key,value in pairs(libraries) do
		print("  - " .. value["location"])
		local h = fs.open(value["location"], "w")
		h.write(value["content"])
		h.close()
	end
end

local packager = Packager:create("packager.json")

if args[1] == nil then
	packager:run()
elseif args[1] == "self-upgrade" then
	packager:selfUpgrade()
else
	error("Unknown signal " .. args[1])
end