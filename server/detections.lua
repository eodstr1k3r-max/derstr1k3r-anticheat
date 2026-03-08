--[[
    RedM Anticheat System - Detections
    © 2026 DerStr1k3r
--]]

Detections = {}

local playerData = {}
local systemStats = {
    totalViolations = 0,
    totalKicks = 0,
    totalBans = 0
}

-- ═══════════════════════════════════════════════════════════
--  SPIELER VERWALTUNG
-- ═══════════════════════════════════════════════════════════

function Detections.InitPlayer(source)
    playerData[source] = {
        violations = {},
        totalViolations = 0,
        lastPosition = nil,
        lastHealth = 0,
        lastArmor = 0,
        lastWeapon = 0,
        lastWeaponAmmo = 0,
        lastShot = 0,
        shotCount = 0,
        explosionCount = 0,
        lastExplosion = 0,
        joinTime = os.time(),
        isFrozen = false
    }
    Utils.Debug("Player " .. source .. " initialized")
end

function Detections.RemovePlayer(source)
    playerData[source] = nil
    Utils.ClearPlayerCache(source)
    Utils.Debug("Player " .. source .. " removed")
end

function Detections.GetPlayerStats(source)
    return playerData[source]
end

function Detections.GetSystemStats()
    local activePlayers = 0
    local activeChecks = 0
    
    for _ in pairs(playerData) do
        activePlayers = activePlayers + 1
    end
    
    for check, enabled in pairs(Config.Checks) do
        if enabled then
            activeChecks = activeChecks + 1
        end
    end
    
    return {
        totalPlayers = activePlayers,
        totalViolations = systemStats.totalViolations,
        totalKicks = systemStats.totalKicks,
        totalBans = systemStats.totalBans,
        activeChecks = activeChecks
    }
end

-- ═══════════════════════════════════════════════════════════
--  VIOLATION HANDLER
-- ═══════════════════════════════════════════════════════════

function Detections.HandleViolation(source, reason, severity)
    if Utils.CanBypass(source) then 
        Utils.Debug("Bypass " .. source .. " skipped: " .. reason)
        return 
    end
    
    if not playerData[source] then
        Detections.InitPlayer(source)
    end
    
    -- Performance Tracking
    local timer = Performance.StartTimer('detectionTime')
    
    local data = playerData[source]
    data.totalViolations = data.totalViolations + 1
    systemStats.totalViolations = systemStats.totalViolations + 1
    
    severity = severity or Config.SeverityLevels[reason] or 1
    
    table.insert(data.violations, {
        reason = reason,
        time = os.time(),
        severity = severity
    })
    
    local playerInfo = Utils.GetPlayerInfo(source)
    
    -- Database Recording
    if Config.Database and Config.Database.Enabled then
        Database.RecordViolation(playerInfo.license, reason, severity, {
            playerName = playerInfo.name,
            ping = playerInfo.ping
        })
    end
    
    -- Dashboard Recording
    if Config.Dashboard and Config.Dashboard.Enabled then
        Dashboard.RecordDetection(source, reason)
    end
    
    -- Reputation System
    if Config.Reputation and Config.Reputation.Enabled then
        Reputation.OnViolation(source, severity)
    end
    
    -- ML-Score & Reputation Anpassung
    local adjustedThreshold = Config.Thresholds.ViolationsBeforeKick
    local mlScore = nil
    
    if Config.MLScoring and Config.MLScoring.Enabled then
        mlScore = MLScoring.CalculateOverallScore(source)
        if mlScore >= 70 then
            adjustedThreshold = math.floor(adjustedThreshold * 0.6)
        elseif mlScore >= 50 then
            adjustedThreshold = math.floor(adjustedThreshold * 0.8)
        end
    end
    
    if Config.Reputation and Config.Reputation.Enabled then
        adjustedThreshold = Reputation.GetAdjustedThreshold(source, adjustedThreshold)
    end
    
    -- Smart Notifications
    if Config.Notifications and Config.Notifications.Enabled then
        Notifications.SmartDetection(source, reason, severity, mlScore)
    else
        if Config.Actions.Log then
            Utils.Log("warning", string.format("%s (ID: %d) - %s (Verstöße: %d/%d)", 
                playerInfo.name, source, reason, data.totalViolations, adjustedThreshold))
        end
        
        Utils.NotifyAdmins(string.format(
            Utils.GetMessage("AdminNotification"),
            playerInfo.name, source, reason, data.totalViolations, adjustedThreshold
        ))
    end
    
    -- Warnung an Spieler
    if data.totalViolations < adjustedThreshold then
        TriggerClientEvent('chat:addMessage', source, {
            args = {Utils.GetMessage("PlayerWarning")}
        })
    end
    
    -- Freeze bei hoher Severity
    if Config.Actions.FreezePlayer and severity >= 3 and not data.isFrozen then
        Utils.FreezePlayer(source, true)
        data.isFrozen = true
    end
    
    -- Auto-Ban Check
    for _, autoBanViolation in pairs(Config.AutoBanViolations) do
        if reason == autoBanViolation then
            if Config.Actions.Ban and Config.Database.Enabled then
                Database.AddBan(playerInfo.license, "Auto-Ban: " .. reason, 0, "System")
                systemStats.totalBans = systemStats.totalBans + 1
                
                if Config.Reputation and Config.Reputation.Enabled then
                    Reputation.OnBan(source)
                end
            end
            DropPlayer(source, string.format(Utils.GetMessage("KickReason"), reason))
            systemStats.totalKicks = systemStats.totalKicks + 1
            
            if Config.Dashboard and Config.Dashboard.Enabled then
                Dashboard.RecordKick(source)
            end
            
            Performance.EndTimer(timer)
            return
        end
    end
    
    -- Kick bei zu vielen Verstößen
    if Config.Actions.Kick and data.totalViolations >= adjustedThreshold then
        DropPlayer(source, string.format(Utils.GetMessage("KickReason"), reason))
        systemStats.totalKicks = systemStats.totalKicks + 1
        
        if Config.Dashboard and Config.Dashboard.Enabled then
            Dashboard.RecordKick(source)
        end
        
        if Config.Reputation and Config.Reputation.Enabled then
            Reputation.OnKick(source)
        end
    end
    
    Performance.EndTimer(timer)
