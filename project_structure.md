# Dhaher Trading Plan AI™ - Project Structure

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
│   │   │   ├── chat_page.dart
│   │   │   └── intel_tab.dart
│   │   └── widgets/
│   │       ├── mood_tracker.dart
│   │       ├── risk_calculator.dart
│   │       └── chat_bubble.dart
│   ├── components/
│   │   ├── entry_form.dart
│   │   ├── chart.dart
│   │   ├── equity_chart.dart
│   │   ├── winrate_pie_chart.dart
│   │   ├── setup_performance_barchart.dart
│   │   ├── trading_view_embed.dart
│   │   └── consistency_streak_calendar.dart
│   ├── services/
│   │   ├── api_service.dart
│   │   ├── gpt_service.dart
│   │   ├── sheet_api.dart
│   │   ├── whatsapp_trigger.dart
│   │   ├── emotional_lockout_service.dart
│   │   ├── cot_service.dart
│   │   ├── news_fetcher.dart
│   │   └── gpt_summarizer.dart
│   └── models/
│       ├── trade.dart
├── pubspec.yaml
└── web/
    └── index.html
```

## ⚙️ `google_apps_scripts/`
```
/google_apps_scripts
├── main.gs
└── api_integrations.gs
```

## 💬 `whatsapp_bot/`
```
/whatsapp_bot
├── main.js
└── package.json
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
├── Dhaher_Trading_Sheet_Template.md
├── advanced_ui.md
├── responsive_design.md
├── voice_commands.md
├── gamification.md
└── market_intel_hub.md
```

---

> **Contact:** Mulky Malikul Dhaher — [mulkymalikudhr@mail.com](mailto:mulkymalikudhr@mail.com)
>
> **Disclaimer:** This project is for Education Purpose only. Risiko apapun tidak kita tanggung. (We are not responsible for any risks or damages.)
