# Trading Plan AI Module

This module helps users create and validate their trading plans using AI.

## Input Fields
-   **Ticker:** The stock or asset ticker.
-   **Strategy:** The trading strategy to be used.
-   **Entry Price:** The target entry price.
-   **Stop Loss:** The stop loss price.
-   **Take Profit:** The take profit price.

## Output Functions
-   `validate_plan()`: Validates the trading plan using the LLM7 API.
-   `save_plan()`: Saves the trading plan to the Google Sheet.

## Sheet Tab Needed
-   `Trading Plans`

## GPT Prompt Used
```
You are a trading plan validator. Based on the following information, please provide feedback and a validation score (1-100):
- Ticker: {ticker}
- Strategy: {strategy}
- Entry Price: {entry_price}
- Stop Loss: {stop_loss}
- Take Profit: {take_profit}
```

## Risk Conditions
-   The risk/reward ratio must be at least 1:2.
-   The stop loss must be within a reasonable range of the entry price.

## Override Logic
-   Users can override the validation and save the plan anyway, but it will be flagged for review.

---

> **Contact:** Mulky Malikul Dhaher — [mulkymalikuldhaher@email.com](mailto:mulkymalikuldhaher@email.com)
>
> **Disclaimer:** This project is for Education Purpose only. Risiko apapun tidak kita tanggung. (We are not responsible for any risks or damages.)
