fx_version 'cerulean'
game 'gta5'
lua54 'yes'
author 'TATITUPTECH'
description 'Allows players to play as a news reporter and access the equipment for it'
version '1.3.0'

shared_scripts {
    'config.lua',
    '@ta2-core/shared/locale.lua',
    'locales/en.lua',
    'locales/*.lua',
}

client_scripts {
    'client/main.lua',
    'client/camera.lua',
}

server_script 'server/main.lua'
