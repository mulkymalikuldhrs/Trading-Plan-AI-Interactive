<div align="center">
  <img src="https://i.imgur.com/8J5gO6R.png" alt="Dhaher Trading Plan AI Header">
  <h1>🔮 Dhaher Trading Plan AI™</h1>
  <p>
    <b>Your personal AI-powered market intelligence agency.</b>
    <br />
    This is not just a trading journal; it's a proactive, predictive, and psychologically-aware co-pilot designed to help you master the market by mastering yourself.
  </p>
</div>

---

<details>
<summary>🇮🇩 <strong>Baca dalam Bahasa Indonesia</strong></summary>

## 🇮🇩 Panduan Lengkap: Dhaher Trading Plan AI™

Selamat datang di agensi intelijen pasar pribadi Anda. Ini bukan sekadar jurnal trading; ini adalah co-pilot yang **proaktif, prediktif, dan sadar secara psikologis** yang dirancang untuk membantu Anda menguasai pasar dengan menguasai diri sendiri.

### 🚀 **Ritual Harian: Panduan Memulai Cepat**

Sistem ini dirancang untuk digunakan dalam ritual harian untuk membangun disiplin dan kesadaran pasar.

1.  **Pra-Pasar (Pagi):**
    *   Buka tab **`🧠 Market Intel`** untuk mendapatkan briefing harian Anda.
    *   Buka tab **`🔮 Forecast Center`** untuk melihat proyeksi AI untuk hari/minggu ini.
    *   Mengobrol dengan AI: *"Apa yang harus menjadi fokus saya hari ini?"*

2.  **Eksekusi Perdagangan:**
    *   Gunakan **`📋 Entry Planner`** untuk merencanakan perdagangan Anda.
    *   **Selalu** klik **`✅ Confirm with AI`** sebelum memasuki perdagangan.
    *   Tinjau grafik TradingView langsung yang disematkan.

3.  **Pasca-Perdagangan:**
    *   Isi **`📘 Journal`** Anda dengan hasil perdagangan dan emosi Anda.
    *   Tinjau umpan balik AI tentang kinerja Anda.

**Untuk alur kerja A-Z yang lengkap, silakan lihat [Panduan & Tutorial Pengguna Ultimate](docs/TUTORIAL.md).**

### ✨ **Fitur Inti**

-   **🔮 AI Forecast Engine™:** Dapatkan prakiraan pasar beberapa hari yang mensintesis data teknis, fundamental, berita, dan sentimen institusional (COT) menjadi satu tesis perdagangan probabilistik.
-   **🧠 Analis AI Otonom:** AI 24/7 yang memindai pasar, mengidentifikasi penyiapan keyakinan tinggi berdasarkan rencana perdagangan *Anda*, dan mengirimkannya langsung kepada Anda.
-   **📲 Bot WhatsApp Interaktif:** Dapatkan prakiraan, ringkasan, dan sinyal perdagangan saat bepergian. Gunakan perintah sederhana seperti `/forecast GOLD` untuk mendapatkan wawasan instan yang digerakkan oleh AI.
-   **📈 Visualisasi Langsung:** "Dasbor Disiplin" dengan bagan animasi canggih untuk kurva ekuitas, tingkat kemenangan, kinerja penyiapan, dan lainnya.
-   **👁️ Grafik TradingView Tersemat:** Analisis grafik langsung di dalam aplikasi saat merencanakan atau meninjau perdagangan.
-   **🧘‍♂️ Kecerdasan Emosional:** Sistem melacak suasana hati Anda, mengidentifikasi pola emosional, dan memberikan umpan balik gamified dan periode "pendinginan" untuk menegakkan disiplin.
-   **🎤 Obrolan Berkemampuan Suara:** Berinteraksi dengan pelatih AI Anda secara hands-free menggunakan perintah suara alami.
-   **📱 UI yang Sepenuhnya Responsif:** Pengalaman yang mulus di seluruh desktop, tablet, dan seluler.

### 📜 **Filosofi Sistem**

Dhaher Trading Plan AI dibangun di atas satu keyakinan inti: **penguasaan perdagangan sejati berasal dari perpaduan analisis berbasis data dan disiplin psikologis yang tak tergoyahkan.**

### 🛠️ **Panduan Pemasangan & Penyiapan**

