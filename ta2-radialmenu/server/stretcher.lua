RegisterNetEvent('ta2-radialmenu:server:RemoveStretcher', function(pos, stretcherObject)
    TriggerClientEvent('ta2-radialmenu:client:RemoveStretcherFromArea', -1, pos, stretcherObject)
end)

RegisterNetEvent('ta2-radialmenu:Stretcher:BusyCheck', function(target, type)
    local src = source
    if not IsCloseToTarget(src, target) then return end
    TriggerClientEvent('ta2-radialmenu:Stretcher:client:BusyCheck', target, source, type)
end)

RegisterNetEvent('ta2-radialmenu:server:BusyResult', function(isBusy, target, type)
    local src = source
    if not IsCloseToTarget(src, target) then return end
    TriggerClientEvent('ta2-radialmenu:client:Result', target, isBusy, type)
end)
