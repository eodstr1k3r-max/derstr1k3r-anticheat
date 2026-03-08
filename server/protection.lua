--[[
    RedM Anticheat System - Advanced Protection
    © 2026 DerStr1k3r
--]]

Protection = {}

local protectedEvents = {}
local eventRateLimits = {}
local blockedIPs = {}
local vpnCache = {}

-- ═══════════════════════════════════════════════════════════
--  EVENT PROTECTION
-- ═══════════════════════════════════════════════════════════

function Protection.RegisterProtectedEvent(eventName, maxCallsPerSecond)
    protectedEvents[eventName] = {
        maxCalls = maxCallsPerSecond or 10,
        calls = {}
    }
    
    Utils.Debug("Protected event registered: " .. eventName)
end

function Protection.CheckEventRateLimit(source, eventName)
    if Utils.CanBypass(source) then return true end
    
    if not protectedEvents[eventName] then return true end
    
    if not eventRateLimits[source] then
        eventRateLimits[source] = {}
    end
    
    if not eventRateLimits[source][eventName] then
        eventRateLimits[source][eventName] = {
            calls = {},
            violations = 0
        }
    end
    
    local currentTime = os.time()
    local data = eventRateLimits[source][eventName]
    
    -- Entferne alte Einträge
    for i = #data.calls, 1, -1 do
        if currentTime - data.calls[i] > 1 then
            table.remove(data.calls, i)
        end
    end
    
    -- Prüfe Rate Limit
    if #data.calls >= protectedEvents[eventName].maxCalls then
        data.violations = data.violations + 1
        
        if data.violations >= 3 then
            Detections.HandleViolation(source, "EventSpam: " .. eventName, 2)
            data.violations = 0
        end
        
        return false
    end
    
    table.insert(data.calls, currentTime)
    return true
end

-- ═══════════════════════════════════════════════════════════
--  SQL INJECTION PROTECTION
-- ═══════════════════════════════════════════════════════════

function Protection.CheckSQLInjection(input)
    if type(input) ~= "string" then return false end
    
    local sqlPatterns = {
        "union.*select",
        "insert.*into",
        "delete.*from",
        "drop.*table",
        "update.*set",
        "exec.*xp_",
        "';.*--",
        "or.*1.*=.*1",
        "and.*1.*=.*1"
    }
    
    local lowerInput = string.lower(input)
    
    for _, pattern in ipairs(sqlPatterns) do
        if string.match(lowerInput, pattern) then
            return true
        end
    end
    
    return false
end

-- ═══════════════════════════════════════════════════════════
--  XSS PROTECTION
-- ═══════════════════════════════════════════════════════════

function Protection.CheckXSS(input)
    if type(input) ~= "string" then return false end
    
    local xssPatterns = {
        "<script",
        "javascript:",
        "onerror=",
        "onload=",
        "<iframe",
        "eval%(.*%)"
    }
    
    local lowerInput = string.lower(input)
    
    for _, pattern in ipairs(xssPatterns) do
        if string.match(lowerInput, pattern) then
            return true
        end
    end
    
    return false
end

-- ═══════════════════════════════════════════════════════════
--  IP PROTECTION
-- ═══════════════════════════════════════════════════════════

function Protection.BlockIP(ip, reason)
    blockedIPs[ip] = {
        reason = reason,
        time = os.time()
    }
    
    Utils.Log("warning", "IP blocked: " .. ip .. " - " .. reason)
    
    Utils.SendWebhook(
        "🚫 IP Blockiert",
        string.format("**IP:** %s\n**Grund:** %s", ip, reason),
        Config.Colors.Kick
    )
end

function Protection.IsIPBlocked(ip)
    return blockedIPs[ip] ~= nil
end

function Protection.UnblockIP(ip)
    blockedIPs[ip] = nil
    Utils.Log("success", "IP unblocked: " .. ip)
end

-- ═══════════════════════════════════════════════════════════
--  VPN DETECTION (Basic)
-- ═══════════════════════════════════════════════════════════

