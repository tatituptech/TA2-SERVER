local function DnaHash(s)
    local h = string.gsub(s, '.', function(c)
        return string.format('%02x', string.byte(c))
    end)
    return h
end

-- License

TA2Core.Commands.Add('grantlicense', Lang:t('commands.license_grant'), { { name = 'id', help = Lang:t('info.player_id') }, { name = 'license', help = Lang:t('info.license_type') } }, true, function(source, args)
    local src = source
    local Player = TA2Core.Functions.GetPlayer(src)
    if Player.PlayerData.job.type == 'leo' and Player.PlayerData.job.grade.level >= Config.LicenseRank then
        if args[2] == 'driver' or args[2] == 'weapon' then
            local SearchedPlayer = TA2Core.Functions.GetPlayer(tonumber(args[1]))
            if not SearchedPlayer then return end
            local licenseTable = SearchedPlayer.PlayerData.metadata['licences']
            if licenseTable[args[2]] then
                TriggerClientEvent('TA2Core:Notify', src, Lang:t('error.license_already'), 'error')
                return
            end
            licenseTable[args[2]] = true
            SearchedPlayer.Functions.SetMetaData('licences', licenseTable)
            TriggerClientEvent('TA2Core:Notify', SearchedPlayer.PlayerData.source, Lang:t('success.granted_license'), 'success')
            TriggerClientEvent('TA2Core:Notify', src, Lang:t('success.grant_license'), 'success')
        else
            TriggerClientEvent('TA2Core:Notify', src, Lang:t('error.error_license_type'), 'error')
        end
    else
        TriggerClientEvent('TA2Core:Notify', src, Lang:t('error.rank_license'), 'error')
    end
end)

TA2Core.Commands.Add('revokelicense', Lang:t('commands.license_revoke'), { { name = 'id', help = Lang:t('info.player_id') }, { name = 'license', help = Lang:t('info.license_type') } }, true, function(source, args)
    local src = source
    local Player = TA2Core.Functions.GetPlayer(src)
    if Player.PlayerData.job.type == 'leo' and Player.PlayerData.job.grade.level >= Config.LicenseRank then
        if args[2] == 'driver' or args[2] == 'weapon' then
            local SearchedPlayer = TA2Core.Functions.GetPlayer(tonumber(args[1]))
            if not SearchedPlayer then return end
            local licenseTable = SearchedPlayer.PlayerData.metadata['licences']
            if not licenseTable[args[2]] then
                TriggerClientEvent('TA2Core:Notify', src, Lang:t('error.error_license'), 'error')
                return
            end
            licenseTable[args[2]] = false
            SearchedPlayer.Functions.SetMetaData('licences', licenseTable)
            TriggerClientEvent('TA2Core:Notify', SearchedPlayer.PlayerData.source, Lang:t('error.revoked_license'), 'error')
            TriggerClientEvent('TA2Core:Notify', src, Lang:t('success.revoke_license'), 'success')
        else
            TriggerClientEvent('TA2Core:Notify', src, Lang:t('error.error_license'), 'error')
        end
    else
        TriggerClientEvent('TA2Core:Notify', src, Lang:t('error.rank_revoke'), 'error')
    end
end)

TA2Core.Commands.Add('takedrivinglicense', Lang:t('commands.drivinglicense'), {}, false, function(source)
    local src = source
    local Player = TA2Core.Functions.GetPlayer(src)
    if Player.PlayerData.job.type == 'leo' and Player.PlayerData.job.onduty then
        TriggerClientEvent('police:client:SeizeDriverLicense', source)
    else
        TriggerClientEvent('TA2Core:Notify', src, Lang:t('error.on_duty_police_only'), 'error')
    end
end)

-- Objects

TA2Core.Commands.Add('spikestrip', Lang:t('commands.place_spike'), {}, false, function(source)
    local src = source
    local Player = TA2Core.Functions.GetPlayer(src)
    if Player.PlayerData.job.type == 'leo' and Player.PlayerData.job.onduty then
        TriggerClientEvent('police:client:SpawnSpikeStrip', src)
    end
end)

