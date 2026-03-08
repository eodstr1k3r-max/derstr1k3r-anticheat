--[[
    RedM Anticheat System - Utils
    © 2026 DerStr1k3r
--]]

Utils = {}

local playerCache = {}
local cacheTimeout = Config.Performance and Config.Performance.CacheTimeout or 5000

-- ═══════════════════════════════════════════════════════════
--  PERMISSION CHECKS
-- ═══════════════════════════════════════════════════════════

-- TxAdmin Check
function Utils.IsTxAdmin(source)
    local identifiers = GetPlayerIdentifiers(source)
    for _, id in pairs(identifiers) do
        if string.find(id, "txAdmin") then
            return true
        end
    end
    return false
end

-- Whitelist Check
function Utils.IsWhitelisted(source)
    local identifiers = GetPlayerIdentifiers(source)
    for _, id in pairs(identifiers) do
        for _, whitelisted in pairs(Config.WhitelistedIdentifiers) do
            if id == whitelisted then
                return true
            end
        end
    end
    return false
end

-- Bypass Check (TxAdmin oder Whitelist)
function Utils.CanBypass(source)
    return Utils.IsTxAdmin(source) or Utils.IsWhitelisted(source)
end

-- ═══════════════════════════════════════════════════════════
--  WEBHOOK & LOGGING
-- ═══════════════════════════════════════════════════════════

-- Webhook Logging
function Utils.SendWebhook(title, message, color, fields)
    if not Config.Webhook or Config.Webhook == "" then return end
    
    local embed = {
        {
            ["title"] = title,
            ["description"] = message,
            ["color"] = color or Config.Colors.Info,
            ["fields"] = fields or {},
            ["footer"] = {
                ["text"] = "RedM Anticheat • " .. os.date("%d.%m.%Y %H:%M:%S"),
            },
            ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%S")
        }
    }
    
    PerformHttpRequest(Config.Webhook, function(err, text, headers) 
        if Config.Debug and err ~= 200 then
            print("^3[ANTICHEAT DEBUG]^7 Webhook Error: " .. tostring(err))
        end
    end, 'POST', json.encode({
        username = Config.WebhookName,
        avatar_url = Config.WebhookAvatar,
        embeds = embed
    }), {['Content-Type'] = 'application/json'})
end

-- Console Log mit Farben
function Utils.Log(type, message)
    local colors = {
        error = "^1",
        warning = "^3",
        success = "^2",
        info = "^5",
    }
    
    local color = colors[type] or "^7"
    print(string.format("%s[ANTICHEAT]^7 %s", color, message))
end

-- Debug Print
function Utils.Debug(message)
    if Config.Debug then
        print("^3[ANTICHEAT DEBUG]^7 " .. message)
    end
end

-- ═══════════════════════════════════════════════════════════
--  SPIELER INFORMATIONEN
-- ═══════════════════════════════════════════════════════════

-- Spieler Info mit Cache
function Utils.GetPlayerInfo(source)
    if Config.Performance.CachePlayerData and playerCache[source] then
        local cache = playerCache[source]
        if (GetGameTimer() - cache.timestamp) < cacheTimeout then
            return cache.data
        end
    end
    
    local name = GetPlayerName(source) or "Unknown"
    local identifiers = GetPlayerIdentifiers(source)
    local steam, license, discord, ip = "N/A", "N/A", "N/A", "N/A"
    
    for _, id in pairs(identifiers) do
        if string.find(id, "steam:") then
            steam = id
        elseif string.find(id, "license:") then
            license = id
        elseif string.find(id, "discord:") then
            discord = id
        elseif string.find(id, "ip:") then
            ip = id
        end
    end
    
    local data = {
        name = name,
        steam = steam,
        license = license,
        discord = discord,
        ip = ip,
        ping = GetPlayerPing(source) or 0
    }
    
    if Config.Performance.CachePlayerData then
        playerCache[source] = {
            data = data,
            timestamp = GetGameTimer()
        }
    end
    
    return data
end

-- Cache leeren
function Utils.ClearPlayerCache(source)
    playerCache[source] = nil
end

-- ═══════════════════════════════════════════════════════════
--  MATHEMATISCHE FUNKTIONEN
-- ═══════════════════════════════════════════════════════════

-- Distanz berechnen
function Utils.GetDistance(coords1, coords2)
    return #(vector3(coords1.x, coords1.y, coords1.z) - vector3(coords2.x, coords2.y, coords2.z))
end

