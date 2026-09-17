-- ==============================================================================
-- cagan-market Configuration
-- Open-source RedM shopping and general store system built for VORP Core & RSG-Core
-- Modular framework bridge, shopping cart UI, job restrictions, and Discord webhooks
-- ==============================================================================

Config = {}

-- ------------------------------------------------------------------------------
-- Framework & Language Settings
-- ------------------------------------------------------------------------------
-- 'auto' -> Automatically detects whether VORP Core or RSG-Core is running
-- 'vorp' -> Forces VORP Core & vorp_inventory
-- 'rsg'  -> Forces RSG-Core & rsg-inventory
Config.Framework = 'auto'

-- Language: 'tr' (Turkish), 'en' (English), 'de' (German), 'fr' (French)
Config.DefaultLocale = 'tr'

-- ------------------------------------------------------------------------------
-- UI Localization & Notifications
-- ------------------------------------------------------------------------------
-- Active language code: 'tr' | 'en' | 'de' | 'fr'
Config.Locale = 'tr'


-- ------------------------------------------------------------------------------
-- Discord Webhook Logging
-- Set enabled = true and insert your Discord Webhook URL to receive purchase logs.
-- ------------------------------------------------------------------------------
Config.DiscordLog = {
    enabled = false,
    webhook = "", -- Insert your Discord webhook URL here
    botName = "cagan-market",
    botAvatar = ""
}

-- ------------------------------------------------------------------------------
-- Inventory & Interaction Settings
-- ------------------------------------------------------------------------------
Config.ImageBasePath = "auto" -- Path to inventory item images
Config.OpenKey = 0xDFF812F9 -- Default prompt key: [G]
Config.OpenHoldMs = 700                  -- Milliseconds required to hold key
Config.OpenDistance = 3.0                -- Max interaction radius in game units
Config.DrawDistance = 4.0                -- Prompt rendering distance
Config.DefaultNpcModel = "U_M_M_NbxGeneralStoreOwner_01" -- Default fallback ped model
Config.DefaultNpcHeading = 0.0
Config.DefaultNpcZOffset = 0.0

-- ------------------------------------------------------------------------------
-- Map Blip Icons & Custom Points of Interest
-- ------------------------------------------------------------------------------
Config.ShopBlips = {
    enabled = true,
    scale = 0.2,
    gunsmithSprite = joaat("blip_shop_gunsmith"),
    horseSprite = joaat("blip_shop_horse"),
    hardwareSprite = joaat("blip_shop_blacksmith"),
    farmingSprite = joaat("blip_shop_store"),
    saloonSprite = 1879260108,
}

Config.ExtraBlips = {
    {
        id = "stdenis_hipodrom",
        name = "Saint Denis Racetrack",
        coords = vector4(1315.458, 38.139, 91.752, 124.96),
        sprite = joaat("blip_shop_horse"),
        scale = 0.2,
    }
}

