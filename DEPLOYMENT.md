# 🚀 Deployment Guide - Dhaher Trading Plan AI™

This guide provides the steps to deploy the various components of the system.

---

## 1. Google Apps Script

1.  **Open Google Sheets:** Create a new Sheet and paste the `main.gs` and `api_integrations.gs` code into the Script Editor.
2.  **Set Script Properties:** Go to **Project Settings > Script Properties** and add the following keys:
    *   `SPREADSHEET_ID`: Your Google Sheet ID.
    *   `LLM7_API_KEY`: Your LLM7.io API Key.
    *   `LLM7_API_URL`: `https://api.llm7.io/v1/chat/completions` (Default)
    *   `WHATSAPP_API_URL`: URL of your deployed WhatsApp bot (e.g., `https://your-bot.render.com/send`).
    *   `BOT_API_KEY`: A secret key shared between GAS and the Bot.
    *   `USER_PHONE_NUMBER`: Your phone number in international format (e.g., `62812345678`).
    *   `FINNHUB_API_KEY`: Your Finnhub.io API Key for market data.
3.  **Deploy as Web App:**
    *   Click **Deploy > New deployment**.
    *   Select **Web app** as the type.
    *   Set **Execute as** to `Me` and **Who has access** to `Anyone`.
    *   Copy the **Web App URL**.

---

## 2. Flutter Web/Mobile App

1.  **Build with Environment Variable:** The app expects the `GAS_URL` to be defined at build time.
    *   **Run:** `flutter run --dart-define=GAS_URL=YOUR_GAS_WEB_APP_URL`
    *   **Build Web:** `flutter build web --dart-define=GAS_URL=YOUR_GAS_WEB_APP_URL`
    *   **Build Android:** `flutter build apk --dart-define=GAS_URL=YOUR_GAS_WEB_APP_URL`

---

## 3. WhatsApp Bot (Node.js)

1.  **Environment Variables:** Create a `.env` file in the `whatsapp_bot` directory (the `setup.sh` script does this automatically):
    ```env
    PORT=3000
    GAS_URL=YOUR_GAS_WEB_APP_URL
    API_KEY=YOUR_SHARED_BOT_API_KEY
    ```
2.  **Install & Run:**
    ```bash
    cd whatsapp_bot
    npm install
    node index.js
    ```
3.  **Authentication:** Scan the QR code in the terminal to link your WhatsApp account.
