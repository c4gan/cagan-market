const app = document.getElementById("app");
const panel = document.querySelector(".panel");
const panelDrag = document.querySelector(".panelDrag");
const itemsEl = document.getElementById("items");
const shopNameEl = document.getElementById("shopName");
const marketTypeEl = document.getElementById("marketType");
const cartTotalEl = document.getElementById("cartTotal");
const cartTitleEl = document.getElementById("cartTitle");
const searchInput = document.getElementById("searchInput");
const buyBtn = document.getElementById("buyBtn");
const closeBtn = document.getElementById("closeBtn");
const buyBtnText = document.getElementById("buyBtnText");
const closeBtnText = document.getElementById("closeBtnText");

const PANEL_POS_KEY = "cagan-market-panel-pos";

let locale = {
    cart: "Cart",
    search: "Search...",
    buy: "Purchase",
    close: "Close",
    empty: "No items available in this store.",
    total: "Total",
    stock: "Stock",
    unlimited: "Unlimited"
};

let items = [];
let cart = {};
let lastQtyClickAt = 0;

let panelDragging = false;
let dragPointerX = 0;
let dragPointerY = 0;
let panelOriginX = 0;
let panelOriginY = 0;

const RESOURCE_NAME = "cagan-market";

function isAuthorizedResource() {
    if (typeof GetParentResourceName === "function") {
        try {
            const res = GetParentResourceName();
            if (res && res !== RESOURCE_NAME) {
                console.error(`[cagan-market] Unauthorized resource name '${res}'. Expected '${RESOURCE_NAME}'.`);
                return false;
            }
        } catch (_) {
            return false;
        }
    }
    return true;
}

function postNui(eventName, payload) {
    if (!isAuthorizedResource()) return;
    const resName = typeof GetParentResourceName === "function" ? GetParentResourceName() : RESOURCE_NAME;
    fetch(`https://${resName}/${eventName}`, {
        method: "POST",
        headers: { "Content-Type": "application/json; charset=UTF-8" },
        body: JSON.stringify(payload || {})
    }).catch(() => {});
}

function formatMoney(value) {
    return `$${Number(value || 0).toFixed(2)}`;
}

function loadPanelPosition() {
    if (!panel) {
        return;
    }
    try {
        const raw = localStorage.getItem(PANEL_POS_KEY);
        if (!raw) {
            return;
        }
        const pos = JSON.parse(raw);
        if (!Number.isFinite(pos.x) || !Number.isFinite(pos.y)) {
            return;
        }
        applyPanelPosition(pos.x, pos.y);
    } catch (_) {

    }
}

function applyPanelPosition(x, y) {
    if (!panel) {
        return;
    }
    const maxX = Math.max(0, window.innerWidth - panel.offsetWidth);
    const maxY = Math.max(0, window.innerHeight - panel.offsetHeight);
    const clampedX = Math.max(0, Math.min(x, maxX));
    const clampedY = Math.max(0, Math.min(y, maxY));

    app.classList.add("app--floating");
    panel.style.position = "fixed";
    panel.style.left = `${clampedX}px`;
    panel.style.top = `${clampedY}px`;
    panel.style.margin = "0";
}

function savePanelPosition() {
    if (!panel || panel.style.position !== "fixed") {
        return;
    }
    const rect = panel.getBoundingClientRect();
    try {
        localStorage.setItem(
            PANEL_POS_KEY,
            JSON.stringify({ x: Math.round(rect.left), y: Math.round(rect.top) })
        );
    } catch (_) {

    }
}

function ensurePanelFixedForDrag() {
    if (!panel) {
        return;
    }
    if (panel.style.position === "fixed") {
        return;
    }
    const rect = panel.getBoundingClientRect();
    applyPanelPosition(rect.left, rect.top);
}

function startPanelDrag(clientX, clientY) {
    ensurePanelFixedForDrag();
    const rect = panel.getBoundingClientRect();
    panelDragging = true;
    dragPointerX = clientX;
    dragPointerY = clientY;
    panelOriginX = rect.left;
    panelOriginY = rect.top;
    panel.classList.add("panel--dragging");
}

function movePanelDrag(clientX, clientY) {
    if (!panelDragging) {
        return;
    }
    const dx = clientX - dragPointerX;
    const dy = clientY - dragPointerY;
    applyPanelPosition(panelOriginX + dx, panelOriginY + dy);
}

function endPanelDrag() {
    if (!panelDragging) {
        return;
    }
    panelDragging = false;
    panel.classList.remove("panel--dragging");
    savePanelPosition();
}

function computeTotal() {
    let total = 0;
    for (const item of items) {
        const qty = Number(cart[item.name] || 0);
        if (qty > 0) {
            total += qty * Number(item.price || 0);
        }
    }
    cartTotalEl.textContent = formatMoney(total);
}

function qtyOf(itemName) {
    return Number(cart[itemName] || 0);
}

function normalizedStock(item) {
    if (!item || !Object.prototype.hasOwnProperty.call(item, "stock")) {
        return null;
    }
    if (item.stock === null || item.stock === undefined || item.stock === "") {
        return null;
    }
    const n = Number(item.stock);
    if (!Number.isFinite(n)) {
        return null;
    }
    return Math.max(0, Math.floor(n));
}

function maxQtyForItem(itemName) {
    const item = items.find((i) => i.name === itemName);
    const st = normalizedStock(item);
    if (st === null) {
        return 9999;
    }
    return st;
}