-- ------------------------------------------------------------------------------
-- Store Catalogs & Categories (Market Types)
-- ------------------------------------------------------------------------------
-- Defines catalog presets referenced by shops in Config.Shops.
-- jobs = { "job_name" } restricts opening the store to players with specified jobs.
-- items:
--   name: internal database item identifier (must match your inventory DB)
--   label: display name shown in the UI
--   price: unit price in dollars ($)
--   description: descriptive item text
--   category: filter/tab category shown in the UI
-- ------------------------------------------------------------------------------
Config.MarketTypes = {
    general = {
        label = "General Store",
        items = {
            { name = "water", label = "Water", price = 0.25, description = "Fresh spring water.", category = "Food" },
            { name = "bread", label = "Bread", price = 0.5, description = "Daily baked bread.", category = "Food" },
            { name = "apple", label = "Apple", price = 0.5, description = "Crisp fresh apple.", category = "Food" },
            { name = "consumable_chocolate", label = "Chocolate", price = 1, description = "Sweet chocolate snack.", category = "Food" },
            { name = "consumable_kidneybeans_can", label = "Canned Kidney Beans", price = 0.75, description = "Preserved canned food.", category = "Food" },
            { name = "canteen", label = "Canteen", price = 5, description = "Used for carrying fresh water.", category = "Equipment" },
            { name = "wateringcan_empty", label = "Empty Bucket", price = 5, description = "Bucket for hauling water.", category = "Equipment" },
            { name = "petfood", label = "Pet Food", price = 1, description = "Nutritious pet feed.", category = "Pets" },
            { name = "petwater", label = "Pet Water", price = 0.75, description = "Fresh water for pets.", category = "Pets" },
            { name = "petrevive", label = "Pet Reviver", price = 5, description = "Revives unconscious pets.", category = "Pets" },
            { name = "petheal", label = "Pet Medicine", price = 5, description = "Restores health to pets.", category = "Pets" },
            { name = "petbox", label = "Pet Carrier", price = 10, description = "Carrier box for domestic animals.", category = "Pets" },
            { name = "bandage", label = "Bandage", price = 1, description = "Basic first aid bandage.", category = "Medical" }
        }
    },
    gunsmith = {
        label = "Gunsmith",
        jobs = {}, 
        items = {
            { name = "ammorevolvernormal", label = "Revolver Ammo", price = 1.5, description = "Standard ammunition for revolvers.", category = "Ammo" },
            { name = "ammorepeaternormal", label = "Repeater Ammo", price = 5.0, description = "Standard ammunition for repeaters.", category = "Ammo" },
            { name = "weapon_repair_kit", label = "Gun Cleaning Kit", price = 5.0, description = "Kit for maintaining firearm quality.", category = "Equipment" },
            { name = "WEAPON_MELEE_KNIFE", label = "Hunting Knife", price = 5.0, description = "Sturdy all-purpose hunting knife.", category = "Equipment" },
            { name = "WEAPON_BOW", label = "Bow", price = 10.0, description = "Traditional hunting bow.", category = "Equipment" },
            { name = "WEAPON_REVOLVER_DOUBLEACTION", label = "Double-Action Revolver", price = 30.0, description = "Standard Double-Action revolver.", category = "Equipment" },
            { name = "WEAPON_LASSO", label = "Lasso", price = 5.0, description = "Standard durable lasso.", category = "Equipment" },
            { name = "ammoarrownormal", label = "Arrows", price = 0.5, description = "Arrows suitable for hunting bows.", category = "Ammo" }
        }
    },
    wapiti_gunsmith = {
        label = "Wapiti Gunsmith",
        jobs = { "redriver" },
        items = {
            { name = "WEAPON_BOW", label = "Bow", price = 10.0, description = "Traditional hunting bow.", category = "Equipment" },
            { name = "WEAPON_BOW_IMPROVED", label = "Improved Bow", price = 20.0, description = "Reinforced bow with higher velocity.", category = "Equipment" },
            { name = "WEAPON_LASSO_REINFORCED", label = "Reinforced Lasso", price = 15.0, description = "Heavy reinforced lasso.", category = "Equipment" },
            { name = "WEAPON_THROWN_TOMAHAWK", label = "Tomahawk", price = 8.0, description = "Sharpened thrown tomahawk.", category = "Equipment" },
            { name = "WEAPON_MELEE_KNIFE_JAWBONE", label = "Jawbone Knife", price = 12.0, description = "Knife carved from a bear jawbone.", category = "Equipment" },
            { name = "ammoarrownormal", label = "Arrows", price = 0.5, description = "Arrows suitable for hunting bows.", category = "Ammo" }
        }
    },
    horse = {
        label = "Horse Supplies",
        jobs = {},
        items = {
            { name = "apple", label = "Apple", price = 0.5, description = "Fresh sweet apple for horses.", category = "Horse Care" },
            { name = "sugarcube", label = "Sugar Cube", price = 0.75, description = "Sweet reward for your horse.", category = "Horse Care" },
            { name = "carrot", label = "Carrot", price = 0.5, description = "Crisp carrot for horses.", category = "Horse Care" },
            { name = "Hoof_Hook", label = "Hoof Pick", price = 1.5, description = "Tool for cleaning horse hooves.", category = "Horse Care" },
            { name = "horseadrenaline", label = "Horse Stimulant", price = 3.0, description = "Stimulant that restores stamina.", category = "Horse Medicine" },
            { name = "horserevive", label = "Horse Reviver", price = 3.0, description = "Revives a severely injured horse.", category = "Horse Medicine" },
            { name = "Gold_For_Horse", label = "Potent Horse Remedy", price = 5.0, description = "Potent restorative tonic for horses.", category = "Horse Medicine" },
            { name = "consumable_haycube", label = "Hay Cube", price = 1.0, description = "Compressed nutritious hay fodder.", category = "Horse Care" },
            { name = "carrots", label = "Horse Feed", price = 0.5, description = "Nutritious grain and vegetable feed.", category = "Horse Care" },
            { name = "horsebrush", label = "Horse Brush", price = 1.5, description = "Grooms your horse coat and mane.", category = "Horse Care" },
            { name = "horse_reviver", label = "Horse Syringe", price = 2.5, description = "Emergency horse reviver syringe.", category = "Horse Medicine" }
        }
    },
    hardware = {
        label = "Hardware Store",
        jobs = {},
        items = {
            { name = "pickaxe", label = "Pickaxe", price = 10.0, description = "Mining pick for prospecting rocks.", category = "Tools" },
            { name = "Axe", label = "Wood Axe", price = 10.0, description = "Heavy axe for cutting lumber.", category = "Tools" },
            { name = "campflag", label = "Camp Supplies", price = 5.0, description = "Standard camping equipment.", category = "Tools" },
            { name = "campfire", label = "Campfire Kit", price = 2.5, description = "Kit to assemble an outdoor fire.", category = "Tools" },
            { name = "lockpick", label = "Lockpick", price = 2.75, description = "Precision lockpicking tool.", category = "Tools" },
            { name = "goldpan", label = "Gold Pan", price = 7.5, description = "Pan used for panning gold in rivers.", category = "Tools" },
            { name = "shovel", label = "Shovel", price = 10.0, description = "Heavy duty digging shovel.", category = "Tools" },
            { name = "rope", label = "Rope", price = 2.0, description = "Strong braided rope.", category = "Materials" },
            { name = "minershat", label = "Miner's Hat", price = 2.5, description = "Protective hat with headlamp.", category = "Tools" }
        }
    },
    saloon = {
        label = "Saloon",
        jobs = {},
        items = {
            { name = "beer", label = "Beer", price = 1.5, description = "Cold bottled beer.", category = "Alcohol" },
            { name = "whisky", label = "Whiskey", price = 2.0, description = "House saloon whiskey.", category = "Alcohol" },
            { name = "wine", label = "Wine", price = 2.0, description = "Bottle of vintage red wine.", category = "Alcohol" },
            { name = "vodka", label = "Vodka", price = 2.0, description = "Strong distilled grain spirit.", category = "Alcohol" },
            { name = "tequila", label = "Tequila", price = 2.5, description = "Imported agave spirit.", category = "Alcohol" },
            { name = "absinthe", label = "Absinthe", price = 3.25, description = "High-proof wormwood spirit.", category = "Alcohol" },
            { name = "tropicalPunchMoonshine", label = "Tropical Moonshine", price = 1.0, description = "Special fruity moonshine.", category = "Alcohol" },
            { name = "wildCiderMoonshine", label = "Wild Cider Moonshine", price = 1.0, description = "Crisp apple moonshine blend.", category = "Alcohol" },
            { name = "raspberryale", label = "Raspberry Ale", price = 3.0, description = "Sweet berry flavored ale.", category = "Alcohol" },
            { name = "blackberryale", label = "Blackberry Ale", price = 3.0, description = "Tart blackberry fermented ale.", category = "Alcohol" },
            { name = "water", label = "Water", price = 0.5, description = "Fresh spring water.", category = "Beverages" },
            { name = "milk", label = "Milk", price = 1.0, description = "Fresh morning cow's milk.", category = "Beverages" },
            { name = "consumable_coffee", label = "Coffee", price = 0.75, description = "Hot black roasted coffee.", category = "Beverages" },
            { name = "lemonade", label = "Lemonade", price = 0.75, description = "Cold, refreshing lemonade.", category = "Beverages" },
            { name = "hot_chocolate", label = "Hot Chocolate", price = 0.5, description = "Warm sweet cocoa drink.", category = "Beverages" },
            { name = "consumable_soup", label = "Hot Stew", price = 2.0, description = "Hearty warm tavern stew.", category = "Food" },
            { name = "consumable_meat_greavy", label = "Meat & Gravy", price = 1.5, description = "Braised meat with savory gravy.", category = "Food" },
            { name = "consumable_fruitsalad", label = "Fruit Salad", price = 2.0, description = "Light seasonal fruit plate.", category = "Food" },
            { name = "consumable_kidneybeans_can", label = "Canned Beans", price = 1.0, description = "Standard canned kidney beans.", category = "Food" },
            { name = "consumable_salmon_can", label = "Canned Salmon", price = 1.5, description = "Preserved canned pink salmon.", category = "Food" },
            { name = "consumable_breakfast", label = "Hearty Breakfast", price = 2.0, description = "Full breakfast platter.", category = "Food" },
            { name = "consumable_pretzel", label = "Pretzel", price = 1.0, description = "Salty baked tavern pretzel.", category = "Food" },
            { name = "consumable_chocolate", label = "Chocolate", price = 0.50, description = "Sweet confectionery chocolate.", category = "Food" }
        }
    },
    blackwater_saloon = {
        label = "Blackwater Saloon",
        jobs = { "blackwater_saloon" },
        items = {
            { name = "beer", label = "Beer", price = 0.7, description = "Cold bottled beer.", category = "Alcohol" },
            { name = "whisky", label = "Whiskey", price = 1.0, description = "House saloon whiskey.", category = "Alcohol" },
            { name = "wine", label = "Wine", price = 1.5, description = "Bottle of vintage red wine.", category = "Alcohol" },
            { name = "vodka", label = "Vodka", price = 1.5, description = "Strong distilled grain spirit.", category = "Alcohol" },
            { name = "tequila", label = "Tequila", price = 2.0, description = "Imported agave spirit.", category = "Alcohol" },
            { name = "absinthe", label = "Absinthe", price = 2.5, description = "High-proof wormwood spirit.", category = "Alcohol" },
            { name = "tropicalPunchMoonshine", label = "Tropical Moonshine", price = 0.75, description = "Special fruity moonshine.", category = "Alcohol" },
            { name = "wildCiderMoonshine", label = "Wild Cider Moonshine", price = 0.75, description = "Crisp apple moonshine blend.", category = "Alcohol" },
            { name = "raspberryale", label = "Raspberry Ale", price = 2.25, description = "Sweet berry flavored ale.", category = "Alcohol" },
            { name = "blackberryale", label = "Blackberry Ale", price = 2.25, description = "Tart blackberry fermented ale.", category = "Alcohol" },
            { name = "water", label = "Water", price = 0.35, description = "Fresh spring water.", category = "Beverages" },
            { name = "milk", label = "Milk", price = 0.75, description = "Fresh morning cow's milk.", category = "Beverages" },
            { name = "consumable_coffee", label = "Coffee", price = 0.5, description = "Hot black roasted coffee.", category = "Beverages" },
            { name = "lemonade", label = "Lemonade", price = 0.5, description = "Cold, refreshing lemonade.", category = "Beverages" },
            { name = "hot_chocolate", label = "Hot Chocolate", price = 0.35, description = "Warm sweet cocoa drink.", category = "Beverages" },
            { name = "consumable_soup", label = "Hot Stew", price = 1.5, description = "Hearty warm tavern stew.", category = "Food" },
            { name = "consumable_meat_greavy", label = "Meat & Gravy", price = 0.5, description = "Braised meat with savory gravy.", category = "Food" },
            { name = "consumable_fruitsalad", label = "Fruit Salad", price = 1.5, description = "Light seasonal fruit plate.", category = "Food" },
            { name = "consumable_kidneybeans_can", label = "Canned Beans", price = 0.75, description = "Standard canned kidney beans.", category = "Food" },
            { name = "consumable_salmon_can", label = "Canned Salmon", price = 1.0, description = "Preserved canned pink salmon.", category = "Food" },
            { name = "consumable_breakfast", label = "Hearty Breakfast", price = 1.5, description = "Full breakfast platter.", category = "Food" },
            { name = "consumable_pretzel", label = "Pretzel", price = 0.75, description = "Salty baked tavern pretzel.", category = "Food" },
            { name = "consumable_chocolate", label = "Chocolate", price = 0.35, description = "Sweet confectionery chocolate.", category = "Food" }
        }
    },
    farming = {
        label = "Farming Supplies",
        jobs = {},
        items = {
            { name = "cornseed", label = "Corn Seeds", price = 0.25, description = "Seeds for planting corn.", category = "Seeds" },
            { name = "sugarcaneseed", label = "Sugarcane Seeds", price = 0.25, description = "Seeds for planting sugarcane.", category = "Seeds" },
            { name = "cottonseed", label = "Cotton Seeds", price = 0.45, description = "Seeds for planting cotton.", category = "Seeds" },
            { name = "carrotseed", label = "Carrot Seeds", price = 0.25, description = "Seeds for planting carrots.", category = "Seeds" },
            { name = "potatoseed", label = "Potato Seeds", price = 0.30, description = "Seeds for planting potatoes.", category = "Seeds" },
            { name = "wheatseed", label = "Wheat Seeds", price = 0.25, description = "Seeds for planting wheat fields.", category = "Seeds" },
            { name = "tomatoseed", label = "Tomato Seeds", price = 0.30, description = "Seeds for planting tomatoes.", category = "Seeds" },
            { name = "waterbucket0", label = "Empty Water Bucket", price = 5.0, description = "Bucket used for crop irrigation.", category = "Equipment" }
        }
    },
    suvari_flags = {
        label = "Flag Shop",
        jobs = { "suvari" },
        items = {
            { name = "americanflag", label = "American Flag", price = 4.5, description = "Wavable cloth flag.", category = "Flags" },
            { name = "whiteflag", label = "White Flag", price = 4.5, description = "Wavable surrender flag.", category = "Flags" },
            { name = "redflag", label = "Red Flag", price = 4.5, description = "Wavable signal flag.", category = "Flags" },
            { name = "campflag", label = "Camp Flag", price = 4.5, description = "Standard camping pennant.", category = "Flags" },
            { name = "lemoynelongflag", label = "Lemoyne Long Flag", price = 4.5, description = "Elongated state flag.", category = "Flags" },
            { name = "whitelongflag", label = "White Long Flag", price = 4.5, description = "Elongated white flag.", category = "Flags" },
            { name = "alligatorflag", label = "Alligator Flag", price = 4.5, description = "Decorative emblem flag.", category = "Flags" },
            { name = "ambarinoflag", label = "Ambarino Flag", price = 4.5, description = "Decorative regional flag.", category = "Flags" },
            { name = "aceflag", label = "Ace Flag", price = 4.5, description = "Decorative playing card flag.", category = "Flags" },
            { name = "anchorflag", label = "Anchor Flag", price = 4.5, description = "Decorative nautical flag.", category = "Flags" },
            { name = "breweryflag", label = "Brewery Flag", price = 4.5, description = "Decorative brewery flag.", category = "Flags" },
            { name = "bearflag", label = "Bear Flag", price = 4.5, description = "Decorative wildlife flag.", category = "Flags" },
            { name = "buckflag", label = "Buck Flag", price = 4.5, description = "Decorative wildlife flag.", category = "Flags" },
            { name = "clamjuiceflag", label = "Clam Juice Flag", price = 4.5, description = "Decorative commercial flag.", category = "Flags" },
            { name = "coyoteflag", label = "Coyote Flag", price = 4.5, description = "Decorative wildlife flag.", category = "Flags" },
            { name = "eagleflag", label = "Eagle Flag", price = 4.5, description = "Decorative eagle flag.", category = "Flags" },
            { name = "festaflag", label = "Festa Flag", price = 4.5, description = "Decorative festive banner.", category = "Flags" },
            { name = "fishflag", label = "Fish Flag", price = 4.5, description = "Decorative angler flag.", category = "Flags" },
            { name = "gelatinflag", label = "Gelatin Flag", price = 4.5, description = "Decorative commercial banner.", category = "Flags" },
            { name = "gilamonsterflag", label = "Gila Monster Flag", price = 4.5, description = "Decorative desert flag.", category = "Flags" },
            { name = "guarmaflag", label = "Guarma Flag", price = 4.5, description = "Decorative island flag.", category = "Flags" },
            { name = "jollyjacksflag", label = "Jolly Jacks Flag", price = 4.5, description = "Decorative tobacco flag.", category = "Flags" },
            { name = "lallycolaflag", label = "Lally Cola Flag", price = 4.5, description = "Decorative beverage flag.", category = "Flags" },
            { name = "lemoyneflag", label = "Lemoyne Flag", price = 4.5, description = "Decorative state flag.", category = "Flags" },
            { name = "morganflag", label = "Morgan Flag", price = 4.5, description = "Decorative equestrian flag.", category = "Flags" },
            { name = "newhanoverflag", label = "New Hanover Flag", price = 4.5, description = "Decorative territory flag.", category = "Flags" },
            { name = "oldbloodeyesflag", label = "Old Blood Eyes Flag", price = 4.5, description = "Decorative saloon flag.", category = "Flags" },
            { name = "pirateskullsflag", label = "Pirate Skulls Flag", price = 4.5, description = "Decorative pirate banner.", category = "Flags" },
            { name = "prairiemoonginflag", label = "Prairie Moongin Flag", price = 4.5, description = "Decorative spirit flag.", category = "Flags" },
            { name = "schifferflag", label = "Schiffer Flag", price = 4.5, description = "Decorative brewery banner.", category = "Flags" },
            { name = "stdenisflag", label = "Saint Denis Flag", price = 4.5, description = "Decorative city crest flag.", category = "Flags" },
            { name = "sturgeonflag", label = "Sturgeon Flag", price = 4.5, description = "Decorative fish banner.", category = "Flags" },
            { name = "tennesseeflag", label = "Tennessee Flag", price = 4.5, description = "Decorative state flag.", category = "Flags" },
            { name = "vultureflag", label = "Vulture Flag", price = 4.5, description = "Decorative scavenger flag.", category = "Flags" },
            { name = "westelizabethflag", label = "West Elizabeth Flag", price = 4.5, description = "Decorative territory flag.", category = "Flags" },
            { name = "catfishflag", label = "Catfish Flag", price = 4.5, description = "Decorative river banner.", category = "Flags" },
        }
    }
}

