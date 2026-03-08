--[[
    RedM Anticheat System
    © 2026 DerStr1k3r
    Alle Rechte vorbehalten
--]]

Config = {}

-- ═══════════════════════════════════════════════════════════
--  WEBHOOK KONFIGURATION
-- ═══════════════════════════════════════════════════════════
Config.Webhook = ""
Config.WebhookName = "RedM Anticheat"
Config.WebhookAvatar = "https://i.imgur.com/your-avatar.png"

-- ═══════════════════════════════════════════════════════════
--  SYSTEM EINSTELLUNGEN
-- ═══════════════════════════════════════════════════════════
Config.Debug = false -- Debug Modus (zeigt mehr Informationen)
Config.Language = "de" -- Sprache: de, en
Config.PerformanceMode = false -- Reduziert Check-Frequenz für bessere Performance

-- ═══════════════════════════════════════════════════════════
--  ERKENNUNGS-SYSTEME
-- ═══════════════════════════════════════════════════════════
Config.Checks = {
    -- Spieler Manipulation
    GodMode = true,
    Invincible = true,
    InfiniteStamina = true,
    
    -- Bewegungs-Cheats
    SpeedHack = true,
    Teleport = true,
    Noclip = true,
    SuperJump = true,
    Fly = true,
    
    -- Waffen & Kampf
    WeaponSpawn = true,
    RapidFire = true,
    InfiniteAmmo = true,
    Aimbot = true,
    
    -- System & Injection
    ResourceInjection = true,
    EventInjection = true,
    ExplosionSpam = true,
    
    -- Wirtschaft & Items
    MoneyCheat = false, -- Erfordert ESX/QBCore Integration
    ItemSpawn = false, -- Erfordert Framework Integration
}

-- ═══════════════════════════════════════════════════════════
--  SCHWELLENWERTE & LIMITS
-- ═══════════════════════════════════════════════════════════
Config.Thresholds = {
    -- Bewegung
    MaxSpeed = 15.0, -- m/s zu Fuß
    MaxSpeedOnHorse = 25.0, -- m/s auf Pferd
    MaxSpeedInVehicle = 35.0, -- m/s in Fahrzeug
    TeleportDistance = 100.0, -- Meter
    MaxJumpHeight = 5.0, -- Meter
    MaxFallSpeed = 50.0, -- m/s
    
    -- Verstöße
    ViolationsBeforeKick = 5,
    ViolationsBeforeBan = 10,
    ViolationDecayTime = 300, -- Sekunden bis Verstöße verfallen
    
    -- Check Intervalle (ms)
    PositionCheckInterval = 2000,
    HealthCheckInterval = 3000,
    WeaponCheckInterval = 1000,
    SpeedCheckInterval = 1000,
    
    -- Kampf
    MaxShotsPerSecond = 10,
    MaxExplosionsPerMinute = 5,
    
    -- Ping & Performance
    MaxPing = 500, -- Spieler mit höherem Ping werden toleranter behandelt
    HighPingMultiplier = 1.5, -- Schwellenwerte werden erhöht
}

-- ═══════════════════════════════════════════════════════════
--  AKTIONEN BEI ERKENNUNG
-- ═══════════════════════════════════════════════════════════
Config.Actions = {
    Kick = true,
    Ban = false, -- Erfordert Ban-System
    Log = true,
    Screenshot = false, -- Erfordert Screenshot-System
    NotifyAdmins = true,
    FreezePlayer = true, -- Friert Spieler bei schweren Verstößen ein
    TeleportToJail = false, -- Teleportiert zu Jail-Koordinaten
}

-- Jail Koordinaten (falls TeleportToJail aktiviert)
Config.JailCoords = vector3(-1355.0, -2469.0, 43.0)

-- ═══════════════════════════════════════════════════════════
--  WHITELISTS
-- ═══════════════════════════════════════════════════════════

