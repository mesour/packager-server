local args = {...}

Packager = {}
Packager.__index = Packager

function Packager:create(configFile)
  local obj = {}
  setmetatable(obj, self)

  obj.name = name
  obj.configFile = configFile
  obj.server = "packager0"
  obj.waiting = false
  obj.updateUrl = "https://raw.githubusercontent.com/mesour/packager-server/master/generated/packager.lua"

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

function Packager:init(packageName)
    local h = fs.open("packager.json", "w")
    h.write("{\n\t\"required\": {\n\t\t\"" .. packageName .. "\": \"*\"\n\t}\n}")
    h.close();

    print("Package " .. packageName .. " is successfully initialized. You can run `packager`.")
end

function Packager:run()
  local side = self.findSide("modem")
  if side == "none" then
    error("Can not find Wireless modem")
  end

  rednet.open(side)
  local id = self.random(6)
  local data = decodeFromFile(self.configFile)

  while true
  do
    if self.waiting == false then
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
elseif args[1] == "init" then
    if args[2] == nil then
        error("Second parameter: package name is required")
    end
	packager:init(args[2])
elseif args[1] == "self-upgrade" then
	packager:selfUpgrade()
else
	error("Unknown signal: " .. args[1])
end
