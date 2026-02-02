local PlayerInjuries = {}
local PlayerWeaponWounds = {}
local TA2Core = exports['ta2-core']:GetCoreObject()
local doctorCount = 0
local doctorCalled = false
local Doctors = {}

-- Events

-- Compatibility with txAdmin Menu's heal options.
-- This is an admin only server side event that will pass the target player id or -1.
AddEventHandler('txAdmin:events:healedPlayer', function(eventData)
	if GetInvokingResource() ~= 'monitor' or type(eventData) ~= 'table' or type(eventData.id) ~= 'number' then
		return
	end

	TriggerClientEvent('hospital:client:Revive', eventData.id)
	TriggerClientEvent('hospital:client:HealInjuries', eventData.id, 'full')
end)

RegisterNetEvent('hospital:server:SendToBed', function(bedId, isRevive, hospitalIndex)
	local src = source
	local Player = TA2Core.Functions.GetPlayer(src)
	TriggerClientEvent('hospital:client:SendToBed', src, bedId, Config.Locations['hospital'][hospitalIndex]['beds'][bedId], isRevive)
	TriggerClientEvent('hospital:client:SetBed', -1, bedId, true, hospitalIndex)
	Player.Functions.RemoveMoney('bank', Config.BillCost, 'respawned-at-hospital')
	exports['ta2-banking']:AddMoney('ambulance', Config.BillCost, 'Player treatment')
	TriggerClientEvent('hospital:client:SendBillEmail', src, Config.BillCost, Config.Locations['hospital'][hospitalIndex]['name'])
end)

RegisterNetEvent('hospital:server:RespawnAtHospital', function(hospitalIndex)
	local src = source
	local Player = TA2Core.Functions.GetPlayer(src)
	if Player.PlayerData.metadata['injail'] > 0 then
		for i = 1, #Config.Locations['jailbeds'] do
			local v = Config.Locations['jailbeds'][i]
			if not v.taken then
				TriggerClientEvent('hospital:client:SendToBed', src, i, v, true)
				TriggerClientEvent('hospital:client:SetBed2', -1, i, true)
				if Config.WipeInventoryOnRespawn then
					Player.Functions.ClearInventory()
					MySQL.Async.execute('UPDATE players SET inventory = ? WHERE citizenid = ?', { json.encode({}), Player.PlayerData.citizenid })
					TriggerClientEvent('TA2Core:Notify', src, Lang:t('error.possessions_taken'), 'error')
				end
				Player.Functions.RemoveMoney('bank', Config.BillCost, 'respawned-at-hospital')
				exports['ta2-banking']:AddMoney('ambulance', Config.BillCost, 'Player treatment')
				TriggerClientEvent('hospital:client:SendBillEmail', src, Config.BillCost)
				return
			end
		end

		TriggerClientEvent('hospital:client:SendToBed', src, 1, Config.Locations['jailbeds'][1], true)
		TriggerClientEvent('hospital:client:SetBed', -1, 1, true)
		if Config.WipeInventoryOnRespawn then
			Player.Functions.ClearInventory()
			MySQL.Async.execute('UPDATE players SET inventory = ? WHERE citizenid = ?', { json.encode({}), Player.PlayerData.citizenid })
			TriggerClientEvent('TA2Core:Notify', src, Lang:t('error.possessions_taken'), 'error')
		end
		Player.Functions.RemoveMoney('bank', Config.BillCost, 'respawned-at-hospital')
		exports['ta2-banking']:AddMoney('ambulance', Config.BillCost, 'Player treatment')
		TriggerClientEvent('hospital:client:SendBillEmail', src, Config.BillCost)
	else
		for i = 1, #Config.Locations['hospital'][hospitalIndex]['beds'] do
			local v = Config.Locations['hospital'][hospitalIndex]['beds'][i]
			if not v.taken then
				TriggerClientEvent('hospital:client:SendToBed', src, i, v, true)
				TriggerClientEvent('hospital:client:SetBed', -1, i, true, hospitalIndex)
				if Config.WipeInventoryOnRespawn then
					Player.Functions.ClearInventory()
					MySQL.update('UPDATE players SET inventory = ? WHERE citizenid = ?', { json.encode({}), Player.PlayerData.citizenid })
					TriggerClientEvent('TA2Core:Notify', src, Lang:t('error.possessions_taken'), 'error')
				end
				Player.Functions.RemoveMoney('bank', Config.BillCost, 'respawned-at-hospital')
				exports['ta2-banking']:AddMoney('ambulance', Config.BillCost, 'Player treatment')
				TriggerClientEvent('hospital:client:SendBillEmail', src, Config.BillCost, Config.Locations['hospital'][hospitalIndex]['name'])
				return
			end
		end
		-- All beds were full, placing in first bed as fallback
		TriggerClientEvent('hospital:client:SendToBed', src, 1, Config.Locations['hospital'][hospitalIndex]['beds'][1], true)
		TriggerClientEvent('hospital:client:SetBed', -1, 1, true, hospitalIndex)
		if Config.WipeInventoryOnRespawn then
			Player.Functions.ClearInventory()
			MySQL.update('UPDATE players SET inventory = ? WHERE citizenid = ?', { json.encode({}), Player.PlayerData.citizenid })
			TriggerClientEvent('TA2Core:Notify', src, Lang:t('error.possessions_taken'), 'error')
		end
		Player.Functions.RemoveMoney('bank', Config.BillCost, 'respawned-at-hospital')
		exports['ta2-banking']:AddMoney('ambulance', Config.BillCost, 'Player treatment')
		TriggerClientEvent('hospital:client:SendBillEmail', src, Config.BillCost, Config.Locations['hospital'][hospitalIndex]['name'])
	end
end)

