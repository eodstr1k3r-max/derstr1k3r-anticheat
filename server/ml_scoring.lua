--[[
    RedM Anticheat System - Machine Learning Scoring
    © 2026 DerStr1k3r
    
    Heuristische Analyse mit gewichteten Scoring-Algorithmen
--]]

MLScoring = {}

local playerProfiles = {}
local globalBaseline = {
    avgSpeed = 5.0,
    avgAccuracy = 0.45,
    avgShotInterval = 1.5,
    avgMovementVariance = 2.0
}

-- ═══════════════════════════════════════════════════════════
--  PLAYER PROFILING
-- ═══════════════════════════════════════════════════════════

function MLScoring.InitProfile(source)
    playerProfiles[source] = {
        -- Bewegungsprofil
        movement = {
            avgSpeed = 0,
            maxSpeed = 0,
            speedVariance = 0,
            teleportCount = 0,
            samples = {}
        },
        
        -- Kampfprofil
        combat = {
            avgAccuracy = 0,
            headshotRatio = 0,
            avgShotInterval = 0,
            totalShots = 0,
            totalHits = 0,
            samples = {}
        },
        
        -- Verhaltensprofil
        behavior = {
            playTime = 0,
            deathCount = 0,
            killCount = 0,
            resourceUsage = 0,
            eventFrequency = {}
        },
        
        -- Anomalie-Scores
        anomalyScores = {
            movement = 0,
            combat = 0,
            behavior = 0,
            overall = 0
        },
        
        -- Zeitstempel
        created = os.time(),
        lastUpdate = os.time()
    }
end

function MLScoring.RemoveProfile(source)
    playerProfiles[source] = nil
end

-- ═══════════════════════════════════════════════════════════
--  FEATURE EXTRACTION
-- ═══════════════════════════════════════════════════════════