function setQty(itemName, qty) {
    const cap = maxQtyForItem(itemName);
    if (qty > cap) {
        qty = cap;
    }
    if (qty <= 0) {
        delete cart[itemName];
    } else {
        cart[itemName] = qty;
    }
    renderItems();
    computeTotal();
}

function filteredItems() {
    const query = searchInput.value.trim().toLowerCase();
    if (!query) {
        return items;
    }
    return items.filter((item) => {
        return (
            String(item.label || "").toLowerCase().includes(query) ||
            String(item.name || "").toLowerCase().includes(query) ||
            String(item.category || "").toLowerCase().includes(query)
        );
    });
}

function renderItems() {
    const data = filteredItems();
    if (!data.length) {
        itemsEl.innerHTML = `<div class="item"><div></div><div class="itemDesc">${locale.empty}</div><div></div></div>`;
        return;
    }

    itemsEl.innerHTML = data
        .map((item) => {
            const qty = qtyOf(item.name);
            const encodedName = encodeURIComponent(String(item.name || ""));
            return `
            <article class="item" data-item="${encodedName}">
                <img src="${item.image}" alt="${item.label}" draggable="false" />
                <div>
                    <div class="itemName">${item.label}</div>
                    <div class="itemDesc">${item.description || ""}</div>
                    <div class="itemCat">${item.category || ""}</div>
                    <div class="itemCat">${(() => {
                        const st = normalizedStock(item);
                        const stockLabel = locale.stock || "Stock";
                        return st === null ? `${stockLabel}: ${locale.unlimited || "Unlimited"}` : `${stockLabel}: ${st}`;
                    })()}</div>
                </div>
                <div class="itemRight">
                    <div class="price">${formatMoney(item.price)}</div>
                    <div class="qtyBox">
                        <button class="qtyBtn" data-action="dec" data-item="${encodedName}" type="button">-</button>
                        <span class="qty">${qty}</span>
                        <button class="qtyBtn" data-action="inc" data-item="${encodedName}" type="button">+</button>
                    </div>
                </div>
            </article>
        `;
        })
        .join("");
}

function closeUi() {
    endPanelDrag();
    app.classList.add("hidden");
    postNui("close", {});
}

window.addEventListener("message", (event) => {
    if (!isAuthorizedResource()) {
        if (app) app.classList.add("hidden");
        return;
    }
    const data = event.data || {};
    if (data.action === "open") {
        locale = Object.assign(locale, data.locale || {});
        items = Array.isArray(data.items) ? data.items.map((row) => ({ ...row })) : [];
        cart = {};

        shopNameEl.textContent = data.shopName || "Market";
        marketTypeEl.textContent = data.marketType || "Store";
        searchInput.placeholder = locale.search;
        searchInput.disabled = false;
        cartTitleEl.textContent = locale.cart;
        if (closeBtnText) closeBtnText.textContent = locale.close || "Close";
        if (buyBtnText) buyBtnText.textContent = locale.buy || "Purchase";

        loadPanelPosition();
        app.classList.remove("hidden");
        searchInput.value = "";

        renderItems();
        computeTotal();
    }

    if (data.action === "close") {
        endPanelDrag();
        app.classList.add("hidden");
    }
});

if (panelDrag) {
    panelDrag.addEventListener("mousedown", (event) => {
        if (event.button !== 0) {
            return;
        }
        startPanelDrag(event.clientX, event.clientY);
        event.preventDefault();
    });
}

document.addEventListener("mousemove", (event) => {
    movePanelDrag(event.clientX, event.clientY);
});

document.addEventListener("mouseup", () => {
    endPanelDrag();
});

window.addEventListener("resize", () => {
    if (panel && panel.style.position === "fixed") {
        const rect = panel.getBoundingClientRect();
        applyPanelPosition(rect.left, rect.top);
        savePanelPosition();
    }
});

itemsEl.addEventListener("click", (event) => {
    const btn = event.target.closest(".qtyBtn");
    if (!btn) {
        return;
    }
    event.preventDefault();
    event.stopPropagation();

    const rawItem = btn.getAttribute("data-item") || "";
    const itemName = decodeURIComponent(rawItem);
    const action = btn.getAttribute("data-action");
    const current = qtyOf(itemName);
    const next = action === "inc" ? current + 1 : current - 1;
    setQty(itemName, next);
    lastQtyClickAt = Date.now();
});

searchInput.addEventListener("input", () => {
    renderItems();
});
closeBtn.addEventListener("click", closeUi);

let lastBuyClickAt = 0;
buyBtn.addEventListener("click", () => {
    if (Date.now() - lastQtyClickAt < 250) {
        return;
    }
    if (Date.now() - lastBuyClickAt < 1500) {
        return;
    }
    const payload = Object.keys(cart).map((name) => ({
        name,
        amount: cart[name]
    }));
    if (payload.length === 0) {
        return;
    }
    lastBuyClickAt = Date.now();

    cart = {};
    renderItems();
    computeTotal();

    buyBtn.disabled = true;
    buyBtn.classList.add("disabled");
    setTimeout(() => {
        buyBtn.disabled = false;
        buyBtn.classList.remove("disabled");
    }, 1500);

    postNui("buy", { cart: payload });
});

window.addEventListener("message", (event) => {
    const d = event.data || {};
    if (d.action === "resetCart") {
        cart = {};
        renderItems();
        computeTotal();
    }
});

window.addEventListener("keydown", (event) => {
    if (event.key === "Escape") {
        closeUi();
    }
});
