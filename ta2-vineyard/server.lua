local TA2Core = exports['ta2-core']:GetCoreObject()

RegisterNetEvent('ta2-vineyard:server:getGrapes', function()
    local Player = TA2Core.Functions.GetPlayer(source)
    local amount = math.random(Config.GrapeAmount.min, Config.GrapeAmount.max)
    exports['ta2-inventory']:AddItem(source, 'grape', amount, false, false, 'ta2-vineyard:server:getGrapes')
    TriggerClientEvent('ta2-inventory:client:ItemBox', source, TA2Core.Shared.Items['grape'], 'add')
end)

TA2Core.Functions.CreateCallback('ta2-vineyard:server:loadIngredients', function(source, cb)
    local src = source
    local Player = TA2Core.Functions.GetPlayer(src)
    local grape = Player.Functions.GetItemByName('grapejuice')
    if Player.PlayerData.items ~= nil then
        if grape ~= nil then
            if grape.amount >= 23 then
                exports['ta2-inventory']:RemoveItem(src, 'grapejuice', 23, false, 'ta2-vineyard:server:loadIngredients')
                TriggerClientEvent('ta2-inventory:client:ItemBox', source, TA2Core.Shared.Items['grapejuice'], 'remove')
                cb(true)
            else
                TriggerClientEvent('TA2Core:Notify', source, Lang:t('error.invalid_items'), 'error')
                cb(false)
            end
        else
            TriggerClientEvent('TA2Core:Notify', source, Lang:t('error.invalid_items'), 'error')
            cb(false)
        end
    else
        TriggerClientEvent('TA2Core:Notify', source, Lang:t('error.no_items'), 'error')
        cb(false)
    end
end)

TA2Core.Functions.CreateCallback('ta2-vineyard:server:grapeJuice', function(source, cb)
    local src = source
    local Player = TA2Core.Functions.GetPlayer(src)
    local grape = Player.Functions.GetItemByName('grape')
    if Player.PlayerData.items ~= nil then
        if grape ~= nil then
            if grape.amount >= 16 then
                exports['ta2-inventory']:RemoveItem(src, 'grape', 16, false, 'ta2-vineyard:server:grapeJuice')
                TriggerClientEvent('ta2-inventory:client:ItemBox', source, TA2Core.Shared.Items['grape'], 'remove')
                cb(true)
            else
                TriggerClientEvent('TA2Core:Notify', source, Lang:t('error.invalid_items'), 'error')
                cb(false)
            end
        else
            TriggerClientEvent('TA2Core:Notify', source, Lang:t('error.invalid_items'), 'error')
            cb(false)
        end
    else
        TriggerClientEvent('TA2Core:Notify', source, Lang:t('error.no_items'), 'error')
        cb(false)
    end
end)

RegisterNetEvent('ta2-vineyard:server:receiveWine', function()
    local Player = TA2Core.Functions.GetPlayer(tonumber(source))
    local amount = math.random(Config.WineAmount.min, Config.WineAmount.max)
    exports['ta2-inventory']:AddItem(source, 'wine', amount, false, false, 'ta2-vineyard:server:receiveWine')
    TriggerClientEvent('ta2-inventory:client:ItemBox', source, TA2Core.Shared.Items['wine'], 'add')
end)

RegisterNetEvent('ta2-vineyard:server:receiveGrapeJuice', function()
    local Player = TA2Core.Functions.GetPlayer(tonumber(source))
    local amount = math.random(Config.GrapeJuiceAmount.min, Config.GrapeJuiceAmount.max)
    exports['ta2-inventory']:AddItem(source, 'grapejuice', amount, false, false, 'ta2-vineyard:server:receiveGrapeJuice')
    TriggerClientEvent('ta2-inventory:client:ItemBox', source, TA2Core.Shared.Items['grapejuice'], 'add')
end)