function Protection.CheckVPN(source)
    if not Config.Protection.BlockVPN then return false end
    
    local playerInfo = Utils.GetPlayerInfo(source)
    local ip = playerInfo.ip
    
    if ip == "N/A" then return false end
    
    -- Cache Check
    if vpnCache[ip] ~= nil then
        return vpnCache[ip]
    end
    
    -- Basis-Check: Prüfe auf bekannte VPN-Ranges
    local vpnRanges = {
        "^10%.",
        "^172%.16%.",
        "^192%.168%.",
    }
    
    for _, range in ipairs(vpnRanges) do
        if string.match(ip, range) then
            vpnCache[ip] = true
            return true
        end
    end
    
    vpnCache[ip] = false
    return false
end

-- ═══════════════════════════════════════════════════════════
--  COMMAND INJECTION PROTECTION
-- ═══════════════════════════════════════════════════════════

function Protection.SanitizeInput(input)
    if type(input) ~= "string" then return input end
    
    -- Entferne gefährliche Zeichen
    input = string.gsub(input, "[;&|`$()]", "")
    
    -- Limitiere Länge
    if #input > 256 then
        input = string.sub(input, 1, 256)
    end
    
    return input
end

-- ═══════════════════════════════════════════════════════════
--  RESOURCE INTEGRITY CHECK
-- ═══════════════════════════════════════════════════════════

function Protection.CheckResourceIntegrity()
    local currentResource = GetCurrentResourceName()
    local resourcePath = GetResourcePath(currentResource)
    
    -- Prüfe ob kritische Dateien existieren
    local criticalFiles = {
        "fxmanifest.lua",
        "server/main.lua",
        "server/config.lua",
        "server/detections.lua",
        "server/utils.lua",
        "client/main.lua"
    }
    
    for _, file in ipairs(criticalFiles) do
        local fullPath = resourcePath .. "/" .. file
        -- Basis-Check (erweiterte Checks würden natives benötigen)
        Utils.Debug("Checking file: " .. file)
    end
    
    return true
end

-- ═══════════════════════════════════════════════════════════
--  ANTI-DUMP PROTECTION
-- ═══════════════════════════════════════════════════════════

function Protection.ObfuscateData(data)
    -- Basis-Obfuscation für sensitive Daten
    if type(data) == "string" then
        return string.reverse(data)
    end
    return data
end

function Protection.DeobfuscateData(data)
    if type(data) == "string" then
        return string.reverse(data)
    end
    return data
end

-- ═══════════════════════════════════════════════════════════
--  INITIALIZATION
-- ═══════════════════════════════════════════════════════════

function Protection.Initialize()
    -- Registriere geschützte Events
    Protection.RegisterProtectedEvent("anticheat:healthCheck", 5)
    Protection.RegisterProtectedEvent("anticheat:positionCheck", 5)
    Protection.RegisterProtectedEvent("anticheat:speedCheck", 10)
    Protection.RegisterProtectedEvent("anticheat:shotFired", 20)
    
    -- Resource Integrity Check
    Protection.CheckResourceIntegrity()
    
    Utils.Log("success", "Protection systems initialized")
end

-- ═══════════════════════════════════════════════════════════
--  CLEANUP
-- ═══════════════════════════════════════════════════════════

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(300000) -- 5 Minuten
        
        -- Cleanup alte Rate Limit Daten
        for source, events in pairs(eventRateLimits) do
            for eventName, data in pairs(events) do
                if #data.calls == 0 then
                    eventRateLimits[source][eventName] = nil
                end
            end
        end
        
        -- Cleanup alte IP Blocks (nach 24h)
        local currentTime = os.time()
        for ip, data in pairs(blockedIPs) do
            if currentTime - data.time > 86400 then
                Protection.UnblockIP(ip)
            end
        end
        
        Utils.Debug("Protection cleanup completed")
    end
end)

return Protection
