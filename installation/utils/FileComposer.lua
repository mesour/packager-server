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
        h.write(path .. "\n" .. content .. "\n")
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
        local file = h.readLine()
        local content = h.readLine()
        if not file or file == "" or not content or content == "" then break end

        local path = folder .. "/" .. file
        if rewrite == false and fs.exists(path) then
            error("File " .. path .. " already exists")
        end
        if verbose then
            write(".")
        end

        local handle = fs.open(path, "w")
        handle.write(base64.decode(content))
        handle.close()
    end
    h.close()

    if verbose then
        print("\n\nSuccessfully extracted")
    end
end
