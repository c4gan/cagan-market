local rateLimits = {}

local function guard(src, key, ms)
    if not ms or ms <= 0 then
        return true
    end
    local now = GetGameTimer()
    rateLimits[src] = rateLimits[src] or {}
    local last = rateLimits[src][key] or 0
    if (now - last) < ms then
        return false
    end
    rateLimits[src][key] = now
    return true
end

AddEventHandler("playerDropped", function()
    rateLimits[source] = nil
end)

local function notify(src, message, nType)
    TriggerClientEvent("cagan-market:client:notify", src, message, nType or "error")
end

local function sendDiscordWebhook(webhookUrl, embed, botName, botAvatar)
    if not webhookUrl or webhookUrl == "" then
        return
    end

    local payload = json.encode({
        username = (botName and botName ~= "") and botName or "cagan-market",
        avatar_url = (botAvatar and botAvatar ~= "") and botAvatar or nil,
        embeds = { embed }
    })

    PerformHttpRequest(webhookUrl, function(status, text, headers)
        if status < 200 or status >= 300 then
            print(("[cagan-market] Discord webhook response: HTTP %s"):format(tostring(status)))
        end
    end, "POST", payload, { ["Content-Type"] = "application/json" })
end

local function logMarketPurchase(src, shop, marketType, validCart, totalPrice)
    local cfg = Config.DiscordLog
    if not cfg or cfg.enabled == false or not cfg.webhook or cfg.webhook == "" then
        return
    end

    local pedName = GetPlayerName(src) or "?"
    local char = ServerBridge.GetCharacter(src)
    local charId = char and char.charId or "?"
    local charName = char and char.name or "-"

    local lines = {}
    for _, line in ipairs(validCart) do
        lines[#lines + 1] = string.format("• **%s** ×%d → $%.2f", line.label or line.name, line.amount, line.price * line.amount)
    end
    local cartText = table.concat(lines, "\n")
    if #cartText > 950 then
        cartText = cartText:sub(1, 947) .. "..."
    end
    if cartText == "" then
        cartText = "-"
    end

    local discordId = "None"
    for _, id in ipairs(GetPlayerIdentifiers(src) or {}) do
        if type(id) == "string" and id:find("discord:") == 1 then
            discordId = "<@" .. id:sub(9) .. ">"
            break
        end
    end

    local embed = {
        title = "🛒 Store Purchase",
        description = ("**%s** made a purchase at **%s**."):format(pedName, shop.name or shop.id),
        color = 3066993,
        fields = {
            { name = "Player", value = pedName, inline = true },
            { name = "Server ID", value = tostring(src), inline = true },
            { name = "Char ID", value = charId, inline = true },
            { name = "Character", value = charName, inline = true },
            { name = "Discord", value = discordId, inline = true },
            { name = "Store", value = shop.name or shop.id, inline = true },
            { name = "Total", value = string.format("$%.2f", totalPrice), inline = true },
            { name = "Market Type", value = marketType.label or shop.marketType or "Standard", inline = true },
            { name = "Purchased Items", value = cartText, inline = false },
        },
        footer = {
            text = "cagan-market Logging • " .. os.date("!%Y-%m-%d %H:%M:%SZ")
        }
    }

    sendDiscordWebhook(cfg.webhook, embed, cfg.botName, cfg.botAvatar)
end

local function getShopById(shopId)
    for _, shop in ipairs(Config.Shops) do
        if shop.id == shopId then
            return shop
        end
    end
    return nil
end

local function getMarketType(key)
    return Config.MarketTypes[key]
end

local function isWeaponLine(cfg)
    if cfg.weapon == true then
        return true
    end
    if cfg.weapon == false then
        return false
    end
    local n = tostring(cfg.name or ""):upper()
    return n:sub(1, 7) == "WEAPON_"
end

local function hasJobAccess(src, marketType, shop)
    local char = ServerBridge.GetCharacter(src)
    if not char then
        return false
    end

    local playerJob = tostring(char.job or ""):lower()

    local function listAllows(list)
        if not list or #list == 0 then
            return true
        end
        for _, job in ipairs(list) do
            if playerJob == tostring(job):lower() then
                return true
            end
        end
        return false
    end

    if not listAllows(marketType.jobs) then
        return false
    end

    if not listAllows(shop.jobs) then
        return false
    end

    return true
end

local function sanitizeAndPriceCart(marketItems, cart)
    local itemMap = {}
    for _, item in ipairs(marketItems) do
        itemMap[item.name] = item
    end

    local sanitized = {}
    local total = 0.0

    for _, row in ipairs(cart or {}) do
        local name = tostring(row.name or "")
        local amount = tonumber(row.amount or 0) or 0
        amount = math.floor(amount)

        local cfg = itemMap[name]
        if cfg and amount > 0 then
            local lineTotal = cfg.price * amount
            total = total + lineTotal
            sanitized[#sanitized + 1] = {
                name = cfg.name,
                amount = amount,
                price = cfg.price,
                weapon = isWeaponLine(cfg),
                patronCustom = cfg.patronCustom == true,
                isCustom = tostring(cfg.category or "") == "Custom" or tostring(cfg.category or "") == "Ozel" or cfg.patronCustom == true,
            }
        end
    end

    return sanitized, total
end

local function applyPatronCustomPurchase(shopId, validCart, totalPrice)
    if not shopId then
        return true, nil
    end

    local customTotal = 0.0

    for _, line in ipairs(validCart) do
        local row = MySQL.single.await(
            "SELECT id, stock FROM cagan_market_patron_custom WHERE shop_id = ? AND LOWER(TRIM(item_name)) = LOWER(TRIM(?))",
            { shopId, line.name }
        )
        if row then
            local affected = MySQL.update.await(
                "UPDATE cagan_market_patron_custom SET stock = CASE WHEN stock IS NULL THEN NULL ELSE stock - ? END WHERE id = ? AND (stock IS NULL OR stock >= ?)",
                { line.amount, row.id, line.amount }
            )
            if (tonumber(affected) or 0) <= 0 then
                return false, ("Insufficient stock: %s"):format(line.name)
            end
            customTotal = customTotal + ((tonumber(line.price) or 0) * (tonumber(line.amount) or 0))
        elseif line.isCustom == true then
            return false, ("Custom item not found: %s"):format(line.name)
        end
    end

    if customTotal > 0 then
        MySQL.update.await(
            "INSERT INTO cagan_market_patron (shop_id, owner_charid, safe_balance) VALUES (?, NULL, ?) ON DUPLICATE KEY UPDATE safe_balance = safe_balance + VALUES(safe_balance)",
            { shopId, customTotal }
        )
    end

    return true, nil
end

local function mergePatronIntoBaseCatalog(baseItems, patronItems)
    if type(baseItems) ~= "table" then
        return {}
    end
    if type(patronItems) ~= "table" then
        return baseItems
    end

    local merged = {}
    local baseByName = {}
    local patronList = {}

    for _, item in ipairs(baseItems) do
        local copy = {
            name = item.name,
            label = item.label or item.name,
            price = item.price,
            description = item.description or "",
            category = item.category or "Other",
            image = item.image,
            weapon = item.weapon,
        }
        merged[#merged + 1] = copy
        baseByName[tostring(copy.name)] = copy
    end

    for _, p in pairs(patronItems) do
        if type(p) == "table" then
            patronList[#patronList + 1] = p
        end
    end

    if #patronList == 0 then
        return baseItems
    end

    for _, p in ipairs(patronList) do
        local pName = tostring(p.name or "")
        if pName ~= "" then
            local existing = baseByName[pName]
            if not existing then
                merged[#merged + 1] = {
                    name = p.name,
                    label = p.label or p.name,
                    price = p.price or 0,
                    description = p.description or "",
                    category = p.category or "Custom",
                    image = p.image,
                    weapon = p.weapon,
                    stock = p.stock,
                    patronCustom = true,
                }
            end
        end
    end

    return merged
end

local function appendPatronCustomItems(baseItems, shopId)
    if type(baseItems) ~= "table" then
        return {}
    end
    if not shopId then
        return baseItems
    end

    local existingByName = {}
    for _, item in ipairs(baseItems) do
        existingByName[tostring(item.name)] = true
    end

    local rows = MySQL.query.await(
        "SELECT item_name, label, description, price, stock FROM cagan_market_patron_custom WHERE shop_id = ?",
        { shopId }
    ) or {}

    for _, r in pairs(rows) do
        local name = tostring(r.item_name or r.name or "")
        if name ~= "" and not existingByName[name] then
            baseItems[#baseItems + 1] = {
                name = name,
                label = tostring(r.label or name),
                price = tonumber(r.price) or 0,
                description = tostring(r.description or "Custom listing"),
                category = "Custom",
                image = Config.ImageBasePath .. name .. ".png",
                stock = tonumber(r.stock),
                patronCustom = true,
            }
            existingByName[name] = true
        end
    end

    return baseItems
end

RegisterNetEvent("cagan-market:server:openShop", function(shopId)
    local src = source
    if not guard(src, 'cagan-market:open', 350) then
        return
    end
    local shop = getShopById(shopId)
    if not shop then
        notify(src, _U("noAccess"))
        return
    end

    local marketType = getMarketType(shop.marketType)
    if not marketType then
        notify(src, _U("invalidStore"))
        return
    end

    if not hasJobAccess(src, marketType, shop) then
        notify(src, _U("noAccess"))
        return
    end

    local items = {}
    for _, item in ipairs(marketType.items or {}) do
        items[#items + 1] = {
            name = item.name,
            label = item.label or item.name,
            price = item.price,
            description = item.description or "",
            category = item.category or "Other",
            image = item.image or (ServerBridge.GetImageBasePath() .. item.name .. ".png")
        }
    end

    local ok, patronCatalog = pcall(function()
        return exports["cagan-market-patron"]:GetCatalogForShop(shop.id, shop.marketType)
    end)
    if ok then
        items = mergePatronIntoBaseCatalog(items, patronCatalog)
    end
    items = appendPatronCustomItems(items, shop.id)

    TriggerClientEvent("cagan-market:client:openUI", src, {
        shopId = shop.id,
        shopName = shop.name,
        marketType = marketType.label,
        mode = shop.mode or "buy",
        items = items
    })
end)

RegisterNetEvent("cagan-market:server:buy", function(shopId, cart)
    local src = source
    if not guard(src, 'cagan-market:buy', 1500) then
        return
    end
    local shop = getShopById(shopId)
    if not shop then
        notify(src, _U("noAccess"))
        return
    end

    local marketType = getMarketType(shop.marketType)
    if not marketType then
        notify(src, _U("invalidStore"))
        return
    end

    if not hasJobAccess(src, marketType, shop) then
        notify(src, _U("noAccess"))
        return
    end

    local catalogItems = {}
    for _, item in ipairs(marketType.items or {}) do
        catalogItems[#catalogItems + 1] = {
            name = item.name,
            label = item.label or item.name,
            price = item.price,
            description = item.description or "",
            category = item.category or "Other",
            image = item.image or (ServerBridge.GetImageBasePath() .. item.name .. ".png"),
            weapon = item.weapon,
        }
    end
    local ok, patronCatalog = pcall(function()
        return exports["cagan-market-patron"]:GetCatalogForShop(shop.id, shop.marketType)
    end)
    if ok then
        catalogItems = mergePatronIntoBaseCatalog(catalogItems, patronCatalog)
    end
    catalogItems = appendPatronCustomItems(catalogItems, shop.id)

    local validCart, totalPrice = sanitizeAndPriceCart(catalogItems, cart)
    if #validCart == 0 or totalPrice <= 0 then
        notify(src, _U("cartEmpty"))
        return
    end

    local character = ServerBridge.GetCharacter(src)
    if not character then
        return
    end

    if shop.mode == "sell" then
        local totalsByItem = {}
        for _, line in ipairs(validCart) do
            totalsByItem[line.name] = (totalsByItem[line.name] or 0) + line.amount
        end

        for itemName, amount in pairs(totalsByItem) do
            local have = ServerBridge.GetItemCount(src, itemName)
            if have < amount then
                notify(src, _U("notEnoughItem", itemName))
                return
            end
        end

        local removedItems = {}
        for itemName, amount in pairs(totalsByItem) do
            local removed = ServerBridge.RemoveItem(src, itemName, amount)
            if removed == false or removed == nil then
                for rollbackName, rollbackAmount in pairs(removedItems) do
                    ServerBridge.AddItem(src, rollbackName, rollbackAmount, false)
                end
                notify(src, _U("inventoryError"))
                return
            end
            removedItems[itemName] = amount
        end

        ServerBridge.AddMoney(src, totalPrice)
        notify(src, ("%s ($%.2f)"):format(_U("sellSuccess"), totalPrice), "success")
        return
    end

    for _, line in ipairs(validCart) do
        local canCarry = ServerBridge.CanCarry(src, line.name, line.amount, line.weapon)
        if not canCarry then
            notify(src, _U("noCarry"), "error")
            return
        end
    end

    local cash = ServerBridge.GetMoney(src)
    if cash < totalPrice then
        notify(src, _U("noMoney"), "error")
        return
    end

    ServerBridge.RemoveMoney(src, totalPrice)

    local okBuy, errBuy = applyPatronCustomPurchase(shop.id, validCart, totalPrice)
    if not okBuy then
        ServerBridge.AddMoney(src, totalPrice)
        notify(src, errBuy or _U("stockError"), "error")
        return
    end

    for _, line in ipairs(validCart) do
        ServerBridge.AddItem(src, line.name, line.amount, line.weapon)
    end

    logMarketPurchase(src, shop, marketType, validCart, totalPrice)

    notify(src, ("%s ($%.2f)"):format(_U("success"), totalPrice), "success")
end)

exports("GetConfigMarketTypes", function()
    return Config.MarketTypes
end)

exports("GetShopMeta", function(shopId)
    local shop = getShopById(shopId)
    if not shop then
        return nil, nil
    end
    return shop.id, shop.marketType
end)
