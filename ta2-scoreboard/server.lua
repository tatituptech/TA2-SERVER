local TA2Core = exports['ta2-core']:GetCoreObject()

TA2Core.Functions.CreateCallback('ta2-scoreboard:server:GetScoreboardData', function(_, cb)
    local totalPlayers = 0
    local policeCount = 0
    local players = {}
    for _, v in pairs(TA2Core.Functions.GetQBPlayers()) do
        if v then
            totalPlayers += 1
            if v.PlayerData.job.name == 'police' and v.PlayerData.job.onduty then
                policeCount += 1
            end
            players[v.PlayerData.source] = {}
            players[v.PlayerData.source].optin = TA2Core.Functions.IsOptin(v.PlayerData.source)
        end
    end
    cb(totalPlayers, policeCount, players)
end)

RegisterNetEvent('ta2-scoreboard:server:SetActivityBusy', function(activity, bool)
    Config.IllegalActions[activity].busy = bool
    TriggerClientEvent('ta2-scoreboard:client:SetActivityBusy', -1, activity, bool)
end)
