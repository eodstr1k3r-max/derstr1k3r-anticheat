--[[
    RedM Anticheat System - Dashboard & Reporting
    © 2026 DerStr1k3r
--]]

Dashboard = {}

local sessionStats = {
    startTime = os.time(),
    totalDetections = 0,
    totalKicks = 0,
    totalBans = 0,
    detectionsByType = {},
    topOffenders = {},
    hourlyStats = {}
}

-- ═══════════════════════════════════════════════════════════
--  STATISTICS TRACKING
-- ═══════════════════════════════════════════════════════════

function Dashboard.RecordDetection(source, violationType)
    sessionStats.totalDetections = sessionStats.totalDetections + 1
    
    if not sessionStats.detectionsByType[violationType] then
        sessionStats.detectionsByType[violationType] = 0
    end
    sessionStats.detectionsByType[violationType] = sessionStats.detectionsByType[violationType] + 1
    
    -- Track Top Offenders
    local playerInfo = Utils.GetPlayerInfo(source)
    if not sessionStats.topOffenders[source] then
        sessionStats.topOffenders[source] = {
            name = playerInfo.name,
            count = 0,
            violations = {}
        }
    end
    
    sessionStats.topOffenders[source].count = sessionStats.topOffenders[source].count + 1
    table.insert(sessionStats.topOffenders[source].violations, {
        type = violationType,
        time = os.time()
    })
end

function Dashboard.RecordKick(source)
    sessionStats.totalKicks = sessionStats.totalKicks + 1
end

function Dashboard.RecordBan(source)
    sessionStats.totalBans = sessionStats.totalBans + 1
end

-- ═══════════════════════════════════════════════════════════
--  DASHBOARD GENERATION
-- ═══════════════════════════════════════════════════════════

function Dashboard.GenerateReport()
    local uptime = os.time() - sessionStats.startTime
    local uptimeStr = Utils.FormatTime(uptime)
    
    local report = {
        uptime = uptimeStr,
        totalDetections = sessionStats.totalDetections,
        totalKicks = sessionStats.totalKicks,
        totalBans = sessionStats.totalBans,
        detectionsByType = sessionStats.detectionsByType,
        topOffenders = Dashboard.GetTopOffenders(5)
    }
    
    return report
end

function Dashboard.GetTopOffenders(limit)
    local offenders = {}
    
    for source, data in pairs(sessionStats.topOffenders) do
        table.insert(offenders, {
            source = source,
            name = data.name,
            count = data.count
        })
    end
    
    -- Sortiere nach Count
    table.sort(offenders, function(a, b)
        return a.count > b.count
    end)
    
    -- Limitiere Ergebnisse
    local result = {}
    for i = 1, math.min(limit, #offenders) do
        table.insert(result, offenders[i])
    end
    
    return result
end

function Dashboard.GetHourlyStats()
    local currentHour = os.date("%H")
    
    if not sessionStats.hourlyStats[currentHour] then
        sessionStats.hourlyStats[currentHour] = {
            detections = 0,
            kicks = 0
        }
    end
    
    return sessionStats.hourlyStats[currentHour]
end

-- ═══════════════════════════════════════════════════════════
--  FORMATTED OUTPUT
-- ═══════════════════════════════════════════════════════════

function Dashboard.FormatReport(report)
    local output = {}
    
    table.insert(output, "^2╔════════════════════════════════════════════════╗^7")
    table.insert(output, "^2║         ANTICHEAT DASHBOARD REPORT            ║^7")
    table.insert(output, "^2╠════════════════════════════════════════════════╣^7")
    table.insert(output, string.format("^2║^7 Uptime: ^3%-38s^7 ^2║^7", report.uptime))
    table.insert(output, string.format("^2║^7 Total Detections: ^3%-29d^7 ^2║^7", report.totalDetections))
    table.insert(output, string.format("^2║^7 Total Kicks: ^3%-34d^7 ^2║^7", report.totalKicks))
    table.insert(output, string.format("^2║^7 Total Bans: ^3%-35d^7 ^2║^7", report.totalBans))
    table.insert(output, "^2╠════════════════════════════════════════════════╣^7")
    table.insert(output, "^2║^7 Detection Breakdown:                         ^2║^7")
    
    for violationType, count in pairs(report.detectionsByType) do
        local line = string.format("^2║^7   • %-30s ^3%6d^7 ^2║^7", violationType, count)
        table.insert(output, line)
    end
    
    if #report.topOffenders > 0 then
        table.insert(output, "^2╠════════════════════════════════════════════════╣^7")
        table.insert(output, "^2║^7 Top Offenders:                               ^2║^7")
        
        for i, offender in ipairs(report.topOffenders) do
            local line = string.format("^2║^7 %d. %-30s ^1%6d^7 ^2║^7", i, offender.name, offender.count)
            table.insert(output, line)
        end
    end
    
    table.insert(output, "^2╚════════════════════════════════════════════════╝^7")
    
    return output
end

-- ═══════════════════════════════════════════════════════════
--  WEBHOOK REPORTING
-- ═══════════════════════════════════════════════════════════

function Dashboard.SendDailyReport()
    local report = Dashboard.GenerateReport()
    
    local fields = {}
    
    table.insert(fields, {
        name = "📊 Statistiken",
        value = string.format("Detections: %d\nKicks: %d\nBans: %d", 
            report.totalDetections, report.totalKicks, report.totalBans),
        inline = true
    })
    
    table.insert(fields, {
        name = "⏱️ Uptime",
        value = report.uptime,
        inline = true
    })
    
    -- Top Violations
    local topViolations = ""
    local count = 0
    for violationType, vCount in pairs(report.detectionsByType) do
        if count < 5 then
            topViolations = topViolations .. string.format("• %s: %d\n", violationType, vCount)
            count = count + 1
        end
    end
    
    if topViolations ~= "" then
        table.insert(fields, {
            name = "🔍 Top Violations",
            value = topViolations,
            inline = false
        })
    end
    
    -- Top Offenders
    if #report.topOffenders > 0 then
        local topOffendersStr = ""
        for i, offender in ipairs(report.topOffenders) do
            topOffendersStr = topOffendersStr .. string.format("%d. %s (%d)\n", i, offender.name, offender.count)
        end
        
        table.insert(fields, {
            name = "⚠️ Top Offenders",
            value = topOffendersStr,
            inline = false
        })
    end
    
    Utils.SendWebhook(
        "📈 Daily Anticheat Report",
        "Täglicher Bericht über Anticheat-Aktivitäten",
        Config.Colors.Info,
        fields
    )
end

-- ═══════════════════════════════════════════════════════════
--  PERIODIC REPORTING
-- ═══════════════════════════════════════════════════════════

if Config.Dashboard and Config.Dashboard.DailyReport then
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(86400000) -- 24 Stunden
            Dashboard.SendDailyReport()
        end
    end)
end

-- Hourly Stats Update
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(3600000) -- 1 Stunde
        
        local currentHour = os.date("%H")
        if not sessionStats.hourlyStats[currentHour] then
            sessionStats.hourlyStats[currentHour] = {
                detections = 0,
                kicks = 0
            }
        end
    end
end)

return Dashboard
