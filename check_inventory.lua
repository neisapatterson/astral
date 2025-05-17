local chest = peripheral.find("minecraft:chest")
for slot, item in pairs(chest.list()) do 
    print("Slot: " .. slot .. ", Item: " .. item.name .. ", Count: " .. item.count)
end