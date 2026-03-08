--[[
    RedM Anticheat System - Client Events
    © 2026 DerStr1k3r
--]]

local isFrozen = false

-- Spieler einfrieren
RegisterNetEvent('anticheat:freeze')
AddEventHandler('anticheat:freeze', function(freeze)
    local playerPed = PlayerPedId()
    isFrozen = freeze
    
    FreezeEntityPosition(playerPed, freeze)
    SetPlayerControl(PlayerId(), not freeze, 0)
    
    if freeze then
        -- Visueller Effekt beim Einfrieren
        SetEntityAlpha(playerPed, 200, false)
    else
        SetEntityAlpha(playerPed, 255, false)
    end
end)

-- Spieler teleportieren
RegisterNetEvent('anticheat:teleport')
AddEventHandler('anticheat:teleport', function(coords)
    local playerPed = PlayerPedId()
    
    DoScreenFadeOut(500)
    Wait(500)
    
    SetEntityCoords(playerPed, coords.x, coords.y, coords.z, false, false, false, false)
    
    Wait(500)
    DoScreenFadeIn(500)
end)

-- Screenshot Request (optional)
RegisterNetEvent('anticheat:screenshot')
AddEventHandler('anticheat:screenshot', function()
    -- Hier könnte Screenshot-Logik implementiert werden
    -- Erfordert zusätzliche Screenshot-Resource
end)

-- Kick mit Nachricht
RegisterNetEvent('anticheat:kick')
AddEventHandler('anticheat:kick', function(reason)
    -- Wird vom Server gehandhabt, aber hier für Custom UI
end)

-- Ist Spieler eingefroren?
function IsFrozen()
    return isFrozen
end