Config.MarketTypes.moonshine_supplies = {
    label = "Moonshine Supplies",
    jobs = {},
    items = {
        { name = "alcohol", label = "Distilling Alcohol", price = 0.5, description = "Pure base alcohol for distilling.", category = "Distilling" },
        { name = "alcoholbottle", label = "Empty Bottle", price = 0.25, description = "Glass bottle for moonshine.", category = "Distilling" },
        { name = "wood", label = "Wood Planks", price = 0.50, description = "Material for still repair and crafting.", category = "Repair" },
        { name = "ironbar", label = "Iron Bar", price = 1.00, description = "Metal reinforcement for stills.", category = "Repair" },
        { name = "notebook", label = "Recipe Notebook", price = 2.50, description = "Notebook for recipes and notes.", category = "General" },
        { name = "mp006_p_moonshiner_still01x", label = "Basic Still (I)", price = 40.00, description = "Small copper moonshine still.", category = "Equipment" },
        { name = "mp006_p_moonshiner_still02x", label = "Medium Still (II)", price = 75.00, description = "Medium-capacity moonshine still.", category = "Equipment" },
        { name = "mp006_p_moonshiner_still03x", label = "Advanced Still (III)", price = 100.00, description = "High-yield copper still system.", category = "Equipment" },
        { name = "mp006_p_moonshiner_still04x", label = "Industrial Still (IV)", price = 150.00, description = "Heavy duty professional still.", category = "Equipment" },
    }
}

