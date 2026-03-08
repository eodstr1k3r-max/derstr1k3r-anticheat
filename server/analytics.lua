--[[
    RedM Anticheat System - Analytics & Pattern Detection
    © 2026 DerStr1k3r
--]]

Analytics = {}

local behaviorPatterns = {}
local suspiciousActivities = {}

-- ═══════════════════════════════════════════════════════════
--  BEHAVIOR PATTERN ANALYSIS
-- ═══════════════════════════════════════════════════════════

function Analytics.InitPlayer(source)
    behaviorPatterns[source] = {
        movementPattern = {},
        combatPattern = {},
        economicPattern = {},
        socialPattern = {},
        suspicionScore = 0,
        lastAnalysis = os.time()
    }
end

function Analytics.RemovePlayer(source)
    behaviorPatterns[source] = nil
    suspiciousActivities[source] = nil
end

-- Bewegungsmuster analysieren
function Analytics.AnalyzeMovement(source, coords, speed)
    if not behaviorPatterns[source] then return end
    
    local pattern = behaviorPatterns[source].movementPattern
    
    table.insert(pattern, {
        coords = coords,
        speed = speed,
        time = os.time()
    })
    
    -- Behalte nur letzte 50 Einträge
    if #pattern > 50 then
        table.remove(pattern, 1)
    end
    
    -- Analysiere auf unnatürliche Muster
    if #pattern >= 10 then
        local avgSpeed = 0
        local speedVariance = 0
        
        for i = 1, #pattern do
            avgSpeed = avgSpeed + pattern[i].speed
        end
        avgSpeed = avgSpeed / #pattern
        
        -- Prüfe auf konstante hohe Geschwindigkeit (Bot-Verhalten)
        local constantHighSpeed = true
        for i = 1, #pattern do
            if math.abs(pattern[i].speed - avgSpeed) > 2.0 then
                constantHighSpeed = false
                break
            end
        end
        
        if constantHighSpeed and avgSpeed > Config.Thresholds.MaxSpeed * 0.8 then
            Analytics.IncreaseSuspicion(source, 5, "Konstante hohe Geschwindigkeit (Bot-Verdacht)")
        end
    end
end

