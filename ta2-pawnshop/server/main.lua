local TA2Core = exports['ta2-core']:GetCoreObject()

local function exploitBan(id, reason)
    MySQL.insert('INSERT INTO bans (name, license, discord, ip, reason, expire, bannedby) VALUES (?, ?, ?, ?, ?, ?, ?)',
        {
            GetPlayerName(id),
            TA2Core.Functions.GetIdentifier(id, 'license'),
            TA2Core.Functions.GetIdentifier(id, 'discord'),
            TA2Core.Functions.GetIdentifier(id, 'ip'),
            reason,
            2147483647,
            'ta2-pawnshop'
        })
    TriggerEvent('ta2-log:server:CreateLog', 'pawnshop', 'Player Banned', 'red',
        string.format('%s was banned by %s for %s', GetPlayerName(id), 'ta2-pawnshop', reason), true)
    DropPlayer(id, 'You were permanently banned by the server for: Exploiting')
end

RegisterNetEvent('ta2-pawnshop:server:sellPawnItems', function(itemName, itemAmount, itemPrice)
    local src = source
    local Player = TA2Core.Functions.GetPlayer(src)
    local totalPrice = (tonumber(itemAmount) * itemPrice)
    local playerCoords = GetEntityCoords(GetPlayerPed(src))
    local dist
    for _, value in pairs(Config.PawnLocation) do
        dist = #(playerCoords - value.coords)
        if #(playerCoords - value.coords) < 2 then
            dist = #(playerCoords - value.coords)
            break
        end
    end
    if dist > 5 then
        exploitBan(src, 'sellPawnItems Exploiting')
        return
    end
    if exports['ta2-inventory']:RemoveItem(src, itemName, tonumber(itemAmount), false, 'ta2-pawnshop:server:sellPawnItems') then
        if Config.BankMoney then
            Player.Functions.AddMoney('bank', totalPrice, 'ta2-pawnshop:server:sellPawnItems')
        else
            Player.Functions.AddMoney('cash', totalPrice, 'ta2-pawnshop:server:sellPawnItems')
        end
        TriggerClientEvent('TA2Core:Notify', src, Lang:t('success.sold', { value = tonumber(itemAmount), value2 = TA2Core.Shared.Items[itemName].label, value3 = totalPrice }), 'success')
        TriggerClientEvent('ta2-inventory:client:ItemBox', src, TA2Core.Shared.Items[itemName], 'remove')
    else
        TriggerClientEvent('TA2Core:Notify', src, Lang:t('error.no_items'), 'error')
    end
    TriggerClientEvent('ta2-pawnshop:client:openMenu', src)
end)

RegisterNetEvent('ta2-pawnshop:server:meltItemRemove', function(itemName, itemAmount, item)
    local src = source
    local Player = TA2Core.Functions.GetPlayer(src)
    if exports['ta2-inventory']:RemoveItem(src, itemName, itemAmount, false, 'ta2-pawnshop:server:meltItemRemove') then
        TriggerClientEvent('ta2-inventory:client:ItemBox', src, TA2Core.Shared.Items[itemName], 'remove')
        local meltTime = (tonumber(itemAmount) * item.time)
        TriggerClientEvent('ta2-pawnshop:client:startMelting', src, item, tonumber(itemAmount), (meltTime * 60000 / 1000))
        TriggerClientEvent('TA2Core:Notify', src, Lang:t('info.melt_wait', { value = meltTime }), 'primary')
    else
        TriggerClientEvent('TA2Core:Notify', src, Lang:t('error.no_items'), 'error')
    end
end)

RegisterNetEvent('ta2-pawnshop:server:pickupMelted', function(item)
    local src = source
    local Player = TA2Core.Functions.GetPlayer(src)
    local playerCoords = GetEntityCoords(GetPlayerPed(src))
    local dist
    for _, value in pairs(Config.PawnLocation) do
        dist = #(playerCoords - value.coords)
        if #(playerCoords - value.coords) < 2 then
            dist = #(playerCoords - value.coords)
            break
        end
    end
    if dist > 5 then
        exploitBan(src, 'pickupMelted Exploiting')
        return
    end
    for _, v in pairs(item.items) do
        local meltedAmount = v.amount
        for _, m in pairs(v.item.reward) do
            local rewardAmount = m.amount
            if exports['ta2-inventory']:AddItem(src, m.item, (meltedAmount * rewardAmount), false, false, 'ta2-pawnshop:server:pickupMelted') then
                TriggerClientEvent('ta2-inventory:client:ItemBox', src, TA2Core.Shared.Items[m.item], 'add')
                TriggerClientEvent('TA2Core:Notify', src, Lang:t('success.items_received', { value = (meltedAmount * rewardAmount), value2 = TA2Core.Shared.Items[m.item].label }), 'success')
                TriggerClientEvent('ta2-pawnshop:client:resetPickup', src)
            else
                TriggerClientEvent('TA2Core:Notify', src, Lang:t('error.inventory_full', { value = TA2Core.Shared.Items[m.item].label }), 'warning', 7500)
            end
        end
    end
    TriggerClientEvent('ta2-pawnshop:client:openMenu', src)
end)

TA2Core.Functions.CreateCallback('ta2-pawnshop:server:getInv', function(source, cb)
    local Player = TA2Core.Functions.GetPlayer(source)
    local inventory = Player.PlayerData.items
    return cb(inventory)
end)
