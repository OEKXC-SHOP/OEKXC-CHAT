fx_version 'cerulean'
game 'gta5'

author 'OEKXC' 
description 'Chat'
version '0.2.0'

lua54 'yes' 


shared_scripts {
    'config.lua',
    '@es_extended/locale.lua',       -- ESX için
    '@qb-core/shared/locale.lua'      -- QBCore için
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js'
}

client_scripts {
    'client/client.lua'
}

server_scripts {
    '@es_extended/server/common.lua', -- ESX için
    '@qb-core/server/classes.lua',   -- QBCore için
    'server/server_utils.lua',     -- Framework fonksiyonlarını içeren yardımcı dosya
    'server/server.lua'
} 