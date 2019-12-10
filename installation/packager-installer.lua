local args = {...}
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
GithubClient = {}
GithubClient.__index = GithubClient

function GithubClient:create(repository, token)
  local obj = {}
  setmetatable(obj, self)

  obj.repository = repository
  obj.apiUrl = "https://api.github.com/"
  obj.token = token
  return obj
end

function GithubClient:getContents(path)
  path = path or ""
  local url = self.apiUrl .. "repos/" .. self.repository .. "/contents/" .. path

  local response = self:makeRequest(url)
  if response then
    local info = decode(response.readAll())
    response.close()
    return info
  end
  return false
end

function GithubClient:getFileContent(contentData)
  local response = self:makeRequest(contentData["download_url"])
    if response then
      local content = response.readAll()
      response.close()
      return content
    end
    return false
end

function GithubClient.isArrayOfItems(contentData)
  return contentData["type"] == nil
end

function GithubClient:makeRequest(url)
  local response = http.get(url, self:createHeaders())
  if response ~= nil then
    if response.getResponseCode() == 200 then
        return response
    else
        error("Response code: " .. response.getResponseCode().toString() .. response.readAll())
    end
  end
  return false
end

function GithubClient:createHeaders()
  if self.token == nil then
    return ""
  end
  return {
    [ "Authorization" ] = "token " .. self.token
  }
end
PackagerInstaller = {}
PackagerInstaller.__index = PackagerInstaller

function PackagerInstaller:create(repository, token)
  local obj = {}
  setmetatable(obj, self)

  obj.githubClient = GithubClient:create(repository, token)
  obj.serverDirectory = "server"
  return obj
end

function PackagerInstaller:install()
  print("Start downloading files")
  local directoryData = self.githubClient:getContents(self.serverDirectory)
  if directoryData ~= false then
    self:walkFilesRecursive(directoryData)
    print("\nComplete downloading files")
  else
    error("Error response from Github")
  end
end

function PackagerInstaller:walkFilesRecursive(data, dir)
  dir = dir or ""

  if GithubClient.isArrayOfItems(data) then
    for key,item in pairs(data) do
      self:walkFilesRecursive(item, dir)
    end
  else
    local directory = dir .. "/" .. data["name"]

    if data["type"] == "dir" then
      local contents = self.githubClient:getContents(data["path"])
      if contents ~= false then

        print("\nWalk directory: " .. data["path"])
        self:walkFilesRecursive(contents, directory)
      else
        error("Error response from Github")
      end
    else
      local content = self.githubClient:getFileContent(data)
      if content then
        write(".")
        local h = fs.open(directory, "w")
        h.write(content)
        h.close()
      end
    end
  end
end

if args[1] == nil or args[2] == nil then
  error("First and second parameter is required")
else
  local installer = PackagerInstaller:create(args[1], args[2])
  installer:install()
end