TA2Core.Commands.Add('pobject', Lang:t('commands.place_object'), { { name = 'type', help = Lang:t('info.poobject_object') } }, true, function(source, args)
    local src = source
    local Player = TA2Core.Functions.GetPlayer(src)
    local type = args[1]:lower()
    if Player.PlayerData.job.type == 'leo' and Player.PlayerData.job.onduty then
        if type == 'cone' then
            TriggerClientEvent('police:client:spawnCone', src)
        elseif type == 'barrier' then
            TriggerClientEvent('police:client:spawnBarrier', src)
        elseif type == 'roadsign' then
            TriggerClientEvent('police:client:spawnRoadSign', src)
        elseif type == 'tent' then
            TriggerClientEvent('police:client:spawnTent', src)
        elseif type == 'light' then
            TriggerClientEvent('police:client:spawnLight', src)
        elseif type == 'delete' then
            TriggerClientEvent('police:client:deleteObject', src)
        end
    else
        TriggerClientEvent('TA2Core:Notify', src, Lang:t('error.on_duty_police_only'), 'error')
    end
end)

-- Interaction

TA2Core.Commands.Add('cuff', Lang:t('commands.cuff_player'), {}, false, function(source)
    local src = source
    local Player = TA2Core.Functions.GetPlayer(src)
    if Player.PlayerData.job.type == 'leo' and Player.PlayerData.job.onduty then
        TriggerClientEvent('police:client:CuffPlayer', src)
    else
        TriggerClientEvent('TA2Core:Notify', src, Lang:t('error.on_duty_police_only'), 'error')
    end
end)

TA2Core.Commands.Add('escort', Lang:t('commands.escort'), {}, false, function(source)
    local src = source
    TriggerClientEvent('police:client:EscortPlayer', src)
end)

TA2Core.Commands.Add('callsign', Lang:t('commands.callsign'), { { name = 'name', help = Lang:t('info.callsign_name') } }, false, function(source, args)
    local src = source
    local Player = TA2Core.Functions.GetPlayer(src)
    Player.Functions.SetMetaData('callsign', table.concat(args, ' '))
end)

TA2Core.Commands.Add('jail', Lang:t('commands.jail_player'), {}, false, function(source)
    local src = source
    local Player = TA2Core.Functions.GetPlayer(src)
    if Player.PlayerData.job.type == 'leo' and Player.PlayerData.job.onduty then
        TriggerClientEvent('police:client:JailPlayer', src)
    else
        TriggerClientEvent('TA2Core:Notify', src, Lang:t('error.on_duty_police_only'), 'error')
    end
end)

TA2Core.Commands.Add('unjail', Lang:t('commands.unjail_player'), { { name = 'id', help = Lang:t('info.player_id') } }, true, function(source, args)
    local src = source
    local Player = TA2Core.Functions.GetPlayer(src)
    if Player.PlayerData.job.type == 'leo' and Player.PlayerData.job.onduty then
        local targetId = tonumber(args[1])
        TriggerClientEvent('prison:client:UnjailPerson', targetId)
    else
        TriggerClientEvent('TA2Core:Notify', src, Lang:t('error.on_duty_police_only'), 'error')
    end
end)

TA2Core.Commands.Add('seizecash', Lang:t('commands.seizecash'), {}, false, function(source)
    local src = source
    local Player = TA2Core.Functions.GetPlayer(src)
    if Player.PlayerData.job.type == 'leo' and Player.PlayerData.job.onduty then
        TriggerClientEvent('police:client:SeizeCash', src)
    else
        TriggerClientEvent('TA2Core:Notify', src, Lang:t('error.on_duty_police_only'), 'error')
    end
end)