Config.MarketTypes.moonshine_products = {
    label = "Moonshine Buyer",
    jobs = {},
    items = {
        { name = "moonshine_original", label = "Classic Moonshine", price = 2.00, description = "Sell your brewed moonshine batches here.", category = "Moonshine" },
        { name = "moonshine_blueflame", label = "Blue Flame Moonshine", price = 4.00, description = "Sell your brewed moonshine batches here.", category = "Moonshine" },
        { name = "moonshine_red", label = "Red Moonshine", price = 10.00, description = "Sell your brewed moonshine batches here.", category = "Moonshine" },
        { name = "moonshine_blue", label = "Blue Moonshine", price = 5.5, description = "Sell your brewed moonshine batches here.", category = "Moonshine" },
        { name = "moonshine_yellow", label = "Yellow Moonshine", price = 7.5, description = "Sell your brewed moonshine batches here.", category = "Moonshine" },
    }
}

-- Valentine Saloon: Shares inventory and pricing with Blackwater Saloon, restricted to its job.
Config.MarketTypes.valentine_saloon = {
    label = "Valentine Saloon",
    jobs = { "valentine_saloon" },
    items = Config.MarketTypes.blackwater_saloon.items,
}

-- ------------------------------------------------------------------------------
-- Active Store Instances (Config.Shops)
-- ------------------------------------------------------------------------------
-- id: Unique shop identifier
-- name: Display name shown on HUD / radar blip / UI header
-- coords: vector3 coordinates of the interaction point / NPC spawn
-- npcModel: (Optional) Ped model hash/name for the store clerk
-- npcHeading: Ped facing direction in degrees
-- npcZOffset: Height adjustment for interior ground alignment
-- marketType: Preset catalog key from Config.MarketTypes
-- mode: "buy" (default) or "sell" (players sell items to shop for cash)
-- showBlip: Set false to hide map blip for this specific store
-- jobs: Array of job names permitted to interact with this specific store
-- ------------------------------------------------------------------------------
Config.Shops = {
    {
        id = "valentine_general",
        name = "Valentine General Store",
        coords = vector3(-324.628, 803.9818, 116.88),
        npcZOffset = 0.72,
        npcHeading = -81.17,
        marketType = "general",
        jobs = {} 
    },
    {
        id = "rhodes_general",
        name = "Rhodes General Store",
        coords = vector3(1330.227, -1293.41, 76.021),
        npcHeading = 68.88,
        marketType = "general",
        jobs = {}
    },
    {
        id = "strawberry_general",
        name = "Strawberry General Store",
        coords = vector3(-1789.66, -387.918, 160.32),
        npcHeading = 56.96,
        marketType = "general",
        jobs = {}
    },
    {
        id = "blackwater_general",
        name = "Blackwater General Store",
        coords = vector3(-784.738, -1321.73, 42.884),
        npcZOffset = 0.72,
        npcHeading = 179.63,
        marketType = "general",
        jobs = {}
    },
    {
        id = "armadillo_general",
        name = "Armadillo General Store",
        coords = vector3(-3687.34, -2623.53, -13.43),
        npcHeading = -85.32,
        marketType = "general",
        jobs = {}
    },
    {
        id = "tumbleweed_general",
        name = "Tumbleweed General Store",
        coords = vector3(-5485.70, -2938.08, -0.299),
        npcHeading = 127.72,
        marketType = "general",
        jobs = {}
    },
    {
        id = "stdenis_general",
        name = "Saint Denis General Store",
        coords = vector3(2824.863, -1319.74, 45.755),
        npcHeading = -39.61,
        marketType = "general",
        jobs = {}
    },
    {
        id = "wapiti_general",
        name = "Wapiti General Store",
        coords = vector3(449.7435, 2216.437, 245.30),
        npcModel = "A_M_M_WapWarriors_01",
        npcZOffset = 0.45,
        npcHeading = -73.78,
        marketType = "general",
        showBlip = false,
        jobs = {}
    },
    {
        id = "wapiti_gunsmith",
        name = "Wapiti Gunsmith",
        coords = vector3(432.303, 2197.346, 246.430),
        npcModel = "A_M_M_WapWarriors_01",
        npcHeading = 10.07,
        marketType = "wapiti_gunsmith",
        showBlip = false,
        jobs = { "redriver" }
    },
    {
        id = "valentine_gunsmith",
        name = "Valentine Gunsmith",
        coords = vector3(-280.4646, 779.0331, 119.2540),
        npcModel = "u_m_m_valgunsmith_01",
        npcHeading = 2.82,
        marketType = "gunsmith",
        jobs = {}
    },
    {
        id = "stdenis_gunsmith",
        name = "Saint Denis Gunsmith",
        coords = vector3(2717.75, -1286.62, 49.64),
        npcModel = "u_m_m_nbxgunsmith_01",
        npcHeading = 44.58,
        marketType = "gunsmith",
        jobs = {}
    },
    {
        id = "rhodes_gunsmith",
        name = "Rhodes Gunsmith",
        coords = vector3(1322.95, -1323.21, 77.89),
        npcModel = "u_m_m_rhdgunsmith_01",
        npcHeading = 350.17,
        marketType = "gunsmith",
        jobs = {}
    },
    {
        id = "annesburg_gunsmith",
        name = "Annesburg Gunsmith",
        coords = vector3(2948.16, 1318.79, 44.82),
        npcModel = "u_m_m_asbgunsmith_01",
        npcHeading = 91.34,
        marketType = "gunsmith",
        jobs = {}
    },
    {
        id = "tumbleweed_gunsmith",
        name = "Tumbleweed Gunsmith",
        coords = vector3(-5505.97, -2963.91, -0.64),
        npcModel = "u_m_m_tumgunsmith_01",
        npcHeading = 103.15,
        marketType = "gunsmith",
        jobs = {}
    },
    {
        id = "blackwater_gunsmith",
        name = "Blackwater Gunsmith",
        coords = vector3(-787.097, -1299.648, 43.785),
        npcModel = "u_m_m_nbxgunsmith_01",
        npcHeading = 7.17,
        marketType = "gunsmith",
        jobs = {}
    },
    {
        id = "strawberry_gunsmith",
        name = "Strawberry Gunsmith",
        coords = vector3(-1845.796, -426.961, 160.604),
        npcModel = "u_m_m_nbxgunsmith_01",
        npcHeading = 93.67,
        marketType = "gunsmith",
        jobs = {}
    },
    {
        id = "aramdillo_gunsmith",
        name = "Armadillo Gunsmith",
        coords = vector3(-3677.7573, -2598.5654, -13.2029),
        npcModel = "u_m_m_nbxgunsmith_01",
        npcHeading = 257.8086,
        marketType = "gunsmith",
        jobs = {}
    },
    {
        id = "farming_supplier",
        name = "Farming Supplies",
        coords = vector3(1458.8844, 320.2303, 91.5576),
        npcModel = "A_M_M_UniBoatCrew_01",
        npcZOffset = -1.0,
        npcHeading = 88.3237,
        marketType = "farming",
        jobs = {}
    },
    {
        id = "moonshine_supplies",
        name = "Moonshine Supplies",
        coords = vector3(-1634.211, 1213.564, 352.370),
        npcModel = "A_M_M_UniBoatCrew_01",
        npcHeading = 48.06,
        marketType = "moonshine_supplies",
        showBlip = false,
        jobs = {}
    },
    {
        id = "moonshine_products",
        name = "Moonshine Buyer",
        coords = vector3(-2773.501, -3211.978, -7.890),
        npcModel = "A_M_M_UniBoatCrew_01",
        npcHeading = 7.29,
        marketType = "moonshine_products",
        mode = "sell",
        showBlip = false,
        jobs = {}
    },
    {
        id = "stdenis_horse",
        name = "Saint Denis Horse Supplies",
        coords = vector3(2512.84, -1456.75, 46.3),
        npcHeading = 90.0,
        marketType = "horse",
        jobs = {}
    },
    {
        id = "valentine_horse",
        name = "Valentine Horse Supplies",
        coords = vector3(-358.847, 782.413, 116.214),
        npcModel = "u_m_m_bwmstablehand_01",
        npcHeading = 278.57,
        marketType = "horse",
        jobs = {}
    },
    {
        id = "blackwater_horse",
        name = "Blackwater Horse Supplies",
        coords = vector3(-874.430, -1371.268, 43.579),
        npcModel = "u_m_m_bwmstablehand_01",
        npcHeading = 355.04,
        marketType = "horse",
        jobs = {}
    },
    {
        id = "blackwater_hardware",
        name = "Blackwater Hardware",
        coords = vector3(-861.2612, -1309.5685,  43.0917),
        npcHeading = 77.8691,
        marketType = "hardware",
        jobs = {}
    },
    {
        id = "sisika_kantin",
        name = "Sisika Canteen",
        coords = vector3(3364.6377, -701.9519, 45.4739),
        npcHeading = 48.2530,
        marketType = "general",
        jobs = {}
    },
    {
        id = "stdenis_saloon",
        name = "Saint Denis Saloon",
        coords = vector3(2639.8743, -1225.4301, 53.3304),
        npcModel = "re_slumambush_females_01",
        npcHeading = 97.9424,
        marketType = "saloon",
        jobs = { "stdenis_saloon" }
    },
    {
        id = "blackwater_saloon",
        name = "Blackwater Saloon",
        coords = vector3(-817.9915, -1318.1552, 43.5789),
        npcModel = "re_slumambush_females_01",
        npcHeading = 267.8653,
        marketType = "blackwater_saloon",
        jobs = { "blackwater_saloon" }
    },
    {
        id = "armadillo_saloon",
        name = "Armadillo Saloon",
        coords = vector3(-3699.7473, -2594.7632, -13.3230),
        npcModel = "re_slumambush_females_01",
        npcHeading = 85.3780,
        marketType = "saloon",
        jobs = { "armadillo_saloon" }
    },
    {
        id = "strawberry_saloon",
        name = "Strawberry Saloon",
        coords = vector3(-1772.055, -370.149, 159.882),
        npcModel = "re_slumambush_females_01",
        npcHeading = 137.52,
        marketType = "saloon",
        jobs = { "strawberry_saloon" }
    },
    {
        id = "guarma_saloon",
        name = "Guarma Saloon",
        coords = vector3(1287.7538, -6909.2754, 44.7974),
        npcModel = "re_slumambush_females_01",
        npcHeading = 136.5958,
        marketType = "saloon",
        showBlip = false,
        jobs = { "guarma_saloon" }
    },
    {
        id = "valentine_saloon",
        name = "Valentine Saloon 1",
        coords = vector3(-313.2304, 805.3699, 118.8805),
        npcModel = "re_slumambush_females_01",
        npcHeading = 280.6887,
        marketType = "valentine_saloon",
        jobs = { "valentine_saloon" }
    },
    {
        id = "valentine_saloon_2",
        name = "Valentine Saloon 2",
        coords = vector3(-239.2215, 770.8849, 118.0013),
        npcModel = "re_slumambush_females_01",
        npcHeading = 122.4582,
        marketType = "saloon",
        showBlip = false,
        jobs = { "valentine_saloon_2" }
    },
    {
        id = "rhodes_saloon",
        name = "Rhodes Saloon",
        coords = vector3(1340.3571, -1373.8396, 80.5307),
        npcModel = "re_slumambush_females_01",
        npcHeading = 261.6882,
        marketType = "saloon",
        jobs = { "rhodes_saloon" }
    },
    {
        id = "suvari_general",
        name = "Cavalry General Store",
        coords = vector3(343.4665, 1492.6168, 178.6765),
        npcHeading = 209.4105,
        marketType = "general",
        jobs = { "suvari" }
    },
    {
        id = "suvari_horse",
        name = "Cavalry Horse Supplies",
        coords = vector3(351.905, 1498.672, 179.941),
        npcHeading = 148.85,
        marketType = "horse",
        jobs = { "suvari" }
    },
    {
        id = "suvari_flags",
        name = "Cavalry Flag Shop",
        coords = vector3(337.319, 1495.904, 181.163),
        npcHeading = 47.57,
        marketType = "suvari_flags",
        jobs = { "suvari" }
    }
}
