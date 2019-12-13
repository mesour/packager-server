PackagerDevInstaller = {}
PackagerDevInstaller.__index = PackagerDevInstaller

function PackagerDevInstaller:create(repository, token)
  local obj = {}
  setmetatable(obj, self)

  obj.githubClient = GithubClient:create(repository, token)
  obj.serverDirectory = "server"
  return obj
end

function PackagerDevInstaller:install()
  print("Start downloading files")
  local directoryData = self.githubClient:getContents(self.serverDirectory)
  if directoryData ~= false then
    self:walkFilesRecursive(directoryData)
    print("\nComplete downloading files")
  else
    error("Error response from Github")
  end
end

function PackagerDevInstaller.selfUpgrade()
    print("Downloading latest version...")
    print("")

    fs.delete("packager-dev.lua")

    local updateUrl = "https://raw.githubusercontent.com/mesour/packager-server/master/generated/packager-dev.lua"
    shell.run("wget " .. updateUrl)

    print("")
    print("Packager server sucessfully upgraded")
end

function PackagerDevInstaller:walkFilesRecursive(data, dir)
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
elseif args[1] == "self-upgrade" then
    PackagerDevInstaller.selfUpgrade()
else
  local installer = PackagerDevInstaller:create(args[1], args[2])
  installer:install()
end
