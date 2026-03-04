# 🚀 Dhaher Trading Plan AI - Setup Guide

Follow these steps to deploy and configure your personal AI market intelligence agency.

## 1. Google Apps Script (Backend)

1.  Create a new Google Sheet.
2.  Go to `Extensions` > `Apps Script`.
3.  Copy the contents of `google_apps_scripts/main.gs` and `google_apps_scripts/api_integrations.gs` into your script editor.
4.  Go to `Project Settings` (gear icon) and add the following **Script Properties**:
    - `SPREADSHEET_ID`: Your Google Sheet ID.
    - `LLM7_API_KEY`: Your API key for LLM7.
    - `FINNHUB_API_KEY`: Your API key from Finnhub.io.
    - `WHATSAPP_API_URL`: The URL where your WhatsApp bot is running (e.g., `https://your-bot-url.com/send`).
    - `BOT_API_KEY`: A secret key for secure bot communication.
    - `USER_PHONE_NUMBER`: Your WhatsApp phone number (in international format, e.g., `6285322624048`).
5.  Click `Deploy` > `New Deployment`.
    - Select `Web App`.
    - Set `Execute as` to `Me`.
    - Set `Who has access` to `Anyone`.
6.  Copy the **Web App URL**. You will need this for the WhatsApp bot and Flutter app.

## 2. WhatsApp Bot

1.  Navigate to the `whatsapp_bot/` directory.
2.  Install dependencies: `npm install`.
3.  Copy `.env.example` to `.env` and fill in:
    - `GAS_URL`: The Web App URL from step 1.
    - `API_KEY`: The same `BOT_API_KEY` you set in Script Properties.
4.  Start the bot: `npm start`.
5.  Scan the QR code displayed in the terminal with your WhatsApp.

## 3. Flutter Application

1.  Navigate to the `flutter_app/` directory.
2.  Install dependencies: `flutter pub get`.
3.  Run or build the app using the `GAS_URL` define:
    ```bash
    flutter run --dart-define=GAS_URL=https://script.google.com/macros/s/.../exec
    ```

## 4. Python Client (Optional)

1.  Navigate to the `python_client/` directory.
2.  Install dependencies: `pip install -r requirements.txt`.
3.  Set the `GAS_URL` environment variable or pass it to the `DhaherAiClient` constructor.

---
**Note:** Ensure all sheets (Journal, AI Feedback, Violations, Weekly Summary, Settings, Trading Plan) exist in your Google Sheet for full functionality.
