require("commandHandler")
modem = peripheral.find('modem')
c = peripheral.find("chatBox")

modem.open(101)


function SM(m, username) c.sendFormattedMessageToPlayer(textutils.serialiseJSON(m), username, ComputerName) end
function WM(m) c.sendFormattedMessage(textutils.serialiseJSON(m), ComputerName) end


--Help Function, lists commands
 Help = Command:create("Help", "Lists all commands", (function (username, isHidden, ver)
    local playerPermission = Permissions[username]
    local message = {}
        for k, v in pairs(Commands) do
            if(playerPermission >= v.permissionLevel) then
                --Add name of the command
                table.insert(message, {
                    text = "\n" .. v.name,
                    color = 'gold',
                    underlined = true,
                    bold = true,
                    clickEvent ={
                        action = "suggest_command",
                        value = "$i-" .. v.name
                    },
                    hoverEvent = {
                        action = "show_text",
                        contents = "$i-" .. v.name
                    }
                })
                --Add description of the command
                table.insert(message, {
                    text = "\n - " .. v.description,
                    color = 'white',
                    underlined = false,
                    bold = false
                    ,
                    clickEvent ={
                        action = "suggest_command",
                        value = "$i-" .. v.name
                    },
                    hoverEvent = {
                        action = "show_text",
                        contents = "$i-" .. v.name
                    }
                })
                --Save aliases of command in string
                local a = "["
                for ak, av in pairs(v.aliases) do
                    a = a .. av .. ", "
                end
                --Add aliases of command
                a = a:sub(1, -3) .. "]"
                table.insert(message, {
                    text = "\n - Aliases: " .. a,
                    color = 'white',
                    underlined = false,
                    bold = false
                    ,
                    clickEvent ={
                        action = "suggest_command",
                        value = "$i-" .. v.name
                    },
                    hoverEvent = {
                        action = "show_text",
                        contents = "$i-" .. v.name
                    }
                })
                if(v.usage == nil) then
                    
                    local args = ""
                    if(v.args) then
                        for ark, arv in pairs(v.args) do
                            args = args .. arv .. ", "
                        end
                    end
                        args = args:sub(1, -3)
                    table.insert(message, {
                        text = "\n - Usage: " .. v.name .. " [" .. args .. "]",
                        color = 'white',
                        underlined = false,
                        bold = false,
                        clickEvent ={
                            action = "suggest_command",
                            value = "$i-" .. v.name .. " [" .. args .. "]"
                        },
                        hoverEvent = {
                            action = "show_text",
                            contents = "$i-" .. v.name .. " [" .. args .. "]"
                        }
                    })
                else
                    table.insert(message, {
                        text = "\n - Usage: " .. v.usage,
                        color = "white",
                        underlined = false,
                        bold = false,
                        clickEvent ={
                            action = "suggest_command",
                            value = "$i-" .. v.name
                        },
                        hoverEvent = {
                            action = "show_text",
                            contents = "$i-" .. v.name
                        }
                    })
                end
            end
        end
    print(message)
    if(isHidden or ver == false) then
        SM(message, username)
    else
        WM(message) 
    end
end))
Help:regAlias("H")
--End help function

--Command Handler Pastebin
CH = Command:create("Link", "Pastebin link for command handler", (function (username, isHidden, ver)
    local m = {
        {
            text = "https://pastebin.com/auKmUFTu",
            underlined = true,
            color = 'aqua',
            clickEvent = {
                action = 'open_url',
                value = 'https://pastebin.com/auKmUFTu'
            }
        }
    }
    if(isHidden or ver == false) then
        SM(m, username)
    else
        WM(m)
    end
end))
CH:regAlias('l')
CH:regAlias('pb')

