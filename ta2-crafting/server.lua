local TA2Core = exports['ta2-core']:GetCoreObject()

-- Functions

local function IncreasePlayerXP(source, xpGain, xpType)
    local Player = TA2Core.Functions.GetPlayer(source)
    if Player then
        local currentXP = Player.Functions.GetRep(xpType)
        local newXP = currentXP + xpGain
        Player.Functions.AddRep(xpType, newXP)
        TriggerClientEvent('TA2Core:Notify', source, string.format(Lang:t('notifications.xpGain'), xpGain, xpType), 'success')
    end
end

-- Callbacks

TA2Core.Functions.CreateCallback('crafting:getPlayerInventory', function(source, cb)
    local player = TA2Core.Functions.GetPlayer(source)
    if player then
        cb(player.PlayerData.items)
    else
        cb({})
    end
end)

-- Events
RegisterServerEvent('ta2-crafting:server:removeMaterials', function(itemName, amount)
    local src = source
    local Player = TA2Core.Functions.GetPlayer(src)
    if Player then
        exports['ta2-inventory']:RemoveItem(src, itemName, amount, false, 'ta2-crafting:server:removeMaterials')
        TriggerClientEvent('ta2-inventory:client:ItemBox', src, TA2Core.Shared.Items[itemName], 'remove')
    end
end)

RegisterNetEvent('ta2-crafting:server:removeCraftingTable', function(benchType)
    local src = source
    local Player = TA2Core.Functions.GetPlayer(src)
    if not Player then return end
    exports['ta2-inventory']:RemoveItem(src, benchType, 1, false, 'ta2-crafting:server:removeCraftingTable')
    TriggerClientEvent('ta2-inventory:client:ItemBox', src, TA2Core.Shared.Items[benchType], 'remove')
    TriggerClientEvent('TA2Core:Notify', src, Lang:t('notifications.tablePlace'), 'success')
end)

RegisterNetEvent('ta2-crafting:server:addCraftingTable', function(benchType)
    local src = source
    local Player = TA2Core.Functions.GetPlayer(src)
    if not Player then return end
    if not exports['ta2-inventory']:AddItem(src, benchType, 1, false, false, 'ta2-crafting:server:addCraftingTable') then return end
    TriggerClientEvent('ta2-inventory:client:ItemBox', src, TA2Core.Shared.Items[benchType], 'add')
end)

RegisterNetEvent('ta2-crafting:server:receiveItem', function(craftedItem, requiredItems, amountToCraft, xpGain, xpType)
    local src = source
    local Player = TA2Core.Functions.GetPlayer(src)
    if not Player then return end
    local canGive = true
    for _, requiredItem in ipairs(requiredItems) do
        if not exports['ta2-inventory']:RemoveItem(src, requiredItem.item, requiredItem.amount, false, 'ta2-crafting:server:receiveItem') then
            canGive = false
            return
        end
        TriggerClientEvent('ta2-inventory:client:ItemBox', src, TA2Core.Shared.Items[requiredItem.item], 'remove')
    end
    if canGive then
        if not exports['ta2-inventory']:AddItem(src, craftedItem, amountToCraft, false, false, 'ta2-crafting:server:receiveItem') then return end
        TriggerClientEvent('ta2-inventory:client:ItemBox', src, TA2Core.Shared.Items[craftedItem], 'add')
        TriggerClientEvent('TA2Core:Notify', src, string.format(Lang:t('notifications.craftMessage'), TA2Core.Shared.Items[craftedItem].label), 'success')
        IncreasePlayerXP(src, xpGain, xpType)
    end
end)

-- Items

for benchType, v in pairs(Config) do
    if type(v) == 'table' then
        TA2Core.Functions.CreateUseableItem(benchType, function(source)
            TriggerClientEvent('ta2-crafting:client:useCraftingTable', source, benchType)
        end)
    end
end
