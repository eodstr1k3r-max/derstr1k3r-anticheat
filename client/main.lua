--[[
    RedM Anticheat System - Client
    © 2026 DerStr1k3r
--]]

local lastPosition = nil
local lastJumpTime = 0
local lastWeapon = 0
local lastHealth = 0
local shotTimes = {}
local isInitialized = false

-- Initialisierung
Citizen.CreateThread(function()
    Wait(2000)
    isInitialized = true
    print("^2[ANTICHEAT]^7 Client erfolgreich geladen")
    print("^2[ANTICHEAT]^7 © 2026 DerStr1k3r")
end)

-- Health & Position Check
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(2000)
        
        if isInitialized then
            local playerPed = PlayerPedId()
            
            if DoesEntityExist(playerPed) and not IsEntityDead(playerPed) then
                local health = GetEntityHealth(playerPed)
                local maxHealth = GetEntityMaxHealth(playerPed)
                local armor = GetPedArmour(playerPed)
                
                TriggerServerEvent('anticheat:healthCheck', health, maxHealth, armor)
                
                local coords = GetEntityCoords(playerPed)
                TriggerServerEvent('anticheat:positionCheck', {x = coords.x, y = coords.y, z = coords.z})
                
                lastHealth = health
            end
        end
    end
end)

-- Speed Check
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        
        if isInitialized then
            local playerPed = PlayerPedId()
            
            if DoesEntityExist(playerPed) and not IsEntityDead(playerPed) then
                local velocity = GetEntityVelocity(playerPed)
                local speed = math.sqrt(velocity.x^2 + velocity.y^2 + velocity.z^2)
                local isOnHorse = IsPedOnMount(playerPed)
                local isInVehicle = IsPedInAnyVehicle(playerPed, false)
                
                TriggerServerEvent('anticheat:speedCheck', {
                    speed = speed,
                    isOnHorse = isOnHorse,
                    isInVehicle = isInVehicle
                })
            end
        end
    end
end)

-- Jump & Fly Check
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(100)
        
        if isInitialized then
            local playerPed = PlayerPedId()
            
            if DoesEntityExist(playerPed) and not IsEntityDead(playerPed) then
                local velocity = GetEntityVelocity(playerPed)
                local currentTime = GetGameTimer()
                
                if IsPedJumping(playerPed) and currentTime - lastJumpTime > 1000 then
                    TriggerServerEvent('anticheat:jumpCheck', velocity.z)
                    lastJumpTime = currentTime
                end
                
                if not IsPedFalling(playerPed) and not IsPedJumping(playerPed) and 
                   not IsPedOnMount(playerPed) and not IsPedInAnyVehicle(playerPed, false) then
                    if velocity.z > 3.0 or velocity.z < -3.0 then
                        TriggerServerEvent('anticheat:flyCheck', velocity.z)
                    end
                end
            end
        end
    end
end)

-- Weapon Check
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(500)
        
        if isInitialized then
            local playerPed = PlayerPedId()
            
            if DoesEntityExist(playerPed) and not IsEntityDead(playerPed) then
                local currentWeapon = GetSelectedPedWeapon(playerPed)
                
                if currentWeapon ~= lastWeapon and currentWeapon ~= GetHashKey("WEAPON_UNARMED") then
                    local ammo = GetAmmoInPedWeapon(playerPed, currentWeapon)
                    TriggerServerEvent('anticheat:weaponCheck', {hash = currentWeapon, ammo = ammo})
                    lastWeapon = currentWeapon
                end
            end
        end
    end
end)

-- Shot Detection
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        
        if isInitialized then
            local playerPed = PlayerPedId()
            
            if DoesEntityExist(playerPed) and not IsEntityDead(playerPed) then
                if IsPedShooting(playerPed) then
                    local currentTime = GetGameTimer()
                    table.insert(shotTimes, currentTime)
                    
                    for i = #shotTimes, 1, -1 do
                        if currentTime - shotTimes[i] > 1000 then
                            table.remove(shotTimes, i)
                        end
                    end
                    
                    TriggerServerEvent('anticheat:shotFired', #shotTimes)
                    Citizen.Wait(50)
                end
            end
        end
    end
end)

-- GodMode Detection
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(5000)
        
        if isInitialized then
            local playerPed = PlayerPedId()
            
            if DoesEntityExist(playerPed) then
                local invincible = GetEntityInvincible(playerPed)
                if invincible then
                    TriggerServerEvent('anticheat:godmodeDetected')
                end
            end
        end
    end
end)

-- Noclip Detection
Citizen.CreateThread(function()
    local lastGroundCheck = 0
    local airTime = 0
    
    while true do
        Citizen.Wait(500)
        
        if isInitialized then
            local playerPed = PlayerPedId()
            
            if DoesEntityExist(playerPed) and not IsEntityDead(playerPed) then
                local currentTime = GetGameTimer()
                
                if not IsPedOnMount(playerPed) and not IsPedInAnyVehicle(playerPed, false) then
                    local isInAir = not IsPedOnGround(playerPed) and not IsPedSwimming(playerPed)
                    
                    if isInAir then
                        airTime = airTime + (currentTime - lastGroundCheck)
                        
                        if airTime > 5000 then
                            local velocity = GetEntityVelocity(playerPed)
                            if math.abs(velocity.z) < 1.0 then
                                TriggerServerEvent('anticheat:noclipDetected')
                            end
                        end
                    else
                        airTime = 0
                    end
                end
                
                lastGroundCheck = currentTime
            end
        end
    end
end)            
    
                lastGroundCheck = currentTime
            end
        end
    end
