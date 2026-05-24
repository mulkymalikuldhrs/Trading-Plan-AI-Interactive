# Arsitektur Dhaher Trading Plan AI™

> Dokumentasi arsitektur sistem untuk Dhaher Trading Plan AI Interactive

---

## Ikhtisar Arsitektur

Dhaher Trading Plan AI menggunakan arsitektur multi-platform yang mengintegrasikan beberapa komponen untuk memberikan pengalaman trading yang komprehensif. Sistem dirancang dengan prinsip modularitas, memungkinkan setiap komponen beroperasi secara independen sambil tetap terintegrasi melalui antarmuka yang jelas.

```
┌─────────────────────────────────────────────────────────────┐
│                  DHAHER TRADING PLAN AI™                     │
│                                                             │
│  ┌───────────────────────────────────────────────────────┐  │
│  │                    CLIENT LAYER                        │  │
│  │  ┌─────────────┐  ┌─────────────┐  ┌──────────────┐  │  │
│  │  │ Flutter App │  │ WhatsApp Bot│  │ Python Client│  │  │
│  │  │ (Mobile)    │  │ (Node.js)   │  │ (CLI/Colab)  │  │  │
│  │  └─────────────┘  └─────────────┘  └──────────────┘  │  │
│  └───────────────────────────────────────────────────────┘  │
│                           │                                 │
│  ┌───────────────────────────────────────────────────────┐  │
│  │                 INTEGRATION LAYER                      │  │
│  │  ┌─────────────┐  ┌─────────────┐  ┌──────────────┐  │  │
│  │  │ Google Apps │  │ GPT Service │  │ Market Data  │  │  │
│  │  │ Scripts     │  │ (OpenAI)    │  │ APIs         │  │  │
│  │  └─────────────┘  └─────────────┘  └──────────────┘  │  │
│  └───────────────────────────────────────────────────────┘  │
│                           │                                 │
│  ┌───────────────────────────────────────────────────────┐  │
│  │                   AI ENGINE LAYER                      │  │
│  │  ┌─────────────────────────────────────────────────┐  │  │
│  │  │ AI Forecast Engine™ │ Emotional Intelligence    │  │  │
│  │  │ Autonomous Analyst  │ Voice Chat (CoT)          │  │  │
│  │  └─────────────────────────────────────────────────┘  │  │
│  └───────────────────────────────────────────────────────┘  │
│                           │                                 │
│  ┌───────────────────────────────────────────────────────┐  │
│  │                   DATA LAYER                           │  │
│  │  ┌─────────────┐  ┌─────────────┐  ┌──────────────┐  │  │
│  │  │ Google      │  │ Trading     │  │ News &       │  │  │
│  │  │ Sheets      │  │ Journal     │  │ Sentiment    │  │  │
│  │  └─────────────┘  └─────────────┘  └──────────────┘  │  │
│  └───────────────────────────────────────────────────────┘  │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## Komponen Utama

### 1. Flutter App (Mobile)

Aplikasi mobile cross-platform yang dibangun dengan Flutter untuk iOS dan Android. Aplikasi ini adalah antarmuka utama pengguna dan menyediakan pengalaman native-like dengan fitur-fitur berikut:

- **Dashboard Page**: Menampilkan ringkasan performa trading, equity chart, dan metrik kunci
- **Entry Page**: Form pencatatan trade dengan validasi dan saran AI
- **Chat Page**: Antarmuka chat dengan AI coach yang mendukung teks dan suara
- **Journal Page**: Jurnal trading dengan mood tracking dan evaluasi disiplin
- **Forecast Tab**: Prakiraan pasar multi-hari dari AI Forecast Engine
- **Intel Tab**: Hub intelijen pasar dengan berita dan analisis
- **Risk Page**: Kalkulator risiko dan analisis portofolio

**Komponen Kunci:**
- `equity_chart.dart`: Visualisasi equity curve animasi
- `mood_selector.dart`: Pemilih suasana hati dengan feedback gamified
- `forecast_chart.dart`: Grafik prakiraan pasar
- `trading_view_embed.dart`: Widget TradingView tersemat
- `consistency_streak_calendar.dart`: Kalender streak konsistensi
- `ai_chatbox.dart`: Chat AI dengan kemampuan suara

**Layanan:**
- `gpt_service.dart`: Integrasi dengan OpenAI GPT API
- `forecast_service.dart`: Layanan prakiraan pasar
- `emotional_lockout_service.dart`: Lockout otomatis saat emosional
- `sheet_api.dart`: Integrasi dengan Google Sheets API
- `news_fetcher.dart`: Pengambil berita pasar
- `whatsapp_trigger.dart`: Trigger notifikasi WhatsApp

### 2. Google Apps Scripts

Backend ringan yang berjalan di Google Cloud, mengelola logika bisnis dan integrasi data:

- **main.gs**: Script utama yang menangani routing dan logika bisnis
- **api_integrations.gs**: Integrasi dengan API eksternal (market data, news, sentiment)

Google Sheets berfungsi sebagai database ringan, menyimpan data trading journal, konfigurasi pengguna, dan hasil prakiraan. Pendekatan ini dipilih karena kemudahan akses dan biaya operasional yang rendah.

### 3. WhatsApp Bot (Node.js)

Bot WhatsApp yang menyediakan antarmuka chat untuk akses mobile cepat:

- **index.js**: Entry point dan konfigurasi bot
- **main.js**: Logika penanganan pesan dan routing perintah

Bot mendukung perintah-perintah berikut:
- `/forecast` — Dapatkan prakiraan pasar
- `/signal` — Dapatkan sinyal trading terbaru
- `/analyze [symbol]` — Analisis simbol tertentu
- `/journal` — Catat entry trading baru
- `/status` — Cek status portofolio

### 4. Python Client

Klien programatik untuk akses tingkat lanjut:

- **dhaher_ai_client.py**: Klien Python dengan dukungan untuk Google Colab
- **requirements.txt**: Dependensi Python yang diperlukan

Python client memungkinkan:
- Akses terprogram ke semua fitur AI
- Backtesting strategi trading
- Analisis data historis
- Integrasi dengan workflow Python yang sudah ada
- Eksekusi dari Google Colab untuk komputasi cloud

---

## AI Engine Layer

### AI Forecast Engine™

Mesin prakiraan menggunakan pendekatan multi-faktor:

1. **Technical Analysis**: Indikator teknikal (MA, RSI, MACD, Bollinger Bands)
2. **Fundamental Analysis**: Data ekonomi dan laporan keuangan
3. **News Sentiment**: Analisis sentimen dari berita pasar terkini
4. **COT Data**: Commitment of Traders data untuk sentimen institusional

Hasil prakiraan mencakup:
- Arah pasar (bullish/bearish/neutral)
- Tingkat keyakinan (0-100%)
- Rentang harga yang diprediksi
- Skenario alternatif
- Rekomendasi tindakan

### Emotional Intelligence System

Sistem kecerdasan emosional memantau dan mengelola aspek psikologis trading:

- **Mood Tracking**: Pencatatan suasana hati sebelum dan sesudah trading
- **Pattern Detection**: Identifikasi pola perilaku yang merugikan
- **Emotional Lockout**: Nonaktifkan trading saat emosi tidak stabil
- **Gamified Feedback**: Sistem pencapaian dan streak untuk motivasi disiplin
- **CoT (Chain of Thought)**: Proses berpikir AI yang transparan untuk build trust

### Autonomous Analyst

AI analyst yang berjalan 24/7:

- Pemindaian pasar otomatis pada interval terjadwal
- Identifikasi penyiapan keyakinan tinggi berdasarkan kriteria yang dikonfigurasi
- Notifikasi proaktif saat peluang ditemukan
- Analisis mendalam termasuk entry point, target, dan stop loss

---

## Data Layer

### Google Sheets

Digunakan sebagai database ringan dengan keuntungan:
- Akses mudah dari mana saja
- Biaya operasional nol
- Integrasi native dengan Google Apps Scripts
- Visualisasi data langsung di spreadsheet

### Trading Journal

Data jurnal trading mencakup:
- Entri trade dengan timestamp, simbol, arah, ukuran posisi
- Exit trade dengan profit/loss, durasi, dan evaluasi
- Mood dan emosi saat entry dan exit
- Analisis kepatuhan terhadap rencana trading

### News & Sentiment

Data pasar dan sentimen:
- Berita pasar real-time dari berbagai sumber
- Analisis sentimen otomatis menggunakan NLP
- Data kalender ekonomi
- Commitment of Traders (COT) data

---

## Alur Data

### Alur Prediksi Pasar

```
User Request → Flutter App / WhatsApp / Python Client
    → Integration Layer (Google Apps Scripts)
    → GPT Service (OpenAI API)
    → Market Data APIs (Prices, News, COT)
    → AI Forecast Engine (Multi-factor Analysis)
    → Response → User
```

### Alur Pencatatan Trade

```
Trade Entry → Flutter App
    → Google Sheets API (Data Storage)
    → Emotional Intelligence Check
    → Journal Update
    → Performance Metrics Calculation
    → Dashboard Visualization Update
```

---

## Deployment

### Web & Desktop

Menggunakan launcher otomatis yang mengkonfigurasi environment dan menjalankan aplikasi. Lihat [Panduan Pemasang](docs/installer_guide.md) untuk detail.

### Android

Build Flutter APK untuk deployment di perangkat Android. Lihat [Panduan Android](docs/android_deployment.md) untuk detail.

### Python / Colab

Instalasi klien Python untuk akses terprogram. Lihat [Panduan Python](docs/python_client_guide.md) untuk detail.

---

## Keamanan

- API keys disimpan secara aman di environment variables
- Komunikasi dengan API menggunakan HTTPS
- Data trading disimpan di Google Sheets dengan akses terkontrol
- Tidak ada data sensitif yang di-hardcode dalam source code

---

## Kontak

Untuk pertanyaan arsitektur atau kontribusi teknis, hubungi:

**Mulky Malikul Dhaher** — [mulkymalikuldhaher@email.com](mailto:mulkymalikuldhaher@email.com)