ChangePermission = Command:create("ChangePermission", "Change the permission of a player", (function (username, isHidden, ver, target, permLevel)
    if(target  == nil) then
        return SM({
            text = "\nPlease provide a target and a permission level!",
            color="red",
            bold = true
        }, username)
    end
    if(tonumber(permLevel) == nil) then
        return SM({
            text = "\nPlease provide a valid permission level! (numbers)",
            color = "red",
            bold = true
        }, username)
    end
    permLevel = tonumber(permLevel)
    UpdatePermission(target, permLevel)
    SM({
        {
        text = "\nChanged permission level of key ",
        color="white",
        bold = true
        },
        {
            text = "{" .. target .. "}",
            color ="yellow",
            bold=true
        },
        {
            text = " to level ",
            color="white",
            bold=true
        }, 
        {
            text = permLevel,
            color="yellow",
            bold=true
        }
    }, username)
end), PermissionLevels.Root, {"target", "permLevel"})
ChangePermission:regAlias("cp")

Say = Command:create("Say", "Talk as the system", (function (username, isHidden, ver, text)
    if text == nil then
        return SM({
            text = "\nPlease provide some text!",
            color="red",
            bold = true
        }, username)
    end
    WM(text)
end), PermissionLevels.BaseMember, {"text"})

--Prints Registered commands
--Register your commands before this point

for k, v in pairs(Commands) do
    print(k)
    for k2, v2 in pairs(v) do
        print("  ", k2, ":", v2)
    end
end



--Main loop
while true do
    --Peripheral Data
    local event, username, message, uuid, isHidden = os.pullEvent("chat")

    --Check if the message starts with prefix
    if(string.sub(message, 0, 2) == "i-") then
            --Check if they are a whitelisted player for world messages
        local verifiedPlayer = false

        for k,v in pairs(WorldMessageWhitelist) do
            if username == v then
                verifiedPlayer = true
                break
            end
        end
        --Get permission level of player
        local permLevel = Permissions[username]
        --If they are not registered with a permission, assign them the default permission
        if permLevel == nil then
            UpdatePermission(username, PermissionLevels.Default)
            permLevel = PermissionLevels.Default
        end
        print(permLevel)
            --Remove prefix for message
            message = string.sub(message, 3, string.len(message))
            local group = {}
            for w in string.gmatch(message, "%S+")do
                table.insert(group, w)
            end
            print(group[1], group[2])
            --End program
            if(message == 'end') then
                break
            end
            --Commands
            local foundCommand = false
            --Find Dynamic Commands
            print("Searching commands")
            for k, v in pairs(Commands) do
                --If the command was found in the previous iteration, then break
                if foundCommand == true then break end
                -- Check if the message matches an alias
                for k2, v2 in pairs(v.aliases) do
                       if(group[1] == v2) then
                        print("Found Command!") 

                        --Compare permission level of player and command
                        if permLevel >= v.permissionLevel then
                        --Execute command callback
                        local args = {}
                        local argsS = string.match(message, "%[(.+)%]")
                        argsS = argsS or ""
                        local argsSC = argsS
                        --argsS = argsS:gsub("%s+", "{[-space])")
                        for arg in string.gmatch(argsS, '([^,]+)') do

                            table.insert(args, arg)
                        end
                        v.callback(username, isHidden, verifiedPlayer, unpack(args))
                        foundCommand = true
                        break
                        else
                            if isHidden or verifiedPlayer == false then
                                SM({
                                    text = "\nSorry, your permission level of " .. permLevel .. " is too low to run this command!",
                                    color = "red",
                                    bold = true
                                }, username)
                            else 
                                WM({
                                    text = "\nSorry " .. username ..  ", your permission level of " .. permLevel .. " is too low to run this command!",
                                    color = "red",
                                    bold = true
                                })
                            end
                        end
                    end
                end
            end
            print("Finished searching commands")
            --Could not find command
            print(foundCommand)
            if(SendInvalidCommandMessage) then
                if(isHidden) then
                    if foundCommand == false then c.sendMessageToPlayer("Could not find command!", username) end
                else
                    if(verifiedPlayer == false) then
                        c.sendMessageToPlayer("Please use the silent version of these commands. (i.e >$< i-" .. message .. ')  ', username)
                    else
                        if foundCommand == false then c.sendMessage("Could not find command!", username) end
                        print("Failed")
                    end
                end
            end
    end
end