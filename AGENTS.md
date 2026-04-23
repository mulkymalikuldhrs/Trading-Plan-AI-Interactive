# 🤖 Agent Instructions - Mulky AI OS

## 🎯 Purpose
This repository is the authoritative production baseline for the **Dhaher Trading Plan AI (Mulky AI OS)**. It is a high-performance, AI-driven trading intelligence ecosystem.

## 🛡️ Hardened Standards
1. **NO MOCKS:** All services must use real data sources (Google Apps Script, Finnhub, NewsAPI, etc.). Mock data or "dummy modes" are strictly prohibited in the production branch.
2. **SECURITY:** Sensitive keys must NEVER be hardcoded.
   - **GAS:** Use `PropertiesService.getScriptProperties()`.
   - **Flutter:** Use `--dart-define` via `String.fromEnvironment`.
   - **Bot:** Use `process.env`.
3. **VERSIONING:** The `VERSION` file at the root is the source of truth for the system version. Currently at `10.4.2-hardened`.
4. **ARCHITECTURE:**
   - **Backend:** Google Apps Script (`google_apps_scripts/`) handles LLM orchestration, database (Sheets) interaction, and external API fetching.
   - **Frontend:** Flutter Web (`flutter_app/`) is the primary user interface.
   - **Bot:** Node.js WhatsApp Bot (`whatsapp_bot/index.js`) provides mobile interaction.

## 🛠️ Maintenance & Deployment
- **Flutter Build:** `flutter build web --dart-define=GAS_URL=... --dart-define=API_KEY=...`
- **Bot Launch:** `GAS_URL=... BOT_API_KEY=... node index.js`
- **Verification:** Always run `flutter analyze` and `node --check index.js` before submitting changes.

## 🚀 Autonomous Intelligence
The system is designed for autonomous operation. The `scanForTradeSignals` function in GAS and the WhatsApp bot command handlers are the primary agents for proactive market analysis.
