--[[
    RedM Anticheat System - Database Layer
    © 2026 DerStr1k3r
    
    Persistente Speicherung von Bans, Violations und Player History
--]]

Database = {}

local banList = {}
local violationHistory = {}
local playerHistory = {}

-- ═══════════════════════════════════════════════════════════
--  BAN MANAGEMENT
-- ═══════════════════════════════════════════════════════════

function Database.AddBan(identifier, reason, duration, adminName)
    local ban = {
        identifier = identifier,
        reason = reason,
        timestamp = os.time(),
        duration = duration or 0, -- 0 = permanent
        expires = duration and (os.time() + duration) or 0,
        adminName = adminName or "System",
        active = true
    }
    
    banList[identifier] = ban
    
    Utils.Log("warning", string.format("Ban added: %s - %s", identifier, reason))
    
    return ban
end

function Database.RemoveBan(identifier)
    if banList[identifier] then
        banList[identifier].active = false
        Utils.Log("success", string.format("Ban removed: %s", identifier))
        return true
    end
    return false
end

function Database.IsBanned(identifier)
    local ban = banList[identifier]
    
    if not ban or not ban.active then
        return false, nil
    end
    
    -- Check if temporary ban expired
    if ban.duration > 0 and os.time() >= ban.expires then
        ban.active = false
        return false, nil
    end
    
    return true, ban
end

function Database.GetBanInfo(identifier)
    return banList[identifier]
end

function Database.GetAllBans()
    local activeBans = {}
    
    for identifier, ban in pairs(banList) do
        if ban.active then
            table.insert(activeBans, ban)
        end
    end
    
    return activeBans
end

-- ═══════════════════════════════════════════════════════════
--  VIOLATION HISTORY
-- ═══════════════════════════════════════════════════════════

function Database.RecordViolation(identifier, violationType, severity, details)
    if not violationHistory[identifier] then
        violationHistory[identifier] = {}
    end
    
    table.insert(violationHistory[identifier], {
        type = violationType,
        severity = severity,
        details = details or {},
        timestamp = os.time()
    })
    
    -- Keep only last 100 violations per player
    if #violationHistory[identifier] > 100 then
        table.remove(violationHistory[identifier], 1)
    end
end

function Database.GetViolationHistory(identifier, limit)
    if not violationHistory[identifier] then
        return {}
    end
    
    limit = limit or 10
    local history = {}
    local start = math.max(1, #violationHistory[identifier] - limit + 1)
    
    for i = start, #violationHistory[identifier] do
        table.insert(history, violationHistory[identifier][i])
    end
    
    return history
end

function Database.GetViolationCount(identifier, timeWindow)
    if not violationHistory[identifier] then
        return 0
    end
    
    if not timeWindow then
        return #violationHistory[identifier]
    end
    
    local count = 0
    local cutoff = os.time() - timeWindow
    
    for _, violation in ipairs(violationHistory[identifier]) do
        if violation.timestamp >= cutoff then
            count = count + 1
        end
    end
    
    return count
end

-- ═══════════════════════════════════════════════════════════
--  PLAYER HISTORY
-- ═══════════════════════════════════════════════════════════

function Database.RecordPlayerSession(identifier, playerInfo)
    if not playerHistory[identifier] then
        playerHistory[identifier] = {
            firstSeen = os.time(),
            lastSeen = os.time(),
            totalSessions = 0,
            totalPlaytime = 0,
            names = {},
            ips = {}
        }
    end
    
    local history = playerHistory[identifier]
    history.lastSeen = os.time()
    history.totalSessions = history.totalSessions + 1
    
    -- Track names
    if not Utils.TableContains(history.names, playerInfo.name) then
        table.insert(history.names, playerInfo.name)
    end
    
    -- Track IPs
    if playerInfo.ip ~= "N/A" and not Utils.TableContains(history.ips, playerInfo.ip) then
        table.insert(history.ips, playerInfo.ip)
    end
end

function Database.UpdatePlaytime(identifier, playtime)
    if playerHistory[identifier] then
        playerHistory[identifier].totalPlaytime = playerHistory[identifier].totalPlaytime + playtime
    end
end

function Database.GetPlayerHistory(identifier)
    return playerHistory[identifier]
end

function Database.FindPlayersByIP(ip)
    local players = {}
    
    for identifier, history in pairs(playerHistory) do
        if Utils.TableContains(history.ips, ip) then
            table.insert(players, {
                identifier = identifier,
                names = history.names,
                lastSeen = history.lastSeen
            })
        end
    end
    
    return players
end

-- ═══════════════════════════════════════════════════════════
--  STATISTICS
-- ═══════════════════════════════════════════════════════════

function Database.GetStatistics()
    local stats = {
        totalBans = 0,
        activeBans = 0,
        totalPlayers = 0,
        totalViolations = 0
    }
    
    for _, ban in pairs(banList) do
        stats.totalBans = stats.totalBans + 1
        if ban.active then
            stats.activeBans = stats.activeBans + 1
        end
    end
    
    for _ in pairs(playerHistory) do
        stats.totalPlayers = stats.totalPlayers + 1
    end
    
    for _, violations in pairs(violationHistory) do
        stats.totalViolations = stats.totalViolations + #violations
    end
    
    return stats
end

-- ═══════════════════════════════════════════════════════════
--  PERSISTENCE (File-based)
-- ═══════════════════════════════════════════════════════════

function Database.Save()
    local data = {
        banList = banList,
        violationHistory = violationHistory,
        playerHistory = playerHistory,
        timestamp = os.time()
    }
    
    -- In production würde hier JSON in Datei geschrieben
    Utils.Debug("Database saved (in-memory)")
    
    return true
end

function Database.Load()
    -- In production würde hier JSON aus Datei geladen
    Utils.Debug("Database loaded (in-memory)")
    
    return true
end

-- Auto-Save every 5 minutes
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(300000)
        Database.Save()
    end
end)

-- Cleanup expired bans
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(600000) -- 10 minutes
        
        local cleaned = 0
        for identifier, ban in pairs(banList) do
            if ban.active and ban.duration > 0 and os.time() >= ban.expires then
                ban.active = false
                cleaned = cleaned + 1
            end
        end
        
        if cleaned > 0 then
            Utils.Debug(string.format("Cleaned %d expired bans", cleaned))
        end
    end
end)

return Database
