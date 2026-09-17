local isOpen = false
local activeShopId = nil
local activeShopName = nil
local spawnedPeds = {}
local shopBlips = {}
local marketPrompt = nil
local marketPromptGroup = GetRandomIntInRange(0, 0xFFFFFF)

local function CloseMarket()
    if not isOpen then
        return
    end

    isOpen = false
    activeShopId = nil
    activeShopName = nil
    SetNuiFocus(false, false)
    SendNUIMessage({ action = "close" })
end

local function OpenMarket(shopId, shopName)
    if isOpen then
        return
    end

    activeShopId = shopId
    activeShopName = shopName
    isOpen = true
    SetNuiFocus(true, true)

    TriggerServerEvent("cagan-market:server:openShop", shopId)
end

RegisterNetEvent("cagan-market:client:openUI", function(payload)
    if not isOpen then
        return
    end

    local lang = (Config and (Config.DefaultLocale or (type(Config.Locale) == "string" and Config.Locale))) or "tr"
    local currentDict = (Locales and (Locales[lang] or Locales["en"])) or {}
    local locale = {}
    for key, value in pairs(currentDict) do
        locale[key] = value
    end
    if payload.mode == "sell" then
        locale.cart = _U("sellTitle")
        locale.buy = _U("sellButton")
        locale.success = _U("sellSuccess")
    end

    SendNUIMessage({
        action = "open",
        shopId = payload.shopId,
        shopName = payload.shopName,
        marketType = payload.marketType,
        mode = payload.mode,
        items = payload.items,
        locale = locale,
    })
end)

RegisterNUICallback("close", function(_, cb)
    CloseMarket()
    cb({ ok = true })
end)

local lastBuyClick = 0
RegisterNUICallback("buy", function(data, cb)
    if not isOpen or not activeShopId then
        cb({ ok = false, message = _U("storeNotOpen") })
        return
    end

    local now = GetGameTimer()
    if (now - lastBuyClick) < 1500 then
        cb({ ok = false, message = _U("pleaseWait") })
        return
    end
    lastBuyClick = now

    TriggerServerEvent("cagan-market:server:buy", activeShopId, data.cart or {})
    cb({ ok = true })
end)

local lastMarketNotify = 0
RegisterNetEvent("cagan-market:client:notify", function(message, notifyType)
    local msg = tostring(message or '')
    local isSuccess = false
    if notifyType then
        isSuccess = (notifyType == "success")
    else
        isSuccess = msg:find('%$') ~= nil or msg:lower():find('success') ~= nil or msg:lower():find('basari') ~= nil or msg:lower():find('satin alindi') ~= nil or msg:lower():find('purchased') ~= nil
    end

    local now = GetGameTimer()
    if (now - lastMarketNotify) > 250 then
        lastMarketNotify = now
        if isSuccess then
            PlaySoundFrontend(-1, "CONFIRM_BEEP", "HUD_SHOP_SOUNDSET", true)
        else
            PlaySoundFrontend(-1, "ERROR", "HUD_SHOP_SOUNDSET", true)
        end
    end

    ClientBridge.Notify(message, isSuccess and "success" or "error")
end)

local function removeShopPeds()
    for _, ped in ipairs(spawnedPeds) do
        if DoesEntityExist(ped) then
            SetEntityAsMissionEntity(ped, true, true)
            DeleteEntity(ped)
        end
    end
    spawnedPeds = {}
end

local function loadModel(modelName)
    local modelHash = joaat(modelName)
    if not IsModelValid(modelHash) then
        return nil
    end

    RequestModel(modelHash, false)
    while not HasModelLoaded(modelHash) do
        Wait(50)
    end

    return modelHash
end

local function stabilizePedOnGround(ped, coords, targetZ)
    if not ped or not DoesEntityExist(ped) or not coords then
        return
    end

    local z = tonumber(targetZ) or coords.z
    for _ = 1, 10 do
        RequestCollisionAtCoord(coords.x, coords.y, coords.z)
        SetEntityCoordsNoOffset(ped, coords.x, coords.y, z, false, false, false)
        Wait(100)
    end
end

local function clearShopBlips()
    for i = #shopBlips, 1, -1 do
        local blip = shopBlips[i]
        if blip then
            RemoveBlip(blip)
        end
        shopBlips[i] = nil
    end
end

