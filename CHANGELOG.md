# 🚀 CHANGELOG - Dhaher Trading Plan AI™

## v10.2.1 - Intelligence Unification & Refinement
- **🧠 UNIFIED INTEL:** Refactored Flutter 'IntelTab' and 'GptSummarizer' to use a single backend call ('getAiMasterSummary'), reducing latency and ensuring data consistency.
- **🧹 CLEANUP:** Removed redundant 'NewsFetcher' and 'CotService' from Flutter. Deleted 'whatsapp_bot/main.js' and legacy setup scripts.
- **🛡️ BACKEND:** Enhanced Google Apps Script to return structured raw market data alongside AI analysis.
- **✨ UI/UX:** Verified Material 3 compatibility, fixed '.withOpacity' deprecations, and improved memory management by disposing of controllers.
- **🆙 SDK:** Upgraded Flutter SDK constraints to 3.5.0+ to support modern APIs.

## v10.2.0 - Final Consolidation & Branch Sync
- **🔄 SYNC:** Successfully consolidated all development branches (v10.0.0 and v10.1.0) into a single, unified codebase.
- **🆙 DEPENDENCIES:** Ensured all components use the latest production-ready dependencies.
- **🧹 CLEANUP:** Enforced clean architecture by removing redundant entry points and artifacts.

## v10.1.0 - Post-Consolidation Upgrade
- **🆙 LATEST DEPENDENCIES:** Upgraded WhatsApp Bot dependencies to their absolute latest versions (Express 5.2.1+, WhatsApp-web.js 1.34.6+, etc.) for maximum stability and security.
- **✅ VERIFICATION:** Verified project integrity across all components (Flutter, Bot, Python, GAS) after the major v10 merger.

## v10.0.0 - Production Readiness Consolidation & Dependency Upgrade
- **🚀 CONSOLIDATION:** Successfully consolidated multiple development branches into the primary `main` branch, ensuring a unified and production-ready codebase.
- **🛡️ SECURITY & CONFIG:** Updated `DEPLOYMENT.md` and `SETUP.md` to emphasize environment-variable-driven configuration (via `--dart-define` for Flutter and `.env` for WhatsApp bot), adhering to the new `AGENTS.md` guidelines.
- **🆙 DEPENDENCY UPGRADES:**
  - **Flutter:** Upgraded to SDK `>=3.0.0 <4.0.0` with updated core dependencies.
  - **WhatsApp Bot:** Updated Node.js dependencies and consolidated entry points to `index.js`.
  - **Python Client:** Bumped `requests>=2.32.5` and `pandas>=3.0.1` for improved performance and security.
- **🧩 ARCHITECTURE:** Standardized Google Apps Script modules (`main.gs` and `api_integrations.gs`) with advanced symbol normalization and comprehensive market data aggregation.
- **📚 DOCUMENTATION:** Refined `AGENTS.md`, `README.md`, and `DEPLOYMENT.md` for better developer onboarding and production deployment.

## v9.1.0 - Installer Patch & Enhancement
- **🔧 FIX:** Corrected a major oversight in the setup scripts. The installers (`setup.sh` and `setup.bat`) now automatically install Python dependencies from `python_client/requirements.txt` using pip.
- **✨ ENHANCEMENT:** The setup process is now truly "All-in-One", providing a much smoother user onboarding experience.
- **📚 DOCS:** Updated the `installer_guide.md` and `README.md` to reflect the new, fully automated setup process.

## v9.0.0 - Programmatic Access: Python Client & Google Colab
- **🐍 PYTHON CLIENT:** Introduced a new `python_client` that allows for full programmatic interaction with the backend.
- **🔬 GOOGLE COLAB NOTEBOOK:** Added a `Dhaher_AI_Colab_Notebook.ipynb` file for interactive analysis.

## v8.0.0 - The All-in-One Installer & Launcher Update
- **🚀 ONE-CLICK SETUP & LAUNCH:** Added automated setup and launcher scripts.

## v7.0.0 - The Ultimate Documentation & Onboarding Update
- **🌍 BILINGUAL README:** The `README.md` is now fully bilingual with comprehensive setup guides.

## v6.0.0 - The Ultimate User Guide
- **📚 ULTIMATE USER GUIDE:** Added a `TUTORIAL.md` file.

## v5.0.0 - Project Rebranding
- **✨ BRANDING:** Rebranded the project to "Dhaher Trading Plan AI".

## v4.0.0 - The Mind Expansion Module
- **✨ MARKET INTELLIGENCE HUB:** Introduced the "Market Intel" tab.

## v3.0.0 - The Visual Intelligence & Gamification Update
- **✨ ADVANCED VISUALIZATIONS & GAMIFIED DISCIPLINE.**

## v2.0.0 - The AI Analyst Update
- **✨ AUTONOMOUS SIGNAL GENERATION.**

## v1.0.0 - Production Release
- **✅ FULLY RESPONSIVE UI & VOICE-ENABLED CHATBOT.**

## v0.1.0 - The Genesis Build
- **✅ PROJECT INIT:** Initialized the A-Z project structure.