end

-- ═══════════════════════════════════════════════════════════
--  DETECTION FUNCTIONS
-- ═══════════════════════════════════════════════════════════

function Detections.CheckGodMode(source, health, maxHealth, armor)
    if not Config.Checks.GodMode then return end
    if not playerData[source] then return end
    
    if health > maxHealth + 50 then
        Detections.HandleViolation(source, "GodMode", 3)
    end
    
    playerData[source].lastHealth = health
    playerData[source].lastArmor = armor
end

function Detections.CheckSpeed(source, data)
    if not Config.Checks.SpeedHack then return end
    if not playerData[source] then return end
    
    local maxSpeed = Config.Thresholds.MaxSpeed
    
    if data.isInVehicle then
        maxSpeed = Config.Thresholds.MaxSpeedInVehicle
    elseif data.isOnHorse then
        maxSpeed = Config.Thresholds.MaxSpeedOnHorse
    end
    
    maxSpeed = Utils.AdjustThresholdForPing(maxSpeed, source)
    
    if data.speed > maxSpeed and not data.isRagdoll then
        Detections.HandleViolation(source, "SpeedHack", 2)
    end
end

function Detections.CheckTeleport(source, coords)
    if not Config.Checks.Teleport then return end
    if not playerData[source] then return end
    
    local lastPos = playerData[source].lastPosition
    
    if lastPos then
        local distance = Utils.GetDistance(coords, lastPos)
        local adjustedThreshold = Utils.AdjustThresholdForPing(Config.Thresholds.TeleportDistance, source)
        
        if distance > adjustedThreshold then
            Detections.HandleViolation(source, "Teleport", 3)
        end
    end
    
    playerData[source].lastPosition = coords
end

function Detections.CheckSuperJump(source, zVelocity)
    if not Config.Checks.SuperJump then return end
    if not playerData[source] then return end
    
    if zVelocity > Config.Thresholds.MaxJumpHeight then
        Detections.HandleViolation(source, "SuperJump", 2)
    end
end

function Detections.CheckFly(source, zVelocity)
    if not Config.Checks.Fly then return end
    if not playerData[source] then return end
    
    if math.abs(zVelocity) > 3.0 then
        Detections.HandleViolation(source, "Fly", 3)
    end
end

function Detections.CheckWeapon(source, weaponData)
    if not Config.Checks.WeaponSpawn then return end
    if not playerData[source] then return end
    
    if Config.AllowedWeapons[weaponData.hash] == false then
        Detections.HandleViolation(source, "WeaponSpawn", 2)
    end
    
    -- Infinite Ammo Check
    if Config.Checks.InfiniteAmmo then
        local lastAmmo = playerData[source].lastWeaponAmmo
        if lastAmmo > 0 and weaponData.ammo > lastAmmo + 10 then
            Detections.HandleViolation(source, "InfiniteAmmo", 2)
        end
    end
    
    playerData[source].lastWeapon = weaponData.hash
    playerData[source].lastWeaponAmmo = weaponData.ammo
end

function Detections.CheckRapidFire(source, shotCount)
    if not Config.Checks.RapidFire then return end
    if not playerData[source] then return end
    
    if shotCount > Config.Thresholds.MaxShotsPerSecond then
        Detections.HandleViolation(source, "RapidFire", 2)
    end
end

function Detections.CheckExplosion(source, coords)
    if not Config.Checks.ExplosionSpam then return end
    if not playerData[source] then return end
    
    local currentTime = os.time()
    local data = playerData[source]
    
    if currentTime - data.lastExplosion < 60 then
        data.explosionCount = data.explosionCount + 1
        
        if data.explosionCount > Config.Thresholds.MaxExplosionsPerMinute then
            Detections.HandleViolation(source, "ExplosionSpam", 2)
            data.explosionCount = 0
        end
    else
        data.explosionCount = 1
    end
    
    data.lastExplosion = currentTime
end

function Detections.CheckGodModeClient(source)
    if not Config.Checks.GodMode then return end
    Detections.HandleViolation(source, "GodMode", 3)
end

function Detections.CheckNoclip(source)
    if not Config.Checks.Noclip then return end
    Detections.HandleViolation(source, "Noclip", 3)
end

-- ═══════════════════════════════════════════════════════════
--  VIOLATION DECAY SYSTEM
-- ═══════════════════════════════════════════════════════════

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(60000) -- Jede Minute
        
        for source, data in pairs(playerData) do
            if data.violations and #data.violations > 0 then
                local currentTime = os.time()
                local decayed = false
                
                for i = #data.violations, 1, -1 do
                    if currentTime - data.violations[i].time > Config.Thresholds.ViolationDecayTime then
                        table.remove(data.violations, i)
                        data.totalViolations = math.max(0, data.totalViolations - 1)
                        decayed = true
                    end
                end
                
                if decayed then
                    TriggerClientEvent('chat:addMessage', source, {
                        args = {Utils.GetMessage("ViolationDecayed")}
                    })
                    Utils.Debug("Violations decayed for player " .. source)
                end
            end
        end
    end
end)

return Detections
