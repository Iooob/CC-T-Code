Expect = require('cc.expect')
Chest = peripheral.wrap('left')

while true do
    local chest = peripheral.wrap('left')
    local items = 0
    for k, v in pairs(chest.list()) do
        if(k ~= nil) then
            items = items + 1
        end
    end
    if items == chest.size() then
        redstone.setOutput('right', true)
    else
        redstone.setOutput('right', false)
    end
end