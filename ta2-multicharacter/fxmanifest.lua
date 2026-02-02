fx_version 'cerulean'
game 'gta5'
lua54 'yes'
author 'TATITUPTECH'
description 'Allows players to create multiple characters'
version '1.2.0'

shared_scripts {
    '@ta2-core/shared/locale.lua',
    'locales/en.lua',
    'locales/*.lua',
    'config.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    '@qb-apartments/config.lua',
    'server/main.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/reset.css',
    'html/vue.js',
    'html/swal2.js',
    'html/profanity.js',
    'html/translations.js',
    'html/validation.js',
    'html/app.js'
}

dependencies {
    'ta2-core',
    'ta2-spawn'
}
