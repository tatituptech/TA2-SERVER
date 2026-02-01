local TA2Core = exports['ta2-core']:GetCoreObject()
local zones = {}

local isPlayerInsideBankZone = false

-- Functions

local function OpenBank()
    TA2Core.Functions.TriggerCallback('ta2-banking:server:openBank', function(accounts, statements, playerData)
        SetNuiFocus(true, true)
        SendNUIMessage({
            action = 'openBank',
            accounts = accounts,
            statements = statements,
            playerData = playerData
        })
    end)
end

local function OpenATM()
    TA2Core.Functions.Progressbar('accessing_atm', Lang:t('progress.atm'), 1500, false, true, {
        disableMovement = false,
        disableCarMovement = false,
        disableMouse = false,
        disableCombat = false,
    }, {
        animDict = 'amb@prop_human_atm@male@enter',
        anim = 'enter',
    }, {
        model = 'prop_cs_credit_card',
        bone = 28422,
        coords = vector3(0.1, 0.03, -0.05),
        rotation = vector3(0.0, 0.0, 180.0),
    }, {}, function()
        TA2Core.Functions.TriggerCallback('ta2-banking:server:openATM', function(accounts, playerData, acceptablePins)
            SetNuiFocus(true, true)
            SendNUIMessage({
                action = 'openATM',
                accounts = accounts,
                pinNumbers = acceptablePins,
                playerData = playerData
            })
        end)
    end)
end

local function NearATM()
    local playerCoords = GetEntityCoords(PlayerPedId())
    for _, v in pairs(Config.atmModels) do
        local hash = joaat(v)
        local atm = IsObjectNearPoint(hash, playerCoords.x, playerCoords.y, playerCoords.z, 1.5)
        if atm then
            return true
        end
    end
end

-- NUI Callback

RegisterNUICallback('closeApp', function(_, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('withdraw', function(data, cb)
    TA2Core.Functions.TriggerCallback('ta2-banking:server:withdraw', function(status)
        cb(status)
    end, data)
end)

RegisterNUICallback('deposit', function(data, cb)
    TA2Core.Functions.TriggerCallback('ta2-banking:server:deposit', function(status)
        cb(status)
    end, data)
end)

RegisterNUICallback('internalTransfer', function(data, cb)
    TA2Core.Functions.TriggerCallback('ta2-banking:server:internalTransfer', function(status)
        cb(status)
    end, data)
end)

RegisterNUICallback('externalTransfer', function(data, cb)
    TA2Core.Functions.TriggerCallback('ta2-banking:server:externalTransfer', function(status)
        cb(status)
    end, data)
end)

RegisterNUICallback('orderCard', function(data, cb)
    TA2Core.Functions.TriggerCallback('ta2-banking:server:orderCard', function(status)
        cb(status)
    end, data)
end)

RegisterNUICallback('openAccount', function(data, cb)
    TA2Core.Functions.TriggerCallback('ta2-banking:server:openAccount', function(status)
        cb(status)
    end, data)
end)

RegisterNUICallback('renameAccount', function(data, cb)
    TA2Core.Functions.TriggerCallback('ta2-banking:server:renameAccount', function(status)
        cb(status)
    end, data)
end)

RegisterNUICallback('deleteAccount', function(data, cb)
    TA2Core.Functions.TriggerCallback('ta2-banking:server:deleteAccount', function(status)
        cb(status)
    end, data)
end)

RegisterNUICallback('addUser', function(data, cb)
    TA2Core.Functions.TriggerCallback('ta2-banking:server:addUser', function(status)
        cb(status)
    end, data)
end)

RegisterNUICallback('removeUser', function(data, cb)
    TA2Core.Functions.TriggerCallback('ta2-banking:server:removeUser', function(status)
        cb(status)
    end, data)
end)

-- Events

RegisterNetEvent('ta2-banking:client:useCard', function()
    if NearATM() then OpenATM() end
end)

-- Threads

CreateThread(function()
    for i = 1, #Config.locations do
        local blip = AddBlipForCoord(Config.locations[i])
        SetBlipSprite(blip, Config.blipInfo.sprite)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, Config.blipInfo.scale)
        SetBlipColour(blip, Config.blipInfo.color)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentSubstringPlayerName(tostring(Config.blipInfo.name))
        EndTextCommandSetBlipName(blip)
    end
end)

if Config.useTarget then
    CreateThread(function()
        for i = 1, #Config.locations do
            exports['ta2-target']:AddCircleZone('bank_' .. i, Config.locations[i], 1.0, {
                name = 'bank_' .. i,
                useZ = true,
                debugPoly = false,
            }, {
                options = {
                    {
                        icon = 'fas fa-university',
                        label = 'Open Bank',
                        action = function()
                            OpenBank()
                        end,
                    }
                },
                distance = 1.5
            })
        end
    end)

    CreateThread(function()
        for i = 1, #Config.atmModels do
            local atmModel = Config.atmModels[i]
            exports['ta2-target']:AddTargetModel(atmModel, {
                options = {
                    {
                        icon = 'fas fa-university',
                        label = 'Open ATM',
                        item = 'bank_card',
                        action = function()
                            OpenATM()
                        end,
                    }
                },
                distance = 1.5
            })
        end
    end)
end

if not Config.useTarget then
    CreateThread(function()
        for i = 1, #Config.locations do
            local zone = CircleZone:Create(Config.locations[i], 3.0, {
                name = 'bank_' .. i,
                debugPoly = false,
            })
            zones[#zones + 1] = zone
        end

        local combo = ComboZone:Create(zones, {
            name = 'bank_combo',
            debugPoly = false,
        })

        combo:onPlayerInOut(function(isPointInside)
            isPlayerInsideBankZone = isPointInside
            if isPlayerInsideBankZone then
                exports['ta2-core']:DrawText('Open Bank')
                CreateThread(function()
                    while isPlayerInsideBankZone do
                        Wait(0)
                        if IsControlJustPressed(0, 38) then
                            OpenBank()
                        end
                    end
                end)
            else
                exports['ta2-core']:HideText()
            end
        end)
    end)
end
