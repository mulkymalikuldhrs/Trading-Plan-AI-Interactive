# 🛠️ Quick Setup Guide

Follow these steps to get the **Dhaher Trading Plan AI™** up and running in less than 15 minutes.

## 1. Google Sheets & Apps Script (The Brain)
1. Create a new Google Sheet.
2. Go to `Extensions > Apps Script`.
3. Copy `google_apps_scripts/main.gs` and `google_apps_scripts/api_integrations.gs` into the editor.
4. Go to `Project Settings (⚙️) > Script Properties`.
5. Add the following:
   - `SPREADSHEET_ID`: (Your Sheet ID from URL)
   - `LLM7_API_KEY`: (Get from llm7.io)
   - `FINNHUB_API_KEY`: (Get from finnhub.io)
   - `USER_PHONE_NUMBER`: (e.g., 6285322624048)
   - `WHATSAPP_API_URL`: (Your Bot URL + `/send`)
   - `BOT_API_KEY`: (Any secret string)
6. Click `Deploy > New Deployment > Web App`.
7. Set `Execute as: Me` and `Who has access: Anyone`.
8. **Copy the Web App URL.**

## 2. WhatsApp Bot (The Assistant)
1. Go to `whatsapp_bot/`.
2. Create `.env` based on `.env.example`.
3. Fill in `GOOGLE_APPS_SCRIPT_URL` with the URL from step 1.
4. Run `npm install` then `npm start`.
5. Scan the QR code with your WhatsApp.

## 3. Flutter App (The Dashboard)
1. Go to `flutter_app/`.
2. Run `flutter pub get`.
3. Run the app:
   ```bash
   flutter run --dart-define=GAS_URL=YOUR_WEB_APP_URL
   ```

## 4. Triggers (The Automation)
In Apps Script editor:
1. Run `createWeeklyAnalysisTrigger()` once to schedule weekly reports.
2. Run `createKillzoneReminderTrigger()` once to schedule daily reminders.
3. (Optional) Set up a time-based trigger for `scanForTradeSignals()` to run hourly.
