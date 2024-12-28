local ARGS = {...}

local VERSION = "0.1a"
local HOME_DIR = "/quarry/"
local DATA_FILE = HOME_DIR .. "data"
local TURTLE_PROGRAM = HOME_DIR .. "turtle.lua"
local CONSOLE_PROGRAM = HOME_DIR .. "console.lua"

local function SCRIPT_NAME()
    local fullPath = shell.getRunningProgram()
    local fileName = fs.getName(fullPath)
    local baseName = fileName:gsub("%.lua$", "")
    return baseName
end

local function verifyHomeDir()
    if not fs.exists(HOME_DIR) then
        fs.makeDir(HOME_DIR)
    end
end

local function getRemoteVersion()
    local TMP_VERSION_LOC = HOME_DIR .. "tmp_version.txt"
    shell.run("wget", "https://raw.githubusercontent.com/Ether0p12348/ComputerCraft_Quarry/refs/heads/main/version.txt", TMP_VERSION_LOC)

    if fs.exists(TMP_VERSION_LOC) then
        local file = fs.open(TMP_VERSION_LOC, "r")
        local remoteVersion = file.readAll()
        file.close()
        fs.delete(TMP_VERSION_LOC)

        remoteVersion = string.gsub(remoteVersion, "%s+", "")
        return remoteVersion
    else
        error("Failed to get remote version.", 1)
        return nil
    end
end

local function loadData()
    verifyHomeDir()

    if not fs.exists(DATA_FILE) then
        return {}
    end

    local file = fs.open(DATA_FILE, "r")
    local content = file.readAll()
    file.close()

    local ok, result = pcall(textutils.unserialize, content)
    if ok and type(result) == "table" then
        return result
    end

    return {}
end

local function saveData(tbl)
    verifyHomeDir()

    local serialized = textutils.serialize(tbl)
    local file = fs.open(DATA_FILE, "w")
    file.write(serialized)
    file.close()
end

local function showHelp()
    local rows = {
        { "Usage: " .. SCRIPT_NAME() .. " <command> [args]" },
        { "Commands:" },
        { "  " .. SCRIPT_NAME() .. " <help, ?>", "->", "Show This Help Page" },
        { "  " .. SCRIPT_NAME() .. " install turtle", "->", "Install Program for Mining Turtle" },
        { "  " .. SCRIPT_NAME() .. " install console", "->", "Install Program for Console Computer" },
        { "  " .. SCRIPT_NAME() .. " update", "->", "Check and Install Updates" },
        { "  " .. SCRIPT_NAME() .. " start --skipUpdate", "->", "Start a Job\n  --skipUpdate option will skip the auto update." }
    }

    textutils.pagedTabulate(table.unpack(rows))
end

local function install(v)
    if v == "turtle" or v == "console" or v == "main" then
        local path
        if v == "turtle" then
            path = TURTLE_PROGRAM
        elseif v == "console" then
            path = CONSOLE_PROGRAM
        elseif v == "main" then
            path = shell.getRunningProgram()
            fs.delete(path)
        else
            error("Something went wrong.", 1)
        end

        print("Installing " .. v .. " program...")

        shell.run("wget", "https://raw.githubusercontent.com/Ether0p12348/ComputerCraft_Quarry/refs/heads/main/" .. v .. ".lua", path)

        local data = loadData()
        data.forVersion = VERSION
        data.type = v
        saveData(data)

        print("Installation complete!")
    else
        error(v .. " does not have an installation. Please try \"turtle\" or \"console\".", 0)
    end
end

local function update()
    print("Checking for updates...")

    local data = loadData()
    local remoteVersion = getRemoteVersion()

    print("Installed version: " .. (data.forVersion or "N/A"))
    print("Remote version: " .. remoteVersion)
    if remoteVersion ~= data.forVersion then
        print("New version detected. Updating...")
        -- For demonstration, imagine you query a remote version file or do logic
        -- If new version is found, re-download scripts, etc.

        -- Example: Reinstall the same file or do a version-check
        -- shell.run("wget", "https://raw.githubusercontent.com/path/to/quarry.lua", "/quarry.lua")

        -- If the user installed a 'turtle' program, re-download that
        -- If the user installed a 'console' program, re-download that
        local data = loadData()
        if data.type == "turtle" then
            print("Updating turtle program...")
            if fs.exists(TURTLE_PROGRAM) then
                fs.delete(TURTLE_PROGRAM)
            end
            -- reinstall to automatically get the new turtle.lua
            install("turtle")
            install("main")
            print("Completed update to " .. remoteVersion .. "!")
            return true
        elseif data.type == "console" then
            print("Updating console program...")
            if fs.exists(CONSOLE_PROGRAM) then
                fs.delete(CONSOLE_PROGRAM)
            end
            -- reinstall to automatically get the new console.lua
            install("console")
            install("main")
            print("Completed update to " .. remoteVersion .. "!")
            return true
        else
            error("There is no program installed to update. Use " .. SCRIPT_NAME() .. " install <turtle, console> to install a program.", 0)
        end

        error("Update Failed!", 1)
    else
        print("Already up to date!")
    end
end

local function start(u)
    if u then
        if update() then
            local updateVer = getRemoteVersion()
            local data = loadData()

            data.forVersion = updateVer
            saveData(data)
        end
    end

    local data = loadData()
    if data.type == "turtle" then
        if fs.exists(TURTLE_PROGRAM) then
            shell.run(TURTLE_PROGRAM)
            return
        end
    elseif data.type == "console" then
        if fs.exists(CONSOLE_PROGRAM) then
            shell.run(CONSOLE_PROGRAM)
            return
        end
    end
    error("There is no program installed to start. Use " .. SCRIPT_NAME() .. " install <turtle, console> to install a program.", 0)
end

local function hasArg(name)
    for i = 2, #ARGS do
        if ARGS[i] == name then
            return true
        end
    end
    return false
end

local command = ARGS[1]

if command == "install" then
    local subCommand = ARGS[2]
    
    if subCommand == "turtle" then
        install("turtle")
    elseif subCommand == "console" then
        install("console")
    else
        showHelp()
    end
elseif command == "update" then
    if update() then
        local updateVer = getRemoteVersion()
        local data = loadData()

        data.forVersion = updateVer
        saveData(data)
    end
elseif command == "start" then
    if hasArg("--skipUpdate") then
        print("Skipping update...")
        start(false)
    else
        start(true)
    end
else
    showHelp()
end
