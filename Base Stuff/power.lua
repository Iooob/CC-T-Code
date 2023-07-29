os.sleep(3)
local modem = peripheral.find('modem')
local p = peripheral.wrap('bottom')
local c = peripheral.find("chatBox")
--local reader = peripheral.find("blockReader")
modem.open(101)
function SM(m, username) c.sendFormattedMessageToPlayer(textutils.serialiseJSON(m), username, "Iob's Power") end

k = 1000
M = k * 1000
G = M * 1000
T = G * 1000
P = T * 1000

units = {
	'k', 'M', 'G', 'T', 'P',
}
--Format Funtion taken from ckupen's Induction Cell program -> https://github.com/zyxkad/cc/blob/master/induction_cell.lua
local function formatEnergy(fe)
	local prefix = ''
	local negative = fe < 0
	if negative then
		fe = -fe
	end
	for _, u in ipairs(units) do
		if fe < 1000 then
			break
		end
		prefix = u
		fe = fe / 1000
	end
	if negative then
		fe = -fe
	end
	return string.format('%.2f%s', fe, prefix)
end

local times = {
    {Name = "Minute", val = 60},
    {Name = "Hour",val =3600},
    {Name = "Day",val = 86400},
    {Name = "Week", val = 604800},
    {Name = "Month", val = 2628000},
    {Name = "Year", val = 31536000},
    {Name = "Decade", val= 315360000},
    {Name = "End", val=1/0}

}

local function tToTime(t) 
    t = t / 20
    local pre = ""
    local n = t < 0
    local timeDiv = 1
    if n then
        t = -t
    end
    for k, v in ipairs(times) do
        if t < v.val then
            t = t / timeDiv
            break
        end
        pre = v.Name .. "s"
        timeDiv = v.val
    end

    print(t)
    return string.format('%.2f ', t) .. pre
end

while true do
    local event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")
    local curEnergy = p.getEnergy() / 2.5
    local maxEnergy = p.getMaxEnergy() / 2.5    
    local lastIn = p.getLastInput() / 2.5
    local lastOut = p.getLastOutput() / 2.5 
    local net = lastIn - lastOut
    local netB = net > 0
    if(message["message"] == "Power") then
            SM({
                {  
                    text = "\nCapacity: ",
                    color = "green",
                    bold = true,
                    hoverEvent = {
                        action = "show_text",
                        contents = curEnergy .. "/" .. maxEnergy
                    }
                },
                {
                    text =  formatEnergy(curEnergy) .. "/" .. formatEnergy(maxEnergy) .. " (" .. (p.getEnergyFilledPercentage() * 100) .. '%)',
                    color = "white",
                    bold = false,
                    hoverEvent = {
                        action = "show_text",
                        contents = curEnergy .. "/" .. maxEnergy
                    }
                },
                {
                    text = "\nNet In/out: ",
                    color = "green",
                    bold = true,
                    hoverEvent = {
                        action = "show_text",
                        contents = "In: " .. formatEnergy(lastIn) .. " RF\nOut: " .. formatEnergy(lastOut) .. " RF"
                    }
                },
                {
                    text = formatEnergy(net) .. " RF",
                    color = "white",
                    bold = false,
                    hoverEvent = {
                        action = "show_text",
                        contents = "In: " .. formatEnergy(lastIn) .. " RF\nOut: " .. formatEnergy(lastOut) .. " RF"
                    }
                }, 
                netB and {
                    text = "\nFilling in: " .. tToTime(maxEnergy / net),
                    color = "green",
                    bold = true,
                    hoverEvent = {
                        action = "show_text",
                        contents = maxEnergy / net .. " Seconds"
                    }
                } or {
                    text = "\nDraining in: " .. tToTime(maxEnergy / net),
                    color = "red",
                    bold = true,
                    hoverEvent = {
                        action = "show_text",
                        contents = -(maxEnergy / net) .. " Seconds"
                    }   
                },

            }, message.player)
        
    end
end