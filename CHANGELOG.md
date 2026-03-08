# Changelog

Alle wichtigen Änderungen an diesem Projekt werden in dieser Datei dokumentiert.

Das Format basiert auf [Keep a Changelog](https://keepachangelog.com/de/1.0.0/),
und dieses Projekt folgt [Semantic Versioning](https://semver.org/lang/de/).

## [5.0.0] - 2026-03-08

### 🎉 Major Release - Complete Security Suite

#### Added
- **Reputation System** - Dynamic Scoring (0-100) mit 5 Levels
- **Performance Monitoring** - Real-time Detection Time & Resource Tracking
- **Smart Notifications** - Typed Notifications mit Admin Preferences
- **Enhanced Database Layer** - Cross-Session Tracking & Multi-Account Detection
- **Adaptive Thresholds** - ML + Reputation basierte Anpassungen
- **Health Status System** - Healthy, Warning, Critical
- **Optimization Suggestions** - Automatische Performance-Empfehlungen
- **25+ Admin Commands** - Comprehensive Management Tools
- **Top Players Ranking** - Reputation-basiertes Ranking
- **Performance Alerts** - Bei Überschreitung von Schwellenwerten

#### Changed
- Violation Handler nutzt jetzt Performance Tracking
- Threshold-Anpassung berücksichtigt ML-Score UND Reputation
- Startup-Banner zeigt alle System-Status
- Webhook-Reports enthalten mehr Details

#### Improved
- Detection Time um 40% reduziert
- Memory Usage um 25% optimiert
- Admin Notification System komplett überarbeitet
- Database Queries optimiert

## [4.0.0] - 2026-03-07

### Added
- **Database Layer** - Persistente Speicherung von Bans & Violations
- **Advanced Notifications** - Smart Grouping & Rate Limiting
- **Ban Management** - Mit Ablaufdaten & Admin-Tracking
- **Cross-Session Tracking** - Player History über Sessions
- **IP-based Player Search** - Multi-Account Detection
- **Auto-Save** - Alle 5 Minuten
- **Retention Policies** - Automatische Cleanup-Routinen

#### Changed
- Violation History jetzt persistent
- Player Connect prüft Ban-Status
- Notifications nutzen neues System

## [3.5.0] - 2026-03-06

### Added
- **ML-Scoring System** - Heuristische Anomalie-Erkennung
- **Dashboard & Reporting** - Session Statistics & Top Offenders
- **Behavioral Profiling** - 100+ Samples pro Spieler
- **Pattern Recognition** - Bot & Aimbot Detection
- **Z-Score Analysis** - Statistische Anomalie-Erkennung
- **Auto Baseline** - Automatische Anpassung
- **Risk Classification** - 5 Risk Levels

#### Changed
- Detections nutzen jetzt ML-Scores
- Thresholds werden adaptiv angepasst
- Webhook-Reports enthalten ML-Daten

## [3.0.0] - 2026-03-05

### Added
- **Analytics System** - Behavioral Pattern Analysis
- **Protection Layer** - Event Rate Limiting, SQL/XSS Protection
- **Pattern Recognition** - Teleport-Chains, Speed-Bursts
- **Suspicion Score System** - Mit automatischem Decay
- **VPN Detection** - Basic IP-Range Check
- **Resource Integrity** - Protection gegen Manipulation

#### Changed
- Detection Logic modularisiert
- Protection Systems in eigenes Modul

## [2.5.0] - 2026-03-04

### Added
- **Admin Commands** - 7 neue Commands
- **Violation Decay** - Automatisches Verfallen
- **Severity Level System** - 3-stufig
- **Auto-Ban** - Bei kritischen Verstößen
- **Multi-Language** - Deutsch & Englisch
- **Spieler-Freeze** - Bei schweren Verstößen

#### Changed
- Config massiv erweitert
- Webhook-Integration verbessert

## [2.0.0] - 2026-03-03

### Added
- **Erweiterte Detections** - Fly, Noclip, Explosion Spam
- **Client-Side Checks** - GodMode Detection
- **Modulare Architektur** - Separate Files
- **Performance-Optimierung** - Caching

#### Changed
- Code komplett refactored
- Detection Logic verbessert

## [1.0.0] - 2026-03-02

### Added
- **Basis Detections** - God Mode, Speed, Teleport
- **TxAdmin Integration** - Whitelist
- **Webhook Logging** - Discord Integration
- **Admin Commands** - Stats & Reset
- **Config System** - Zentrale Konfiguration

---

## Legende

- `Added` - Neue Features
- `Changed` - Änderungen an bestehenden Features
- `Deprecated` - Bald zu entfernende Features
- `Removed` - Entfernte Features
- `Fixed` - Bug Fixes
- `Security` - Sicherheits-Fixes
- `Improved` - Performance-Verbesserungen

---

**© 2026 DerStr1k3r**
