local args = {...}
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

local base64 = {}

local extract = _G.bit32 and _G.bit32.extract
if not extract then
	if _G.bit then
		local shl, shr, band = _G.bit.lshift, _G.bit.rshift, _G.bit.band
		extract = function( v, from, width )
			return band( shr( v, from ), shl( 1, width ) - 1 )
		end
	elseif _G._VERSION >= "Lua 5.3" then
		extract = load[[return function( v, from, width )
			return ( v >> from ) & ((1 << width) - 1)
		end]]()
	else
		extract = function( v, from, width )
			local w = 0
			local flag = 2^from
			for i = 0, width-1 do
				local flag2 = flag + flag
				if v % flag2 >= flag then
					w = w + 2^i
				end
				flag = flag2
			end
			return w
		end
	end
end


function base64.makeencoder( s62, s63, spad )
	local encoder = {}
	for b64code, char in pairs{[0]='A','B','C','D','E','F','G','H','I','J',
		'K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y',
		'Z','a','b','c','d','e','f','g','h','i','j','k','l','m','n',
		'o','p','q','r','s','t','u','v','w','x','y','z','0','1','2',
		'3','4','5','6','7','8','9',s62 or '+',s63 or'/',spad or'='} do
		encoder[b64code] = char:byte()
	end
	return encoder
end

function base64.makedecoder( s62, s63, spad )
	local decoder = {}
	for b64code, charcode in pairs( base64.makeencoder( s62, s63, spad )) do
		decoder[charcode] = b64code
	end
	return decoder
end

local DEFAULT_ENCODER = base64.makeencoder()
local DEFAULT_DECODER = base64.makedecoder()

local char, concat = string.char, table.concat

function base64.encode( str, encoder, usecaching )
	encoder = encoder or DEFAULT_ENCODER
	local t, k, n = {}, 1, #str
	local lastn = n % 3
	local cache = {}
	for i = 1, n-lastn, 3 do
		local a, b, c = str:byte( i, i+2 )
		local v = a*0x10000 + b*0x100 + c
		local s
		if usecaching then
			s = cache[v]
			if not s then
				s = char(encoder[extract(v,18,6)], encoder[extract(v,12,6)], encoder[extract(v,6,6)], encoder[extract(v,0,6)])
				cache[v] = s
			end
		else
			s = char(encoder[extract(v,18,6)], encoder[extract(v,12,6)], encoder[extract(v,6,6)], encoder[extract(v,0,6)])
		end
		t[k] = s
		k = k + 1
	end
	if lastn == 2 then
		local a, b = str:byte( n-1, n )
		local v = a*0x10000 + b*0x100
		t[k] = char(encoder[extract(v,18,6)], encoder[extract(v,12,6)], encoder[extract(v,6,6)], encoder[64])
	elseif lastn == 1 then
		local v = str:byte( n )*0x10000
		t[k] = char(encoder[extract(v,18,6)], encoder[extract(v,12,6)], encoder[64], encoder[64])
	end
	return concat( t )
end

function base64.decode( b64, decoder, usecaching )
	decoder = decoder or DEFAULT_DECODER
	local pattern = '[^%w%+%/%=]'
	if decoder then
		local s62, s63
		for charcode, b64code in pairs( decoder ) do
			if b64code == 62 then s62 = charcode
			elseif b64code == 63 then s63 = charcode
			end
		end
		pattern = ('[^%%w%%%s%%%s%%=]'):format( char(s62), char(s63) )
	end
	b64 = b64:gsub( pattern, '' )
	local cache = usecaching and {}
	local t, k = {}, 1
	local n = #b64
	local padding = b64:sub(-2) == '==' and 2 or b64:sub(-1) == '=' and 1 or 0
	for i = 1, padding > 0 and n-4 or n, 4 do
		local a, b, c, d = b64:byte( i, i+3 )
		local s
		if usecaching then
			local v0 = a*0x1000000 + b*0x10000 + c*0x100 + d
			s = cache[v0]
			if not s then
				local v = decoder[a]*0x40000 + decoder[b]*0x1000 + decoder[c]*0x40 + decoder[d]
				s = char( extract(v,16,8), extract(v,8,8), extract(v,0,8))
				cache[v0] = s
			end
		else
			local v = decoder[a]*0x40000 + decoder[b]*0x1000 + decoder[c]*0x40 + decoder[d]
			s = char( extract(v,16,8), extract(v,8,8), extract(v,0,8))
		end
		t[k] = s
		k = k + 1
	end
	if padding == 1 then
		local a, b, c = b64:byte( n-3, n-1 )
		local v = decoder[a]*0x40000 + decoder[b]*0x1000 + decoder[c]*0x40
		t[k] = char( extract(v,16,8), extract(v,8,8))
	elseif padding == 2 then
		local a, b = b64:byte( n-3, n-2 )
		local v = decoder[a]*0x40000 + decoder[b]*0x1000
		t[k] = char( extract(v,16,8))
	end
	return concat( t )
