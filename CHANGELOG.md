# 🚀 CHANGELOG - Dhaher Trading Plan AI™

## v11.1.4 - Institutional Hardening & COT Scraping (2025-03-05)

### 🔥 Major Changes
- **INSTITUTIONAL HARDENING:** Replaced third-party COT API reliance with direct scraping from official CFTC (CME/COMEX) reports.
- **CONSOLIDATED API:** Refactored GAS backend to return a unified `market_data` object, reducing frontend requests and improving latency.
- **PRODUCTION BASELINE:** Established `main` branch as the authoritative v11.1.4 production-ready baseline.

### 🛠️ Backend (GAS) Improvements
- **SCRAPING:** Implemented robust text parsing for deacmcl.txt (CME) and deacmxl.txt (COMEX) to extract real-time non-commercial positioning.
- **SECURITY:** Hardened `doPost` to return 401/JSON errors instead of throwing script exceptions on unauthorized access.
- **LOGIC:** Centralized all technical, news, and sentiment data aggregation within `getAiMasterSummary`.

### 📱 Flutter UI & Service Refactoring
- **CLEANUP:** Removed `NewsFetcher` and `CotService`; all market intelligence now flows through `GptSummarizer`.
- **UI:** Updated `IntelTab` to handle consolidated data structures with fail-safe null defaults.
- **STANDARDS:** Replaced all remaining `withOpacity` calls with `withValues(alpha: ...)` for Material 3 compatibility.
- **FIX:** Corrected `DropdownButtonFormField` usage in `EntryForm` by replacing `initialValue` with `value`.

### 🤖 WhatsApp Bot
- **STABILITY:** Pinned `whatsapp-web.js` to `^1.34.7` to prevent regressions and fixed package-lock synchronization issues.

---

## v11.0.0 - Production Release & Branch Consolidation (2025-03-04)

### 🔥 Major Changes
- **MERGE:** Consolidated the best branch into `mulky-ai-os-v1`, resolving all merge conflicts
- **BRANCH CLEANUP:** Deleted stale remote branches, keeping only `mulky-ai-os-v1` as the single source of truth
- **VERSION BUMP:** Upgraded from v10.5.5-hardened to v11.0.0

### 🐛 Critical Bug Fixes
- **FIX: trading_view_embed.dart** — Replaced web-only imports with conditional imports to enable compilation on both mobile and web platforms
- **FIX: entry_form.dart** — Completed the incomplete stub with a fully functional trade entry form
- **FIX: forecast_tab.dart** — Replaced hardcoded mock `FlSpot` data with dynamic loading from `ForecastService`
- **FIX: consistency_streak_calendar.dart** — Converted from static to dynamic stateful loading of real trade data

---

> **Contact:** Mulky Malikul Dhaher — [mulkymalikudhr@mail.com](mailto:mulkymalikudhr@mail.com)
