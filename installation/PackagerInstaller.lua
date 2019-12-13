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