end
FileComposer = {}
FileComposer.__index = FileComposer

function FileComposer.compress(outputFile, files)
    local contents = {}
    for i,path in pairs(files)
    do
        local h = fs.open(path, "r")
        if h == nil then
            error("File " .. path .. " not exist")
        elseif fs.isDir(path) then
            h.close()
            error("Given " .. path .. " is directory. Only files are accepted")
        end
        contents[path] = base64.encode(h.readAll())
        h.close()
    end

    local h = fs.open(outputFile, "w")
    for path,content in pairs(contents)
    do
        h.write(path .. " " .. content .. "\n")
    end
    h.close()
end

function FileComposer.decompress(archive, rewrite, verbose, folder)
    folder = folder or "."
    local h = fs.open(archive, "r")
    if h == nil then
        error("File " .. archive .. " not exist")
    end

    if verbose then
        print("\nExtracting started")
    end

    while true do
        local line = h.readLine()
        if not line then break end

        local pairs = Utils.split(line, " ")
        local path = folder .. "/" .. pairs[1]
        if rewrite == false and fs.exists(path) then
            error("File " .. path .. " already exists")
        end
        if verbose then
            write(".")
        end

        local handle = fs.open(path, "w")
        handle.write(base64.decode(pairs[2]))
        handle.close()
    end
    h.close()

    if verbose then
        print("\n\nSuccessfully extracted")
    end
end
PackagerInstaller = {}
PackagerInstaller.__index = PackagerInstaller

function PackagerInstaller:create(repository, tag)
  local obj = {}
  setmetatable(obj, self)

  obj.repository = repository
  obj.tag = tag or "master"
  obj.serverUrl = "https://raw.githubusercontent.com/"
  obj.path = "/generated/packager-server.compressed"

  return obj
end

function PackagerInstaller:install()
  print("Start downloading files")
  local data = self:getArchiveContent()
  local sourcePath = "source.compressed"
  if data ~= false then
    local h = fs.open(sourcePath, "w")
    h.write(data)
    h.close()

    print("\nComplete downloading files")

    FileComposer.decompress(sourcePath, true, true)
  else
    error("Error response from Github")
  end
end

function PackagerInstaller:getArchiveContent()
  path = path or ""
  local url = self.serverUrl .. self.repository .. "/" .. self.tag .. self.path

  local response = self:makeRequest(url)
  if response then
    local data = response.readAll()
    response.close()
    return data
  end
  return false
end

function PackagerInstaller:makeRequest(url)
  local response = http.get(url)
  if response ~= nil then
    if response.getResponseCode() == 200 then
        return response
    else
        error("Response code: " .. response.getResponseCode().toString() .. response.readAll())
    end
  end
  return false
end

function PackagerInstaller:getUrl(tag)
    return self.serverUrl .. self.repository .. "/" .. self.tag .. self.path
end

function PackagerInstaller.selfUpgrade()
    print("Downloading latest version...")
    print("")

    fs.delete("packager-installer.lua")

    local updateUrl = "https://raw.githubusercontent.com/mesour/packager-server/master/generated/packager-installer.lua"
    shell.run("wget " .. updateUrl)

    print("")
    print("Packager server sucessfully upgraded")
end

if args[1] == nil then
    error("First parameter repository is required")
elseif args[1] == "self-upgrade" then
    PackagerInstaller.selfUpgrade()
else
    local installer = PackagerInstaller:create(args[1], args[2])
    installer:install()
end
