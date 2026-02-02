fx_version 'cerulean'
game 'gta5'
lua54 'yes'
author 'TATITUPTECH'
description 'Allows players to sell items for money'
version '1.2.0'

shared_scripts {
    '@ta2-core/shared/locale.lua',
    'config.lua',
    'locales/en.lua',
    'locales/*.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua'
}

client_scripts {
    '@PolyZone/client.lua',
    '@PolyZone/BoxZone.lua',
    '@PolyZone/ComboZone.lua',
    'client/main.lua'
}
