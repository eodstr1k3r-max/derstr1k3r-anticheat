fx_version 'cerulean'
game 'rdr3'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

author 'DerStr1k3r'
description 'Enterprise RedM Anticheat - Complete Security Suite with ML, Analytics & Performance Monitoring'
version '5.0.0'

server_scripts {
    'server/config.lua',
    'server/utils.lua',
    'server/database.lua',
    'server/notifications.lua',
    'server/performance.lua',
    'server/reputation.lua',
    'server/ml_scoring.lua',
    'server/analytics.lua',
    'server/protection.lua',
    'server/dashboard.lua',
    'server/detections.lua',
    'server/commands.lua',
    'server/main.lua'
}

client_scripts {
    'client/main.lua',
    'client/events.lua'
}

files {
    'README.md',
    'LICENSE'
}

lua54 'yes'
