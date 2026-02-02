
----------- / alcohol

for k, _ in pairs(Config.Consumables.alcohol) do
    TA2Core.Functions.CreateUseableItem(k, function(source, item)
        TriggerClientEvent('consumables:client:DrinkAlcohol', source, item.name)
    end)
end

----------- / Eat

for k, _ in pairs(Config.Consumables.eat) do
    TA2Core.Functions.CreateUseableItem(k, function(source, item)
        if not exports['ta2-inventory']:RemoveItem(source, item.name, 1, item.slot, 'ta2-smallresources:consumables:eat') then return end
        TriggerClientEvent('consumables:client:Eat', source, item.name)
    end)
end

----------- / Drink
for k, _ in pairs(Config.Consumables.drink) do
    TA2Core.Functions.CreateUseableItem(k, function(source, item)
        if not exports['ta2-inventory']:RemoveItem(source, item.name, 1, item.slot, 'ta2-smallresources:consumables:drink') then return end
        TriggerClientEvent('consumables:client:Drink', source, item.name)
    end)
end

----------- / Custom
for k, _ in pairs(Config.Consumables.custom) do
    TA2Core.Functions.CreateUseableItem(k, function(source, item)
        if not exports['ta2-inventory']:RemoveItem(source, item.name, 1, item.slot, 'ta2-smallresources:consumables:custom') then return end
        TriggerClientEvent('consumables:client:Custom', source, item.name)
    end)
end

local function createItem(name, type)
    TA2Core.Functions.CreateUseableItem(name, function(source, item)
        if not exports['ta2-inventory']:RemoveItem(source, item.name, 1, item.slot, 'ta2-smallresources:consumables:createItem') then return end
        TriggerClientEvent('consumables:client:' .. type, source, item.name)
    end)
end
----------- / Drug

TA2Core.Functions.CreateUseableItem('joint', function(source, item)
    if not exports['ta2-inventory']:RemoveItem(source, item.name, 1, item.slot, 'ta2-smallresources:joint') then return end
    TriggerClientEvent('consumables:client:UseJoint', source)
end)

TA2Core.Functions.CreateUseableItem('cokebaggy', function(source)
    TriggerClientEvent('consumables:client:Cokebaggy', source)
end)

TA2Core.Functions.CreateUseableItem('crack_baggy', function(source)
    TriggerClientEvent('consumables:client:Crackbaggy', source)
end)

TA2Core.Functions.CreateUseableItem('xtcbaggy', function(source)
    TriggerClientEvent('consumables:client:EcstasyBaggy', source)
end)

TA2Core.Functions.CreateUseableItem('oxy', function(source)
    TriggerClientEvent('consumables:client:oxy', source)
end)

TA2Core.Functions.CreateUseableItem('meth', function(source)
    TriggerClientEvent('consumables:client:meth', source)
end)

----------- / Tools

TA2Core.Functions.CreateUseableItem('armor', function(source)
    TriggerClientEvent('consumables:client:UseArmor', source)
end)

TA2Core.Functions.CreateUseableItem('heavyarmor', function(source)
    TriggerClientEvent('consumables:client:UseHeavyArmor', source)
end)

TA2Core.Commands.Add('resetarmor', 'Resets Vest (Police Only)', {}, false, function(source)
    local Player = TA2Core.Functions.GetPlayer(source)
    if Player.PlayerData.job.name == 'police' then
        TriggerClientEvent('consumables:client:ResetArmor', source)
    else
        TriggerClientEvent('TA2Core:Notify', source, 'For Police Officer Only', 'error')
    end
end)

TA2Core.Functions.CreateUseableItem('binoculars', function(source)
    TriggerClientEvent('binoculars:Toggle', source)
end)

TA2Core.Functions.CreateUseableItem('parachute', function(source, item)
    if not exports['ta2-inventory']:RemoveItem(source, item.name, 1, item.slot, 'ta2-smallresources:parachute') then return end
    TriggerClientEvent('consumables:client:UseParachute', source)
end)

