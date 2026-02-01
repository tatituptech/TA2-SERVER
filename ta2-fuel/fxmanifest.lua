fx_version "cerulean"
game "gta5"

author 'TATITUPTECH'
version '0.0.4'
description "A siple Fuel System for FiveM"

ui_page "html/index.html"

shared_scripts {
	'@ta2-core/shared/locale.lua',
    "Config.lua",
	'locales/*.lua',
}

client_scripts {
    "client/exports.lua",
    "client/main.lua"
}

server_scripts {
    "server/main.lua"
}

files {
    "html/index.html",
    "html/app.js",
    "html/translations.js",
    "html/style.css"
}

dependency 'ta2-target'

provide 'LegacyFuel'