-- 2D Distanz (ohne Z-Achse)
function Utils.GetDistance2D(coords1, coords2)
    return math.sqrt((coords1.x - coords2.x)^2 + (coords1.y - coords2.y)^2)
end

-- Geschwindigkeit berechnen
function Utils.CalculateSpeed(velocity)
    return math.sqrt(velocity.x^2 + velocity.y^2 + velocity.z^2)
end

-- ═══════════════════════════════════════════════════════════
--  ADMIN FUNKTIONEN
-- ═══════════════════════════════════════════════════════════

-- Admin Benachrichtigung
function Utils.NotifyAdmins(message)
    if not Config.Actions.NotifyAdmins then return end
    
    local players = GetPlayers()
    for _, playerId in ipairs(players) do
        if Utils.IsTxAdmin(tonumber(playerId)) then
            TriggerClientEvent('chat:addMessage', tonumber(playerId), {
                args = {message}
            })
        end
    end
end

-- Spieler einfrieren
function Utils.FreezePlayer(source, freeze)
    TriggerClientEvent('anticheat:freeze', source, freeze)
    Utils.Debug("Player " .. source .. " frozen: " .. tostring(freeze))
end

-- Spieler teleportieren
function Utils.TeleportPlayer(source, coords)
    TriggerClientEvent('anticheat:teleport', source, coords)
    Utils.Debug("Player " .. source .. " teleported to " .. tostring(coords))
end

-- ═══════════════════════════════════════════════════════════
--  NACHRICHTEN SYSTEM
-- ═══════════════════════════════════════════════════════════

-- Nachricht mit Sprache
function Utils.GetMessage(key)
    local lang = Config.Language or "de"
    if Config.Messages[lang] and Config.Messages[lang][key] then
        return Config.Messages[lang][key]
    end
    return Config.Messages["de"][key] or "Message not found"
end

-- ═══════════════════════════════════════════════════════════
--  VALIDIERUNG
-- ═══════════════════════════════════════════════════════════

-- Prüfe ob Event erlaubt ist
function Utils.IsEventAllowed(eventName)
    for _, allowed in pairs(Config.AllowedEvents) do
        if eventName == allowed then
            return true
        end
    end
    return false
end

-- Prüfe ob Resource erlaubt ist
function Utils.IsResourceAllowed(resourceName)
    for _, allowed in pairs(Config.AllowedResources) do
        if resourceName == allowed then
            return true
        end
    end
    return false
end

-- Prüfe ob Waffe erlaubt ist
function Utils.IsWeaponAllowed(weaponHash)
    return Config.AllowedWeapons[weaponHash] == true
end

-- ═══════════════════════════════════════════════════════════
--  PERFORMANCE
-- ═══════════════════════════════════════════════════════════

-- Ping-basierte Schwellenwert-Anpassung
function Utils.AdjustThresholdForPing(threshold, source)
    local ping = GetPlayerPing(source) or 0
    
    if ping > Config.Thresholds.MaxPing then
        return threshold * Config.Thresholds.HighPingMultiplier
    end
    
    return threshold
end

-- Formatiere Zeit
function Utils.FormatTime(seconds)
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local secs = seconds % 60
    
    if hours > 0 then
        return string.format("%dh %dm %ds", hours, minutes, secs)
    elseif minutes > 0 then
        return string.format("%dm %ds", minutes, secs)
    else
        return string.format("%ds", secs)
    end
end

return Utils


-- ═══════════════════════════════════════════════════════════
--  HELPER FUNCTIONS
-- ═══════════════════════════════════════════════════════════

-- Prüfe ob Wert in Tabelle existiert
function Utils.TableContains(table, value)
    for _, v in pairs(table) do
        if v == value then
            return true
        end
    end
    return false
end

-- Merge Tables
function Utils.MergeTables(t1, t2)
    for k, v in pairs(t2) do
        if type(v) == "table" then
            if type(t1[k] or false) == "table" then
                Utils.MergeTables(t1[k] or {}, t2[k] or {})
            else
                t1[k] = v
            end
        else
            t1[k] = v
        end
    end
    return t1
end

-- Deep Copy Table
function Utils.DeepCopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[Utils.DeepCopy(orig_key)] = Utils.DeepCopy(orig_value)
        end
        setmetatable(copy, Utils.DeepCopy(getmetatable(orig)))
    else
        copy = orig
    end
    return copy
end

-- Round Number
function Utils.Round(num, decimals)
    local mult = 10^(decimals or 0)
    return math.floor(num * mult + 0.5) / mult
end

-- Percentage
function Utils.Percentage(value, total)
    if total == 0 then return 0 end
    return (value / total) * 100
end