-- Kampfmuster analysieren
function Analytics.AnalyzeCombat(source, shotData)
    if not behaviorPatterns[source] then return end
    
    local pattern = behaviorPatterns[source].combatPattern
    
    table.insert(pattern, {
        time = os.time(),
        weapon = shotData.weapon or 0,
        accuracy = shotData.accuracy or 0
    })
    
    if #pattern > 100 then
        table.remove(pattern, 1)
    end
    
    -- Prüfe auf unnatürlich hohe Trefferquote (Aimbot)
    if #pattern >= 20 then
        local totalAccuracy = 0
        local count = 0
        
        for i = math.max(1, #pattern - 20), #pattern do
            if pattern[i].accuracy > 0 then
                totalAccuracy = totalAccuracy + pattern[i].accuracy
                count = count + 1
            end
        end
        
        if count > 0 then
            local avgAccuracy = totalAccuracy / count
            
            if avgAccuracy > 0.95 then -- 95%+ Trefferquote
                Analytics.IncreaseSuspicion(source, 10, "Unnatürlich hohe Trefferquote (Aimbot-Verdacht)")
            end
        end
    end
end

-- Suspicion Score System
function Analytics.IncreaseSuspicion(source, amount, reason)
    if not behaviorPatterns[source] then return end
    
    behaviorPatterns[source].suspicionScore = behaviorPatterns[source].suspicionScore + amount
    
    if not suspiciousActivities[source] then
        suspiciousActivities[source] = {}
    end
    
    table.insert(suspiciousActivities[source], {
        reason = reason,
        amount = amount,
        time = os.time()
    })
    
    Utils.Debug(string.format("Suspicion increased for %d: %s (+%d, Total: %d)", 
        source, reason, amount, behaviorPatterns[source].suspicionScore))
    
    -- Warnung bei hohem Suspicion Score
    if behaviorPatterns[source].suspicionScore >= Config.Analytics.SuspicionThreshold then
        local playerInfo = Utils.GetPlayerInfo(source)
        
        Utils.NotifyAdmins(string.format(
            "^3[ANALYTICS]^7 %s (ID: %d) hat verdächtiges Verhalten (Score: %d)",
            playerInfo.name, source, behaviorPatterns[source].suspicionScore
        ))
        
        Utils.SendWebhook(
            "⚠️ Verdächtiges Verhalten",
            string.format(
                "**Spieler:** %s (ID: %d)\n**Suspicion Score:** %d\n**Letzte Aktivitäten:**\n%s",
                playerInfo.name, source, behaviorPatterns[source].suspicionScore,
                Analytics.GetRecentActivities(source)
            ),
            Config.Colors.Warning
        )
    end
end

function Analytics.DecreaseSuspicion(source, amount)
    if not behaviorPatterns[source] then return end
    
    behaviorPatterns[source].suspicionScore = math.max(0, behaviorPatterns[source].suspicionScore - amount)
end

function Analytics.GetRecentActivities(source)
    if not suspiciousActivities[source] then return "Keine" end
    
    local activities = ""
    local count = math.min(5, #suspiciousActivities[source])
    
    for i = #suspiciousActivities[source] - count + 1, #suspiciousActivities[source] do
        if suspiciousActivities[source][i] then
            activities = activities .. string.format("• %s (+%d)\n", 
                suspiciousActivities[source][i].reason,
                suspiciousActivities[source][i].amount
            )
        end
    end
    
    return activities
end

-- ═══════════════════════════════════════════════════════════
--  ADVANCED DETECTION ALGORITHMS
-- ═══════════════════════════════════════════════════════════

-- Erkennt Teleport-Chains (mehrere Teleports hintereinander)
function Analytics.DetectTeleportChain(source)
    if not behaviorPatterns[source] then return false end
    
    local pattern = behaviorPatterns[source].movementPattern
    if #pattern < 5 then return false end
    
    local teleportCount = 0
    local timeWindow = 10 -- Sekunden
    local currentTime = os.time()
    
    for i = #pattern - 4, #pattern do
        if pattern[i] and pattern[i+1] then
            local distance = Utils.GetDistance(pattern[i].coords, pattern[i+1].coords)
            local timeDiff = pattern[i+1].time - pattern[i].time
            
            if distance > 50 and timeDiff < 2 then
                teleportCount = teleportCount + 1
            end
        end
    end
    
    return teleportCount >= 3
end

-- Erkennt Speed-Burst Patterns
function Analytics.DetectSpeedBurst(source)
    if not behaviorPatterns[source] then return false end
    
    local pattern = behaviorPatterns[source].movementPattern
    if #pattern < 10 then return false end
    
    local burstCount = 0
    
    for i = #pattern - 9, #pattern do
        if pattern[i] and pattern[i].speed > Config.Thresholds.MaxSpeed * 1.5 then
            burstCount = burstCount + 1
        end
    end
    
    return burstCount >= 5
end

-- Erkennt Rapid Weapon Switch (Cheat-Indikator)
function Analytics.DetectRapidWeaponSwitch(source)
    if not behaviorPatterns[source] then return false end
    
    local pattern = behaviorPatterns[source].combatPattern
    if #pattern < 5 then return false end
    
    local weaponSwitches = 0
    local lastWeapon = nil
    
    for i = #pattern - 4, #pattern do
        if pattern[i] and lastWeapon and pattern[i].weapon ~= lastWeapon then
            weaponSwitches = weaponSwitches + 1
        end
        lastWeapon = pattern[i] and pattern[i].weapon
    end
    
    return weaponSwitches >= 4
end

-- ═══════════════════════════════════════════════════════════
--  PERIODIC ANALYSIS
-- ═══════════════════════════════════════════════════════════

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(Config.Analytics.AnalysisInterval or 60000)
        
        for source, data in pairs(behaviorPatterns) do
            -- Suspicion Score natürlich abbauen
            if data.suspicionScore > 0 then
                Analytics.DecreaseSuspicion(source, Config.Analytics.SuspicionDecay or 1)
            end
            
            -- Erweiterte Pattern-Checks
            if Analytics.DetectTeleportChain(source) then
                Analytics.IncreaseSuspicion(source, 15, "Teleport-Chain erkannt")
            end
            
            if Analytics.DetectSpeedBurst(source) then
                Analytics.IncreaseSuspicion(source, 10, "Speed-Burst Pattern erkannt")
            end
            
            if Analytics.DetectRapidWeaponSwitch(source) then
                Analytics.IncreaseSuspicion(source, 8, "Rapid Weapon Switch erkannt")
            end
        end
    end
end)

-- ═══════════════════════════════════════════════════════════
--  STATISTICS & REPORTING
-- ═══════════════════════════════════════════════════════════

function Analytics.GetPlayerAnalytics(source)
    if not behaviorPatterns[source] then return nil end
    
    local data = behaviorPatterns[source]
    
    return {
        suspicionScore = data.suspicionScore,
        movementDataPoints = #data.movementPattern,
        combatDataPoints = #data.combatPattern,
        recentActivities = Analytics.GetRecentActivities(source),
        lastAnalysis = data.lastAnalysis
    }
end

function Analytics.GenerateReport(source)
    local analytics = Analytics.GetPlayerAnalytics(source)
    if not analytics then return "Keine Daten verfügbar" end
    
    local report = string.format(
        "Suspicion Score: %d\nBewegungsdaten: %d\nKampfdaten: %d\nLetzte Analyse: %s",
        analytics.suspicionScore,
        analytics.movementDataPoints,
        analytics.combatDataPoints,
        os.date("%H:%M:%S", analytics.lastAnalysis)
    )
    
    return report
end

return Analytics
