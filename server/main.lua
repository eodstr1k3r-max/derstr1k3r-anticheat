--[[
    RedM Anticheat System - Main Server
    © 2026 DerStr1k3r
--]]

-- Startup
Citizen.CreateThread(function()
    Wait(1000)
    
    -- Initialize Systems
    Database.Load()
    Protection.Initialize()
    
    print("^2╔════════════════════════════════════╗^7")
    print("^2║   RedM Anticheat System v5.0      ║^7")
    print("^2║   © 2026 DerStr1k3r                ║^7")
    print("^2║   Status: ^7Aktiv^2                    ║^7")
    print("^2║   Database: ^7" .. (Config.Database.Enabled and "Aktiv" or "Inaktiv") .. "^2                ║^7")
    print("^2║   ML-Scoring: ^7" .. (Config.MLScoring.Enabled and "Aktiv" or "Inaktiv") .. "^2              ║^7")
    print("^2║   Reputation: ^7" .. (Config.Reputation.Enabled and "Aktiv" or "Inaktiv") .. "^2              ║^7")
    print("^2║   Performance: ^7" .. (Config.Performance.Enabled and "Aktiv" or "Inaktiv") .. "^2             ║^7")
    print("^2╚════════════════════════════════════╝^7")
    
    local activeChecks = 0
    for _, enabled in pairs(Config.Checks) do
        if enabled then activeChecks = activeChecks + 1 end
    end
    
    local dbStats = Database.GetStatistics()
    
    Utils.SendWebhook(
        "✅ Anticheat gestartet",
        string.format(
            "Das Anticheat-System wurde erfolgreich gestartet.\n\n**Version:** 5.0.0\n**Features:**\n• Database: %s\n• ML-Scoring: %s\n• Reputation: %s\n• Performance Monitor: %s\n• Analytics: %s\n• Dashboard: %s\n• Protection: %s\n• Active Checks: %d\n\n**Database Stats:**\n• Total Bans: %d\n• Active Bans: %d\n• Total Players: %d",
            Config.Database.Enabled and "✓" or "✗",
            Config.MLScoring.Enabled and "✓" or "✗",
            Config.Reputation.Enabled and "✓" or "✗",
            Config.Performance.Enabled and "✓" or "✗",
            Config.Analytics.Enabled and "✓" or "✗",
            Config.Dashboard.Enabled and "✓" or "✗",
            Config.Protection.EventRateLimit and "✓" or "✗",
            activeChecks,
            dbStats.totalBans,
            dbStats.activeBans,
            dbStats.totalPlayers
        ),
        Config.Colors.Success
    )
end)

-- Player Connect
AddEventHandler('playerConnecting', function(name, setKickReason, deferrals)
    local source = source
    deferrals.defer()
    
    Wait(100)
    
    local playerInfo = Utils.GetPlayerInfo(source)
    
    -- Ban Check
    local isBanned, banInfo = Database.IsBanned(playerInfo.license)
    if isBanned then
        local timeLeft = banInfo.duration > 0 and Utils.FormatTime(banInfo.expires - os.time()) or "Permanent"
        deferrals.done(string.format(
            "Du bist gebannt.\n\nGrund: %s\nDauer: %s\nAdmin: %s",
            banInfo.reason, timeLeft, banInfo.adminName
        ))
        return
    end
    
    -- IP Check
    if Protection.IsIPBlocked(playerInfo.ip) then
        deferrals.done("Du wurdest vom Server gebannt.")
        return
    end
    
    -- VPN Check
    if Config.Protection.BlockVPN and Protection.CheckVPN(source) then
        deferrals.done("VPN/Proxy-Verbindungen sind nicht erlaubt.")
        return
    end
    
    deferrals.update("Anticheat wird initialisiert...")
    
    -- Initialize Systems
    Detections.InitPlayer(source)
    
    if Config.Analytics.Enabled then
        Analytics.InitPlayer(source)
    end
    
    if Config.MLScoring.Enabled then
        MLScoring.InitProfile(source)
    end
    
    if Config.Reputation.Enabled then
        Reputation.InitPlayer(source)
    end
    
    if Config.Database.Enabled then
        Database.RecordPlayerSession(playerInfo.license, playerInfo)
    end
    
    Wait(100)
    deferrals.done()
end)