end)
                        -- Wenn länger als 5 Sekunden in der Luft ohne Fallen
                        if airTime > 5000 then
                            local velocity = GetEntityVelocity(playerPed)
                            if math.abs(velocity.z) < 1.0 then
                                TriggerServerEvent('anticheat:noclipDetected')
                            end
                        end
                    else
                        airTime = 0
                    end
                end
                        
            if DoesEntityExist(playerPed) and not IsEntityDead(playerPed) then
                local currentTime = GetGameTimer()
                
                if not IsPedOnMount(playerPed) and not IsPedInAnyVehicle(playerPed, false) then
                    local isInAir = not IsPedOnGround(playerPed) and not IsPedSwimming(playerPed)
                    
                    if isInAir then
                        airTime = airTime + (currentTime - lastGroundCheck)
                        
)
                end
            end
            
            TriggerServerEvent('anticheat:resourceList', resourceList)
        end
    end
end)

-- ═══════════════════════════════════════════════════════════
--  NOCLIP DETECTION
-- ═══════════════════════════════════════════════════════════

Citizen.CreateThread(function()
    local lastGroundCheck = 0
    local airTime = 0
    
    while true do
        Citizen.Wait(500)
        
        if isInitialized then
            local playerPed = PlayerPedId()
═════════════

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(10000)
        
        if isInitialized then
            -- Prüfe auf verdächtige Resources
            local numResources = GetNumResources()
            local resourceList = {}
            
            for i = 0, numResources - 1 do
                local resourceName = GetResourceByFindIndex(i)
                if GetResourceState(resourceName) == "started" then
                    table.insert(resourceList, resourceName       if isInitialized then
            local playerPed = PlayerPedId()
            
            if DoesEntityExist(playerPed) then
                local invincible = GetEntityInvincible(playerPed)
                
                if invincible then
                    TriggerServerEvent('anticheat:godmodeDetected')
                end
            end
        end
    end
end)

-- ═══════════════════════════════════════════════════════════
--  RESOURCE MONITOR
-- ══════════════════════════════════════════════                TriggerServerEvent('anticheat:explosionDetected', {
                    x = coords.x,
                    y = coords.y,
                    z = coords.z
                })
                Citizen.Wait(1000)
            end
        end
    end
end)

-- ═══════════════════════════════════════════════════════════
--  GODMODE DETECTION (CLIENT-SIDE)
-- ═══════════════════════════════════════════════════════════

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(5000)
        
 CTION
-- ═══════════════════════════════════════════════════════════

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        
        if isInitialized then
            local playerPed = PlayerPedId()
            local coords = GetEntityCoords(playerPed)
            
            -- Prüfe auf Explosionen in der Nähe
            if IsExplosionInArea(-1, coords.x - 10, coords.y - 10, coords.z - 10, 
                                    coords.x + 10, coords.y + 10, coords.z + 10) then
r als 1 Sekunde)
                    for i = #shotTimes, 1, -1 do
                        if currentTime - shotTimes[i] > 1000 then
                            table.remove(shotTimes, i)
                        end
                    end
                    
                    TriggerServerEvent('anticheat:shotFired', #shotTimes)
                    Citizen.Wait(50)
                end
            end
        end
    end
end)

-- ═══════════════════════════════════════════════════════════
--  EXPLOSION DETE═══════════════════════════════

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        
        if isInitialized then
            local playerPed = PlayerPedId()
            
            if DoesEntityExist(playerPed) and not IsEntityDead(playerPed) then
                if IsPedShooting(playerPed) then
                    local currentTime = GetGameTimer()
                    table.insert(shotTimes, currentTime)
                    
                    -- Entferne alte Einträge (älte          local ammo = GetAmmoInPedWeapon(playerPed, currentWeapon)
                    
                    TriggerServerEvent('anticheat:weaponCheck', {
                        hash = currentWeapon,
                        ammo = ammo
                    })
                    
                    lastWeapon = currentWeapon
                end
            end
        end
    end
end)

-- ═══════════════════════════════════════════════════════════
--  SHOT DETECTION & RAPID FIRE
-- ════════════════════════════- ═══════════════════════════════════════════════════════════

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(500)
        
        if isInitialized then
            local playerPed = PlayerPedId()
            
            if DoesEntityExist(playerPed) and not IsEntityDead(playerPed) then
                local currentWeapon = GetSelectedPedWeapon(playerPed)
                
                if currentWeapon ~= lastWeapon and currentWeapon ~= GetHashKey("WEAPON_UNARMED") then
          -Velocity ohne Grund)
                if not IsPedFalling(playerPed) and not IsPedJumping(playerPed) and 
                   not IsPedOnMount(playerPed) and not IsPedInAnyVehicle(playerPed, false) then
                    if velocity.z > 3.0 or velocity.z < -3.0 then
                        TriggerServerEvent('anticheat:flyCheck', velocity.z)
                    end
                end
            end
        end
    end
end)

-- ═══════════════════════════════════════════════════════════
--  WEAPON CHECK
-                -- Fly Check (hohe Z