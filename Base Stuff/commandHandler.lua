local expect = require("cc.expect")




--[[
Stores the levels of permissions for commands
Allows for gating commands behind specific levels
Consists of key-value pairs
Keys can be anything but values are recommended to be incrementing numbers
ex: 
PermissionLevels = {
    Josh = -100,
    None = 0,
    Default = 1,
    Member = 2,
    Admin = 3
}

--]]
PermissionLevels = {
    None = 0,
    Default = 1,
    BaseMember = 10,
    Root = 100
}
--Startup Permissions
Permissions = {
    ["John Doe"] = PermissionLevels.Default,
    ["iamchu"] = PermissionLevels.Root
}

--Checks for permission file    
local pF = io.open('i.Permissions.json', 'r')
if pF == nil then
    print(pF)
    pF = io.open('i.Permissions.json', 'w')
    if pF == nil then
        return
    end
    print(pF)
    pF.write(pF, textutils.serialiseJSON(Permissions))
else
    local pCopy = pF.read(pF, '*a')
    print(pCopy)

    pCopy = textutils.unserialiseJSON(pCopy) or {}
    for k,v  in pairs(Permissions) do
        
        pCopy[k] = v
    end
    Permissions = pCopy
    io.close(pF)
    pF = io.open('i.Permissions.json', 'w')
    pF.write(pF, textutils.serialiseJSON(Permissions))
end
print(textutils.serialiseJSON(Permissions))

io.close(pF)
--[[
Function to refresh permissions in memory.
Permissions in memory will be changed to permission in the file.
Players' permissions who are not in the file will remain unchanged
--]]
function RefreshPermisions()
    print("Old permissions: " .. JSON.serialiseJSON(Permissions))
    local pF = io.open('i.Permissions.json', 'r')
    local pCopy = pF.read(pF, '*a')
    print(pCopy)

    pCopy = textutils.unserialiseJSON(pCopy) or {}
    for k,v  in pairs(Permissions) do
        pCopy[k] = v
    end
    Permissions = pCopy
    print("New Permissions: " .. JSON.serialiseJSON(Permissions))
end
--[[
    Function to save permissions in memory to the file
]]
function FlushPermissions()
    local pF = io.open('i.Permissions.json', 'w')
    pF.write(pF, textutils.serialiseJSON(Permissions))
end

--[[
    Function to change a specific permission
]]
function UpdatePermission(username, permissionLevel)
    if(username ~= nil and permissionLevel ~= nil) then
        Permissions[username] = permissionLevel
        FlushPermissions()
    end
end

SendInvalidCommandMessage = false
WorldMessageWhitelist= {} -- Player Names
ComputerName = "Iob's System"

Command = {}
Command.__index = Command

Commands = {} --Stores commands
--[[
========================================================                   
All callbacks for commands will recieve:
"username, isHidden, ver"
Add these arguments in the same order as they are written here
========================================================
]]
function Command:create(name, description, callback, permissionLevel ,args, usage)
    expect(1, name, "string")
    expect(2, description, "string")
    expect(3, callback, "function")
    expect(4, permissionLevel, "number", "nil")
    expect(5, args, "table", "nil")
    expect(6, usage, "string", "nil")

    local cmd = {}
    setmetatable(cmd, Command)
    cmd.name = name
    cmd.description = description
    cmd.callback = callback
    cmd.aliases = {name, string.lower(name)}
    cmd.args = args
    cmd.usage = usage 
    cmd.permissionLevel = permissionLevel or PermissionLevels.Default
    print(cmd.args)
    table.insert(Commands, cmd)
    return cmd
end
function Command:regAlias(alias) --Register Alias for command
    expect(1, alias, "string")
    table.insert(self.aliases, string.upper(alias))
    table.insert(self.aliases, string.lower(alias))
end
