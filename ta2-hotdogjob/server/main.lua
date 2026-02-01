local TA2Core = exports['ta2-core']:GetCoreObject()
local Bail = {}

-- Callbacks

TA2Core.Functions.CreateCallback('ta2-hotdogjob:server:HasMoney', function(source, cb)
    local Player = TA2Core.Functions.GetPlayer(source)

    if Player.PlayerData.money.bank >= Config.StandDeposit then
        Player.Functions.RemoveMoney('bank', Config.StandDeposit, 'hot dog deposit')
        Bail[Player.PlayerData.citizenid] = true
        cb(true)
    else
        Bail[Player.PlayerData.citizenid] = false
        cb(false)
    end
end)

TA2Core.Functions.CreateCallback('ta2-hotdogjob:server:BringBack', function(source, cb)
    local Player = TA2Core.Functions.GetPlayer(source)

    if Bail[Player.PlayerData.citizenid] then
        Player.Functions.AddMoney('bank', Config.StandDeposit, 'hot dog deposit')
        cb(true)
    else
        cb(false)
    end
end)

-- Events

RegisterNetEvent('ta2-hotdogjob:server:Sell', function(coords, amount, price)
    local src = source
    local pCoords = GetEntityCoords(GetPlayerPed(src))
    local Player = TA2Core.Functions.GetPlayer(src)
    if not Player then return end
    if #(pCoords - coords) > 4 then exports['ta2-core']:ExploitBan(src, 'hotdog job') end
    Player.Functions.AddMoney('cash', tonumber(amount * price), 'sold hotdog')
end)

RegisterNetEvent('ta2-hotdogjob:server:UpdateReputation', function(quality)
    local src = source
    local Player = TA2Core.Functions.GetPlayer(src)
    if quality == 'exotic' then
        if Player.Functions.GetRep('hotdog') + 3 > Config.MaxReputation then
            Player.Functions.AddRep('hotdog', Config.MaxReputation - Player.Functions.GetRep('hotdog'))
        else
            Player.Functions.AddRep('hotdog', 3)
        end
    elseif quality == 'rare' then
        if Player.Functions.GetRep('hotdog') + 2 > Config.MaxReputation then
            Player.Functions.AddRep('hotdog', Config.MaxReputation - Player.Functions.GetRep('hotdog'))
        else
            Player.Functions.AddRep('hotdog', 2)
        end
    elseif quality == 'common' then
        if Player.Functions.GetRep('hotdog') + 1 > Config.MaxReputation then
            Player.Functions.AddRep('hotdog', Config.MaxReputation - Player.Functions.GetRep('hotdog'))
        else
            Player.Functions.AddRep('hotdog', 1)
        end
    end

    TriggerClientEvent('ta2-hotdogjob:client:UpdateReputation', src, Player.PlayerData.metadata['rep'])
end)

-- Commands

TA2Core.Commands.Add('removestand', Lang:t('info.command'), {}, false, function(source, _)
    TriggerClientEvent('ta2-hotdogjob:staff:DeletStand', source)
end, 'admin')