-- Waffen Whitelist (Hash-Werte oder Namen)
Config.AllowedWeapons = {
    -- Beispiel:
    -- [GetHashKey("WEAPON_REVOLVER_CATTLEMAN")] = true,
    -- [GetHashKey("WEAPON_RIFLE_SPRINGFIELD")] = true,
}

-- Event Whitelist (Erlaubte Events von Clients)
Config.AllowedEvents = {
    "anticheat:healthCheck",
    "anticheat:positionCheck",
    "anticheat:speedCheck",
    "anticheat:jumpCheck",
    "anticheat:weaponCheck",
    "anticheat:shotFired",
}

-- Resource Whitelist (Erlaubte Resources)
Config.AllowedResources = {
    "redm-anticheat",
    "chat",
    "spawnmanager",
    "sessionmanager",
    "basic-gamemode",
    "hardcap",
    "rconlog",
}

-- Identifier Whitelist (Spieler die nie gekickt werden)
Config.WhitelistedIdentifiers = {
    -- "steam:110000xxxxxxxx",
    -- "license:xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
}

-- ═══════════════════════════════════════════════════════════
--  NACHRICHTEN
-- ═══════════════════════════════════════════════════════════
Config.Messages = {
    de = {
        KickReason = "Anticheat: Verdächtige Aktivität erkannt (#%s)",
        BanReason = "Anticheat: Mehrfache Verstöße gegen die Serverregeln",
        AdminNotification = "^1[ANTICHEAT]^7 %s (ID: %d) - %s (Verstöße: %d/%d)",
        PlayerWarning = "^3[WARNUNG]^7 Verdächtige Aktivität erkannt. Weitere Verstöße führen zum Kick.",
        PlayerFrozen = "^1[ANTICHEAT]^7 Du wurdest eingefroren. Ein Admin wird sich um dich kümmern.",
        ViolationDecayed = "^2[ANTICHEAT]^7 Ein Verstoß ist verfallen.",
    },
    en = {
        KickReason = "Anticheat: Suspicious activity detected (#%s)",
        BanReason = "Anticheat: Multiple violations of server rules",
        AdminNotification = "^1[ANTICHEAT]^7 %s (ID: %d) - %s (Violations: %d/%d)",
        PlayerWarning = "^3[WARNING]^7 Suspicious activity detected. Further violations will result in a kick.",
        PlayerFrozen = "^1[ANTICHEAT]^7 You have been frozen. An admin will attend to you.",
        ViolationDecayed = "^2[ANTICHEAT]^7 A violation has decayed.",
    }
}

-- ═══════════════════════════════════════════════════════════
--  WEBHOOK FARBEN
-- ═══════════════════════════════════════════════════════════
Config.Colors = {
    Warning = 16776960, -- Gelb
    Kick = 16711680, -- Rot
    Ban = 8388608, -- Dunkelrot
    Info = 3447003, -- Blau
    Success = 65280, -- Grün
}

-- ═══════════════════════════════════════════════════════════
--  ERWEITERTE EINSTELLUNGEN
-- ═══════════════════════════════════════════════════════════

-- Severity Levels (1 = niedrig, 2 = mittel, 3 = hoch)
Config.SeverityLevels = {
    GodMode = 3,
    Invincible = 3,
    SpeedHack = 2,
    Teleport = 3,
    Noclip = 3,
    SuperJump = 2,
    WeaponSpawn = 2,
    RapidFire = 2,
    ResourceInjection = 3,
    EventInjection = 3,
    ExplosionSpam = 2,
    Fly = 3,
    Aimbot = 3,
}

-- Auto-Ban bei bestimmten Verstößen
Config.AutoBanViolations = {
    "ResourceInjection",
    "EventInjection",
}

