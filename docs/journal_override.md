# Journal Override System

An "override" is when a user proceeds with an action despite a warning from the AI. This is a critical data point for psychological analysis.

## How it Works
1.  **AI Warning:** The AI validation returns a low score or identifies rule violations. The UI will clearly display this as a warning.
2.  **User Choice:** The user is given the option to either "Cancel" the trade or "Override & Proceed".
3.  **Logging the Violation:** If the user chooses to override, the `logViolation` function is called in the Google Apps Script. This logs the event to the `Violations` sheet, including the trade ID, the rule that was broken, and any justification the user provides.
4.  **Triggering Reflection:** After an override, the system will proactively prompt the user to reflect on their decision. This can be done via:
    *   A persistent banner in the UI.
    *   A direct message from the AI chatbot.
    *   A WhatsApp notification suggesting a reflection session.
5.  **Weekly Analysis:** Overrides are a key metric in the weekly performance review, helping the user identify patterns of undisciplined behavior.

---

> **Contact:** Mulky Malikul Dhaher — [mulkymalikudhr@mail.com](mailto:mulkymalikudhr@mail.com)
>
> **Disclaimer:** This project is for Education Purpose only. Risiko apapun tidak kita tanggung. (We are not responsible for any risks or damages.)