TA2Core.Commands.Add('sc', Lang:t('commands.softcuff'), {}, false, function(source)
    local src = source
    local Player = TA2Core.Functions.GetPlayer(src)
    if Player.PlayerData.job.type == 'leo' and Player.PlayerData.job.onduty then
        TriggerClientEvent('police:client:CuffPlayerSoft', src)
    else
        TriggerClientEvent('TA2Core:Notify', src, Lang:t('error.on_duty_police_only'), 'error')
    end
end)

TA2Core.Commands.Add('fine', Lang:t('commands.fine'), { { name = 'id', help = Lang:t('info.player_id') }, { name = 'amount', help = Lang:t('info.amount') } }, false, function(source, args)
    local biller = TA2Core.Functions.GetPlayer(source)
    local billed = TA2Core.Functions.GetPlayer(tonumber(args[1]))
    local amount = tonumber(args[2])

    if biller.PlayerData.job.type ~= 'leo' then
        TriggerClientEvent('TA2Core:Notify', source, Lang:t('error.on_duty_police_only'), 'error')
        return
    end

    if not billed then
        TriggerClientEvent('TA2Core:Notify', source, Lang:t('error.not_online'), 'error')
        return
    end

    if biller.PlayerData.citizenid == billed.PlayerData.citizenid then
        TriggerClientEvent('TA2Core:Notify', source, Lang:t('error.fine_yourself'), 'error')
        return
    end

    if amount <= 0 then
        TriggerClientEvent('TA2Core:Notify', source, Lang:t('error.amount_higher'), 'error')
        return
    end

    if billed.Functions.RemoveMoney('bank', amount, 'paid-fine') then
        TriggerClientEvent('TA2Core:Notify', source, Lang:t('info.fine_issued'), 'success')
        TriggerClientEvent('TA2Core:Notify', billed.PlayerData.source, Lang:t('info.received_fine'))
        exports['ta2-banking']:AddMoney(biller.PlayerData.job.name, amount, 'Fine')
    elseif billed.Functions.RemoveMoney('cash', amount, 'paid-fine') then
        TriggerClientEvent('TA2Core:Notify', source, Lang:t('info.fine_issued'), 'success')
        TriggerClientEvent('TA2Core:Notify', billed.PlayerData.source, Lang:t('info.received_fine'))
        exports['ta2-banking']:AddMoney(biller.PlayerData.job.name, amount, 'Fine')
    else
        MySQL.Async.insert('INSERT INTO phone_invoices (citizenid, amount, society, sender, sendercitizenid) VALUES (?, ?, ?, ?, ?)', { billed.PlayerData.citizenid, amount, biller.PlayerData.job.name, biller.PlayerData.charinfo.firstname, biller.PlayerData.citizenid }, function(id)
            if id then
                TriggerClientEvent('ta2-phone:client:AcceptorDenyInvoice', billed.PlayerData.source, id, biller.PlayerData.charinfo.firstname, biller.PlayerData.job.name, biller.PlayerData.citizenid, amount, GetInvokingResource())
            end
        end)
        TriggerClientEvent('ta2-phone:RefreshPhone', billed.PlayerData.source)
    end
end)

-- Evidence

TA2Core.Commands.Add('clearcasings', Lang:t('commands.clear_casign'), {}, false, function(source)
    local src = source
    local Player = TA2Core.Functions.GetPlayer(src)
    if Player.PlayerData.job.type == 'leo' and Player.PlayerData.job.onduty then
        TriggerClientEvent('evidence:client:ClearCasingsInArea', src)
    else
        TriggerClientEvent('TA2Core:Notify', src, Lang:t('error.on_duty_police_only'), 'error')
    end
end)

TA2Core.Commands.Add('clearblood', Lang:t('commands.clearblood'), {}, false, function(source)
    local src = source
    local Player = TA2Core.Functions.GetPlayer(src)
    if Player.PlayerData.job.type == 'leo' and Player.PlayerData.job.onduty then
        TriggerClientEvent('evidence:client:ClearBlooddropsInArea', src)
    else
        TriggerClientEvent('TA2Core:Notify', src, Lang:t('error.on_duty_police_only'), 'error')
    end
end)