local function setupShopBlips()
    clearShopBlips()
    local blipCfg = Config.ShopBlips
    if not blipCfg or not blipCfg.enabled then
        return
    end

    local scale = blipCfg.scale or 0.2
    local spriteByType = {
        gunsmith = blipCfg.gunsmithSprite or joaat("blip_shop_gunsmith"),
        wapiti_gunsmith = blipCfg.gunsmithSprite or joaat("blip_shop_gunsmith"),
        horse = blipCfg.horseSprite or joaat("blip_shop_horse"),
        hardware = blipCfg.hardwareSprite or joaat("blip_shop_blacksmith"),
        farming = blipCfg.farmingSprite or joaat("blip_shop_store"),
        moonshine_supplies = blipCfg.farmingSprite or joaat("blip_shop_store"),
        moonshine_products = blipCfg.saloonSprite or 1879260108,
        saloon = blipCfg.saloonSprite or 1879260108,
        blackwater_saloon = blipCfg.saloonSprite or 1879260108,
        valentine_saloon = blipCfg.saloonSprite or 1879260108,
    }

    for _, shop in ipairs(Config.Shops) do
        if shop.showBlip ~= false then
            local sprite = spriteByType[shop.marketType]
            if sprite then
                local coords = shop.coords
                local blip = Citizen.InvokeNative(0x554D9D53F696D002, 1664425300, coords)
                TriggerEvent('nyks_hud:registerCompassBlip', ('%s:%s'):format(GetCurrentResourceName(), tostring(blip)), coords)
                SetBlipSprite(blip, sprite, true)
                SetBlipScale(blip, scale)
                local mt = shop.marketType and Config.MarketTypes[shop.marketType]
                local fallbackLabel = mt and mt.label or "Market"
                local label = CreateVarString(10, "LITERAL_STRING", shop.name or fallbackLabel)
                Citizen.InvokeNative(0x9CB1A1623062F402, blip, label)
                shopBlips[#shopBlips + 1] = blip
            end
        end
    end

    for _, entry in ipairs(Config.ExtraBlips or {}) do
        if entry.enabled ~= false and entry.coords and entry.sprite then
            local c = entry.coords
            local coords = vector3(c.x, c.y, c.z)
            local blip = Citizen.InvokeNative(0x554D9D53F696D002, 1664425300, coords)
            TriggerEvent('nyks_hud:registerCompassBlip', ('%s:%s'):format(GetCurrentResourceName(), tostring(blip)), coords)
            SetBlipSprite(blip, entry.sprite, true)
            SetBlipScale(blip, entry.scale or scale)
            local label = CreateVarString(10, "LITERAL_STRING", entry.name or "Blip")
            Citizen.InvokeNative(0x9CB1A1623062F402, blip, label)
            shopBlips[#shopBlips + 1] = blip
        end
    end
end

local function setupShopPeds()
    removeShopPeds()

    for _, shop in ipairs(Config.Shops) do
        local modelName = shop.npcModel or Config.DefaultNpcModel
        local modelHash = loadModel(modelName)
        if modelHash then
            local heading = shop.npcHeading or Config.DefaultNpcHeading or 0.0
            local zOffset = shop.npcZOffset or Config.DefaultNpcZOffset or 0.0
            local spawnZ = shop.coords.z + zOffset
            local ped = CreatePed(modelHash, shop.coords.x, shop.coords.y, spawnZ, heading, false, false, false, false)

            if DoesEntityExist(ped) then
                Citizen.InvokeNative(0x283978A15512B2FE, ped, true)
                stabilizePedOnGround(ped, shop.coords, spawnZ)
                SetEntityCanBeDamaged(ped, false)
                SetEntityInvincible(ped, true)
                SetPedCanRagdoll(ped, false)
                SetPedCanBeTargetted(ped, false)
                SetPedCanBeTargettedByPlayer(ped, PlayerId(), false)
                SetBlockingOfNonTemporaryEvents(ped, true)
                FreezeEntityPosition(ped, true)
                spawnedPeds[#spawnedPeds + 1] = ped
            end

            SetModelAsNoLongerNeeded(modelHash)
        end
    end
end

local function createMarketPrompt()
    if marketPrompt then
        UiPromptDelete(marketPrompt)
        marketPrompt = nil
    end

    marketPrompt = UiPromptRegisterBegin()
    UiPromptSetControlAction(marketPrompt, Config.OpenKey or 0xDFF812F9)
    UiPromptSetText(marketPrompt, CreateVarString(10, "LITERAL_STRING", _U("openLabel")))
    UiPromptSetEnabled(marketPrompt, true)
    UiPromptSetVisible(marketPrompt, true)
    UiPromptSetHoldMode(marketPrompt, Config.OpenHoldMs or 700)
    UiPromptSetGroup(marketPrompt, marketPromptGroup, 0)
    UiPromptRegisterEnd(marketPrompt)
end

CreateThread(function()
    Wait(500)
    setupShopBlips()
    setupShopPeds()
    createMarketPrompt()

    while true do
        local sleep = 1000
        if not isOpen then
            local ped = PlayerPedId()
            if DoesEntityExist(ped) and not IsEntityDead(ped) then
                local pCoords = GetEntityCoords(ped)
                local nearestShop = nil
                local nearestDistance = (Config.OpenDistance or 2.0) + 1.0

                for _, shop in ipairs(Config.Shops) do
                    local d = #(pCoords - shop.coords)
                    if d < nearestDistance then
                        nearestDistance = d
                        nearestShop = shop
                    end
                end

                if nearestShop and nearestDistance <= (Config.OpenDistance or 2.0) then
                    sleep = 0
                    local groupLabel = CreateVarString(10, "LITERAL_STRING", nearestShop.name or "Store")
                    UiPromptSetActiveGroupThisFrame(marketPromptGroup, groupLabel, 0, 0, 0, 0)
                    if UiPromptHasHoldModeCompleted(marketPrompt) then
                        OpenMarket(nearestShop.id, nearestShop.name)
                        Wait(700)
                    end
                end
            end
        end
        Wait(sleep)
    end
end)

AddEventHandler("onResourceStop", function(resourceName)
    if resourceName ~= GetCurrentResourceName() then
        return
    end

    removeShopPeds()
    clearShopBlips()
    if marketPrompt then
        UiPromptDelete(marketPrompt)
        marketPrompt = nil
    end
    SetNuiFocus(false, false)
end)
