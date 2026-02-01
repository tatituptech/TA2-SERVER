local StolenDrugs = {}

local function getAvailableDrugs(source)
    local AvailableDrugs = {}
    local Player = TA2Core.Functions.GetPlayer(source)

    if not Player then return nil end

    for k in pairs(Config.DrugsPrice) do
        local item = Player.Functions.GetItemByName(k)

        if item then
            AvailableDrugs[#AvailableDrugs + 1] = {
                item = item.name,
                amount = item.amount,
                label = TA2Core.Shared.Items[item.name]['label']
            }
        end
    end
    return table.type(AvailableDrugs) ~= 'empty' and AvailableDrugs or nil
end

TA2Core.Functions.CreateCallback('ta2-drugs:server:cornerselling:getAvailableDrugs', function(source, cb)
    cb(getAvailableDrugs(source))
end)

RegisterNetEvent('ta2-drugs:server:giveStealItems', function(drugType, amount)
    local src = source
    local Player = TA2Core.Functions.GetPlayer(src)
    if not Player or StolenDrugs == {} then return end
    for k, v in pairs(StolenDrugs) do
        if drugType == v.item and amount == v.amount then
            exports['ta2-inventory']:AddItem(src, drugType, amount, false, false, 'ta2-drugs:server:giveStealItems')
            table.remove(StolenDrugs, k)
        end
    end
end)

RegisterNetEvent('ta2-drugs:server:sellCornerDrugs', function(drugType, amount, price)
    local src = source
    local Player = TA2Core.Functions.GetPlayer(src)
    local availableDrugs = getAvailableDrugs(src)
    if not availableDrugs or not Player then return end
    local item = availableDrugs[drugType].item
    local hasItem = Player.Functions.GetItemByName(item)
    if hasItem.amount >= amount then
        TriggerClientEvent('TA2Core:Notify', src, Lang:t('success.offer_accepted'), 'success')
        exports['ta2-inventory']:RemoveItem(src, item, amount, false, 'ta2-drugs:server:sellCornerDrugs')
        Player.Functions.AddMoney('cash', price, 'ta2-drugs:server:sellCornerDrugs')
        TriggerClientEvent('ta2-inventory:client:ItemBox', src, TA2Core.Shared.Items[item], 'remove')
        TriggerClientEvent('ta2-drugs:client:refreshAvailableDrugs', src, getAvailableDrugs(src))
    else
        TriggerClientEvent('ta2-drugs:client:cornerselling', src)
    end
end)

RegisterNetEvent('ta2-drugs:server:robCornerDrugs', function(drugType, amount)
    local src = source
    local Player = TA2Core.Functions.GetPlayer(src)
    local availableDrugs = getAvailableDrugs(src)
    if not availableDrugs or not Player then return end
    local item = availableDrugs[drugType].item
    exports['ta2-inventory']:RemoveItem(src, item, amount, false, 'ta2-drugs:server:robCornerDrugs')
    table.insert(StolenDrugs, { item = item, amount = amount })
    TriggerClientEvent('ta2-inventory:client:ItemBox', src, TA2Core.Shared.Items[item], 'remove')
    TriggerClientEvent('ta2-drugs:client:refreshAvailableDrugs', src, getAvailableDrugs(src))
end)
