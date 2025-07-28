# MULKY AI TRADING COMPANION OS™ - Project Structure

This document outlines the file and directory structure for the entire system.

## 📁 Root
```
/
├── flutter_app/
├── google_apps_scripts/
├── whatsapp_bot/
├── docs/
├── README.md
├── CHANGELOG.md
├── TODO.md
├── structure.json
└── project_structure.md
```

## 📱 `flutter_app/`
```
/flutter_app
├── lib/
│   ├── main.dart
│   ├── ui/
│   │   ├── pages/
│   │   │   ├── entry_page.dart
│   │   │   ├── journal_page.dart
│   │   │   ├── dashboard_page.dart
│   │   │   └── chat_page.dart
│   │   └── widgets/
│   │       ├── mood_tracker.dart
│   │       ├── risk_calculator.dart
│   │       └── chat_bubble.dart
│   ├── components/
│   │   ├── entry_form.dart
│   │   └── chart.dart
│   ├── services/
│   │   ├── gpt_service.dart
│   │   ├── sheet_service.dart
│   │   └── notification_service.dart
│   └── models/
│       ├── trade.dart
│       ├── journal_entry.dart
│       └── gpt_response.dart
├── pubspec.yaml
└── web/
    └── index.html
```

## ⚙️ `google_apps_scripts/`
```
/google_apps_scripts
├── sync_entry.gs
├── risk_calculator.gs
├── violation_counter.gs
├── gpt_fetcher.gs
└── export_logs.gs
```

## 💬 `whatsapp_bot/`
```
/whatsapp_bot
├── index.js
├── package.json
└── scheduler.js
```

## 📚 `docs/`
```
/docs
├── api.md
├── usage.md
├── ai_prompts.md
├── emotion_logic.md
├── weekly_analysis.md
├── changelog.md
├── trading_plan_ai.md
└── Mulky_Trading_Sheet_Template.md
```
