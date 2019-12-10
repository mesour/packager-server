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
