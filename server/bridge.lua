ServerBridge = {}

local VorpCore = {}
local VorpInv = nil
local RSGCore = nil

function ServerBridge.GetFramework()
    local fw = (Config.Framework or 'auto'):lower()
    if fw ~= 'auto' then return fw end

    if GetResourceState('vorp_core') == 'started' or GetResourceState('vorp_inventory') == 'started' then
        return 'vorp'
    elseif GetResourceState('rsg-core') == 'started' or GetResourceState('rsg-inventory') == 'started' then
        return 'rsg'
    end
    return 'vorp'
end

CreateThread(function()
    local fw = ServerBridge.GetFramework()
    if fw == 'vorp' then
        TriggerEvent("getCore", function(core)
            VorpCore = core
        end)
        pcall(function()
            VorpInv = exports.vorp_inventory:vorp_inventoryApi()
        end)
    elseif fw == 'rsg' then
        pcall(function()
            RSGCore = exports['rsg-core']:GetCoreObject()
        end)
    end
end)

function ServerBridge.GetCharacter(src)
    local fw = ServerBridge.GetFramework()
    if fw == 'vorp' then
        if not VorpCore or not VorpCore.getUser then
            TriggerEvent("getCore", function(core) VorpCore = core end)
        end
        local user = VorpCore and VorpCore.getUser and VorpCore.getUser(src)
        if not user or not user.getUsedCharacter then return nil end
        local ch = user.getUsedCharacter
        local fn = tostring(ch.firstname or ""):gsub("^%s+", ""):gsub("%s+$", "")
        local ln = tostring(ch.lastname or ""):gsub("^%s+", ""):gsub("%s+$", "")
        local fullName = (fn .. " " .. ln):gsub("^%s+", ""):gsub("%s+$", "")
        return {
            charId = tostring(ch.charIdentifier or "?"),
            name = fullName ~= "" and fullName or "-",
            job = tostring(ch.job or ""):lower(),
            jobGrade = tonumber(ch.jobGrade or 0) or 0,
            money = tonumber(ch.money or 0) or 0,
            raw = ch
        }
    elseif fw == 'rsg' then
        if not RSGCore then
            pcall(function() RSGCore = exports['rsg-core']:GetCoreObject() end)
        end
        if not RSGCore then return nil end
        local Player = RSGCore.Functions.GetPlayer(src)
        if not Player then return nil end
        local charinfo = Player.PlayerData.charinfo or {}
        local job = Player.PlayerData.job or {}
        local fn = tostring(charinfo.firstname or ""):gsub("^%s+", ""):gsub("%s+$", "")
        local ln = tostring(charinfo.lastname or ""):gsub("^%s+", ""):gsub("%s+$", "")
        local fullName = (fn .. " " .. ln):gsub("^%s+", ""):gsub("%s+$", "")
        local money = Player.PlayerData.money and tonumber(Player.PlayerData.money['cash'] or 0) or 0
        return {
            charId = tostring(Player.PlayerData.citizenid or "?"),
            name = fullName ~= "" and fullName or "-",
            job = tostring(job.name or ""):lower(),
            jobGrade = tonumber(job.grade and job.grade.level or 0) or 0,
            money = money,
            raw = Player
        }
    end
    return nil
end

function ServerBridge.GetMoney(src)
    local char = ServerBridge.GetCharacter(src)
    return char and char.money or 0
end

function ServerBridge.RemoveMoney(src, amount)
    local fw = ServerBridge.GetFramework()
    if fw == 'vorp' then
        local char = ServerBridge.GetCharacter(src)
        if char and char.raw and char.raw.removeCurrency then
            char.raw.removeCurrency(0, amount)
            return true
        end
    elseif fw == 'rsg' then
        if not RSGCore then pcall(function() RSGCore = exports['rsg-core']:GetCoreObject() end) end
        if RSGCore then
            local Player = RSGCore.Functions.GetPlayer(src)
            if Player then
                return Player.Functions.RemoveMoney('cash', amount, "cagan-market-buy")
            end
        end
    end
    return false
end