-- Player Disconnect
AddEventHandler('playerDropped', function(reason)
    local source = source
    Detections.RemovePlayer(source)
    
    if Config.Analytics.Enabled then
        Analytics.RemovePlayer(source)
    end
    
    if Config.MLScoring.Enabled then
        MLScoring.RemoveProfile(source)
    end
end)

-- Health Check
RegisterNetEvent('anticheat:healthCheck')
AddEventHandler('anticheat:healthCheck', function(health, maxHealth, armor)
    local source = source
    
    if Config.Protection.EventRateLimit and not Protection.CheckEventRateLimit(source, 'anticheat:healthCheck') then
        return
    end
    
    Detections.CheckGodMode(source, health, maxHealth, armor or 0)
end)

-- Position Check
RegisterNetEvent('anticheat:positionCheck')
AddEventHandler('anticheat:positionCheck', function(coords)
    local source = source
    
    if Config.Protection.EventRateLimit and not Protection.CheckEventRateLimit(source, 'anticheat:positionCheck') then
        return
    end
    
    Detections.CheckTeleport(source, coords)
end)

-- Speed Check
RegisterNetEvent('anticheat:speedCheck')
AddEventHandler('anticheat:speedCheck', function(data)
    local source = source
    
    if Config.Protection.EventRateLimit and not Protection.CheckEventRateLimit(source, 'anticheat:speedCheck') then
        return
    end
    
    Detections.CheckSpeed(source, data)
    
    if Config.Analytics.Enabled and Config.Analytics.TrackMovement then
        Analytics.AnalyzeMovement(source, data.coords or {x=0,y=0,z=0}, data.speed)
    end
    
    if Config.MLScoring.Enabled then
        MLScoring.ExtractMovementFeatures(source, data)
    end
end)

-- Jump Check
RegisterNetEvent('anticheat:jumpCheck')
AddEventHandler('anticheat:jumpCheck', function(zVelocity)
    local source = source
    Detections.CheckSuperJump(source, zVelocity)
end)

-- Fly Check
RegisterNetEvent('anticheat:flyCheck')
AddEventHandler('anticheat:flyCheck', function(zVelocity)
    local source = source
    Detections.CheckFly(source, zVelocity)
end)

-- Weapon Check
RegisterNetEvent('anticheat:weaponCheck')
AddEventHandler('anticheat:weaponCheck', function(weaponData)
    local source = source
    Detections.CheckWeapon(source, weaponData)
end)

-- Shot Check
RegisterNetEvent('anticheat:shotFired')
AddEventHandler('anticheat:shotFired', function(shotCount)
    local source = source
    
    if Config.Protection.EventRateLimit and not Protection.CheckEventRateLimit(source, 'anticheat:shotFired') then
        return
    end
    
    Detections.CheckRapidFire(source, shotCount)
end)

-- Explosion Check
RegisterNetEvent('anticheat:explosionDetected')
AddEventHandler('anticheat:explosionDetected', function(coords)
    local source = source
    Detections.CheckExplosion(source, coords)
end)

-- GodMode Client Detection
RegisterNetEvent('anticheat:godmodeDetected')
AddEventHandler('anticheat:godmodeDetected', function()
    local source = source
    Detections.CheckGodModeClient(source)
end)

-- Noclip Detection
RegisterNetEvent('anticheat:noclipDetected')
AddEventHandler('anticheat:noclipDetected', function()
    local source = source
    Detections.CheckNoclip(source)
end)

-- Resource Injection Check
if Config.Checks.ResourceInjection then
    AddEventHandler('onResourceStarting', function(resourceName)
        local source = source
        if source and source > 0 and not Utils.CanBypass(source) then
            if not Utils.IsResourceAllowed(resourceName) then
                Detections.HandleViolation(source, "ResourceInjection", 3)
                CancelEvent()
            end
        end
    end)
end

-- Event Injection Check
if Config.Checks.EventInjection then
    AddEventHandler('onServerResourceStart', function(resourceName)
        if resourceName == GetCurrentResourceName() then
            Utils.Log("info", "Event protection initialized")
        end
    end)
end
