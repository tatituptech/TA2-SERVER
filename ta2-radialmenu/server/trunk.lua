local TA2Core = exports['ta2-core']:GetCoreObject()
local trunkBusy = {}

function IsCloseToTarget(source, target)
    if not DoesPlayerExist(target) then return false end
    return #(GetEntityCoords(GetPlayerPed(source)) - GetEntityCoords(GetPlayerPed(target))) < 2.0
end

RegisterNetEvent('ta2-radialmenu:trunk:server:Door', function(open, plate, door)
    TriggerClientEvent('ta2-radialmenu:trunk:client:Door', -1, plate, door, open)
end)

RegisterNetEvent('ta2-trunk:server:setTrunkBusy', function(plate, busy)
    trunkBusy[plate] = busy
end)

RegisterNetEvent('ta2-trunk:server:KidnapTrunk', function(target, closestVehicle)
    local src = source
    if not IsCloseToTarget(src, target) then return end
    TriggerClientEvent('ta2-trunk:client:KidnapGetIn', target, closestVehicle)
end)

TA2Core.Functions.CreateCallback('ta2-trunk:server:getTrunkBusy', function(_, cb, plate)
    if trunkBusy[plate] then
        cb(true)
        return
    end
    cb(false)
end)

TA2Core.Commands.Add('getintrunk', Lang:t('general.getintrunk_command_desc'), {}, false, function(source)
    TriggerClientEvent('ta2-trunk:client:GetIn', source)
end)

TA2Core.Commands.Add('putintrunk', Lang:t('general.putintrunk_command_desc'), {}, false, function(source)
    TriggerClientEvent('ta2-trunk:server:KidnapTrunk', source)
end)