function ServerBridge.AddMoney(src, amount)
    local fw = ServerBridge.GetFramework()
    if fw == 'vorp' then
        local char = ServerBridge.GetCharacter(src)
        if char and char.raw and char.raw.addCurrency then
            char.raw.addCurrency(0, amount)
            return true
        end
    elseif fw == 'rsg' then
        if not RSGCore then pcall(function() RSGCore = exports['rsg-core']:GetCoreObject() end) end
        if RSGCore then
            local Player = RSGCore.Functions.GetPlayer(src)
            if Player then
                return Player.Functions.AddMoney('cash', amount, "cagan-market-sell")
            end
        end
    end
    return false
end

function ServerBridge.CanCarry(src, itemName, amount, isWeapon)
    local fw = ServerBridge.GetFramework()
    if fw == 'vorp' then
        if isWeapon then
            return exports.vorp_inventory:canCarryWeapons(src, amount, nil, itemName)
        else
            return exports.vorp_inventory:canCarryItem(src, itemName, amount)
        end
    elseif fw == 'rsg' then
        return true
    end
    return true
end

function ServerBridge.AddItem(src, itemName, amount, isWeapon)
    local fw = ServerBridge.GetFramework()
    if fw == 'vorp' then
        if not VorpInv then
            pcall(function() VorpInv = exports.vorp_inventory:vorp_inventoryApi() end)
        end
        if isWeapon then
            for _ = 1, amount do
                exports.vorp_inventory:createWeapon(src, itemName)
            end
        else
            if VorpInv and VorpInv.addItem then
                VorpInv.addItem(src, itemName, amount)
            else
                exports.vorp_inventory:addItem(src, itemName, amount)
            end
        end
        return true
    elseif fw == 'rsg' then
        if not RSGCore then pcall(function() RSGCore = exports['rsg-core']:GetCoreObject() end) end
        if RSGCore then
            local Player = RSGCore.Functions.GetPlayer(src)
            if Player then
                local added = Player.Functions.AddItem(itemName:lower(), amount)
                if added then
                    TriggerClientEvent('inventory:client:ItemBox', src, RSGCore.Shared.Items[itemName:lower()] or { name = itemName, label = itemName }, 'add')
                    return true
                end
            end
        end
    end
    return false
end

function ServerBridge.GetItemCount(src, itemName)
    local fw = ServerBridge.GetFramework()
    if fw == 'vorp' then
        return tonumber(exports.vorp_inventory:getItemCount(src, nil, itemName)) or 0
    elseif fw == 'rsg' then
        if not RSGCore then pcall(function() RSGCore = exports['rsg-core']:GetCoreObject() end) end
        if RSGCore then
            local Player = RSGCore.Functions.GetPlayer(src)
            if Player then
                local item = Player.Functions.GetItemByName(itemName:lower())
                return item and tonumber(item.amount) or 0
            end
        end
    end
    return 0
end

function ServerBridge.RemoveItem(src, itemName, amount)
    local fw = ServerBridge.GetFramework()
    if fw == 'vorp' then
        return exports.vorp_inventory:subItem(src, itemName, amount)
    elseif fw == 'rsg' then
        if not RSGCore then pcall(function() RSGCore = exports['rsg-core']:GetCoreObject() end) end
        if RSGCore then
            local Player = RSGCore.Functions.GetPlayer(src)
            if Player then
                local removed = Player.Functions.RemoveItem(itemName:lower(), amount)
                if removed then
                    TriggerClientEvent('inventory:client:ItemBox', src, RSGCore.Shared.Items[itemName:lower()] or { name = itemName, label = itemName }, 'remove')
                    return true
                end
            end
        end
    end
    return false
end

function ServerBridge.GetImageBasePath()
    if Config.ImageBasePath and Config.ImageBasePath ~= "auto" then
        return Config.ImageBasePath
    end
    local fw = ServerBridge.GetFramework()
    if fw == 'rsg' then
        return "nui://rsg-inventory/html/images/"
    else
        return "nui://vorp_inventory/html/img/items/"
    end
end
