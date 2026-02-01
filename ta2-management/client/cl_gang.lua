local TA2Core = exports['ta2-core']:GetCoreObject()
local PlayerGang = TA2Core.Functions.GetPlayerData().gang
local shownGangMenu = false
local DynamicMenuItems = {}

-- UTIL
local function CloseMenuFullGang()
    exports['ta2-menu']:closeMenu()
    exports['ta2-core']:HideText()
    shownGangMenu = false
end

--//Events
AddEventHandler('onResourceStart', function(resource) --if you restart the resource
    if resource == GetCurrentResourceName() then
        Wait(200)
        PlayerGang = TA2Core.Functions.GetPlayerData().gang
    end
end)

RegisterNetEvent('TA2Core:Client:OnPlayerLoaded', function()
    PlayerGang = TA2Core.Functions.GetPlayerData().gang
end)

RegisterNetEvent('TA2Core:Client:OnGangUpdate', function(InfoGang)
    PlayerGang = InfoGang
end)

RegisterNetEvent('ta2-gangmenu:client:Warbobe', function()
    TriggerEvent('ta2-clothing:client:openOutfitMenu')
end)

local function AddGangMenuItem(data, id)
    local menuID = id or (#DynamicMenuItems + 1)
    DynamicMenuItems[menuID] = deepcopy(data)
    return menuID
end

exports('AddGangMenuItem', AddGangMenuItem)

local function RemoveGangMenuItem(id)
    DynamicMenuItems[id] = nil
end

exports('RemoveGangMenuItem', RemoveGangMenuItem)

RegisterNetEvent('ta2-gangmenu:client:OpenMenu', function()
    shownGangMenu = true
    local gangMenu = {
        {
            header = Lang:t('headersgang.bsm') .. string.upper(PlayerGang.label),
            icon = 'fa-solid fa-circle-info',
            isMenuHeader = true,
        },
        {
            header = Lang:t('bodygang.manage'),
            txt = Lang:t('bodygang.managed'),
            icon = 'fa-solid fa-list',
            params = {
                event = 'ta2-gangmenu:client:ManageGang',
            }
        },
        {
            header = Lang:t('bodygang.hire'),
            txt = Lang:t('bodygang.hired'),
            icon = 'fa-solid fa-hand-holding',
            params = {
                event = 'ta2-gangmenu:client:HireMembers',
            }
        },
        {
            header = Lang:t('bodygang.storage'),
            txt = Lang:t('bodygang.storaged'),
            icon = 'fa-solid fa-box-open',
            params = {
                isServer = true,
                event = 'ta2-gangmenu:server:stash',
            }
        },
        {
            header = Lang:t('bodygang.outfits'),
            txt = Lang:t('bodygang.outfitsd'),
            icon = 'fa-solid fa-shirt',
            params = {
                event = 'ta2-gangmenu:client:Warbobe',
            }
        }
    }

    for _, v in pairs(DynamicMenuItems) do
        gangMenu[#gangMenu + 1] = v
    end

    gangMenu[#gangMenu + 1] = {
        header = Lang:t('bodygang.exit'),
        icon = 'fa-solid fa-angle-left',
        params = {
            event = 'ta2-menu:closeMenu',
        }
    }

    exports['ta2-menu']:openMenu(gangMenu)
end)

RegisterNetEvent('ta2-gangmenu:client:ManageGang', function()
    local GangMembersMenu = {
        {
            header = Lang:t('bodygang.mempl') .. string.upper(PlayerGang.label),
            icon = 'fa-solid fa-circle-info',
            isMenuHeader = true,
        },
    }
    TA2Core.Functions.TriggerCallback('ta2-gangmenu:server:GetEmployees', function(cb)
        for _, v in pairs(cb) do
            GangMembersMenu[#GangMembersMenu + 1] = {
                header = v.name,
                txt = v.grade.name,
                icon = 'fa-solid fa-circle-user',
                params = {
                    event = 'ta2-gangmenu:lient:ManageMember',
                    args = {
                        player = v,
                        work = PlayerGang
                    }
                }
            }
        end
        GangMembersMenu[#GangMembersMenu + 1] = {
            header = Lang:t('bodygang.return'),
            icon = 'fa-solid fa-angle-left',
            params = {
                event = 'ta2-gangmenu:client:OpenMenu',
            }
        }
        exports['ta2-menu']:openMenu(GangMembersMenu)
    end, PlayerGang.name)
end)

RegisterNetEvent('ta2-gangmenu:lient:ManageMember', function(data)
    local MemberMenu = {
        {
            header = Lang:t('bodygang.mngpl') .. data.player.name .. ' - ' .. string.upper(PlayerGang.label),
            isMenuHeader = true,
            icon = 'fa-solid fa-circle-info',
        },
    }
    for k, v in pairs(TA2Core.Shared.Gangs[data.work.name].grades) do
        MemberMenu[#MemberMenu + 1] = {
            header = v.name,
            txt = Lang:t('bodygang.grade') .. k,
            params = {
                isServer = true,
                event = 'ta2-gangmenu:server:GradeUpdate',
                icon = 'fa-solid fa-file-pen',
                args = {
                    cid = data.player.empSource,
                    grade = tonumber(k),
                    gradename = v.name
                }
            }
        }
    end
    MemberMenu[#MemberMenu + 1] = {
        header = Lang:t('bodygang.fireemp'),
        icon = 'fa-solid fa-user-large-slash',
        params = {
            isServer = true,
            event = 'ta2-gangmenu:server:FireMember',
            args = data.player.empSource
        }
    }
    MemberMenu[#MemberMenu + 1] = {
        header = Lang:t('bodygang.return'),
        icon = 'fa-solid fa-angle-left',
        params = {
            event = 'ta2-gangmenu:client:ManageGang',
        }
    }
    exports['ta2-menu']:openMenu(MemberMenu)
end)

RegisterNetEvent('ta2-gangmenu:client:HireMembers', function()
    local HireMembersMenu = {
        {
            header = Lang:t('bodygang.hireemp') .. string.upper(PlayerGang.label),
            isMenuHeader = true,
            icon = 'fa-solid fa-circle-info',
        },
    }
    TA2Core.Functions.TriggerCallback('ta2-gangmenu:getplayers', function(players)
        for _, v in pairs(players) do
            if v and v ~= PlayerId() then
                HireMembersMenu[#HireMembersMenu + 1] = {
                    header = v.name,
                    txt = Lang:t('bodygang.cid') .. v.citizenid .. ' - ID: ' .. v.sourceplayer,
                    icon = 'fa-solid fa-user-check',
                    params = {
                        isServer = true,
                        event = 'ta2-gangmenu:server:HireMember',
                        args = v.sourceplayer
                    }
                }
            end
        end
        HireMembersMenu[#HireMembersMenu + 1] = {
            header = Lang:t('bodygang.return'),
            icon = 'fa-solid fa-angle-left',
            params = {
                event = 'ta2-gangmenu:client:OpenMenu',
            }
        }
        exports['ta2-menu']:openMenu(HireMembersMenu)
    end)
end)

-- MAIN THREAD

CreateThread(function()
    if Config.UseTarget then
        for gang, zones in pairs(Config.GangMenus) do
            for index, coords in ipairs(zones) do
                local zoneName = gang .. '_gangmenu_' .. index
                exports['ta2-target']:AddCircleZone(zoneName, coords, 0.5, {
                    name = zoneName,
                    debugPoly = false,
                    useZ = true
                }, {
                    options = {
                        {
                            type = 'client',
                            event = 'ta2-gangmenu:client:OpenMenu',
                            icon = 'fas fa-sign-in-alt',
                            label = Lang:t('targetgang.label'),
                            canInteract = function() return gang == PlayerGang.name and PlayerGang.isboss end,
                        },
                    },
                    distance = 2.5
                })
            end
        end
    else
        while true do
            local wait = 2500
            local pos = GetEntityCoords(PlayerPedId())
            local inRangeGang = false
            local nearGangmenu = false
            if PlayerGang then
                wait = 0
                for k, menus in pairs(Config.GangMenus) do
                    for _, coords in ipairs(menus) do
                        if k == PlayerGang.name and PlayerGang.isboss then
                            if #(pos - coords) < 5.0 then
                                inRangeGang = true
                                if #(pos - coords) <= 1.5 then
                                    nearGangmenu = true
                                    if not shownGangMenu then
                                        exports['ta2-core']:DrawText(Lang:t('drawtextgang.label'), 'left')
                                        shownGangMenu = true
                                    end

                                    if IsControlJustReleased(0, 38) then
                                        exports['ta2-core']:HideText()
                                        TriggerEvent('ta2-gangmenu:client:OpenMenu')
                                    end
                                end

                                if not nearGangmenu and shownGangMenu then
                                    CloseMenuFullGang()
                                    shownGangMenu = false
                                end
                            end
                        end
                    end
                end
                if not inRangeGang then
                    Wait(1500)
                    if shownGangMenu then
                        CloseMenuFullGang()
                        shownGangMenu = false
                    end
                end
            end
            Wait(wait)
        end
    end
end)
