local TA2Core = exports['ta2-core']:GetCoreObject()

RegisterNetEvent('ta2-newsjob:server:addVehicleItems', function(plate)
    local src = source
    local Player = TA2Core.Functions.GetPlayer(src)
    if not Player or Player.PlayerData.job.name ~= 'reporter' then return end
    if not exports['ta2-vehiclekeys']:HasKeys(src, plate) then return end

    exports['ta2-inventory']:CreateInventory('trunk-' .. plate)

    for slot, item in pairs(Config.VehicleItems) do
        exports['ta2-inventory']:AddItem('trunk-' .. plate, item.name, item.amount, slot, item.info, 'ta2-newsjob:vehicleItems')
    end
end)

if Config.UseableItems then
    TA2Core.Functions.CreateUseableItem('newscam', function(source)
        local Player = TA2Core.Functions.GetPlayer(source)
        if not Player or Player.PlayerData.job.name ~= 'reporter' then return end
            
        TriggerClientEvent('Cam:ToggleCam', source)
    end)

    TA2Core.Functions.CreateUseableItem('newsmic', function(source)
        local Player = TA2Core.Functions.GetPlayer(source)
        if not Player or Player.PlayerData.job.name ~= 'reporter' then return end
            
        TriggerClientEvent('Mic:ToggleMic', source)
    end)

    TA2Core.Functions.CreateUseableItem('newsbmic', function(source)
        local Player = TA2Core.Functions.GetPlayer(source)
        if not Player or Player.PlayerData.job.name ~= 'reporter' then return end
            
        TriggerClientEvent('Mic:ToggleBMic', source)
    end)

else
    TA2Core.Commands.Add('newscam', 'Grab a news camera', {}, false, function(source, _)
        local Player = TA2Core.Functions.GetPlayer(source)
        if not Player or Player.PlayerData.job.name ~= 'reporter' then return end

        TriggerClientEvent('Cam:ToggleCam', source)
    end)

    TA2Core.Commands.Add('newsmic', 'Grab a news microphone', {}, false, function(source, _)
        local Player = TA2Core.Functions.GetPlayer(source)
        if not Player or Player.PlayerData.job.name ~= 'reporter' then return end
                
        TriggerClientEvent('Mic:ToggleMic', source)
    end)

    TA2Core.Commands.Add('newsbmic', 'Grab a Boom microphone', {}, false, function(source, _)
        local Player = TA2Core.Functions.GetPlayer(source)
        if not Player or Player.PlayerData.job.name ~= 'reporter' then return end
                
        TriggerClientEvent('Mic:ToggleBMic', source)
    end)
end
