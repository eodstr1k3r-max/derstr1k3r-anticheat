--[[
    RedM Anticheat System - Performance Monitor
    © 2026 DerStr1k3r
--]]

Performance = {}

local metrics = {
    detectionTime = {},
    eventProcessing = {},
    databaseOperations = {},
    mlScoring = {},
    resourceUsage = {
        memory = 0,
        cpu = 0,
        threads = 0
    }
}

local performanceHistory = {}

-- ═══════════════════════════════════════════════════════════
--  PERFORMANCE TRACKING
-- ═══════════════════════════════════════════════════════════

function Performance.StartTimer(category)
    return {
        category = category,
        startTime = os.clock()
    }
end

function Performance.EndTimer(timer)
    local elapsed = (os.clock() - timer.startTime) * 1000 -- Convert to ms
    
    if not metrics[timer.category] then
        metrics[timer.category] = {}
    end
    
    table.insert(metrics[timer.category], elapsed)
    
    -- Keep only last 100 measurements
    if #metrics[timer.category] > 100 then
        table.remove(metrics[timer.category], 1)
    end
    
    return elapsed
end

-- ═══════════════════════════════════════════════════════════
--  STATISTICS
-- ═══════════════════════════════════════════════════════════

function Performance.GetAverageTime(category)
    if not metrics[category] or #metrics[category] == 0 then
        return 0
    end
    
    local sum = 0
    for _, time in ipairs(metrics[category]) do
        sum = sum + time
    end
    
    return sum / #metrics[category]
end

function Performance.GetMaxTime(category)
    if not metrics[category] or #metrics[category] == 0 then
        return 0
    end
    
    local max = 0
    for _, time in ipairs(metrics[category]) do
        if time > max then
            max = time
        end
    end
    
    return max
end

function Performance.GetMinTime(category)
    if not metrics[category] or #metrics[category] == 0 then
        return 0
    end
    
    local min = math.huge
    for _, time in ipairs(metrics[category]) do
        if time < min then
            min = time
        end
    end
    
    return min
end

-- ═══════════════════════════════════════════════════════════
--  RESOURCE MONITORING
-- ═══════════════════════════════════════════════════════════

function Performance.UpdateResourceUsage()
    local resourceName = GetCurrentResourceName()
    
    -- Memory Usage (in MB)
    metrics.resourceUsage.memory = GetResourceMemoryUsage(resourceName) / 1024
    
    -- Thread Count
    metrics.resourceUsage.threads = GetNumResourceMetadata(resourceName, 'server_script')
    
    -- Store in history
    table.insert(performanceHistory, {
        timestamp = os.time(),
        memory = metrics.resourceUsage.memory,
        avgDetectionTime = Performance.GetAverageTime('detectionTime')
    })
    
    -- Keep only last 60 entries (1 hour if updated every minute)
    if #performanceHistory > 60 then
        table.remove(performanceHistory, 1)
    end
end

-- ═══════════════════════════════════════════════════════════
--  PERFORMANCE REPORT
-- ═══════════════════════════════════════════════════════════

function Performance.GenerateReport()
    local report = {
        resourceUsage = {
            memory = Utils.Round(metrics.resourceUsage.memory, 2),
            threads = metrics.resourceUsage.threads
        },
        timings = {}
    }
    
    for category, times in pairs(metrics) do
        if type(times) == "table" and #times > 0 then
            report.timings[category] = {
                avg = Utils.Round(Performance.GetAverageTime(category), 2),
                max = Utils.Round(Performance.GetMaxTime(category), 2),
                min = Utils.Round(Performance.GetMinTime(category), 2),
                samples = #times
            }
        end
    end
    
    return report
end

function Performance.GetHealthStatus()
    local avgDetection = Performance.GetAverageTime('detectionTime')
    local memory = metrics.resourceUsage.memory
    
    if avgDetection > 50 or memory > 100 then
        return "CRITICAL", "^1"
    elseif avgDetection > 20 or memory > 50 then
        return "WARNING", "^3"
    else
        return "HEALTHY", "^2"
    end
end

-- ═══════════════════════════════════════════════════════════
--  ALERTS
-- ═══════════════════════════════════════════════════════════

function Performance.CheckThresholds()
    local avgDetection = Performance.GetAverageTime('detectionTime')
    local memory = metrics.resourceUsage.memory
    
    -- Detection Time Alert
    if avgDetection > 50 then
        Utils.Log("warning", string.format("High detection time: %.2fms", avgDetection))
        
        if Config.Performance and Config.Performance.Alerts then
            Utils.SendWebhook(
                "⚠️ Performance Alert",
                string.format("**Detection Time:** %.2fms (Threshold: 50ms)", avgDetection),
                Config.Colors.Warning
            )
        end
    end
    
    -- Memory Alert
    if memory > 100 then
        Utils.Log("warning", string.format("High memory usage: %.2fMB", memory))
        
        if Config.Performance and Config.Performance.Alerts then
            Utils.SendWebhook(
                "⚠️ Memory Alert",
                string.format("**Memory Usage:** %.2fMB (Threshold: 100MB)", memory),
                Config.Colors.Warning
            )
        end
    end
end

-- ═══════════════════════════════════════════════════════════
--  OPTIMIZATION SUGGESTIONS
-- ═══════════════════════════════════════════════════════════

function Performance.GetOptimizationSuggestions()
    local suggestions = {}
    local avgDetection = Performance.GetAverageTime('detectionTime')
    local memory = metrics.resourceUsage.memory
    
    if avgDetection > 30 then
        table.insert(suggestions, "Erhöhe Check-Intervalle in Config.Thresholds")
        table.insert(suggestions, "Deaktiviere nicht benötigte Checks")
    end
    
    if memory > 75 then
        table.insert(suggestions, "Reduziere Cache-Größen")
        table.insert(suggestions, "Aktiviere Performance-Modus")
    end
    
    if Performance.GetAverageTime('mlScoring') > 10 then
        table.insert(suggestions, "Reduziere ML-Scoring Samples")
    end
    
    return suggestions
end

-- ═══════════════════════════════════════════════════════════
--  PERIODIC MONITORING
-- ═══════════════════════════════════════════════════════════

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(60000) -- Every minute
        
        Performance.UpdateResourceUsage()
        Performance.CheckThresholds()
    end
end)

return Performance
