# Instructions for AI Agents

Welcome to the **Dhaher Trading Plan AI™** codebase. This is a production-ready system. Please follow these guidelines when working on this project:

## Architecture
1. **Google Apps Script (GAS)**: The central hub. It handles database operations (Google Sheets), AI reasoning (LLM7), and market data (Finnhub).
2. **Flutter App**: The frontend. It MUST be built with `--dart-define=GAS_URL=...`. Never hardcode the GAS URL in `api_service.dart`.
3. **WhatsApp Bot**: The mobile assistant. It interacts with GAS via POST requests and is secured with an `API_KEY`.

## Coding Standards
- **No Mocks**: Do not use mock data or simulations. Always use real API calls or configuration-driven fallbacks.
- **Security**: Never hardcode API keys or sensitive URLs. Use `ScriptProperties` in GAS, `.env` in the WhatsApp bot, and `dart-define` in Flutter.
- **Consistency**: Maintain the established JSON response structures. GAS should always return `{ "status": "success", "data": ... }` or `{ "status": "error", "message": ... }`.

## Maintenance
- When updating GAS, ensure `doPost` handles the new actions correctly.
- When updating the WhatsApp bot, ensure new commands are added to the `commandHandlers` map in `index.js`.
- Always verify dependency resolution in `flutter_app/`, `whatsapp_bot/`, and `python_client/`.

## Deployment
Refer to `SETUP.md` and `DEPLOYMENT.md` for full instructions.
