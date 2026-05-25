# 🤖 AGENTS.md - Development & Maintenance Rules

## Architecture Overview
This project, **Mulky AI OS (TradingPlan Interactive)**, is a multi-component intelligence agency for traders.

- **Frontend:** Flutter Web/Mobile (Material 3).
- **Backend:** Google Apps Script (GAS) acting as a serverless API and Database (Google Sheets).
- **Automation:** Node.js WhatsApp Bot (whatsapp-web.js).
- **Analysis:** OpenAI GPT-4o via GAS.

## Strict Maintenance Rules
1. **NO MOCKS:** All data must be real or derived from real sources (GAS/Finnhub/NewsAPI). Mocking is strictly prohibited in production branches.
2. **CENTRALIZED LOGIC:** AI analysis and data aggregation MUST happen in the GAS backend (`google_apps_scripts/`). Frontend services should only call the backend.
3. **SECURITY:** Never hardcode API keys. Use `PropertiesService` in GAS, `process.env` in Node.js, and `--dart-define` in Flutter.
4. **VERSIONING:** Always update the root `VERSION` file and `CHANGELOG.md` after significant changes.
5. **UI STANDARDS:** Follow Material 3 guidelines. Use `withValues(alpha: ...)` instead of the deprecated `withOpacity`.

## Verification Commands
- **Flutter:** `cd flutter_app && flutter analyze`
- **WhatsApp Bot:** `cd whatsapp_bot && node --check index.js`
- **Python:** `python3 -m py_compile python_client/dhaher_ai_client.py`
- **Audit:** `grep -riE "mock|simulation" . | grep -v "node_modules" | grep -v "CHANGELOG.md"`

---

> **Contact:** Mulky Malikul Dhaher — [mulkymalikuldhaher@email.com](mailto:mulkymalikuldhaher@email.com)
>
> **Disclaimer:** This project is for Education Purpose only. Risiko apapun tidak kita tanggung. (We are not responsible for any risks or damages.)
