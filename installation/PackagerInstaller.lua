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

function PackagerInstaller:getUrl(tag)
    return self.serverUrl .. self.repository .. "/" .. self.tag .. self.path
end

if args[1] == nil then
    error("First parameter repository is required")
else
    local installer = PackagerDevInstaller:create(args[1], args[2])
    installer:install()
end
