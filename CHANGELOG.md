# 🚀 CHANGELOG - Dhaher Trading Plan AI™

## v11.1.0 - Production Baseline Hardening & Institutional Data (2025-03-05)

### 🔥 Major Changes
- **INSTITUTIONAL DATA:** Implemented direct scraping of raw Commitment of Traders (COT) reports from CFTC (CME/COMEX) websites.
- **CONSOLIDATION:** Finalized the merge of v11.1.0-hardened production baseline into `main`.
- **ARCHITECTURE:** Centralized all market intelligence (technicals, news, COT) into a single `getAiMasterSummary` action in GAS.

### 🐛 Bug Fixes & Refinement
- **FIX: intel_tab.dart** — Streamlined UI to consume consolidated intelligence from GAS; added null-safe defaults and async-safe state updates.
- **FIX: entry_form.dart** — Updated typography and color usage to Material 3 standards; resolved merge conflicts.
- **FIX: api_integrations.gs** — Fortified COT parser with global date matching and heuristic row detection.

### 🔐 Security
- Strict `BOT_API_KEY` verification enforced for all GAS actions.
- No hardcoded secrets; utilizes `PropertiesService` and `--dart-define`.

### 📝 Documentation
- **VERSION:** Updated to 11.1.0.
- **TODO.md:** Marked Phase 5 as 100% complete.
- **README.md:** Updated references to institutional data sourcing.

---

## v11.0.0 - Production Release & Branch Consolidation (2025-03-04)

### 🔥 Major Changes
- **MERGE:** Consolidated the best branch (`consolidate-and-upgrade-to-v10-5-5-hardened-baseline-verified-final-consolidated-production-ready`) into `mulky-ai-os-v1`, resolving all merge conflicts
- **BRANCH CLEANUP:** Deleted 50 stale remote branches, keeping only `mulky-ai-os-v1` as the single source of truth
- **VERSION BUMP:** Upgraded from v10.5.5-hardened to v11.0.0

### 🐛 Critical Bug Fixes
- **FIX: trading_view_embed.dart** — Replaced `dart:ui_web` and `dart:html` web-only imports with conditional imports (`trading_view_embed_stub.dart` / `trading_view_embed_web.dart`) to enable compilation on both mobile and web platforms
- **FIX: entry_form.dart** — Completed the incomplete stub with a fully functional trade entry form including: asset/direction/entry/SL/TP fields, RRR calculation, mood selector, AI validation, live chart toggle, and trade logging
- **FIX: forecast_tab.dart** — Replaced hardcoded mock `FlSpot` data with dynamic loading from `ForecastService` API, including proper empty states and error handling
- **FIX: consistency_streak_calendar.dart** — Converted from static `StatelessWidget` with empty dataset to `StatefulWidget` that loads real trade data from `ApiService.exportSheet()`, with empty state and legend
- **FIX: mood_selector.dart** — Replaced invalid `initialValue` property with `value` on `DropdownButtonFormField`
- **FIX: sheet_api.dart** — Added `logTradeFromMap()` method to support flexible trade data submission from EntryForm

### 🔐 Security
- All API keys use environment variables only (`String.fromEnvironment` for Flutter, `PropertiesService.getScriptProperties()` for GAS)
- Backend enforces `BOT_API_KEY` authentication on all actions
- No hardcoded secrets in source code

### 📝 Documentation
- **README.md** — Updated to v11.0.0 with production-ready badges, architecture table, security section, and trilingual disclaimer (EN/ID/CN)
- **CHANGELOG.md** — Added v11.0.0 release notes

### 🧹 Cleanup
- Removed 50 stale remote branches
- Eliminated all remaining mock/dummy data patterns
- All chart components load real data from API with proper error/empty states

---

> **Contact:** Mulky Malikul Dhaher — [mulkymalikuldhaher@email.com](mailto:mulkymalikuldhaher@email.com)
>
> **Disclaimer:** This project is for Education Purpose only. Risiko apapun tidak kita tanggung. (We are not responsible for any risks or damages.)
