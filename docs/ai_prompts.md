# 🧠 MULKY AI OS - AI Prompt Templates

This file contains all the core GPT/LLM7 prompts used throughout the system.

---

## 1. Trade Entry Validation Prompt

**Objective:** To validate a user's trade setup before they enter a position. The AI should act as a strict but fair mentor.

**Prompt:**
```
You are my Trading Mentor & Validator. I am about to enter a trade, and I need your objective, data-driven feedback. Do not be soft on me; my discipline depends on your honesty.

Here is my setup:
- **Pair:** {{Pair}}
- **Arah:** {{Arah}}
- **SL:** {{SL}}
- **TP:** {{TP}}
- **Mood:** {{Mood}}
- **Setup:** {{Setup}}

Tolong validasi dan beri saran. Jika saya override, tolong bantu refleksi.
```

---

## 2. Emotional Override Reflection Prompt

**Objective:** To help the user reflect after they override a system warning or a losing trade. The AI should act as a supportive therapist.

**Prompt:**
```
Saya override entry. Mood saya {{Mood}}.
Kenapa ini bisa terjadi dan bagaimana saya bisa memperbaiki mindset saya?
```

---

## 3. Weekly Performance Review Prompt

**Objective:** To provide the user with a comprehensive, data-driven review of their weekly trading performance, focusing on psychological insights.

**Prompt:**
```
Berikut data jurnal saya minggu ini:
- **Total Trades:** {{total_trades}}
- **Win Rate:** {{win_rate}}%
- **Emosi Dominan:** {{dominant_emotion}}
- **Ringkasan:** {{journal_summary}}
Tolong beri analisa teknikal, emosi dominan, motivasi, dan saran peningkatan minggu depan.
```

---

## 4. Reflective Question Prompt

**Objective:** To ask a targeted question to provoke self-reflection based on a user's recent action.

**Prompt:**
```
Based on my last action ({{last_action}}), ask me one deep, open-ended question to help me understand my own psychology better.
```

---

## 5. Motivational Quote Prompt

**Objective:** To provide a context-aware motivational quote.

**Prompt:**
```
I'm feeling {{mood}}. Give me a powerful, relevant quote to help me stay disciplined and focused.
```

---

> **Contact:** Mulky Malikul Dhaher — [mulkymalikudhr@mail.com](mailto:mulkymalikudhr@mail.com)
>
> **Disclaimer:** This project is for Education Purpose only. Risiko apapun tidak kita tanggung. (We are not responsible for any risks or damages.)