-- Performance Optimierung
Config.Performance = {
    MaxPlayersPerCheck = 32, -- Maximale Spieler pro Check-Zyklus
    CheckDelay = 50, -- ms Verzögerung zwischen Spieler-Checks
    CachePlayerData = true, -- Cached Spielerdaten für bessere Performance
    CacheTimeout = 5000, -- ms bis Cache erneuert wird
}

-- ═══════════════════════════════════════════════════════════
--  ANALYTICS & PATTERN DETECTION
-- ═══════════════════════════════════════════════════════════

Config.Analytics = {
    Enabled = true, -- Aktiviert erweiterte Verhaltensanalyse
    SuspicionThreshold = 50, -- Score ab dem Admins benachrichtigt werden
    SuspicionDecay = 1, -- Score-Abbau pro Minute
    AnalysisInterval = 60000, -- Analyse-Intervall in ms
    TrackMovement = true, -- Bewegungsmuster tracken
    TrackCombat = true, -- Kampfmuster tracken
    TrackEconomy = false, -- Wirtschafts-Aktivitäten tracken (ESX/QB)
}

-- ═══════════════════════════════════════════════════════════
--  PROTECTION SYSTEMS
-- ═══════════════════════════════════════════════════════════

Config.Protection = {
    EventRateLimit = true, -- Rate Limiting für Events
    SQLInjectionCheck = true, -- SQL Injection Schutz
    XSSProtection = true, -- XSS Schutz
    BlockVPN = false, -- VPN-Nutzer blockieren
    IPBlacklist = true, -- IP-Blacklist System
    ResourceIntegrity = true, -- Resource Integritäts-Check
    AntiDump = false, -- Anti-Dump Protection (experimentell)
}

-- ═══════════════════════════════════════════════════════════
--  SCREENSHOT SYSTEM (Optional)
-- ═══════════════════════════════════════════════════════════

Config.Screenshot = {
    Enabled = false, -- Erfordert Screenshot-Resource
    OnViolation = true, -- Screenshot bei Verstoß
    OnHighSuspicion = true, -- Screenshot bei hohem Suspicion Score
    WebhookURL = "", -- Separater Webhook für Screenshots
}

-- ═══════════════════════════════════════════════════════════
--  DISCORD INTEGRATION
-- ═══════════════════════════════════════════════════════════

Config.Discord = {
    Enabled = false, -- Discord Bot Integration
    BotToken = "", -- Discord Bot Token
    GuildID = "", -- Server ID
    LogChannelID = "", -- Channel für Logs
    AlertChannelID = "", -- Channel für Alerts
    RoleID = "", -- Admin Role ID für Mentions
}

-- ═══════════════════════════════════════════════════════════
--  MACHINE LEARNING SCORING
-- ═══════════════════════════════════════════════════════════

Config.MLScoring = {
    Enabled = true, -- ML-basiertes Scoring aktivieren
    AnalysisInterval = 120000, -- Analyse alle 2 Minuten
    AlertThreshold = 60, -- Score ab dem Admins benachrichtigt werden
    AutoKickThreshold = 85, -- Score für automatischen Kick
    ProfileSamples = 100, -- Anzahl Samples für Profiling
    
    -- Feature Weights
    Weights = {
        Movement = 0.35,
        Combat = 0.40,
        Behavior = 0.25
    },
    
    -- Anomaly Detection Thresholds
    Thresholds = {
        SpeedZScore = 2.0, -- Z-Score für Speed Anomaly
        AccuracyThreshold = 0.90, -- Verdächtige Trefferquote
        HeadshotRatio = 0.70, -- Verdächtige Headshot-Rate
        KDRatio = 10.0, -- Verdächtige K/D Ratio
        LowVariance = 0.5 -- Bot-Indikator
    }
}

-- ═══════════════════════════════════════════════════════════
--  DASHBOARD & REPORTING
-- ═══════════════════════════════════════════════════════════

