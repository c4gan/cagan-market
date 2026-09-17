fx_version "cerulean"
game "rdr3"
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

lua54 "yes"

author "cagan"
description "cagan-market - Clean, Configurable Store & Shopping Cart System for RedM (VORP Core / RSG-Core)"
version "1.0.0"

shared_scripts {
    "config.lua",
    "locales/en.lua",
    "locales/tr.lua",
    "locales/de.lua",
    "locales/fr.lua",
    "shared/locale.lua"
}

client_scripts {
    "client/bridge.lua",
    "client/main.lua"
}

server_scripts {
    "@oxmysql/lib/MySQL.lua",
    "server/bridge.lua",
    "server/main.lua"
}

ui_page "html/index.html"

files {
    "html/index.html",
    "html/style.css",
    "html/app.js",
    "html/img/*",
    "html/img/**/*"
}
