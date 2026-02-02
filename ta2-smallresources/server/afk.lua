

RegisterNetEvent('KickForAFK', function()
	DropPlayer(source, Lang:t("afk.kick_message"))
end)

TA2Core.Functions.CreateCallback('ta2-afkkick:server:GetPermissions', function(source, cb)
    cb(TA2Core.Functions.GetPermission(source))
end)