RegisterNetEvent('hospital:server:ambulanceAlert', function(text)
	local src = source
	local ped = GetPlayerPed(src)
	local coords = GetEntityCoords(ped)
	local players = TA2Core.Functions.GetQBPlayers()
	for _, v in pairs(players) do
		if v.PlayerData.job.name == 'ambulance' and v.PlayerData.job.onduty then
			TriggerClientEvent('hospital:client:ambulanceAlert', v.PlayerData.source, coords, text)
		end
	end
end)

RegisterNetEvent('hospital:server:LeaveBed', function(id, hospitalIndex)
	TriggerClientEvent('hospital:client:SetBed', -1, id, false, hospitalIndex)
end)

RegisterNetEvent('hospital:server:SyncInjuries', function(data)
	local src = source
	PlayerInjuries[src] = data
end)

RegisterNetEvent('hospital:server:SetWeaponDamage', function(data)
	local src = source
	local Player = TA2Core.Functions.GetPlayer(src)
	if Player then
		PlayerWeaponWounds[Player.PlayerData.source] = data
	end
end)

RegisterNetEvent('hospital:server:RestoreWeaponDamage', function()
	local src = source
	local Player = TA2Core.Functions.GetPlayer(src)
	PlayerWeaponWounds[Player.PlayerData.source] = nil
end)

RegisterNetEvent('hospital:server:SetDeathStatus', function(isDead)
	local src = source
	local Player = TA2Core.Functions.GetPlayer(src)
	if Player then
		Player.Functions.SetMetaData('isdead', isDead)
	end
end)

RegisterNetEvent('hospital:server:SetLaststandStatus', function(bool)
	local src = source
	local Player = TA2Core.Functions.GetPlayer(src)
	if Player then
		Player.Functions.SetMetaData('inlaststand', bool)
	end
end)

RegisterNetEvent('hospital:server:SetArmor', function(amount)
	local src = source
	local Player = TA2Core.Functions.GetPlayer(src)
	if Player then
		Player.Functions.SetMetaData('armor', amount)
	end
end)

RegisterNetEvent('hospital:server:TreatWounds', function(playerId)
	local src = source
	local Player = TA2Core.Functions.GetPlayer(src)
	local Patient = TA2Core.Functions.GetPlayer(playerId)
	if Patient then
		if Player.PlayerData.job.name == 'ambulance' then
			exports['ta2-inventory']:RemoveItem(src, 'bandage', 1, false, 'hospital:server:TreatWounds')
			TriggerClientEvent('ta2-inventory:client:ItemBox', src, TA2Core.Shared.Items['bandage'], 'remove')
			TriggerClientEvent('hospital:client:HealInjuries', Patient.PlayerData.source, 'full')
		end
	end
end)

RegisterNetEvent('hospital:server:AddDoctor', function(job)
	if job == 'ambulance' then
		local src = source
		doctorCount = doctorCount + 1
		TriggerClientEvent('hospital:client:SetDoctorCount', -1, doctorCount)
		Doctors[src] = true
	end
end)