#### **Langkah 1: Prasyarat**
-   [Node.js](https://nodejs.org/) (untuk Bot WhatsApp)
-   [Flutter SDK](https://flutter.dev/docs/get-started/install) (untuk Aplikasi Web)
-   Akun Google (untuk Google Sheets & Apps Script)
-   Kunci API dari [NewsAPI.org](https://newsapi.org/) dan [Finnhub.io](https://finnhub.io/)

#### **Langkah 2: Penyiapan Backend (Google Apps Script)**
1.  Buat Google Sheet baru dan beri nama tab sesuai dengan `docs/Dhaher_Trading_Sheet_Template.md`.
2.  Buka `Extensions > Apps Script`.
3.  Salin konten dari `google_apps_scripts/main.gs` dan `google_apps_scripts/api_integrations.gs` ke dalam editor skrip.
4.  Buka `Project Settings > Script Properties` dan tambahkan kunci API Anda (`NEWS_API_KEY`, `FINNHUB_API_KEY`, `LLM7_API_KEY`).
5.  Klik `Deploy > New deployment`. Pilih `Web app` dan berikan akses kepada `Anyone`. Salin URL Aplikasi Web yang dihasilkan.

#### **Langkah 3: Penyiapan Frontend (Aplikasi Flutter)**
1.  Buka `flutter_app/lib/services/api_service.dart`.
2.  Ganti placeholder `_googleAppsScriptUrl` dengan URL Aplikasi Web yang Anda salin.
3.  Jalankan `flutter pub get` untuk menginstal dependensi.
4.  Jalankan `flutter run -d chrome` untuk memulai aplikasi secara lokal.
5.  Untuk membangun versi produksi, jalankan `flutter build web`.

#### **Langkah 4: Penyiapan Bot WhatsApp**
1.  `cd whatsapp_bot`
2.  Jalankan `npm install`.
3.  Jalankan `node main.js`.
4.  Pindai kode QR yang muncul di terminal Anda dengan WhatsApp di ponsel Anda.
5.  Untuk produksi, deploy bot ini ke layanan seperti Heroku atau Render dan perbarui `WHATSAPP_API_URL` di Google Apps Script Anda.

### 👥 **Kredit**

Proyek ini dikonsep dan disutradarai oleh:
**Mulky Malikul Dhaher**
-   **Kontak:** mulkymalikuldhr@mail.com

</details>

<details open>
<summary>🇬🇧 <strong>Read in English</strong></summary>

## 🇬🇧 The Complete Guide: Dhaher Trading Plan AI™

Welcome to your personal AI-powered market intelligence agency. This is not just a trading journal; it's a **proactive, predictive, and psychologically-aware** co-pilot designed to help you master the market by mastering yourself.

### 🚀 **The Daily Ritual: A Quick Start Guide**

This system is designed to be used in a daily ritual to build discipline and market awareness.

1.  **Pre-Market (Morning):**
    *   Open the **`🧠 Market Intel`** tab to get your daily briefing.
    *   Open the **`🔮 Forecast Center`** to see the AI's projection for the day/week.
    *   Chat with the AI: *"What should be my focus today?"*

2.  **Trade Execution:**
    *   Use the **`📋 Entry Planner`** to plan your trade.
    *   **Always** click **`✅ Confirm with AI`** before entering a trade.
    *   Review the live TradingView chart embedded.

3.  **Post-Trade:**
    *   Fill out your **`📘 Journal`** with the trade outcome and your emotions.
    *   Review the AI's feedback on your performance.

**For a complete, A-Z workflow, please see the [Ultimate User Guide & Tutorial](docs/TUTORIAL.md).**

### ✨ **Core Features**

-   **🔮 AI Forecast Engine™:** Get multi-day market forecasts that synthesize technicals, fundamentals, news, and institutional sentiment (COT) into a single, probabilistic trade thesis.
-   **🧠 Autonomous AI Analyst:** A 24/7 AI that scans the markets, identifies high-conviction setups based on *your* trading plan, and sends them directly to you.
-   **📲 Interactive WhatsApp Bot:** Get forecasts, summaries, and trade signals on the go. Use simple commands like `/forecast GOLD` to get instant, AI-driven insights.
-   **📈 Live Visualizations:** A "Dashboard of Discipline" with advanced, animated charts for your equity curve, win rate, setup performance, and more.
-   **👁️ Embedded TradingView Charts:** Analyze live charts directly within the app when planning or reviewing trades.
-   **🧘‍♂️ Emotional Intelligence:** The system tracks your mood, identifies emotional patterns, and provides gamified feedback and "cooldown" periods to enforce discipline.
-   **🎤 Voice-Enabled Chat:** Interact with your AI coach hands-free using natural voice commands.
-   **📱 Fully Responsive UI:** A seamless experience across desktop, tablet, and mobile.

### 📜 **System Philosophy**

The Dhaher Trading Plan AI is built on a single core belief: **true trading mastery comes from a fusion of data-driven analysis and unwavering psychological discipline.**

### 🛠️ **Installation & Setup Guide**

#### **Step 1: Prerequisites**
-   [Node.js](https://nodejs.org/) (for the WhatsApp Bot)
-   [Flutter SDK](https://flutter.dev/docs/get-started/install) (for the Web App)
-   A Google Account (for Google Sheets & Apps Script)
-   API Keys from [NewsAPI.org](https://newsapi.org/) and [Finnhub.io](https://finnhub.io/)

#### **Step 2: Backend Setup (Google Apps Script)**
1.  Create a new Google Sheet and name the tabs according to `docs/Dhaher_Trading_Sheet_Template.md`.
2.  Open `Extensions > Apps Script`.
3.  Copy the contents of `google_apps_scripts/main.gs` and `google_apps_scripts/api_integrations.gs` into the script editor.
4.  Go to `Project Settings > Script Properties` and add your API keys (`NEWS_API_KEY`, `FINNHUB_API_KEY`, `LLM7_API_KEY`).
5.  Click `Deploy > New deployment`. Choose `Web app` and grant access to `Anyone`. Copy the generated Web App URL.

#### **Step 3: Frontend Setup (Flutter App)**
1.  Open `flutter_app/lib/services/api_service.dart`.
2.  Replace the `_googleAppsScriptUrl` placeholder with your copied Web App URL.
3.  Run `flutter pub get` to install dependencies.
4.  Run `flutter run -d chrome` to start the app locally.
5.  To build a production version, run `flutter build web`.

#### **Step 4: WhatsApp Bot Setup**
1.  `cd whatsapp_bot`
2.  Run `npm install`.
3.  Run `node main.js`.
4.  Scan the QR code in your terminal with WhatsApp on your phone.
5.  For production, deploy this bot to a service like Heroku or Render and update the `WHATSAPP_API_URL` in your Google Apps Script.

### 👥 **Credits**

This project was conceptualized and directed by:
**Mulky Malikul Dhaher**
-   **Contact:** mulkymalikuldhr@mail.com

</details>
