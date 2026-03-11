# API Reference

The system uses a Google Apps Script as a simple REST API.

**Endpoint:** `[Your Deployed Google Apps Script URL]`

**Method:** `POST`

**Headers:**
-   `Content-Type: application/json`

**Body:**
```json
{
  "action": "[action_name]",
  "data": { ... }
}
```

## Actions

### `getGptFeedback`
-   **Description:** Triggers a call to the LLM7 API with a specified prompt.
-   **Data:** `{ "promptType": "...", "promptData": { ... }, "referenceId": "..." }`

### `logTrade`
-   **Description:** Logs a completed trade to the Journal sheet.
-   **Data:** A JSON representation of the `Trade` object.

### `logViolation`
-   **Description:** Logs a rule violation.
-   **Data:** `{ "tradeId": "...", "ruleBroken": "...", "justification": "..." }`

### `triggerWeeklyAnalysis`
-   **Description:** Manually triggers the weekly analysis script.
-   **Data:** `{}`

### `exportToJson`
-   **Description:** Exports an entire sheet to a JSON object.
-   **Data:** `{ "sheetName": "..." }`

### `getAiMasterSummary`
-   **Description:** Gathers comprehensive market data and generates a unified AI analysis.
-   **Data:** `{ "symbol": "EURUSD" }`

### `getForecast`
-   **Description:** Generates a multi-day forecast for a given pair and timeframe.
-   **Data:** `{ "pair": "EURUSD", "timeframe": "H4", "days": 7 }`