RegisterNetEvent('hospital:server:RemoveDoctor', function(job)
	if job == 'ambulance' then
		local src = source
		doctorCount = doctorCount - 1
		TriggerClientEvent('hospital:client:SetDoctorCount', -1, doctorCount)
		Doctors[src] = nil
	end
end)

AddEventHandler('playerDropped', function()
	local src = source
	if Doctors[src] then
		doctorCount = doctorCount - 1
		TriggerClientEvent('hospital:client:SetDoctorCount', -1, doctorCount)
		Doctors[src] = nil
	end
end)

RegisterNetEvent('hospital:server:RevivePlayer', function(playerId, isOldMan)
	local src = source
	local Player = TA2Core.Functions.GetPlayer(src)
	local Patient = TA2Core.Functions.GetPlayer(playerId)
	local oldMan = isOldMan or false
	if Patient then
		if Player.PlayerData.job.name == 'ambulance' or TA2Core.Functions.HasItem(src, 'firstaid', 1) then
			if oldMan then
				if Player.Functions.RemoveMoney('cash', 5000, 'revived-player') then
					exports['ta2-inventory']:RemoveItem(src, 'firstaid', 1, false, 'hospital:server:RevivePlayer')
					TriggerClientEvent('ta2-inventory:client:ItemBox', src, TA2Core.Shared.Items['firstaid'], 'remove')
					TriggerClientEvent('hospital:client:Revive', Patient.PlayerData.source)
				else
					TriggerClientEvent('TA2Core:Notify', src, Lang:t('error.not_enough_money'), 'error')
				end
			else
				exports['ta2-inventory']:RemoveItem(src, 'firstaid', 1, false, 'hospital:server:RevivePlayer')
				TriggerClientEvent('ta2-inventory:client:ItemBox', src, TA2Core.Shared.Items['firstaid'], 'remove')
				TriggerClientEvent('hospital:client:Revive', Patient.PlayerData.source)
			end
		else
			MySQL.insert('INSERT INTO bans (name, license, discord, ip, reason, expire, bannedby) VALUES (?, ?, ?, ?, ?, ?, ?)', {
				GetPlayerName(src),
				TA2Core.Functions.GetIdentifier(src, 'license'),
				TA2Core.Functions.GetIdentifier(src, 'discord'),
				TA2Core.Functions.GetIdentifier(src, 'ip'),
				'Trying to revive theirselves or other players',
				2147483647,
				'ta2-ambulancejob'
			})
			TriggerEvent('ta2-log:server:CreateLog', 'ambulancejob', 'Player Banned', 'red', string.format('%s was banned by %s for %s', GetPlayerName(src), 'ta2-ambulancejob', 'Trying to revive theirselves or other players'), true)
			DropPlayer(src, 'You were permanently banned by the server for: Exploiting')
		end
	end
end)

RegisterNetEvent('hospital:server:SendDoctorAlert', function(hospitalName)
	local src = source
	if not doctorCalled then
		doctorCalled = true
		local players = TA2Core.Functions.GetQBPlayers()
		for _, v in pairs(players) do
			if v.PlayerData.job.name == 'ambulance' and v.PlayerData.job.onduty then
				TriggerClientEvent('TA2Core:Notify', v.PlayerData.source, Lang:t('info.dr_needed', { hospital = hospitalName }), 'ambulance')
			end
		end
		SetTimeout(Config.DocCooldown * 60000, function()
			doctorCalled = false
		end)
	else
		TriggerClientEvent('TA2Core:Notify', src, 'Doctor has already been notified', 'error')
	end
end)

RegisterNetEvent('hospital:server:UseFirstAid', function(targetId)
	local src = source
	local Target = TA2Core.Functions.GetPlayer(targetId)
	if Target then
		TriggerClientEvent('hospital:client:CanHelp', targetId, src)
	end
end)

RegisterNetEvent('hospital:server:CanHelp', function(helperId, canHelp)
	local src = source
	if canHelp then
		TriggerClientEvent('hospital:client:HelpPerson', helperId, src)
	else
		TriggerClientEvent('TA2Core:Notify', helperId, Lang:t('error.cant_help'), 'error')
	end
end)

RegisterNetEvent('hospital:server:removeBandage', function()
	local Player = TA2Core.Functions.GetPlayer(source)
	if not Player then return end
	exports['ta2-inventory']:RemoveItem(source, 'bandage', 1, false, 'hospital:server:removeBandage')
end)

