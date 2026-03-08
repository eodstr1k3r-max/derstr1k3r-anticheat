--[[
    RedM Anticheat System - Admin Commands
    © 2026 DerStr1k3r
--]]

-- ═══════════════════════════════════════════════════════════
--  ADMIN COMMANDS
-- ═══════════════════════════════════════════════════════════

-- Statistiken anzeigen
RegisterCommand('acstats', function(source, args)
    if not Utils.IsTxAdmin(source) then 
        TriggerClientEvent('chat:addMessage', source, {
            args = {"^1[ANTICHEAT]^7 Keine Berechtigung!"}
        })
        return 
    end
    
    local targetId = tonumber(args[1])
    if not targetId then
        TriggerClientEvent('chat:addMessage', source, {
            args = {"^3[ANTICHEAT]^7 Verwendung: /acstats [ID]"}
        })
        return
    end
    
    local stats = Detections.GetPlayerStats(targetId)
    if not stats then
        TriggerClientEvent('chat:addMessage', source, {
            args = {"^1[ANTICHEAT]^7 Spieler nicht gefunden!"}
        })
        return
    end
    
    local playerInfo = Utils.GetPlayerInfo(targetId)
    
    TriggerClientEvent('chat:addMessage', source, {
        args = {"^2═══════════════════════════════════"}
    })
    TriggerClientEvent('chat:addMessage', source, {
        args = {string.format("^2[ANTICHEAT]^7 Statistiken für %s (ID: %d)", playerInfo.name, targetId)}
    })
    TriggerClientEvent('chat:addMessage', source, {
        args = {string.format("^7Verstöße: ^3%d^7 / ^1%d", stats.totalViolations, Config.Thresholds.ViolationsBeforeKick)}
    })
    TriggerClientEvent('chat:addMessage', source, {
        args = {string.format("^7Ping: ^3%d ms", playerInfo.ping)}
    })
    TriggerClientEvent('chat:addMessage', source, {
        args = {string.format("^7Spielzeit: ^3%s", Utils.FormatTime(os.time() - stats.joinTime))}
    })
    
    if #stats.violations > 0 then
        TriggerClientEvent('chat:addMessage', source, {
            args = {"^7Letzte Verstöße:"}
        })
        for i = math.max(1, #stats.violations - 3), #stats.violations do
            local v = stats.violations[i]
            TriggerClientEvent('chat:addMessage', source, {
                args = {string.format("  ^1•^7 %s (vor %s)", v.reason, Utils.FormatTime(os.time() - v.time))}
            })
        end
    end
    
    TriggerClientEvent('chat:addMessage', source, {
        args = {"^2═══════════════════════════════════"}
    })
end, false)

-- Verstöße zurücksetzen
RegisterCommand('acreset', function(source, args)
    if not Utils.IsTxAdmin(source) then 
        TriggerClientEvent('chat:addMessage', source, {
            args = {"^1[ANTICHEAT]^7 Keine Berechtigung!"}
        })
        return 
    end
    
    local targetId = tonumber(args[1])
    if not targetId then
        TriggerClientEvent('chat:addMessage', source, {
            args = {"^3[ANTICHEAT]^7 Verwendung: /acreset [ID]"}
        })
        return
    end
    
    Detections.RemovePlayer(targetId)
    Detections.InitPlayer(targetId)
    
    local playerInfo = Utils.GetPlayerInfo(targetId)
    
    TriggerClientEvent('chat:addMessage', source, {
        args = {string.format("^2[ANTICHEAT]^7 Verstöße für %s zurückgesetzt", playerInfo.name)}
    })
    
    Utils.Log("success", string.format("Admin %s hat Verstöße von %s zurückgesetzt", 
        GetPlayerName(source), playerInfo.name))
end, false)

-- Spieler einfrieren
RegisterCommand('acfreeze', function(source, args)
    if not Utils.IsTxAdmin(source) then 
        TriggerClientEvent('chat:addMessage', source, {
            args = {"^1[ANTICHEAT]^7 Keine Berechtigung!"}
        })
        return 
    end
    
    local targetId = tonumber(args[1])
    if not targetId then
        TriggerClientEvent('chat:addMessage', source, {
            args = {"^3[ANTICHEAT]^7 Verwendung: /acfreeze [ID]"}
        })
        return
    end
    
    Utils.FreezePlayer(targetId, true)
    
    local playerInfo = Utils.GetPlayerInfo(targetId)
    TriggerClientEvent('chat:addMessage', source, {
        args = {string.format("^2[ANTICHEAT]^7 %s wurde eingefroren", playerInfo.name)}
    })
    
    TriggerClientEvent('chat:addMessage', targetId, {
        args = {Utils.GetMessage("PlayerFrozen")}
    })
end, false)

-- Spieler auftauen
RegisterCommand('acunfreeze', function(source, args)
    if not Utils.IsTxAdmin(source) then 
        TriggerClientEvent('chat:addMessage', source, {
            args = {"^1[ANTICHEAT]^7 Keine Berechtigung!"}
        })
        return 
    end
    
    local targetId = tonumber(args[1])
    if not targetId then
        TriggerClientEvent('chat:addMessage', source, {
            args = {"^3[ANTICHEAT]^7 Verwendung: /acunfreeze [ID]"}
        })
        return
    end
    
    Utils.FreezePlayer(targetId, false)
    
    local playerInfo = Utils.GetPlayerInfo(targetId)
    TriggerClientEvent('chat:addMessage', source, {
        args = {string.format("^2[ANTICHEAT]^7 %s wurde aufgetaut", playerInfo.name)}
    })
end, false)

-- System Status
RegisterCommand('acstatus', function(source, args)
    if not Utils.IsTxAdmin(source) then 
        TriggerClientEvent('chat:addMessage', source, {
            args = {"^1[ANTICHEAT]^7 Keine Berechtigung!"}
        })
        return 
    end
    
    local stats = Detections.GetSystemStats()
    
    TriggerClientEvent('chat:addMessage', source, {
        args = {"^2═══════════════════════════════════"}
    })
    TriggerClientEvent('chat:addMessage', source, {
        args = {"^2[ANTICHEAT]^7 System Status"}
    })
    TriggerClientEvent('chat:addMessage', source, {
        args = {string.format("^7Version: ^33.0.0")}
    })
    TriggerClientEvent('chat:addMessage', source, {
        args = {string.format("^7Überwachte Spieler: ^3%d", stats.totalPlayers)}
    })
    TriggerClientEvent('chat:addMessage', source, {
        args = {string.format("^7Gesamt Verstöße: ^3%d", stats.totalViolations)}
    })
    TriggerClientEvent('chat:addMessage', source, {
        args = {string.format("^7Gesamt Kicks: ^3%d", stats.totalKicks)}
    })
    TriggerClientEvent('chat:addMessage', source, {
        args = {string.format("^7Aktive Checks: ^3%d", stats.activeChecks)}
    })
    TriggerClientEvent('chat:addMessage', source, {
        args = {string.format("^7Analytics: ^3%s", Config.Analytics.Enabled and "Aktiv" or "Inaktiv")}
    })
    TriggerClientEvent('chat:addMessage', source, {
        args = {string.format("^7Protection: ^3%s", Config.Protection.EventRateLimit and "Aktiv" or "Inaktiv")}
    })
    TriggerClientEvent('chat:addMessage', source, {
        args = {"^2═══════════════════════════════════"}
    })
end, false)

-- Analytics Report
RegisterCommand('acanalytics', function(source, args)
    if not Utils.IsTxAdmin(source) then 
        TriggerClientEvent('chat:addMessage', source, {
            args = {"^1[ANTICHEAT]^7 Keine Berechtigung!"}
        })
        return 
    end
    
    if not Config.Analytics.Enabled then
        TriggerClientEvent('chat:addMessage', source, {
            args = {"^1[ANTICHEAT]^7 Analytics ist deaktiviert!"}
        })
        return
    end
    
    local targetId = tonumber(args[1])
    if not targetId then
        TriggerClientEvent('chat:addMessage', source, {
            args = {"^3[ANTICHEAT]^7 Verwendung: /acanalytics [ID]"}
        })
        return
    end
    
    local report = Analytics.GenerateReport(targetId)
    local playerInfo = Utils.GetPlayerInfo(targetId)
    
    TriggerClientEvent('chat:addMessage', source, {
        args = {"^2═══════════════════════════════════"}
    })
    TriggerClientEvent('chat:addMessage', source, {
        args = {string.format("^2[ANALYTICS]^7 Report für %s", playerInfo.name)}
    })
    TriggerClientEvent('chat:addMessage', source, {
        args = {report}
    })
    TriggerClientEvent('chat:addMessage', source, {
        args = {"^2═══════════════════════════════════"}
    })
end, false)

-- Whitelist hinzufügen
RegisterCommand('acwhitelist', function(source, args)
    if not Utils.IsTxAdmin(source) then 
        TriggerClientEvent('chat:addMessage', source, {
            args = {"^1[ANTICHEAT]^7 Keine Berechtigung!"}
        })
        return 
    end
    
    local targetId = tonumber(args[1])
    if not targetId then
        TriggerClientEvent('chat:addMessage', source, {
            args = {"^3[ANTICHEAT]^7 Verwendung: /acwhitelist [ID]"}
        })
        return
    end
    
    local playerInfo = Utils.GetPlayerInfo(targetId)
    table.insert(Config.WhitelistedIdentifiers, playerInfo.license)
    
    TriggerClientEvent('chat:addMessage', source, {
        args = {string.format("^2[ANTICHEAT]^7 %s wurde zur Whitelist hinzugefügt", playerInfo.name)}
    })
    
    Utils.Log("success", string.format("%s wurde zur Whitelist hinzugefügt", playerInfo.name))
end, false)

-- Help Command
RegisterCommand('achelp', function(source, args)
    if not Utils.IsTxAdmin(source) then 
        TriggerClientEvent('chat:addMessage', source, {
            args = {"^1[ANTICHEAT]^7 Keine Berechtigung!"}
        })
        return 
    end
    
    TriggerClientEvent('chat:addMessage', source, {
        args = {"^2═══════════════════════════════════"}
    })
    TriggerClientEvent('chat:addMessage', source, {
        args = {"^2[ANTICHEAT]^7 Verfügbare Commands:"}
    })
    TriggerClientEvent('chat:addMessage', source, {
        args = {"^3/acstats [ID]^7 - Zeigt Spieler-Statistiken"}
    })
    TriggerClientEvent('chat:addMessage', source, {
        args = {"^3/acreset [ID]^7 - Setzt Verstöße zurück"}
    })
    TriggerClientEvent('chat:addMessage', source, {
        args = {"^3/acfreeze [ID]^7 - Friert Spieler ein"}
    })
    TriggerClientEvent('chat:addMessage', source, {
        args = {"^3/acunfreeze [ID]^7 - Taut Spieler auf"}
    })
    TriggerClientEvent('chat:addMessage', source, {
        args = {"^3/acstatus^7 - Zeigt System-Status"}
    })
    TriggerClientEvent('chat:addMessage', source, {
        args = {"^3/acwhitelist [ID]^7 - Fügt zur Whitelist hinzu"}
    })
    TriggerClientEvent('chat:addMessage', source, {
        args = {"^3/achelp^7 - Zeigt diese Hilfe"}
    })
    TriggerClientEvent('chat:addMessage', source, {
        args = {"^2═══════════════════════════════════"}
    })
end, false)


-- Block IP Command
RegisterCommand('acblockip', function(source, args)
    if not Utils.IsTxAdmin(source) then 
        TriggerClientEvent('chat:addMessage', source, {
            args = {"^1[ANTICHEAT]^7 Keine Berechtigung!"}
        })
        return 
    end
    
    local targetId = tonumber(args[1])
    local reason = table.concat(args, " ", 2) or "Kein Grund angegeben"
    
    if not targetId then
        TriggerClientEvent('chat:addMessage', source, {
            args = {"^3[ANTICHEAT]^7 Verwendung: /acblockip [ID] [Grund]"}
        })
        return
    end
    
    local playerInfo = Utils.GetPlayerInfo(targetId)
    Protection.BlockIP(playerInfo.ip, reason)
    
    TriggerClientEvent('chat:addMessage', source, {
        args = {string.format("^2[ANTICHEAT]^7 IP %s wurde blockiert", playerInfo.ip)}
    })
    
    DropPlayer(targetId, "Deine IP wurde vom Server gebannt.")
end, false)

-- Unblock IP Command
RegisterCommand('acunblockip', function(source, args)
    if not Utils.IsTxAdmin(source) then 
        TriggerClientEvent('chat:addMessage', source, {
            args = {"^1[ANTICHEAT]^7 Keine Berechtigung!"}
        })
        return 
    end
    
    local ip = args[1]
    
    if not ip then
        TriggerClientEvent('chat:addMessage', source, {
            args = {"^3[ANTICHEAT]^7 Verwendung: /acunblockip [IP]"}
        })
        return
    end
    
    Protection.UnblockIP(ip)
    
    TriggerClientEvent('chat:addMessage', source, {
        args = {string.format("^2[ANTICHEAT]^7 IP %s wurde entblockt", ip)}
    })
end, false)


-- Dashboard Command
RegisterCommand('acdashboard', function(source, args)
    if not Utils.IsTxAdmin(source) then 
        TriggerClientEvent('chat:addMessage', source, {
            args = {"^1[ANTICHEAT]^7 Keine Berechtigung!"}
        })
        return 
    end
    
    local report = Dashboard.GenerateReport()
    local formatted = Dashboard.FormatReport(report)
    
    for _, line in ipairs(formatted) do
        TriggerClientEvent('chat:addMessage', source, {
            args = {line}
        })
    end
end, false)

-- ML Score Command
RegisterCommand('acmlscore', function(source, args)
    if not Utils.IsTxAdmin(source) then 
        TriggerClientEvent('chat:addMessage', source, {
            args = {"^1[ANTICHEAT]^7 Keine Berechtigung!"}
        })
        return 
    end
    
    local targetId = tonumber(args[1])
    if not targetId then
        TriggerClientEvent('chat:addMessage', source, {
            args = {"^3[ANTICHEAT]^7 Verwendung: /acmlscore [ID]"}
        })
        return
    end
    
    local report = MLScoring.GetRiskReport(targetId)
    if not report then
        TriggerClientEvent('chat:addMessage', source, {
            args = {"^1[ANTICHEAT]^7 Keine Daten verfügbar!"}
        })
        return
    end
    
    local playerInfo = Utils.GetPlayerInfo(targetId)
    
    TriggerClientEvent('chat:addMessage', source, {
        args = {"^2═══════════════════════════════════"}
    })
    TriggerClientEvent('chat:addMessage', source, {
        args = {string.format("%s[ML-SCORE]^7 %s (ID: %d)", report.color, playerInfo.name, targetId)}
    })
    TriggerClientEvent('chat:addMessage', source, {
        args = {string.format("^7Risk Level: %s%s", report.color, report.risk)}
    })
    TriggerClientEvent('chat:addMessage', source, {
        args = {string.format("^7Overall Score: ^3%.1f/100", report.overall)}
    })
    TriggerClientEvent('chat:addMessage', source, {
        args = {"^7Breakdown:"}
    })
    TriggerClientEvent('chat:addMessage', source, {
        args = {string.format("  ^7Movement: ^3%.1f", report.breakdown.movement)}
    })
    TriggerClientEvent('chat:addMessage', source, {
        args = {string.format("  ^7Combat: ^3%.1f", report.breakdown.combat)}
    })
    TriggerClientEvent('chat:addMessage', source, {
        args = {string.format("  ^7Behavior: ^3%.1f", report.breakdown.behavior)}
    })
    TriggerClientEvent('chat:addMessage', source, {
        args = {"^2═══════════════════════════════════"}
    })
end, false)


-- Ban Command
RegisterCommand('acban', function(source, args)
    if not Utils.IsTxAdmin(source) then 
        TriggerClientEvent('chat:addMessage', source, {
            args = {"^1[ANTICHEAT]^7 Keine Berechtigung!"}
        })
        return 
    end
    
    local targetId = tonumber(args[1])
    local duration = tonumber(args[2]) or 0 -- 0 = permanent
    local reason = table.concat(args, " ", 3) or "Kein Grund angegeben"
    
    if not targetId then
        TriggerClientEvent('chat:addMessage', source, {
            args = {"^3[ANTICHEAT]^7 Verwendung: /acban [ID] [Dauer in Sekunden] [Grund]"}
        })
        return
    end
    
    local playerInfo = Utils.GetPlayerInfo(targetId)
    local adminName = GetPlayerName(source)
    
    Database.AddBan(playerInfo.license, reason, duration, adminName)
    
    DropPlayer(targetId, string.format("Du wurdest gebannt.\nGrund: %s\nDauer: %s", 
        reason, duration == 0 and "Permanent" or Utils.FormatTime(duration)))
    
    TriggerClientEvent('chat:addMessage', source, {
        args = {string.format("^2[ANTICHEAT]^7 %s wurde gebannt", playerInfo.name)}
    })
    
    Utils.SendWebhook(
        "🔨 Spieler gebannt",
        string.format(
            "**Spieler:** %s\n**Grund:** %s\n**Dauer:** %s\n**Admin:** %s",
            playerInfo.name, reason, 
            duration == 0 and "Permanent" or Utils.FormatTime(duration),
            adminName
        ),
        Config.Colors.Ban
    )
end, false)

-- Unban Command
RegisterCommand('acunban', function(source, args)
    if not Utils.IsTxAdmin(source) then 
        TriggerClientEvent('chat:addMessage', source, {
            args = {"^1[ANTICHEAT]^7 Keine Berechtigung!"}
        })
        return 
    end
    
    local identifier = args[1]
    
    if not identifier then
        TriggerClientEvent('chat:addMessage', source, {
            args = {"^3[ANTICHEAT]^7 Verwendung: /acunban [License]"}
        })
        return
    end
    
    if Database.RemoveBan(identifier) then
        TriggerClientEvent('chat:addMessage', source, {
            args = {string.format("^2[ANTICHEAT]^7 Ban für %s entfernt", identifier)}
        })
    else
        TriggerClientEvent('chat:addMessage', source, {
            args = {"^1[ANTICHEAT]^7 Kein aktiver Ban gefunden"}
        })
    end
end, false)

-- Ban List Command
RegisterCommand('acbanlist', function(source, args)
    if not Utils.IsTxAdmin(source) then 
        TriggerClientEvent('chat:addMessage', source, {
            args = {"^1[ANTICHEAT]^7 Keine Berechtigung!"}
        })
        return 
    end
    
    local bans = Database.GetAllBans()
    
    TriggerClientEvent('chat:addMessage', source, {
        args = {"^2═══════════════════════════════════"}
    })
    TriggerClientEvent('chat:addMessage', source, {
        args = {string.format("^2[ANTICHEAT]^7 Aktive Bans: %d", #bans)}
    })
    
    for i, ban in ipairs(bans) do
        if i <= 10 then -- Zeige nur erste 10
            local timeLeft = ban.duration > 0 and Utils.FormatTime(ban.expires - os.time()) or "Permanent"
            TriggerClientEvent('chat:addMessage', source, {
                args = {string.format("^7%d. %s - %s (%s)", i, ban.identifier, ban.reason, timeLeft)}
            })
        end
    end
    
    TriggerClientEvent('chat:addMessage', source, {
        args = {"^2═══════════════════════════════════"}
    })
end, false)

-- Notification Preferences
RegisterCommand('acnotify', function(source, args)
    if not Utils.IsTxAdmin(source) then 
        TriggerClientEvent('chat:addMessage', source, {
            args = {"^1[ANTICHEAT]^7 Keine Berechtigung!"}
        })
        return 
    end
    
    local notifType = args[1]
    local enabled = args[2] == "true"
    
    if not notifType then
        TriggerClientEvent('chat:addMessage', source, {
            args = {"^3[ANTICHEAT]^7 Verwendung: /acnotify [type] [true/false]"}
        })
        TriggerClientEvent('chat:addMessage', source, {
            args = {"^7Types: detection, kick, ban, high_risk, critical, info"}
        })
        return
    end
    
    Notifications.SetPreference(source, notifType, enabled)
    
    TriggerClientEvent('chat:addMessage', source, {
        args = {string.format("^2[ANTICHEAT]^7 Notifications für '%s' %s", 
            notifType, enabled and "aktiviert" or "deaktiviert")}
    })
end, false)

-- Database Stats
RegisterCommand('acdbstats', function(source, args)
    if not Utils.IsTxAdmin(source) then 
        TriggerClientEvent('chat:addMessage', source, {
            args = {"^1[ANTICHEAT]^7 Keine Berechtigung!"}
        })
        return 
    end
    
    local stats = Database.GetStatistics()
    
    TriggerClientEvent('chat:addMessage', source, {
        args = {"^2═══════════════════════════════════"}
    })
    TriggerClientEvent('chat:addMessage', source, {
        args = {"^2[DATABASE]^7 Statistiken"}
    })
    TriggerClientEvent('chat:addMessage', source, {
        args = {string.format("^7Total Bans: ^3%d", stats.totalBans)}
    })
    TriggerClientEvent('chat:addMessage', source, {
        args = {string.format("^7Active Bans: ^3%d", stats.activeBans)}
    })
    TriggerClientEvent('chat:addMessage', source, {
        args = {string.format("^7Total Players: ^3%d", stats.totalPlayers)}
    })
    TriggerClientEvent('chat:addMessage', source, {
        args = {string.format("^7Total Violations: ^3%d", stats.totalViolations)}
    })
    TriggerClientEvent('chat:addMessage', source, {
        args = {"^2═══════════════════════════════════"}
    })
end, false)


-- Reputation Command
RegisterCommand('acreputation', function(source, args)
    if not Utils.IsTxAdmin(source) then 
        TriggerClientEvent('chat:addMessage', source, {
            args = {"^1[ANTICHEAT]^7 Keine Berechtigung!"}
        })
        return 
    end
    
    local targetId = tonumber(args[1])
    if not targetId then
        TriggerClientEvent('chat:addMessage', source, {
            args = {"^3[ANTICHEAT]^7 Verwendung: /acreputation [ID]"}
        })
        return
    end
    
    local report = Reputation.GenerateReport(targetId)
    if not report then
        TriggerClientEvent('chat:addMessage', source, {
            args = {"^1[ANTICHEAT]^7 Keine Daten verfügbar!"}
        })
        return
    end
    
    local playerInfo = Utils.GetPlayerInfo(targetId)
    
    TriggerClientEvent('chat:addMessage', source, {
        args = {"^2═══════════════════════════════════"}
    })
    TriggerClientEvent('chat:addMessage', source, {
        args = {string.format("%s[REPUTATION]^7 %s (ID: %d)", report.color, playerInfo.name, targetId)}
    })
    TriggerClientEvent('chat:addMessage', source, {
        args = {string.format("^7Score: %s%d/100", report.color, report.score)}
    })
    TriggerClientEvent('chat:addMessage', source, {
        args = {string.format("^7Level: %s%s", report.color, report.level)}
    })
    TriggerClientEvent('chat:addMessage', source, {
        args = {string.format("^7Violations: ^3%d", report.violations)}
    })
    TriggerClientEvent('chat:addMessage', source, {
        args = {string.format("^7Session Time: ^3%s", report.sessionTime)}
    })
    TriggerClientEvent('chat:addMessage', source, {
        args = {"^2═══════════════════════════════════"}
    })
end, false)

-- Performance Command
RegisterCommand('acperformance', function(source, args)
    if not Utils.IsTxAdmin(source) then 
        TriggerClientEvent('chat:addMessage', source, {
            args = {"^1[ANTICHEAT]^7 Keine Berechtigung!"}
        })
        return 
    end
    
    local report = Performance.GenerateReport()
    local health, color = Performance.GetHealthStatus()
    
    TriggerClientEvent('chat:addMessage', source, {
        args = {"^2═══════════════════════════════════"}
    })
    TriggerClientEvent('chat:addMessage', source, {
        args = {string.format("%s[PERFORMANCE]^7 Status: %s%s", color, color, health)}
    })
    TriggerClientEvent('chat:addMessage', source, {
        args = {string.format("^7Memory: ^3%.2f MB", report.resourceUsage.memory)}
    })
    TriggerClientEvent('chat:addMessage', source, {
        args = {"^7Timings:"}
    })
    
    for category, timing in pairs(report.timings) do
        TriggerClientEvent('chat:addMessage', source, {
            args = {string.format("  ^7%s: ^3%.2fms ^7(avg)", category, timing.avg)}
        })
    end
    
    local suggestions = Performance.GetOptimizationSuggestions()
    if #suggestions > 0 then
        TriggerClientEvent('chat:addMessage', source, {
            args = {"^3Optimierungsvorschläge:"}
        })
        for _, suggestion in ipairs(suggestions) do
            TriggerClientEvent('chat:addMessage', source, {
                args = {"  ^7• " .. suggestion}
            })
        end
    end
    
    TriggerClientEvent('chat:addMessage', source, {
        args = {"^2═══════════════════════════════════"}
    })
end, false)

-- Top Players Command
RegisterCommand('actop', function(source, args)
    if not Utils.IsTxAdmin(source) then 
        TriggerClientEvent('chat:addMessage', source, {
            args = {"^1[ANTICHEAT]^7 Keine Berechtigung!"}
        })
        return 
    end
    
    local players = GetPlayers()
    local playerScores = {}
    
    for _, playerId in ipairs(players) do
        local id = tonumber(playerId)
        local score = Reputation.GetScore(id)
        local playerInfo = Utils.GetPlayerInfo(id)
        
        table.insert(playerScores, {
            id = id,
            name = playerInfo.name,
            score = score
        })
    end
    
    -- Sort by score
    table.sort(playerScores, function(a, b)
        return a.score > b.score
    end)
    
    TriggerClientEvent('chat:addMessage', source, {
        args = {"^2═══════════════════════════════════"}
    })
    TriggerClientEvent('chat:addMessage', source, {
        args = {"^2[TOP PLAYERS]^7 Reputation Ranking"}
    })
    
    for i = 1, math.min(10, #playerScores) do
        local player = playerScores[i]
        local level, color = Reputation.GetLevel(player.id)
        
        TriggerClientEvent('chat:addMessage', source, {
            args = {string.format("^7%d. %s - %s%d ^7(%s%s^7)", 
                i, player.name, color, player.score, color, level)}
        })
    end
    
    TriggerClientEvent('chat:addMessage', source, {
        args = {"^2═══════════════════════════════════"}
    })
end, false)
