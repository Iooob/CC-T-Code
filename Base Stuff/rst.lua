local modem = peripheral.find('modem')
local c  = peripheral.find('chatBox')
if not c and not modem then
    error("Could not find one of the peripherals")
end
modem.open(101)
local status = false
local activator = ""
function SM(m, username) c.sendFormattedMessageToPlayer(textutils.serialiseJSON(m), username, "Iob's RST") end
local currentTimer = 0
while true do
    local eventData = {os.pullEvent()}
    if(eventData[1] == "modem_message") then
        local event, side, channel, replyChannel, message, distance = unpack(eventData)
        if message["message"] == 'RST' then
            activator = message["player"]
            if status then
                status = false
                redstone.setAnalogOutput('front', 0)
                os.cancelTimer(currentTimer)
            else
                status = true
                redstone.setAnalogOutput('front',1)
                currentTimer = os.startTimer(1800)
            end
            print(status)
        end
    else if (eventData[1] == "timer") then
        status = false
        redstone.setAnalogOutput('front', 0)
        SM({
            text = "\nWireless transmitter power has been shut off to save power",
            color = "red",
            bold = true
        }, activator)
        end
    end
end