# 🤖 AGENTS.md - Developer & AI Agent Guidelines

This document provides architectural context and maintenance rules for the Dhaher Trading Plan AI project.

## 🏗️ Architecture Overview

The project consists of four main components:
1.  **Google Apps Script (GAS)**: The "brain" and database. It handles trade logging, GPT analysis, data aggregation, and autonomous triggers.
2.  **Flutter App**: The primary user interface for journal entry, dashboard visualization, and AI chat.
3.  **WhatsApp Bot**: A Node.js/Express service that provides a mobile interface for commands and receives notifications from GAS.
4.  **Python Client**: A tool for programmatic access, analysis, and backtesting.

## 📜 Coding Standards & Principles

-   **No Mocks/Simulations**: All components must interact with real data and real APIs. Do not use placeholders for production logic.
-   **Security**: API keys and sensitive URLs must never be hardcoded. Use Script Properties (GAS), Environment Variables (Bot/Python), or `--dart-define` (Flutter). The `setup.sh` and `launch.sh` scripts facilitate this by managing a central `.env` file and passing variables at runtime.
-   **Autonomy**: The system is designed to be proactive. Triggers in GAS should handle scanning and reminders without manual user intervention.
-   **Clean YAML**: Ensure `pubspec.yaml` and other config files are well-formatted and free of duplication.

## 🛠️ Maintenance Tasks

-   **GAS Deployment**: When updating GAS files, a "New Version" must be deployed for changes to take effect on the Web App URL.
-   **API Keys**: Monitor the usage of Finnhub and LLM7 APIs. Ensure keys are valid and properly set in Script Properties.
-   **WhatsApp Session**: The bot uses `LocalAuth`. If authentication fails, delete the `.wwebjs_auth` folder and re-scan the QR code.

## 🚫 Negative Constraints (What to Avoid)

-   Missing files or inconsistent logic across platforms.
-   Low-quality, non-descriptive error messages.
-   Simulation data in the dashboard; always fetch from the `Journal` sheet.
-   Non-production-ready code in the `main` branch.

---
*Created by Mulky Malikul Dhaher. Maintained by autonomous agents.*
