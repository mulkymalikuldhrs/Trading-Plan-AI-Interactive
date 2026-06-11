<!-- BANNER -->
<img width="100%" src="https://capsule-render.vercel.app/api?type=waving&color=0:0a1a2e,50:0d2b4a,100:143d5e&fontColor=38bdf8&descColor=22d3ee&height=220&section=header&text=Trading%20Plan%20AI&fontSize=60&desc=AI%20Market%20Intelligence&animation=fadeIn" />

<!-- TYPING SVG -->
<div align="center">
  <a href="https://git.io/typing-svg">
    <img src="https://readme-typing-svg.demolab.com?font=Fira+Code&size=22&duration=3000&pause=1000&color=38BDF8&center=true&vCenter=true&width=600&lines=Flutter+%2B+Python+%2B+WhatsApp;AI-Powered+Market+Analysis;Personal+Decision+Support;Not+a+Guaranteed+Trading+System" alt="Typing SVG" />
  </a>
</div>

<br/>

<!-- BADGES -->
<div align="center">

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev/)
[![Python](https://img.shields.io/badge/Python-3.11-3776AB?style=for-the-badge&logo=python&logoColor=white)](https://python.org/)
[![WhatsApp](https://img.shields.io/badge/WhatsApp-API-25D366?style=for-the-badge&logo=whatsapp&logoColor=white)](https://www.whatsapp.com/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)](./LICENSE)

</div>

---

## Overview

**Trading Plan AI Interactive** is an AI-powered market intelligence platform that combines a Flutter mobile app, a Python analysis backend, and WhatsApp integration for real-time trading signal delivery. Designed as a personal decision-support tool, it provides market analysis, trade plan generation, and instant notifications via WhatsApp — keeping you informed without requiring you to stare at charts all day.

## Features

### AI Market Analysis
- Multi-timeframe technical analysis
- Trend detection and momentum scoring
- Support/resistance level identification
- Pattern recognition across markets

### Trade Plan Generation
- AI-generated trade plans with entry/exit points
- Risk-reward ratio calculations
- Position sizing based on account size and risk tolerance
- Plan templates for different trading styles

### WhatsApp Integration
- Real-time signal alerts via WhatsApp
- Daily market briefings delivered to your phone
- Interactive commands (check prices, request analysis)
- Customizable alert thresholds

### Flutter Mobile App
- Cross-platform (iOS & Android)
- Real-time charts and market data
- Trade plan tracking and journaling
- Performance analytics dashboard

### Python Backend
- Market data collection and processing
- AI analysis engine
- WhatsApp Business API integration
- RESTful API for Flutter client

## Visual Architecture

> Interactive diagrams showing multi-platform architecture, AI plan generation, signal delivery, and emotional lockout system.

### Multi-Platform Architecture

```mermaid
graph TB
    subgraph MOBILE["📱 Flutter Mobile App"]
        UI["Cross-Platform UI<br/>iOS & Android"]
        CHARTS2["Real-Time<br/>Charts"]
        JOURNAL["Trade Journal<br/>& Tracking"]
        LOCKOUT_UI["Emotional Lockout<br/>Interface"]
    end

    subgraph BACKEND2["🐍 Python Backend"]
        ANALYSIS["AI Analysis<br/>Engine"]
        PLANNER["Trade Plan<br/>Generator"]
        SIGNAL_GEN2["Signal<br/>Detector"]
        EMOTION["Emotional<br/>Lockout Engine"]
        REST["RESTful API<br/>FastAPI/Flask"]
    end

    subgraph WHATSAPP["💬 WhatsApp Integration"]
        WA_BOT["WhatsApp<br/>Bot"]
        WA_ALERTS["Signal<br/>Alerts"]
        WA_BRIEF["Daily<br/>Briefings"]
        WA_CMD["Interactive<br/>Commands"]
    end

    subgraph SHEETS["📊 Google Sheets"]
        GAS["Google Apps<br/>Script"]
        PLAN_LOG["Trade Plan<br/>Logger"]
        PERF["Performance<br/>Tracker"]
    end

    subgraph DATA_SRC["🌐 Data Sources"]
        MARKET["Market Data<br/>Providers"]
        NEWS3["News &<br/>Sentiment"]
    end

    DATA_SRC --> BACKEND2
    BACKEND2 --> REST
    REST --> MOBILE
    REST --> WHATSAPP
    BACKEND2 --> SHEETS

    style MOBILE fill:#02569B20,stroke:#02569B,color:#fff
    style BACKEND2 fill:#3776AB20,stroke:#3776AB,color:#fff
    style WHATSAPP fill:#25D36620,stroke:#25D366,color:#fff
    style SHEETS fill:#34A85320,stroke:#34A853,color:#fff
    style DATA_SRC fill:#0d2137,stroke:#22d3ee,color:#fff
```

### AI Trading Plan Flow

```mermaid
flowchart LR
    subgraph INPUT2["📊 Market Data Input"]
        PRICE["Price<br/>Action"]
        IND["Technical<br/>Indicators"]
        NEWS4["News &<br/>Events"]
        VOL["Volatility<br/>Metrics"]
    end

    subgraph ANALYZE["🧠 AI Analysis"]
        TREND["Trend<br/>Detection"]
        S_R["Support/<br/>Resistance"]
        MOM["Momentum<br/>Scoring"]
        PATTERN["Pattern<br/>Recognition"]
    end

    subgraph GENERATE["📝 Plan Generation"]
        ENTRY["Entry Point<br/>Calculation"]
        EXIT["Exit Point<br/>Calculation"]
        RR["Risk-Reward<br/>Ratio"]
        SIZE["Position<br/>Sizing"]
    end

    subgraph DELIVER["📤 Delivery"]
        APP["📱 App<br/>Notification"]
        WA2["💬 WhatsApp<br/>Message"]
        SHEET["📊 Google<br/>Sheet"]
    end

    INPUT2 --> ANALYZE --> GENERATE --> DELIVER

    PRICE & IND & NEWS4 & VOL --> TREND & S_R & MOM & PATTERN
    TREND & S_R & MOM & PATTERN --> ENTRY & EXIT & RR & SIZE
    ENTRY & EXIT & RR & SIZE --> APP & WA2 & SHEET

    style INPUT2 fill:#0d2137,stroke:#22d3ee,color:#fff
    style ANALYZE fill:#1a0f3d,stroke:#a78bfa,color:#fff
    style GENERATE fill:#1a3d0f,stroke:#4ade80,color:#fff
    style DELIVER fill:#3d1a0f,stroke:#f97316,color:#fff
```

### Signal Alert Pipeline

```mermaid
flowchart TD
    subgraph DETECT["🔍 Signal Detection"]
        SIG_SCAN["Market<br/>Scanner"]
        SIG_CRIT["Criteria<br/>Matching"]
        SIG_CONF2["Signal<br/>Confirmation"]
    end

    subgraph PROCESS["⚙️ Alert Processing"]
        PRIOR["Priority<br/>Classification"]
        FORMAT["Message<br/>Formatting"]
        QUEUE["Alert<br/>Queue"]
    end

    subgraph ROUTE["🚀 Delivery Routes"]
        direction LR
        WA3["💬 WhatsApp<br/>Instant"]
        PUSH["📱 Push<br/>Notification"]
        SHEET2["📊 Sheet<br/>Logging"]
    end

    subgraph FEEDBACK["🔄 Feedback Loop"]
        TRACK2["Delivery<br/>Confirmation"]
        READ["Read<br/>Receipt"]
        ACTION["User<br/>Action Log"]
    end

    DETECT --> PROCESS --> ROUTE --> FEEDBACK
    FEEDBACK -->|"Optimize"| PROCESS

    style DETECT fill:#0d2137,stroke:#22d3ee,color:#fff
    style PROCESS fill:#1a0f3d,stroke:#a78bfa,color:#fff
    style ROUTE fill:#1a3d0f,stroke:#4ade80,color:#fff
    style FEEDBACK fill:#3d1a0f,stroke:#f97316,color:#fff
```

### Emotional Lockout System

```mermaid
flowchart TD
    subgraph TRIGGERS["🧠 Lockout Triggers"]
        DD_TRIG["Drawdown<br/>Exceeds Limit"]
        LOSS_STREAK["Consecutive<br/>Loss Streak"]
        OVERTRADE["Trade Frequency<br/>Exceeds Limit"]
        EMOTION_VOL["Emotional<br/>Volatility High"]
        AFTER_HOURS["Outside<br/>Trading Hours"]
    end

    subgraph ENGINE["⚙️ Lockout Engine"]
        EVAL["Evaluate<br/>Trigger Score"]
        DECIDE{"Lockout<br/>Required?"}
        COOLDOWN["Set Cooldown<br/>Period"]
        NOTIFY["Notify User<br/>via All Channels"]
    end

    subgraph LOCKED["🔒 Lockout State"]
        BLOCK["Block All<br/>New Trades"]
        VIEW_ONLY["View-Only<br/>Mode"]
        JOURNAL2["Mandatory<br/>Journal Entry"]
        CALM["Cool-Down<br/>Timer"]
    end

    subgraph RECOVER["🔓 Recovery"]
        REFLECT["Reflection<br/>Period"]
        RESET["Manual<br/>Unlocked"]
        RESUME["Resume<br/>Trading"]
    end

    TRIGGERS --> ENGINE
    EVAL --> DECIDE
    DECIDE -->|"Yes"| COOLDOWN --> LOCKED
    DECIDE -->|"No"| CONTINUE["✅ Continue<br/>Trading"]
    LOCKED --> RECOVER
    CALM --> REFLECT --> RESET --> RESUME

    style TRIGGERS fill:#3a0a0a,stroke:#f87171,color:#fff
    style ENGINE fill:#2a2a0a,stroke:#facc15,color:#fff
    style LOCKED fill:#3a1a0f,stroke:#f97316,color:#fff
    style RECOVER fill:#0a2a0a,stroke:#4ade80,color:#fff
    style CONTINUE fill:#0a2a0a,stroke:#4ade80,color:#fff
```

> **The Emotional Lockout System** is designed to prevent impulsive trading decisions during high-stress or high-loss periods. It enforces mandatory cool-down periods and journaling before trading can resume.

---

## Honest Notes

> **Important:**

- **Personal Decision-Support Tool** — This is designed to support your decision-making, not replace it. The final trade decision is always yours.
- **Not a Guaranteed Trading System** — No AI system can guarantee trading profits. Markets are inherently unpredictable and losses are possible.
- **WhatsApp Rate Limits** — WhatsApp Business API has message rate limits and requires approval. Personal WhatsApp integration may have restrictions.
- **API Dependencies** — Relies on market data providers which may have rate limits, downtime, or changed pricing.

## Quick Start

### Prerequisites
- Flutter 3.x SDK
- Python 3.11+
- WhatsApp Business API account (or Twilio)

### Installation

```bash
git clone https://github.com/mulkymalikuldhrs/Trading-Plan-AI-Interactive.git
cd Trading-Plan-AI-Interactive

# Python backend
cd backend
pip install -r requirements.txt

# Flutter app
cd ../app
flutter pub get
```

### Running

```bash
# Backend
cd backend && python main.py

# Flutter
cd app && flutter run
```

## Disclaimer

This is a personal decision-support tool, not a guaranteed trading system. All trading involves risk of loss. AI-generated insights are for informational purposes only and do not constitute financial advice. Always consult a qualified financial advisor.

## License

**MIT License** — see [LICENSE](./LICENSE) for details.

## Author

<div align="center">

**Mulky Malikul Dhaher**

[![GitHub](https://img.shields.io/badge/GitHub-mulkymalikuldhrs-181717?style=flat-square&logo=github)](https://github.com/mulkymalikuldhrs)
[![Email](https://img.shields.io/badge/Email-mulkymalikudhr@mail.com-EA4335?style=flat-square&logo=gmail&logoColor=white)](mailto:mulkymalikudhr@mail.com)

</div>

---

<!-- FOOTER BANNER -->
<img width="100%" src="https://capsule-render.vercel.app/api?type=waving&color=0:0a1a2e,50:0d2b4a,100:143d5e&fontColor=38bdf8&descColor=22d3ee&height=120&section=footer&text=&fontSize=0" />