function MLScoring.ExtractMovementFeatures(source, data)
    if not playerProfiles[source] then return end
    
    local profile = playerProfiles[source].movement
    
    table.insert(profile.samples, {
        speed = data.speed,
        time = os.time()
    })
    
    -- Behalte nur letzte 100 Samples
    if #profile.samples > 100 then
        table.remove(profile.samples, 1)
    end
    
    -- Berechne Statistiken
    if #profile.samples >= 10 then
        local sum = 0
        local max = 0
        
        for _, sample in ipairs(profile.samples) do
            sum = sum + sample.speed
            if sample.speed > max then
                max = sample.speed
            end
        end
        
        profile.avgSpeed = sum / #profile.samples
        profile.maxSpeed = max
        
        -- Berechne Varianz
        local variance = 0
        for _, sample in ipairs(profile.samples) do
            variance = variance + math.pow(sample.speed - profile.avgSpeed, 2)
        end
        profile.speedVariance = math.sqrt(variance / #profile.samples)
    end
end

function MLScoring.ExtractCombatFeatures(source, data)
    if not playerProfiles[source] then return end
    
    local profile = playerProfiles[source].combat
    
    profile.totalShots = profile.totalShots + 1
    
    if data.hit then
        profile.totalHits = profile.totalHits + 1
    end
    
    if profile.totalShots > 0 then
        profile.avgAccuracy = profile.totalHits / profile.totalShots
    end
    
    table.insert(profile.samples, {
        hit = data.hit or false,
        headshot = data.headshot or false,
        time = os.time()
    })
    
    if #profile.samples > 100 then
        table.remove(profile.samples, 1)
    end
end

-- ═══════════════════════════════════════════════════════════
--  ANOMALY DETECTION
-- ═══════════════════════════════════════════════════════════

function MLScoring.CalculateMovementAnomaly(source)
    if not playerProfiles[source] then return 0 end
    
    local profile = playerProfiles[source].movement
    local score = 0
    
    -- Speed Anomaly (Z-Score)
    if profile.avgSpeed > 0 then
        local zScore = (profile.avgSpeed - globalBaseline.avgSpeed) / (globalBaseline.avgMovementVariance + 0.1)
        if zScore > 2.0 then -- 2 Standardabweichungen
            score = score + (zScore - 2.0) * 10
        end
    end
    
    -- Max Speed Anomaly
    if profile.maxSpeed > Config.Thresholds.MaxSpeed * 1.5 then
        score = score + 15
    end
    
    -- Low Variance (Bot-Indikator)
    if profile.speedVariance < 0.5 and profile.avgSpeed > 3.0 then
        score = score + 20
    end
    
    -- Teleport Frequency
    if profile.teleportCount > 5 then
        score = score + (profile.teleportCount * 3)
    end
    
    return math.min(score, 100)
end

function MLScoring.CalculateCombatAnomaly(source)
    if not playerProfiles[source] then return 0 end
    
    local profile = playerProfiles[source].combat
    local score = 0
    
    -- Accuracy Anomaly
    if profile.totalShots >= 20 then
        if profile.avgAccuracy > 0.90 then
            score = score + 30 -- Sehr verdächtig
        elseif profile.avgAccuracy > 0.80 then
            score = score + 15
        end
    end
    
    -- Headshot Ratio
    if profile.headshotRatio > 0.70 then
        score = score + 25
    end
    
    -- Shot Interval Consistency (Bot-Indikator)
    if #profile.samples >= 10 then
        local intervals = {}
        for i = 2, #profile.samples do
            local interval = profile.samples[i].time - profile.samples[i-1].time
            table.insert(intervals, interval)
        end
        
        -- Berechne Standardabweichung der Intervalle
        local avgInterval = 0
        for _, interval in ipairs(intervals) do
            avgInterval = avgInterval + interval
        end
        avgInterval = avgInterval / #intervals
        
        local variance = 0
        for _, interval in ipairs(intervals) do
            variance = variance + math.pow(interval - avgInterval, 2)
        end
        local stdDev = math.sqrt(variance / #intervals)
        
        -- Sehr konstante Intervalle = Bot
        if stdDev < 0.1 and avgInterval < 0.5 then
            score = score + 35
        end
    end
    
    return math.min(score, 100)
end

function MLScoring.CalculateBehaviorAnomaly(source)
    if not playerProfiles[source] then return 0 end
    
    local profile = playerProfiles[source].behavior
    local score = 0
    
    -- K/D Ratio Anomaly
    if profile.deathCount > 0 then
        local kdRatio = profile.killCount / profile.deathCount
        if kdRatio > 10 then
            score = score + 20
        elseif kdRatio > 5 then
            score = score + 10
        end
    end
    
    -- Event Frequency Anomaly
    for eventName, count in pairs(profile.eventFrequency) do
        if count > 100 then -- Mehr als 100 Events pro Minute
            score = score + 15
        end
    end
    
    -- Neue Spieler mit hoher Aktivität (Cheat-Account)
    local playTime = os.time() - profile.created
    if playTime < 3600 and profile.killCount > 20 then -- Weniger als 1h Spielzeit
        score = score + 25
    end
    
    return math.min(score, 100)
end

-- ═══════════════════════════════════════════════════════════
--  OVERALL RISK SCORE
-- ═══════════════════════════════════════════════════════════

function MLScoring.CalculateOverallScore(source)
    if not playerProfiles[source] then return 0 end
    
    local movementScore = MLScoring.CalculateMovementAnomaly(source)
    local combatScore = MLScoring.CalculateCombatAnomaly(source)
    local behaviorScore = MLScoring.CalculateBehaviorAnomaly(source)
    
    -- Gewichtete Summe
    local weights = {
        movement = 0.35,
        combat = 0.40,
        behavior = 0.25
    }
    
    local overallScore = (movementScore * weights.movement) + 
                        (combatScore * weights.combat) + 
                        (behaviorScore * weights.behavior)
    
    -- Speichere Scores
    playerProfiles[source].anomalyScores = {
        movement = movementScore,
        combat = combatScore,
        behavior = behaviorScore,
        overall = overallScore
    }
    
    return overallScore
end

-- ═══════════════════════════════════════════════════════════
--  RISK CLASSIFICATION
-- ═══════════════════════════════════════════════════════════

function MLScoring.ClassifyRisk(score)
    if score >= 80 then
        return "CRITICAL", "^1"
    elseif score >= 60 then
        return "HIGH", "^3"
    elseif score >= 40 then
        return "MEDIUM", "^3"
    elseif score >= 20 then
        return "LOW", "^2"
    else
        return "SAFE", "^2"
    end
end

function MLScoring.GetRiskReport(source)
    if not playerProfiles[source] then return nil end
    
    local score = MLScoring.CalculateOverallScore(source)
    local risk, color = MLScoring.ClassifyRisk(score)
    local scores = playerProfiles[source].anomalyScores
    
    return {
        overall = score,
        risk = risk,
        color = color,
        breakdown = {
            movement = scores.movement,
            combat = scores.combat,
            behavior = scores.behavior
        }
    }
end

-- ═══════════════════════════════════════════════════════════
--  ADAPTIVE THRESHOLDS
-- ═══════════════════════════════════════════════════════════

function MLScoring.GetAdaptiveThreshold(source, baseThreshold)
    if not playerProfiles[source] then return baseThreshold end
    
    local score = MLScoring.CalculateOverallScore(source)
    
    -- Reduziere Threshold bei hohem Risk Score
    if score >= 60 then
        return baseThreshold * 0.7
    elseif score >= 40 then
        return baseThreshold * 0.85
    end
    
    return baseThreshold
end

-- ═══════════════════════════════════════════════════════════
--  PERIODIC ANALYSIS
-- ═══════════════════════════════════════════════════════════

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(Config.MLScoring.AnalysisInterval or 120000)
        
        for source, profile in pairs(playerProfiles) do
            local score = MLScoring.CalculateOverallScore(source)
            
            if score >= Config.MLScoring.AlertThreshold then
                local playerInfo = Utils.GetPlayerInfo(source)
                local risk, color = MLScoring.ClassifyRisk(score)
                
                Utils.NotifyAdmins(string.format(
                    "%s[ML-SCORING]^7 %s (ID: %d) - Risk: %s (Score: %.1f)",
                    color, playerInfo.name, source, risk, score
                ))
                
                if score >= 80 then
                    Utils.SendWebhook(
                        "🚨 CRITICAL RISK DETECTED",
                        string.format(
                            "**Spieler:** %s (ID: %d)\n**Risk Level:** %s\n**Overall Score:** %.1f\n\n**Breakdown:**\n• Movement: %.1f\n• Combat: %.1f\n• Behavior: %.1f",
                            playerInfo.name, source, risk, score,
                            profile.anomalyScores.movement,
                            profile.anomalyScores.combat,
                            profile.anomalyScores.behavior
                        ),
                        Config.Colors.Kick
                    )
                end
            end
            
            profile.lastUpdate = os.time()
        end
    end
end)

-- ═══════════════════════════════════════════════════════════
--  GLOBAL BASELINE UPDATE
-- ═══════════════════════════════════════════════════════════

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(300000) -- 5 Minuten
        
        local totalSpeed = 0
        local totalAccuracy = 0
        local count = 0
        
        for _, profile in pairs(playerProfiles) do
            if profile.movement.avgSpeed > 0 then
                totalSpeed = totalSpeed + profile.movement.avgSpeed
                count = count + 1
            end
            if profile.combat.avgAccuracy > 0 then
                totalAccuracy = totalAccuracy + profile.combat.avgAccuracy
            end
        end
        
        if count > 0 then
            globalBaseline.avgSpeed = totalSpeed / count
            globalBaseline.avgAccuracy = totalAccuracy / count
            
            Utils.Debug(string.format("Global baseline updated: Speed=%.2f, Accuracy=%.2f", 
                globalBaseline.avgSpeed, globalBaseline.avgAccuracy))
        end
    end
end)

return MLScoring
