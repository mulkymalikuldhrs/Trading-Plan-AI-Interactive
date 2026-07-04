# Emotion Logic & Gamification

The emotional state of the trader is a primary data point in this system.

## Mood Selection
-   The user selects their mood from a predefined list during trade entry.
-   This list includes both positive and negative emotions (e.g., Focused, FOMO, Anxious, Greedy).

## AI Interaction
-   The selected mood is passed to the AI during validation. The AI's response will be tailored to the user's emotional state.
-   For example, if the user's mood is "FOMO," the AI will be more strict and may warn the user about chasing the market.

## Gamification & Lockouts
-   **Streaks:** The system will track consecutive trades taken in a "Focused" or "Neutral" state, rewarding the user with positive reinforcement.
-   **Emotional Lockout:** If a user logs 3 consecutive trades with a negative emotion (or has 3 consecutive violations), the system will trigger a "soft lockout," suggesting a mandatory break and providing reflective exercises through the AI Chatbot. The `logViolation` function in the Google Apps Script contains the initial logic for this.

---

> **Contact:** Mulky Malikul Dhaher — [mulkymalikudhr@mail.com](mailto:mulkymalikudhr@mail.com)
>
> **Disclaimer:** This project is for Education Purpose only. Risiko apapun tidak kita tanggung. (We are not responsible for any risks or damages.)
