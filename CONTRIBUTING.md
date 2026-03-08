# Contributing to RedM Anticheat System

Vielen Dank für dein Interesse, zum RedM Anticheat System beizutragen! 🎉

## 📋 Code of Conduct

Bitte sei respektvoll und konstruktiv in allen Interaktionen.

## 🐛 Bug Reports

### Bevor du einen Bug meldest:
1. Prüfe, ob der Bug bereits gemeldet wurde
2. Stelle sicher, dass du die neueste Version verwendest
3. Sammle relevante Informationen

### Bug Report Template:
```markdown
**Beschreibung:**
Eine klare Beschreibung des Bugs.

**Schritte zur Reproduktion:**
1. Gehe zu '...'
2. Klicke auf '...'
3. Scrolle nach '...'
4. Siehe Fehler

**Erwartetes Verhalten:**
Was sollte passieren?

**Tatsächliches Verhalten:**
Was passiert stattdessen?

**Screenshots:**
Falls zutreffend, füge Screenshots hinzu.

**Umgebung:**
- RedM Version: [z.B. Build 1355]
- Anticheat Version: [z.B. 5.0.0]
- Server OS: [z.B. Windows/Linux]
- Spieleranzahl: [z.B. 50]

**Zusätzlicher Kontext:**
Weitere relevante Informationen.
```

## 💡 Feature Requests

### Feature Request Template:
```markdown
**Problem:**
Welches Problem löst dieses Feature?

**Lösung:**
Beschreibe die gewünschte Lösung.

**Alternativen:**
Hast du alternative Lösungen in Betracht gezogen?

**Zusätzlicher Kontext:**
Screenshots, Mockups, etc.
```

## 🔧 Pull Requests

### Bevor du einen PR erstellst:
1. Fork das Repository
2. Erstelle einen Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Committe deine Änderungen (`git commit -m 'Add some AmazingFeature'`)
4. Push zum Branch (`git push origin feature/AmazingFeature`)
5. Öffne einen Pull Request

### PR Guidelines:
- Beschreibe deine Änderungen klar
- Referenziere relevante Issues
- Füge Tests hinzu (falls zutreffend)
- Aktualisiere die Dokumentation
- Folge dem Code Style

## 📝 Code Style

### Lua Conventions:
```lua
-- Variablen: camelCase
local playerData = {}

-- Funktionen: PascalCase für Module, camelCase für lokale
function Utils.GetPlayerInfo(source)
    local function helperFunction()
        -- ...
    end
end

-- Konstanten: UPPER_CASE
local MAX_VIOLATIONS = 5

-- Kommentare: Deutsch oder Englisch, konsistent
-- Gute Kommentare erklären WARUM, nicht WAS
```

### File Structure:
```lua
--[[
    RedM Anticheat System - Module Name
    © 2026 DerStr1k3r
--]]

ModuleName = {}

-- ═══════════════════════════════════════════════════════════
--  SECTION NAME
-- ═══════════════════════════════════════════════════════════

function ModuleName.FunctionName()
    -- Implementation
end

return ModuleName
```

## 🧪 Testing

### Vor dem Commit:
1. Teste alle Änderungen gründlich
2. Prüfe auf Syntax-Fehler
3. Teste mit verschiedenen Spielerzahlen
4. Prüfe Performance-Impact

### Test Checklist:
- [ ] Keine Lua-Fehler
- [ ] Performance akzeptabel
- [ ] Keine False Positives
- [ ] Dokumentation aktualisiert
- [ ] Config-Optionen getestet

## 📚 Dokumentation

### Was dokumentieren:
- Neue Features
- API-Änderungen
- Config-Optionen
- Admin Commands
- Breaking Changes

### Wo dokumentieren:
- README.md - Hauptdokumentation
- CHANGELOG.md - Änderungen
- Code-Kommentare - Implementation Details
- Wiki - Ausführliche Guides

## 🏷️ Commit Messages

### Format:
```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types:
- `feat` - Neues Feature
- `fix` - Bug Fix
- `docs` - Dokumentation
- `style` - Formatierung
- `refactor` - Code Refactoring
- `perf` - Performance-Verbesserung
- `test` - Tests
- `chore` - Maintenance

### Beispiele:
```
feat(ml-scoring): Add Z-Score analysis for speed detection

Implements statistical anomaly detection using Z-Scores
to reduce false positives in speed hack detection.

Closes #123
```

```
fix(database): Prevent memory leak in violation history

Fixed issue where old violations were not properly
cleaned up, causing memory usage to grow over time.

Fixes #456
```

## 🎯 Priority Labels

- `critical` - Kritische Bugs, sofortige Aufmerksamkeit
- `high` - Wichtige Features/Bugs
- `medium` - Standard Priority
- `low` - Nice-to-have
- `enhancement` - Feature Requests
- `bug` - Bug Reports
- `documentation` - Dokumentation
- `help wanted` - Community-Hilfe erwünscht

## 🤝 Community

### Wo du helfen kannst:
- Bug Reports & Testing
- Feature Suggestions
- Dokumentation verbessern
- Code Reviews
- Community Support
- Übersetzungen

### Kommunikation:
- GitHub Issues - Bug Reports & Features
- GitHub Discussions - Allgemeine Diskussionen
- Discord - Community Chat
- Email - Direkte Anfragen

## 📜 Lizenz

Durch deine Beiträge stimmst du zu, dass deine Arbeit unter der MIT License lizenziert wird.

---

**Vielen Dank für deine Beiträge! 🙏**

© 2026 DerStr1k3r
