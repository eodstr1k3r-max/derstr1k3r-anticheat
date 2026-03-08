--[[
    RedM Anticheat System - Reputation System
    © 2026 DerStr1k3r
--]]

Reputation = {}

local playerReputation = {}

-- ═══════════════════════════════════════════════════════════
--  REPUTATION MANAGEMENT
-- ═══════════════════════════════════════════════════════════

function Reputation.InitPlayer(source)
    local playerInfo = Utils.GetPlayerInfo(source)
    
    -- Load from database if exists
    local history = Database.GetPlayerHistory(playerInfo.license)
    local startingRep = Config.Reputation.StartingReputation
    
    if history then
        -- Adjust starting reputation based on history
        local violationCount = Database.GetViolationCount(playerInfo.license)
        startingRep = math.max(0, startingRep - (violationCount * 2))
    end
    
    playerReputation[source] = {
        score = startingRep,
        lastUpdate = os.time(),
        sessionStart = os.time(),
        violations = 0,
        cleanTime = 0
    }
    
    Utils.Debug(string.format("Reputation initialized for %d: %d", source, startingRep))
end

function Reputation.RemovePlayer(source)
    playerReputation[source] = nil
end

-- ═══════════════════════════════════════════════════════════
--  REPUTATION CHANGES
-- ═══════════════════════════════════════════════════════════

function Reputation.ModifyReputation(source, amount, reason)
    if not playerReputation[source] then
        Reputation.InitPlayer(source)
    end
    
    local oldScore = playerReputation[source].score
    playerReputation[source].score = math.max(0, math.min(100, oldScore + amount))
    playerReputation[source].lastUpdate = os.time()
    
    local newScore = playerReputation[source].score
    
    Utils.Debug(string.format("Reputation changed for %d: %d -> %d (%s)", 
        source, oldScore, newScore, reason))
    
    -- Check for threshold crossings
    Reputation.CheckThresholds(source, oldScore, newScore)
    
    return newScore
end

function Reputation.OnViolation(source, severity)
    if not Config.Reputation or not Config.Reputation.Enabled then return end
    
    local penalty = Config.Reputation.ViolationPenalty * severity
    Reputation.ModifyReputation(source, -penalty, "Violation (Severity: " .. severity .. ")")
    
    if playerReputation[source] then
        playerReputation[source].violations = playerReputation[source].violations + 1
    end
end

function Reputation.OnKick(source)
    if not Config.Reputation or not Config.Reputation.Enabled then return end
    
    Reputation.ModifyReputation(source, -Config.Reputation.KickPenalty, "Kicked")
end

function Reputation.OnBan(source)
    if not Config.Reputation or not Config.Reputation.Enabled then return end
    
    Reputation.ModifyReputation(source, -Config.Reputation.BanPenalty, "Banned")
end

function Reputation.OnCleanSession(source, hours)
    if not Config.Reputation or not Config.Reputation.Enabled then return end
    
    local bonus = Config.Reputation.CleanSessionBonus * hours
    Reputation.ModifyReputation(source, bonus, "Clean Session (" .. hours .. "h)")
end

-- ═══════════════════════════════════════════════════════════
--  REPUTATION QUERIES
-- ═══════════════════════════════════════════════════════════

function Reputation.GetScore(source)
    if not playerReputation[source] then
        return Config.Reputation.StartingReputation
    end
    
    return playerReputation[source].score
end

function Reputation.GetLevel(source)
    local score = Reputation.GetScore(source)
    
    if score >= 90 then
        return "EXCELLENT", "^2"
    elseif score >= 75 then
        return "GOOD", "^2"
    elseif score >= 50 then
        return "AVERAGE", "^3"
    elseif score >= 25 then
        return "LOW", "^3"
    else
        return "VERY LOW", "^1"
    end
end

function Reputation.IsLowReputation(source)
    local score = Reputation.GetScore(source)
    return score < Config.Reputation.LowReputationThreshold
end

function Reputation.IsVeryLowReputation(source)
    local score = Reputation.GetScore(source)
    return score < Config.Reputation.VeryLowReputationThreshold
end

-- ═══════════════════════════════════════════════════════════
--  THRESHOLD ACTIONS
-- ═══════════════════════════════════════════════════════════

function Reputation.CheckThresholds(source, oldScore, newScore)
    local playerInfo = Utils.GetPlayerInfo(source)
    
    -- Crossed into low reputation
    if oldScore >= Config.Reputation.LowReputationThreshold and 
       newScore < Config.Reputation.LowReputationThreshold then
        
        if Config.Reputation.LowReputationActions.AdminAlert then
            Utils.NotifyAdmins(string.format(
                "^3[REPUTATION]^7 %s (ID: %d) hat jetzt niedrige Reputation: %d",
                playerInfo.name, source, newScore
            ))
        end
        
        Utils.SendWebhook(
            "⚠️ Low Reputation",
            string.format(
                "**Spieler:** %s (ID: %d)\n**Reputation:** %d\n**Status:** Low",
                playerInfo.name, source, newScore
            ),
            Config.Colors.Warning
        )
    end
    
    -- Crossed into very low reputation
    if oldScore >= Config.Reputation.VeryLowReputationThreshold and 
       newScore < Config.Reputation.VeryLowReputationThreshold then
        
        Utils.SendWebhook(
            "🔴 Very Low Reputation",
            string.format(
                "**Spieler:** %s (ID: %d)\n**Reputation:** %d\n**Status:** Very Low\n**Action:** Increased Monitoring",
                playerInfo.name, source, newScore
            ),
            Config.Colors.Kick
        )
    end
end

function Reputation.GetAdjustedThreshold(source, baseThreshold)
    if not Config.Reputation or not Config.Reputation.Enabled then
        return baseThreshold
    end
    
    if not Config.Reputation.LowReputationActions.ReducedThresholds then
        return baseThreshold
    end
    
    local score = Reputation.GetScore(source)
    
    if score < Config.Reputation.VeryLowReputationThreshold then
        return math.floor(baseThreshold * 0.5) -- 50% threshold
    elseif score < Config.Reputation.LowReputationThreshold then
        return math.floor(baseThreshold * 0.75) -- 75% threshold
    end
    
    return baseThreshold
end

-- ═══════════════════════════════════════════════════════════
--  REPUTATION REPORT
-- ═══════════════════════════════════════════════════════════

function Reputation.GenerateReport(source)
    if not playerReputation[source] then
        return nil
    end
    
    local data = playerReputation[source]
    local level, color = Reputation.GetLevel(source)
    local sessionTime = os.time() - data.sessionStart
    
    return {
        score = data.score,
        level = level,
        color = color,
        violations = data.violations,
        sessionTime = Utils.FormatTime(sessionTime),
        lastUpdate = os.date("%H:%M:%S", data.lastUpdate)
    }
end

-- ═══════════════════════════════════════════════════════════
--  PERIODIC UPDATES
-- ═══════════════════════════════════════════════════════════

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(3600000) -- Every hour
        
        for source, data in pairs(playerReputation) do
            local sessionTime = os.time() - data.sessionStart
            local hours = math.floor(sessionTime / 3600)
            
            -- Reward clean sessions
            if data.violations == 0 and hours > 0 then
                Reputation.OnCleanSession(source, 1)
                data.violations = 0 -- Reset for next hour
            end
        end
    end
end)

return Reputation