RegisterNetEvent('hospital:server:removeIfaks', function()
	local Player = TA2Core.Functions.GetPlayer(source)
	if not Player then return end
	exports['ta2-inventory']:RemoveItem(source, 'ifaks', 1, false, 'hospital:server:removeIfaks')
end)

RegisterNetEvent('hospital:server:removePainkillers', function()
	local Player = TA2Core.Functions.GetPlayer(source)
	if not Player then return end
	exports['ta2-inventory']:RemoveItem(source, 'painkillers', 1, false, 'hospital:server:removePainkillers')
end)

RegisterNetEvent('hospital:server:resetHungerThirst', function()
	local Player = TA2Core.Functions.GetPlayer(source)

	if not Player then return end

	Player.Functions.SetMetaData('hunger', 100)
	Player.Functions.SetMetaData('thirst', 100)

	TriggerClientEvent('hud:client:UpdateNeeds', source, 100, 100)
end)

RegisterNetEvent('ta2-ambulancejob:server:stash', function()
	local src = source
	local Player = TA2Core.Functions.GetPlayer(src)
	if not Player then return end
	local citizenId = Player.PlayerData.citizenid
	local stashName = 'ambulancestash_' .. citizenId
	exports['ta2-inventory']:OpenInventory(src, stashName)
end)

-- Callbacks

TA2Core.Functions.CreateCallback('hospital:GetDoctors', function(_, cb)
	local amount = 0
	local players = TA2Core.Functions.GetQBPlayers()
	for _, v in pairs(players) do
		if v.PlayerData.job.name == 'ambulance' and v.PlayerData.job.onduty then
			amount = amount + 1
		end
	end
	cb(amount)
end)

TA2Core.Functions.CreateCallback('hospital:GetPlayerStatus', function(_, cb, playerId)
	local Player = TA2Core.Functions.GetPlayer(playerId)
	local injuries = {}
	injuries['WEAPONWOUNDS'] = {}
	if Player then
		if PlayerInjuries[Player.PlayerData.source] then
			if (PlayerInjuries[Player.PlayerData.source].isBleeding > 0) then
				injuries['BLEED'] = PlayerInjuries[Player.PlayerData.source].isBleeding
			end
			for k, _ in pairs(PlayerInjuries[Player.PlayerData.source].limbs) do
				if PlayerInjuries[Player.PlayerData.source].limbs[k].isDamaged then
					injuries[k] = PlayerInjuries[Player.PlayerData.source].limbs[k]
				end
			end
		end
		if PlayerWeaponWounds[Player.PlayerData.source] then
			for k, v in pairs(PlayerWeaponWounds[Player.PlayerData.source]) do
				injuries['WEAPONWOUNDS'][k] = v
			end
		end
	end
	cb(injuries)
end)

TA2Core.Functions.CreateCallback('hospital:GetPlayerBleeding', function(source, cb)
	local src = source
	if PlayerInjuries[src] and PlayerInjuries[src].isBleeding then
		cb(PlayerInjuries[src].isBleeding)
	else
		cb(nil)
	end
end)

-- Commands

TA2Core.Commands.Add('911e', Lang:t('info.ems_report'), { { name = 'message', help = Lang:t('info.message_sent') } }, false, function(source, args)
	local src = source
	local message
	if args[1] then message = table.concat(args, ' ') else message = Lang:t('info.civ_call') end
	local ped = GetPlayerPed(src)
	local coords = GetEntityCoords(ped)
	local players = TA2Core.Functions.GetQBPlayers()
	for _, v in pairs(players) do
		if v.PlayerData.job.name == 'ambulance' and v.PlayerData.job.onduty then
			TriggerClientEvent('hospital:client:ambulanceAlert', v.PlayerData.source, coords, message)
		end
	end
end)

TA2Core.Commands.Add('status', Lang:t('info.check_health'), {}, false, function(source, _)
	local src = source
	local Player = TA2Core.Functions.GetPlayer(src)
	if Player.PlayerData.job.name == 'ambulance' then
		TriggerClientEvent('hospital:client:CheckStatus', src)
	else
		TriggerClientEvent('TA2Core:Notify', src, Lang:t('error.not_ems'), 'error')
	end
end)