TA2Core.Commands.Add('resetparachute', 'Resets Parachute', {}, false, function(source)
    TriggerClientEvent('consumables:client:ResetParachute', source)
end)

----------- / Firework

for _, v in pairs(Config.Fireworks.items) do
    TA2Core.Functions.CreateUseableItem(v, function(source, item)
        local src = source
        TriggerClientEvent('fireworks:client:UseFirework', src, item.name, 'proj_indep_firework')
    end)
end

----------- / Lockpicking

TA2Core.Functions.CreateUseableItem('lockpick', function(source)
    TriggerClientEvent('lockpicks:UseLockpick', source, false)
end)

TA2Core.Functions.CreateUseableItem('advancedlockpick', function(source)
    TriggerClientEvent('lockpicks:UseLockpick', source, true)
end)

-- Events for adding and removing specific items to fix some exploits

RegisterNetEvent('consumables:server:AddParachute', function()
    local Player = TA2Core.Functions.GetPlayer(source)
    if not Player then return end
    exports['ta2-inventory']:AddItem(source, 'parachute', 1, false, false, 'consumables:server:AddParachute')
end)

RegisterNetEvent('consumables:server:resetArmor', function()
    local Player = TA2Core.Functions.GetPlayer(source)
    if not Player then return end
    exports['ta2-inventory']:AddItem(source, 'heavyarmor', 1, false, false, 'consumables:server:resetArmor')
end)

RegisterNetEvent('consumables:server:useHeavyArmor', function()
    local Player = TA2Core.Functions.GetPlayer(source)
    if not Player then return end
    if not exports['ta2-inventory']:RemoveItem(source, 'heavyarmor', 1, false, 'consumables:server:useHeavyArmor') then return end
    TriggerClientEvent('ta2-inventory:client:ItemBox', source, TA2Core.Shared.Items['heavyarmor'], 'remove')
    TriggerClientEvent('hospital:server:SetArmor', source, 100)
    SetPedArmour(GetPlayerPed(source), 100)
end)

RegisterNetEvent('consumables:server:useArmor', function()
    local Player = TA2Core.Functions.GetPlayer(source)
    if not Player then return end
    if not exports['ta2-inventory']:RemoveItem(source, 'armor', 1, false, 'consumables:server:useArmor') then return end
    TriggerClientEvent('ta2-inventory:client:ItemBox', source, TA2Core.Shared.Items['armor'], 'remove')
    TriggerClientEvent('hospital:server:SetArmor', source, 75)
    SetPedArmour(GetPlayerPed(source), 75)
end)

RegisterNetEvent('consumables:server:useMeth', function()
    local Player = TA2Core.Functions.GetPlayer(source)
    if not Player then return end
    exports['ta2-inventory']:RemoveItem(source, 'meth', 1, false, 'consumables:server:useMeth')
end)

RegisterNetEvent('consumables:server:useOxy', function()
    local Player = TA2Core.Functions.GetPlayer(source)
    if not Player then return end
    exports['ta2-inventory']:RemoveItem(source, 'oxy', 1, false, 'consumables:server:useOxy')
end)

RegisterNetEvent('consumables:server:useXTCBaggy', function()
    local Player = TA2Core.Functions.GetPlayer(source)
    if not Player then return end
    exports['ta2-inventory']:RemoveItem(source, 'xtcbaggy', 1, false, 'consumables:server:useXTCBaggy')
end)

RegisterNetEvent('consumables:server:useCrackBaggy', function()
    local Player = TA2Core.Functions.GetPlayer(source)
    if not Player then return end
    exports['ta2-inventory']:RemoveItem(source, 'crack_baggy', 1, false, 'consumables:server:useCrackBaggy')
end)

