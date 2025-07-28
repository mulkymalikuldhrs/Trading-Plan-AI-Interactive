# Voice Command System

The AI Coach in the MULKY AI TRADING COMPANION OS™ supports voice commands for a hands-free, natural interaction experience.

## Activation

To activate voice input, tap the microphone icon on the chat page. The icon will change to indicate that the system is listening. Speak your command, and the transcribed text will appear in the input field. The system will stop listening automatically after a pause.

## Supported Commands

While the chatbot can understand natural language, here are some core commands to get you started:

-   **"Reflect on my last trade."**
    -   Triggers the AI to ask you a targeted question about your most recent trade.
-   **"What were my biggest mistakes this week?"**
    -   Initiates a weekly review, focusing on areas for improvement.
-   **"Give me some motivation."**
    -   The AI will provide a relevant motivational quote based on your recent performance and emotional state.
-   **"Log a new trade for XAU/USD, long."**
    -   The chatbot can pre-fill parts of the entry form for you. (Future implementation)
-   **"How am I feeling today?"**
    -   The AI will analyze your recent mood logs and give you a summary of your emotional state.

## Technical Implementation

-   We use the `speech_to_text` package in Flutter to handle the speech recognition.
-   The transcribed text is then processed by the same natural language understanding (NLU) layer as text input, ensuring consistent responses from the AI.
-   The system is designed to be robust against background noise, but for best results, speak clearly in a quiet environment.