TA2Core.Commands.Add('takedna', Lang:t('commands.takedna'), { { name = 'id', help = Lang:t('info.player_id') } }, true, function(source, args)
    local src = source
    local Player = TA2Core.Functions.GetPlayer(src)
    local OtherPlayer = TA2Core.Functions.GetPlayer(tonumber(args[1]))
    if not OtherPlayer or Player.PlayerData.job.type ~= 'leo' or not Player.PlayerData.job.onduty then return end
    if exports['ta2-inventory']:RemoveItem(src, 'empty_evidence_bag', 1, false, 'ta2-policejob:takedna') then
        local info = {
            label = Lang:t('info.dna_sample'),
            type = 'dna',
            dnalabel = DnaHash(OtherPlayer.PlayerData.citizenid)
        }
        if not exports['ta2-inventory']:AddItem(src, 'filled_evidence_bag', 1, false, info, 'ta2-policejob:takedna') then return end
        TriggerClientEvent('ta2-inventory:client:ItemBox', src, TA2Core.Shared.Items['filled_evidence_bag'], 'add')
    else
        TriggerClientEvent('TA2Core:Notify', src, Lang:t('error.have_evidence_bag'), 'error')
    end
end)

TA2Core.Commands.Add('anklet', Lang:t('commands.anklet'), {}, false, function(source)
    local src = source
    local Player = TA2Core.Functions.GetPlayer(src)
    if Player.PlayerData.job.type == 'leo' and Player.PlayerData.job.onduty then
        TriggerClientEvent('police:client:CheckDistance', src)
    else
        TriggerClientEvent('TA2Core:Notify', src, Lang:t('error.on_duty_police_only'), 'error')
    end
end)

TA2Core.Commands.Add('ankletlocation', Lang:t('commands.ankletlocation'), { { name = 'cid', help = Lang:t('info.citizen_id') } }, true, function(source, args)
    local src = source
    local Player = TA2Core.Functions.GetPlayer(src)
    if Player.PlayerData.job.type == 'leo' and Player.PlayerData.job.onduty then
        local citizenid = args[1]
        local Target = TA2Core.Functions.GetPlayerByCitizenId(citizenid)
        if not Target then return end
        if Target.PlayerData.metadata['tracker'] then
            TriggerClientEvent('police:client:SendTrackerLocation', Target.PlayerData.source, src)
        else
            TriggerClientEvent('TA2Core:Notify', src, Lang:t('error.no_anklet'), 'error')
        end
    else
        TriggerClientEvent('TA2Core:Notify', src, Lang:t('error.on_duty_police_only'), 'error')
    end
end)

-- Vehicle

TA2Core.Commands.Add('depot', Lang:t('commands.depot'), { { name = 'price', help = Lang:t('info.impound_price') } }, false, function(source, args)
    local src = source
    local Player = TA2Core.Functions.GetPlayer(src)
    if Player.PlayerData.job.type == 'leo' and Player.PlayerData.job.onduty then
        TriggerClientEvent('police:client:ImpoundVehicle', src, false, tonumber(args[1]))
    else
        TriggerClientEvent('TA2Core:Notify', src, Lang:t('error.on_duty_police_only'), 'error')
    end
end)

TA2Core.Commands.Add('impound', Lang:t('commands.impound'), {}, false, function(source)
    local src = source
    local Player = TA2Core.Functions.GetPlayer(src)
    if Player.PlayerData.job.type == 'leo' and Player.PlayerData.job.onduty then
        TriggerClientEvent('police:client:ImpoundVehicle', src, true)
    else
        TriggerClientEvent('TA2Core:Notify', src, Lang:t('error.on_duty_police_only'), 'error')
    end
end)

