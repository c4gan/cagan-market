# [FREE][RELEASE][VORP / RSG] cagan-market - Modern Western Store & Shopping Cart System

Hello RedM Community! 👋

Today I'm thrilled to release **cagan-market**, a clean, highly optimized, and beautifully designed shopping cart and store system for RedM servers.

It was designed from the ground up to give players an authentic Wild West shopping experience with an immersive dark torn-paper aesthetic, responsive multi-item cart, dynamic search bar, stock counters, sound effects, and dual buying & selling modes.

Best of all, it features a **Universal Multi-Framework Bridge** that automatically detects whether your server is running **VORP Core** or **RSG-Core**!

---

### 📸 Preview / Screenshot

![cagan-market In-Game Preview](https://raw.githubusercontent.com/caganbey/cagan-market/main/docs/preview.png)

---

### 🌟 Key Features

- 🛒 **Interactive Shopping Cart NUI**:
  - Add multiple items with quantity selectors (`-` / `+`).
  - Real-time subtotal & total cost computation.
  - Category tabs (Food, Drinks, Medical, Tools, Weapons, Custom).
  - Live instant search bar.
  - Stock indicators (`Stok: Sınırsız` or custom stock limit).
  - RedM store sound effects on cart actions and checkout.

- 🔄 **Universal Framework Support (VORP & RSG-Core)**:
  - **Auto-Detection (`Config.Framework = 'auto'`)**: No code changes needed when switching frameworks.
  - **VORP Core**: Full compatibility with `vorp_core` & `vorp_inventory`.
  - **RSG-Core**: Full compatibility with `rsg-core` & `rsg-inventory`.
  - **Automatic Item Images**: Seamlessly pulls icons from your inventory resource.

- ⚖️ **Dual Store Mode (Buy & Sell)**:
  - Run general stores, gunsmiths, blacksmiths, saloons, stables.
  - Create sell-only markets where players trade hunting pelts, meats, or crops for money.

- 🔒 **Job & Grade Restrictions**:
  - Lock specific stores or catalog items to designated jobs (e.g. Police Armory, Doctor Supply).

- 📍 **Storekeeper NPCs & Map Blips**:
  - Configurable NPC models, interaction hold prompt (`[G]`), and custom map blips.

- ⚡ **0.00 ms Performance & Exploit Protection**:
  - 0.00 ms on idle.
  - Strict server-side validation on prices, counts, and carrying capacity before deducting money or granting items.

- 📊 **Discord Webhook Purchase Receipts**:
  - Detailed embeds with character name, Steam/License ID, items breakdown, and total cost.

- 🌐 **Multi-Language Support**:
  - English (`en`), Turkish (`tr`), German (`de`), French (`fr`).

---

### ⚙️ Configuration Snippet

```lua
Config = {}

-- 'auto' | 'vorp' | 'rsg'
Config.Framework = 'auto'

-- Language: 'en' | 'tr' | 'de' | 'fr'
Config.DefaultLocale = 'en'
Config.Locale = 'en'

-- [G] Key to open store
Config.OpenKey = 0xDFF812F9
Config.OpenHoldMs = 700
Config.OpenDistance = 3.0

-- Optional Discord Webhook
Config.DiscordLog = {
    enabled = false,
    webhook = "",
    botName = "cagan-market"
}
```

---

### 📥 Download & Repository

- **GitHub Repository**: [https://github.com/c4gan/cagan-market](https://github.com/c4gan/cagan-market)
- **Requirements**: `oxmysql` + (`vorp_core` OR `rsg-core`)
- **License**: MIT

If you find this script useful for your server, please consider leaving a ⭐ on GitHub!
