fx_version 'cerulean' --bodacious, adamant
games { 'rdr3', 'gta5' }

author 'Hakos47'
description 'saca el raton y haz click sobre las cosas para darte opciones'


client_scripts {
    'hks_menu-c.lua',
    'config.lua',
}


server_script 'hks_menu-s.lua'
    

ui_page('html/index.html')

files {
    'html/index.html',
    'html/index.js',
    'html/index.css',
    'html/reset.css'
}