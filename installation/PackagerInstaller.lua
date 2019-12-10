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