RegisterNetEvent('consumables:server:useCokeBaggy', function()
    local Player = TA2Core.Functions.GetPlayer(source)
    if not Player then return end
    exports['ta2-inventory']:RemoveItem(source, 'cokebaggy', 1, false, 'consumables:server:useCokeBaggy')
end)

RegisterNetEvent('consumables:server:drinkAlcohol', function(item)
    local Player = TA2Core.Functions.GetPlayer(source)
    if not Player then return end
    local foundItem = nil

    for k in pairs(Config.Consumables.alcohol) do
        if k == item then
            foundItem = k
            break
        end
    end

    if not foundItem then return end
    exports['ta2-inventory']:RemoveItem(source, foundItem, 1, false, 'consumables:server:drinkAlcohol')
end)

RegisterNetEvent('consumables:server:UseFirework', function(item)
    local Player = TA2Core.Functions.GetPlayer(source)
    if not Player then return end
    local foundItem = nil

    for i = 1, #Config.Fireworks.items do
        if Config.Fireworks.items[i] == item then
            foundItem = Config.Fireworks.items[i]
            break
        end
    end

    if not foundItem then return end
    exports['ta2-inventory']:RemoveItem(source, foundItem, 1, false, 'consumables:server:UseFirework')
end)

RegisterNetEvent('consumables:server:addThirst', function(amount)
    local Player = TA2Core.Functions.GetPlayer(source)
    if not Player then return end
    Player.Functions.SetMetaData('thirst', amount)
    TriggerClientEvent('hud:client:UpdateNeeds', source, Player.PlayerData.metadata.hunger, amount)
end)

RegisterNetEvent('consumables:server:addHunger', function(amount)
    local Player = TA2Core.Functions.GetPlayer(source)
    if not Player then return end
    Player.Functions.SetMetaData('hunger', amount)
    TriggerClientEvent('hud:client:UpdateNeeds', source, amount, Player.PlayerData.metadata.thirst)
end)

TA2Core.Functions.CreateCallback('consumables:itemdata', function(_, cb, itemName)
    cb(Config.Consumables.custom[itemName])
end)

---Checks if item already exists in the table. If not, it creates it.
---@param drinkName string name of item
---@param replenish number amount it replenishes
---@return boolean, string
local function addDrink(drinkName, replenish)
    if Config.Consumables.drink[drinkName] ~= nil then
        return false, 'already added'
    else
        Config.Consumables.drink[drinkName] = replenish
        createItem(drinkName, 'Drink')
        return true, 'success'
    end
end

exports('AddDrink', addDrink)

---Checks if item already exists in the table. If not, it creates it.
---@param foodName string name of item
---@param replenish number amount it replenishes
---@return boolean, string
local function addFood(foodName, replenish)
    if Config.Consumables.eat[foodName] ~= nil then
        return false, 'already added'
    else
        Config.Consumables.eat[foodName] = replenish
        createItem(foodName, 'Eat')
        return true, 'success'
    end
end

exports('AddFood', addFood)

---Checks if item already exists in the table. If not, it creates it.
---@param alcoholName string name of item
---@param replenish number amount it replenishes
---@return boolean, string
local function addAlcohol(alcoholName, replenish)
    if Config.Consumables.alcohol[alcoholName] ~= nil then
        return false, 'already added'
    else
        Config.Consumables.alcohol[alcoholName] = replenish
        createItem(alcoholName, 'DrinkAlcohol')
        return true, 'success'
    end
end

exports('AddAlcohol', addAlcohol)

---Checks if item already exists in the table. If not, it creates it.
---@param itemName string name of item
---@param data number amount it replenishes
---@return boolean, string
local function addCustom(itemName, data)
    if Config.Consumables.custom[itemName] ~= nil then
        return false, 'already added'
    else
        Config.Consumables.custom[itemName] = data
        createItem(itemName, 'Custom')
        return true, 'success'
    end
end

exports('AddCustom', addCustom)
