--[[
    RedM Anticheat System - Advanced Notification System
    © 2026 DerStr1k3r
--]]

Notifications = {}

local notificationQueue = {}
local adminPreferences = {}

-- ═══════════════════════════════════════════════════════════
--  NOTIFICATION TYPES
-- ═══════════════════════════════════════════════════════════

Notifications.Types = {
    DETECTION = "detection",
    KICK = "kick",
    BAN = "ban",
    HIGH_RISK = "high_risk",
    CRITICAL = "critical",
    INFO = "info"
}

-- ═══════════════════════════════════════════════════════════
--  ADMIN PREFERENCES
-- ═══════════════════════════════════════════════════════════

function Notifications.SetPreference(source, notificationType, enabled)
    if not adminPreferences[source] then
        adminPreferences[source] = {}
    end
    
    adminPreferences[source][notificationType] = enabled
end

function Notifications.GetPreference(source, notificationType)
    if not adminPreferences[source] then
        return true -- Default: all enabled
    end
    
    if adminPreferences[source][notificationType] == nil then
        return true
    end
    
    return adminPreferences[source][notificationType]
end

-- ═══════════════════════════════════════════════════════════
--  NOTIFICATION SYSTEM
-- ═══════════════════════════════════════════════════════════

function Notifications.Send(notificationType, title, message, data)
    local notification = {
        type = notificationType,
        title = title,
        message = message,
        data = data or {},
        timestamp = os.time()
    }
    
    table.insert(notificationQueue, notification)
    
    -- Keep only last 50 notifications
    if #notificationQueue > 50 then
        table.remove(notificationQueue, 1)
    end
    
    -- Send to admins
    Notifications.BroadcastToAdmins(notification)
    
    -- Send to webhook if configured
    if Config.Webhook and Config.Webhook ~= "" then
        Notifications.SendToWebhook(notification)
    end
end

function Notifications.BroadcastToAdmins(notification)
    local players = GetPlayers()
    
    for _, playerId in ipairs(players) do
        local source = tonumber(playerId)
        
        if Utils.IsTxAdmin(source) then
            if Notifications.GetPreference(source, notification.type) then
                local color = Notifications.GetColor(notification.type)
                
                TriggerClientEvent('chat:addMessage', source, {
                    args = {string.format("%s[%s]^7 %s", color, notification.title, notification.message)}
                })
            end
        end
    end
end

function Notifications.SendToWebhook(notification)
    local color = Notifications.GetWebhookColor(notification.type)
    local emoji = Notifications.GetEmoji(notification.type)
    
    Utils.SendWebhook(
        emoji .. " " .. notification.title,
        notification.message,
        color,
        notification.data.fields or {}
    )
end

-- ═══════════════════════════════════════════════════════════
--  HELPERS
-- ═══════════════════════════════════════════════════════════

function Notifications.GetColor(notificationType)
    local colors = {
        detection = "^3",
        kick = "^1",
        ban = "^1",
        high_risk = "^3",
        critical = "^1",
        info = "^5"
    }
    
    return colors[notificationType] or "^7"
end

function Notifications.GetWebhookColor(notificationType)
    local colors = {
        detection = Config.Colors.Warning,
        kick = Config.Colors.Kick,
        ban = Config.Colors.Ban,
        high_risk = Config.Colors.Warning,
        critical = Config.Colors.Kick,
        info = Config.Colors.Info
    }
    
    return colors[notificationType] or Config.Colors.Info
end

function Notifications.GetEmoji(notificationType)
    local emojis = {
        detection = "🚨",
        kick = "⛔",
        ban = "🔨",
        high_risk = "⚠️",
        critical = "🔴",
        info = "ℹ️"
    }
    
    return emojis[notificationType] or "📢"
end

function Notifications.GetHistory(limit)
    limit = limit or 10
    local history = {}
    local start = math.max(1, #notificationQueue - limit + 1)
    
    for i = start, #notificationQueue do
        table.insert(history, notificationQueue[i])
    end
    
    return history
end

-- ═══════════════════════════════════════════════════════════
--  SMART NOTIFICATIONS
-- ═══════════════════════════════════════════════════════════

function Notifications.SmartDetection(source, violationType, severity, mlScore)
    local playerInfo = Utils.GetPlayerInfo(source)
    
    local message = string.format(
        "**Spieler:** %s (ID: %d)\n**Violation:** %s\n**Severity:** %d/3",
        playerInfo.name, source, violationType, severity
    )
    
    if mlScore then
        message = message .. string.format("\n**ML-Score:** %.1f", mlScore)
    end
    
    local notifType = severity >= 3 and Notifications.Types.CRITICAL or Notifications.Types.DETECTION
    
    Notifications.Send(
        notifType,
        "Anticheat Detection",
        message,
        {
            fields = {
                {name = "Steam", value = playerInfo.steam, inline = true},
                {name = "License", value = playerInfo.license, inline = true},
                {name = "Ping", value = tostring(playerInfo.ping) .. " ms", inline = true}
            }
        }
    )
end

function Notifications.HighRiskPlayer(source, mlScore, riskLevel)
    local playerInfo = Utils.GetPlayerInfo(source)
    
    Notifications.Send(
        Notifications.Types.HIGH_RISK,
        "High Risk Player",
        string.format(
            "**Spieler:** %s (ID: %d)\n**Risk Level:** %s\n**ML-Score:** %.1f",
            playerInfo.name, source, riskLevel, mlScore
        )
    )
end

return Notifications