Config.Dashboard = {
    Enabled = true, -- Dashboard aktivieren
    DailyReport = true, -- Täglicher Report via Webhook
    HourlyStats = true, -- Stündliche Statistiken
    TopOffendersLimit = 10, -- Anzahl Top Offenders zu tracken
    
    -- Export Options
    ExportToFile = false, -- Statistiken in Datei exportieren
    ExportInterval = 86400000, -- Export alle 24h
    ExportPath = "anticheat_stats.json"
}

-- ═══════════════════════════════════════════════════════════
--  ADVANCED FEATURES
-- ═══════════════════════════════════════════════════════════

Config.Advanced = {
    -- Adaptive Thresholds basierend auf ML-Score
    AdaptiveThresholds = true,
    
    -- Automatische Baseline-Anpassung
    AutoBaseline = true,
    
    -- Heuristische Analyse
    HeuristicAnalysis = true,
    
    -- Pattern Recognition
    PatternRecognition = true,
    
    -- Behavioral Profiling
    BehavioralProfiling = true,
    
    -- Predictive Detection (experimentell)
    PredictiveDetection = false,
    
    -- Cross-Session Tracking
    CrossSessionTracking = true, -- Jetzt mit Database Support
    
    -- Smart Notifications
    SmartNotifications = true,
    
    -- Auto-Ban System
    AutoBanSystem = true,
    
    -- Reputation System
    ReputationSystem = true,
}

-- ═══════════════════════════════════════════════════════════
--  DATABASE SETTINGS
-- ═══════════════════════════════════════════════════════════

Config.Database = {
    Enabled = true, -- Database Layer aktivieren
    AutoSave = true, -- Automatisches Speichern
    SaveInterval = 300000, -- Save alle 5 Minuten
    
    -- Retention
    ViolationRetention = 2592000, -- 30 Tage in Sekunden
    BanRetention = 7776000, -- 90 Tage für inaktive Bans
    
    -- History Tracking
    TrackPlayerHistory = true,
    TrackViolations = true,
    TrackBans = true,
}

-- ═══════════════════════════════════════════════════════════
--  NOTIFICATION SYSTEM
-- ═══════════════════════════════════════════════════════════

Config.Notifications = {
    Enabled = true,
    
    -- Notification Channels
    InGame = true, -- Chat notifications
    Webhook = true, -- Discord webhook
    
    -- Smart Notifications
    GroupSimilar = true, -- Gruppiere ähnliche Notifications
    RateLimitNotifications = true, -- Verhindere Spam
    
    -- Notification Levels
    MinSeverity = 1, -- Minimale Severity für Notifications
}

-- ═══════════════════════════════════════════════════════════
--  REPUTATION SYSTEM
-- ═══════════════════════════════════════════════════════════

Config.Reputation = {
    Enabled = true,
    
    -- Starting Reputation
    StartingReputation = 100,
    
    -- Reputation Loss
    ViolationPenalty = 5,
    KickPenalty = 20,
    BanPenalty = 100,
    
    -- Reputation Gain
    CleanSessionBonus = 2, -- Pro Stunde ohne Violations
    
    -- Thresholds
    LowReputationThreshold = 50,
    VeryLowReputationThreshold = 25,
    
    -- Actions
    LowReputationActions = {
        ReducedThresholds = true, -- Niedrigere Kick-Schwelle
        IncreasedMonitoring = true, -- Häufigere Checks
        AdminAlert = true
    }
}

-- ═══════════════════════════════════════════════════════════
--  PERFORMANCE MONITORING
-- ═══════════════════════════════════════════════════════════

Config.Performance = {
    Enabled = true,
    
    -- Monitoring
    TrackDetectionTime = true,
    TrackResourceUsage = true,
    
    -- Alerts
    Alerts = true,
    AlertThresholds = {
        DetectionTime = 50, -- ms
        MemoryUsage = 100, -- MB
    },
    
    -- Optimization
    AutoOptimize = false, -- Experimentell
    OptimizationInterval = 300000, -- 5 Minuten
}