TA2Core.Commands.Add('heal', Lang:t('info.heal_player'), {}, false, function(source, _)
	local src = source
	local Player = TA2Core.Functions.GetPlayer(src)
	if Player.PlayerData.job.name == 'ambulance' then
		TriggerClientEvent('hospital:client:TreatWounds', src)
	else
		TriggerClientEvent('TA2Core:Notify', src, Lang:t('error.not_ems'), 'error')
	end
end)

TA2Core.Commands.Add('revivep', Lang:t('info.revive_player'), {}, false, function(source, _)
	local src = source
	local Player = TA2Core.Functions.GetPlayer(src)
	if Player.PlayerData.job.name == 'ambulance' then
		TriggerClientEvent('hospital:client:RevivePlayer', src)
	else
		TriggerClientEvent('TA2Core:Notify', src, Lang:t('error.not_ems'), 'error')
	end
end)

TA2Core.Commands.Add('revive', Lang:t('info.revive_player_a'), { { name = 'id', help = Lang:t('info.player_id') } }, false, function(source, args)
	local src = source
	if args[1] then
		local Player = TA2Core.Functions.GetPlayer(tonumber(args[1]))
		if Player then
			TriggerClientEvent('hospital:client:Revive', Player.PlayerData.source)
		else
			TriggerClientEvent('TA2Core:Notify', src, Lang:t('error.not_online'), 'error')
		end
	else
		TriggerClientEvent('hospital:client:Revive', src)
	end
end, 'admin')

TA2Core.Commands.Add('setpain', Lang:t('info.pain_level'), { { name = 'id', help = Lang:t('info.player_id') } }, false, function(source, args)
	local src = source
	if args[1] then
		local Player = TA2Core.Functions.GetPlayer(tonumber(args[1]))
		if Player then
			TriggerClientEvent('hospital:client:SetPain', Player.PlayerData.source)
		else
			TriggerClientEvent('TA2Core:Notify', src, Lang:t('error.not_online'), 'error')
		end
	else
		TriggerClientEvent('hospital:client:SetPain', src)
	end
end, 'admin')

TA2Core.Commands.Add('kill', Lang:t('info.kill'), { { name = 'id', help = Lang:t('info.player_id') } }, false, function(source, args)
	local src = source
	if args[1] then
		local Player = TA2Core.Functions.GetPlayer(tonumber(args[1]))
		if Player then
			TriggerClientEvent('hospital:client:KillPlayer', Player.PlayerData.source)
		else
			TriggerClientEvent('TA2Core:Notify', src, Lang:t('error.not_online'), 'error')
		end
	else
		TriggerClientEvent('hospital:client:KillPlayer', src)
	end
end, 'admin')

TA2Core.Commands.Add('aheal', Lang:t('info.heal_player_a'), { { name = 'id', help = Lang:t('info.player_id') } }, false, function(source, args)
	local src = source
	if args[1] then
		local Player = TA2Core.Functions.GetPlayer(tonumber(args[1]))
		if Player then
			TriggerClientEvent('hospital:client:adminHeal', Player.PlayerData.source)
		else
			TriggerClientEvent('TA2Core:Notify', src, Lang:t('error.not_online'), 'error')
		end
	else
		TriggerClientEvent('hospital:client:adminHeal', src)
	end
end, 'admin')

-- Items

TA2Core.Functions.CreateUseableItem('ifaks', function(source, item)
	local src = source
	local Player = TA2Core.Functions.GetPlayer(src)
	if Player.Functions.GetItemByName(item.name) ~= nil then
		TriggerClientEvent('hospital:client:UseIfaks', src)
	end
end)

TA2Core.Functions.CreateUseableItem('bandage', function(source, item)
	local src = source
	local Player = TA2Core.Functions.GetPlayer(src)
	if Player.Functions.GetItemByName(item.name) ~= nil then
		TriggerClientEvent('hospital:client:UseBandage', src)
	end
end)

TA2Core.Functions.CreateUseableItem('painkillers', function(source, item)
	local src = source
	local Player = TA2Core.Functions.GetPlayer(src)
	if Player.Functions.GetItemByName(item.name) ~= nil then
		TriggerClientEvent('hospital:client:UsePainkillers', src)
	end
end)

TA2Core.Functions.CreateUseableItem('firstaid', function(source, item)
	local src = source
	local Player = TA2Core.Functions.GetPlayer(src)
	if Player.Functions.GetItemByName(item.name) ~= nil then
		TriggerClientEvent('hospital:client:UseFirstAid', src)
	end
end)

exports('GetDoctorCount', function() return doctorCount end)
