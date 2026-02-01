local TA2Core = exports['ta2-core']:GetCoreObject()

-- Get Employees
TA2Core.Functions.CreateCallback('ta2-gangmenu:server:GetEmployees', function(source, cb, gangname)
	local src = source
	local Player = TA2Core.Functions.GetPlayer(src)

	if not Player.PlayerData.gang.isboss then
		ExploitBan(src, 'GetEmployees Exploiting')
		return
	end

	local employees = {}
	local players = MySQL.query.await("SELECT * FROM `players` WHERE `gang` LIKE '%" .. gangname .. "%'", {})
	if players[1] ~= nil then
		for _, value in pairs(players) do
			local Target = TA2Core.Functions.GetPlayerByCitizenId(value.citizenid) or TA2Core.Functions.GetOfflinePlayerByCitizenId(value.citizenid)

			if Target then
				local isOnline = Target.PlayerData.source
				employees[#employees + 1] = {
					empSource = Target.PlayerData.citizenid,
					grade = Target.PlayerData.gang.grade,
					isboss = Target.PlayerData.gang.isboss,
					name = (isOnline and '🟢 ' or '❌ ') .. Target.PlayerData.charinfo.firstname .. ' ' .. Target.PlayerData.charinfo.lastname
				}
			end
		end
	end
	cb(employees)
end)

RegisterNetEvent('ta2-gangmenu:server:stash', function()
	local src = source
	local Player = TA2Core.Functions.GetPlayer(src)
	if not Player then return end
	local playerGang = Player.PlayerData.gang
	if not playerGang.isboss then return end
	local playerPed = GetPlayerPed(src)
	local playerCoords = GetEntityCoords(playerPed)
	if not Config.GangMenus[playerGang.name] then return end
	local bossCoords = Config.GangMenus[playerGang.name]
	for i = 1, #bossCoords do
		local coords = bossCoords[i]
		if #(playerCoords - coords) < 2.5 then
			local stashName = 'boss_' .. playerGang.name
			exports['ta2-inventory']:OpenInventory(src, stashName, {
				maxweight = 4000000,
				slots = 25,
			})
			return
		end
	end
end)

-- Grade Change
RegisterNetEvent('ta2-gangmenu:server:GradeUpdate', function(data)
	local src = source
	local Player = TA2Core.Functions.GetPlayer(src)
	local Employee = TA2Core.Functions.GetPlayerByCitizenId(data.cid) or TA2Core.Functions.GetOfflinePlayerByCitizenId(data.cid)

	if not Player.PlayerData.gang.isboss then
		ExploitBan(src, 'GradeUpdate Exploiting')
		return
	end
	if data.grade > Player.PlayerData.gang.grade.level then
		TriggerClientEvent('TA2Core:Notify', src, 'You cannot promote to this rank!', 'error')
		return
	end

	if Employee then
		if Employee.Functions.SetGang(Player.PlayerData.gang.name, data.grade) then
			TriggerClientEvent('TA2Core:Notify', src, 'Successfully promoted!', 'success')
			Employee.Functions.Save()

			if Employee.PlayerData.source then
				TriggerClientEvent('TA2Core:Notify', Employee.PlayerData.source, 'You have been promoted to ' .. data.gradename .. '.', 'success')
			end
		else
			TriggerClientEvent('TA2Core:Notify', src, 'Grade does not exist.', 'error')
		end
	end
	TriggerClientEvent('ta2-gangmenu:client:OpenMenu', src)
end)

-- Fire Member
RegisterNetEvent('ta2-gangmenu:server:FireMember', function(target)
	local src = source
	local Player = TA2Core.Functions.GetPlayer(src)
	local Employee = TA2Core.Functions.GetPlayerByCitizenId(target) or TA2Core.Functions.GetOfflinePlayerByCitizenId(target)

	if not Player.PlayerData.gang.isboss then
		ExploitBan(src, 'FireEmployee Exploiting')
		return
	end

	if Employee then
		if target == Player.PlayerData.citizenid then
			TriggerClientEvent('TA2Core:Notify', src, 'You can\'t kick yourself out of the gang!', 'error')
			return
		elseif Employee.PlayerData.gang.grade.level > Player.PlayerData.gang.grade.level then
			TriggerClientEvent('TA2Core:Notify', src, 'You cannot fire this citizen!', 'error')
			return
		end
		if Employee.Functions.SetGang('none', '0') then
			Employee.Functions.Save()
			TriggerEvent('ta2-log:server:CreateLog', 'gangmenu', 'Gang Fire', 'orange', Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname .. ' successfully fired ' .. Employee.PlayerData.charinfo.firstname .. ' ' .. Employee.PlayerData.charinfo.lastname .. ' (' .. Player.PlayerData.gang.name .. ')', false)
			TriggerClientEvent('TA2Core:Notify', src, 'Gang Member fired!', 'success')

			if Employee.PlayerData.source then -- Player is online
				TriggerClientEvent('TA2Core:Notify', Employee.PlayerData.source, 'You have been expelled from the gang!', 'error')
			end
		else
			TriggerClientEvent('TA2Core:Notify', src, 'Error.', 'error')
		end
	end
	TriggerClientEvent('ta2-gangmenu:client:OpenMenu', src)
end)

-- Recruit Player
RegisterNetEvent('ta2-gangmenu:server:HireMember', function(recruit)
	local src = source
	local Player = TA2Core.Functions.GetPlayer(src)
	local Target = TA2Core.Functions.GetPlayer(recruit)

	if not Player.PlayerData.gang.isboss then
		ExploitBan(src, 'HireEmployee Exploiting')
		return
	end

	if Target and Target.Functions.SetGang(Player.PlayerData.gang.name, 0) then
		TriggerClientEvent('TA2Core:Notify', src, 'You hired ' .. (Target.PlayerData.charinfo.firstname .. ' ' .. Target.PlayerData.charinfo.lastname) .. ' come ' .. Player.PlayerData.gang.label .. '', 'success')
		TriggerClientEvent('TA2Core:Notify', Target.PlayerData.source, 'You have been hired as ' .. Player.PlayerData.gang.label .. '', 'success')
		TriggerEvent('ta2-log:server:CreateLog', 'gangmenu', 'Recruit', 'yellow', (Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname) .. ' successfully recruited ' .. Target.PlayerData.charinfo.firstname .. ' ' .. Target.PlayerData.charinfo.lastname .. ' (' .. Player.PlayerData.gang.name .. ')', false)
	end
	TriggerClientEvent('ta2-gangmenu:client:OpenMenu', src)
end)

-- Get closest player sv
TA2Core.Functions.CreateCallback('ta2-gangmenu:getplayers', function(source, cb)
	local src = source
	local players = {}
	local PlayerPed = GetPlayerPed(src)
	local pCoords = GetEntityCoords(PlayerPed)
	for _, v in pairs(TA2Core.Functions.GetPlayers()) do
		local targetped = GetPlayerPed(v)
		local tCoords = GetEntityCoords(targetped)
		local dist = #(pCoords - tCoords)
		if PlayerPed ~= targetped and dist < 10 then
			local ped = TA2Core.Functions.GetPlayer(v)
			players[#players + 1] = {
				id = v,
				coords = GetEntityCoords(targetped),
				name = ped.PlayerData.charinfo.firstname .. ' ' .. ped.PlayerData.charinfo.lastname,
				citizenid = ped.PlayerData.citizenid,
				sources = GetPlayerPed(ped.PlayerData.source),
				sourceplayer = ped.PlayerData.source
			}
		end
	end
	table.sort(players, function(a, b)
		return a.name < b.name
	end)
	cb(players)
end)
