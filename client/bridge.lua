ClientBridge = {}

local RSGCore = nil

function ClientBridge.GetFramework()
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
    local fw = ClientBridge.GetFramework()
    if fw == 'rsg' then
        pcall(function()
            RSGCore = exports['rsg-core']:GetCoreObject()
        end)
    end
end)

function ClientBridge.GetImageBasePath()
    if Config.ImageBasePath and Config.ImageBasePath ~= "auto" then
        return Config.ImageBasePath
    end
    local fw = ClientBridge.GetFramework()
    if fw == 'rsg' then
        return "nui://rsg-inventory/html/images/"
    else
        return "nui://vorp_inventory/html/img/items/"
    end
end

function ClientBridge.Notify(message, notifyType)
    local msg = tostring(message or '')
    local nType = notifyType
    if not nType then
        local isSuccess = msg:find('%$') ~= nil or msg:lower():find('success') ~= nil or msg:lower():find('basari') ~= nil or msg:lower():find('satin alindi') ~= nil or msg:lower():find('purchased') ~= nil
        nType = isSuccess and 'success' or 'error'
    end

    local ok = pcall(function()
        TriggerEvent('ox_lib:notify', {
            title       = 'STORE',
            description = msg,
            type        = nType,
            position    = 'top-right',
            duration    = 7000,
        })
    end)

    if not ok then
        local fw = ClientBridge.GetFramework()
        if fw == 'rsg' then
            if not RSGCore then
                pcall(function() RSGCore = exports['rsg-core']:GetCoreObject() end)
            end
            if RSGCore and RSGCore.Functions and RSGCore.Functions.Notify then
                RSGCore.Functions.Notify(msg, nType, 7000)
            else
                TriggerEvent("RSGCore:Notify", msg, nType, 7000)
            end
        else
            TriggerEvent("vorp:TipBottom", message, 7000)
        end
    end
end
