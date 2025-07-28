# 🚀 Deployment Guide - MULKY AI OS

This guide provides the steps to deploy the various components of the system.

---

## 1. Google Apps Script

1.  **Open Google Sheets:** Create a new Sheet and paste the `main.gs` code into the Script Editor.
2.  **Set Script Properties:** Go to `File > Project properties > Script properties` and add your `LLM7_API_KEY` and `SPREADSHEET_ID`.
3.  **Deploy as Web App:**
    *   Click `Deploy > New deployment`.
    *   Select `Web app` as the type.
    *   Configure with:
        *   **Execute as:** `Me (your Google account)`
        *   **Who has access:** `Anyone, even anonymous` (if you want the Flutter app to access it publicly) or restrict it as needed.
    *   Copy the generated Web App URL. This is your API endpoint.

---

## 2. Flutter Web App

1.  **Update API URL:** In `flutter_app/lib/services/api_service.dart`, replace `YOUR_GOOGLE_APPS_SCRIPT_WEB_APP_URL` with the URL you copied from the Apps Script deployment.
2.  **Choose a Hosting Provider:**
    *   **Firebase Hosting:**
        *   Follow the Firebase CLI setup instructions.
        *   Run `firebase init hosting`.
        *   Run `flutter build web`.
        *   Run `firebase deploy`.
    *   **Vercel:**
        *   Install the Vercel CLI.
        *   Run `vercel`. The CLI will guide you through the process.

---

## 3. WhatsApp Bot

1.  **Install Dependencies:**
    *   `npm install whatsapp-web.js qrcode-terminal`
2.  **Run the Bot:**
    *   `node whatsapp_bot/index.js`
    *   Scan the QR code that appears in your terminal with your phone's WhatsApp app.
3.  **Hosting:** For persistent uptime, deploy this Node.js app to a service like Heroku, Render, or a VPS.

---

## 4. Backup Logs

1.  **Google Drive:** The `exportSheetToJson` function in the Apps Script can be triggered on a schedule (e.g., daily) to save a JSON backup of your sheets to a specific Google Drive folder. You would add a new function that calls `exportSheetToJson` and saves the result using `DriveApp.createFile()`.
