fx_version 'cerulean'
game 'gta5'
author 'Zevo Scripts'
description 'Harbour Job'
version '1.0'

lua54 'yes'

client_scripts {
    '@PolyZone/client.lua',
    '@PolyZone/BoxZone.lua',
    '@PolyZone/ComboZone.lua',
    'client/*'
}
server_script 'server/*'
shared_scripts { 
    'shared/locale.lua',
    'locales/*.lua',
    'config.lua'
}
dependencies { 
    '/server:5181',
    '/gameBuild:2189',
    '/onesync',
}

escrow_ignore {
	'server/functions.lua',
	'client/functions.lua',
	'config.lua',
}