-- Misc

TA2Core.Commands.Add('cam', Lang:t('commands.camera'), { { name = 'camid', help = Lang:t('info.camera_id') } }, false, function(source, args)
    local src = source
    local Player = TA2Core.Functions.GetPlayer(src)
    if Player.PlayerData.job.type == 'leo' and Player.PlayerData.job.onduty then
        TriggerClientEvent('police:client:ActiveCamera', src, tonumber(args[1]))
    else
        TriggerClientEvent('TA2Core:Notify', src, Lang:t('error.on_duty_police_only'), 'error')
    end
end)

TA2Core.Commands.Add('paytow', Lang:t('commands.paytow'), { { name = 'id', help = Lang:t('info.player_id') } }, true, function(source, args)
    local src = source
    local Player = TA2Core.Functions.GetPlayer(src)
    if Player.PlayerData.job.type == 'leo' and Player.PlayerData.job.onduty then
        local playerId = tonumber(args[1])
        local OtherPlayer = TA2Core.Functions.GetPlayer(playerId)
        if OtherPlayer then
            if OtherPlayer.PlayerData.job.name == 'tow' then
                OtherPlayer.Functions.AddMoney('bank', 500, 'police-tow-paid')
                TriggerClientEvent('TA2Core:Notify', OtherPlayer.PlayerData.source, Lang:t('success.tow_paid'), 'success')
                TriggerClientEvent('TA2Core:Notify', src, Lang:t('info.tow_driver_paid'))
            else
                TriggerClientEvent('TA2Core:Notify', src, Lang:t('error.not_towdriver'), 'error')
            end
        end
    else
        TriggerClientEvent('TA2Core:Notify', src, Lang:t('error.on_duty_police_only'), 'error')
    end
end)

TA2Core.Commands.Add('paylawyer', Lang:t('commands.paylawyer'), { { name = 'id', help = Lang:t('info.player_id') } }, true, function(source, args)
    local src = source
    local Player = TA2Core.Functions.GetPlayer(src)
    if Player.PlayerData.job.type == 'leo' or Player.PlayerData.job.name == 'judge' then
        local playerId = tonumber(args[1])
        local OtherPlayer = TA2Core.Functions.GetPlayer(playerId)
        if not OtherPlayer then return end
        if OtherPlayer.PlayerData.job.name == 'lawyer' then
            OtherPlayer.Functions.AddMoney('bank', 500, 'police-lawyer-paid')
            TriggerClientEvent('TA2Core:Notify', OtherPlayer.PlayerData.source, Lang:t('success.tow_paid'), 'success')
            TriggerClientEvent('TA2Core:Notify', src, Lang:t('info.paid_lawyer'))
        else
            TriggerClientEvent('TA2Core:Notify', src, Lang:t('error.not_lawyer'), 'error')
        end
    else
        TriggerClientEvent('TA2Core:Notify', src, Lang:t('error.on_duty_police_only'), 'error')
    end
end)

TA2Core.Commands.Add('911p', Lang:t('commands.police_report'), { { name = 'message', help = Lang:t('commands.message_sent') } }, false, function(source, args)
    local src = source
    local message
    if args[1] then message = table.concat(args, ' ') else message = Lang:t('commands.civilian_call') end
    local ped = GetPlayerPed(src)
    local coords = GetEntityCoords(ped)
    local players = TA2Core.Functions.GetQBPlayers()
    for _, v in pairs(players) do
        if v and v.PlayerData.job.type == 'leo' and v.PlayerData.job.onduty then
            local alertData = { title = Lang:t('commands.emergency_call'), coords = { x = coords.x, y = coords.y, z = coords.z }, description = message }
            TriggerClientEvent('ta2-phone:client:addPoliceAlert', v.PlayerData.source, alertData)
            TriggerClientEvent('police:client:policeAlert', v.PlayerData.source, coords, message)
        end
    end
end)
