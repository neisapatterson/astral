function FindEmptySlot(chest)
    print("Finding empty slot.")
    for i = 1, 90 do
        local item = chest.getItemDetail(i)
        if item == nil then
            return i
        end
    end

    return -1
end

-- Helper function to set the input chest
function GetInputChest(chestId)
    print("Getting input chest.")
    -- Get the input chest where you put the items you want to attach
    local inputChest = peripheral.wrap("reinfchest:copper_chest_" .. chestId)
    return inputChest
end

-- Helper function to find all connected chests, excluding the input chest
function FindConnectedChests(inputChestId)
    print("Finding connected chests.")
    -- Get all connected chests
    local chests = { peripheral.find("reinfchest:copper_chest", function(name, chest)
        if peripheral.getName(chest) == "reinfchest:copper_chest_" .. inputChestId then
            return false
        else
            print("Found connected chest: " .. peripheral.getName(chest))
            return true
        end
    end) }

    return chests
end

function CanStack(currStackSize, itemCount)
    print("Checking if items can stack.")
    return currStackSize + itemCount <= 64
end

function StoreItem(inputChest, connectedChests)
    for storeSlot, storeItem in pairs(inputChest.list()) do
        print("Storing item: " .. storeItem.name .. " from slot: " .. storeSlot)
        -- Check if the item is in another chest
        local found = false

        for _, currChest in pairs(connectedChests) do
            print("Checking connected chest: " .. peripheral.getName(currChest))
            for searchSlot, searchItem in pairs(currChest.list()) do
                if searchItem.name == storeItem.name then
                    if searchItem.count < 64 then
                        found = true

                        if CanStack(searchItem.count, storeItem.count) then
                            print("Pushing items to the chest after CanStack.")
                            inputChest.pushItems(peripheral.getName(currChest), storeSlot, storeItem.count, searchSlot)
                        else
                            local spaceLeft = 64 - searchItem.count
                            local remainingCount = storeItem.count - spaceLeft
                            if spaceLeft > 0 then
                                inputChest.pushItems(peripheral.getName(currChest), storeSlot, spaceLeft, searchSlot)
                            end

                            -- If not enough space, push the item to the first empty slot in a chest
                            if remainingCount > 0 then
                                for _, newChest in pairs(connectedChests) do
                                    if peripheral.getName(newChest) ~= peripheral.getName(inputChest) then
                                        local emptySlot = FindEmptySlot(newChest)
                                        if emptySlot ~= -1 then
                                            inputChest.pushItems(peripheral.getName(newChest), storeSlot, storeItem
                                            .count, emptySlot)
                                            break
                                        end
                                    else
                                        print("Skipping input chest: " .. peripheral.getName(inputChest))
                                    end
                                end
                            end
                        end
                    end
                end
            end

            -- ::continue::
        end

        local successful = false
        if not found then
            for _, currChest in pairs(connectedChests) do
                if peripheral.getName(currChest) ~= peripheral.getName(inputChest) then
                    local emptySlot = FindEmptySlot(inputChest)
                    if emptySlot ~= -1 then
                        inputChest.pushItems(peripheral.getName(inputChest), storeSlot, storeItem.count, emptySlot)
                        successful = true
                    end
                end
            end
        end

        if not successful then
            print("No empty slot available in any connected chest for item: " .. storeItem.name)
        end
    end
end

function Main()
    local inputChestId = "2" -- Change this to the ID of your input chest
    local inputChest = GetInputChest(inputChestId)
    local connectedChests = FindConnectedChests(inputChestId)

    for _, chest in pairs(connectedChests) do
        print("Connected chest found: " .. peripheral.getName(chest))
    end

    StoreItem(inputChest, connectedChests)
    print("Items stored successfully.")
end

Main()
