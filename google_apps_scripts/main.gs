/****************************************************************
 * MULKY AI TRADING OS - GOOGLE APPS SCRIPTS
 *
 * This file contains all the core functions for interacting
 * with the Google Sheet database.
 ****************************************************************/

const SPREADSHEET_ID = "YOUR_SPREADSHEET_ID";
const API_KEY = "YOUR_LLM7_API_KEY";
const API_URL = "https://api.llm7.io/v1/chat/completions";

const journalSheet = SpreadsheetApp.openById(SPREADSHEET_ID).getSheetByName("Journal");
const aiFeedbackSheet = SpreadsheetApp.openById(SPREADSHEET_ID).getSheetByName("AI Feedback");
const violationsSheet = SpreadsheetApp.openById(SPREADSHEET_ID).getSheetByName("Violations");

/**
 * Main function to handle POST requests from the Flutter app.
 * This acts as the central API endpoint.
 */
function doPost(e) {
  const contents = JSON.parse(e.postData.contents);
  const action = contents.action;

  try {
    let result;
    switch (action) {
      case "logTrade":
        result = logTrade(contents.data);
        break;
      case "getGptFeedback":
        result = getGptFeedback(contents.data);
        break;
      case "logViolation":
        result = logViolation(contents.data);
        break;
      case "exportToJson":
        result = exportSheetToJson(contents.sheetName);
        break;
      default:
        throw new Error("Invalid action specified.");
    }
    return ContentService.createTextOutput(JSON.stringify({ "status": "success", "data": result }))
      .setMimeType(ContentService.MimeType.JSON);
  } catch (error) {
    return ContentService.createTextOutput(JSON.stringify({ "status": "error", "message": error.message }))
      .setMimeType(ContentService.MimeType.JSON);
  }
}

/****************************************************************
 * 1. AUTO-SYNC ENTRY
 ****************************************************************/

/**
 * Logs a new trade to the 'Journal' sheet.
 * @param {object} tradeData - The trade data from the Flutter app.
 * @returns {string} Confirmation message.
 */
function logTrade(tradeData) {
  const newRow = [
    "TRADE-" + new Date().getTime(), // TradeID
    new Date(), // Timestamp
    tradeData.asset,
    tradeData.direction,
    tradeData.entryPrice,
    tradeData.exitPrice,
    tradeData.stopLoss,
    tradeData.takeProfit,
    tradeData.status,
    tradeData.pnl,
    tradeData.moodBefore,
    tradeData.moodAfter,
    tradeData.notes
  ];
  journalSheet.appendRow(newRow);
  return "Trade logged successfully.";
}

/****************************************************************
 * 2. GPT FETCHER & FEEDBACK LOGGER
 ****************************************************************/

/**
 * Fetches feedback from the GPT API and logs it.
 * @param {object} promptData - The data needed to format the prompt.
 * @returns {object} The parsed GPT response.
 */
function getGptFeedback(promptData) {
  const { promptType, data } = promptData;
  const promptTemplate = getPromptTemplate(promptType);
  const formattedPrompt = formatPrompt(promptTemplate, data);

  const payload = {
    "model": "gpt-4.5-turbo", // Or your preferred model
    "messages": [
      { "role": "system", "content": "You are an AI assistant for a trader." },
      { "role": "user", "content": formattedPrompt }
    ],
    "temperature": 0.7
  };

  const options = {
    'method': 'post',
    'contentType': 'application/json',
    'headers': {
      'Authorization': 'Bearer ' + API_KEY
    },
    'payload': JSON.stringify(payload)
  };

  const response = UrlFetchApp.fetch(API_URL, options);
  const gptResponse = JSON.parse(response.getContentText());
  const gptContent = JSON.parse(gptResponse.choices[0].message.content);

  // Log the feedback
  logAiFeedback(promptData.referenceId, promptType, gptContent);

  return gptContent;
}

/**
 * Logs the AI's feedback to the 'AI Feedback' sheet.
 */
function logAiFeedback(referenceId, promptType, gptResponseJson) {
  const newRow = [
    "AI-F-" + new Date().getTime(), // FeedbackID
    new Date(), // Timestamp
    referenceId,
    promptType,
    JSON.stringify(gptResponseJson)
  ];
  aiFeedbackSheet.appendRow(newRow);
}

/****************************************************************
 * 3. VIOLATION COUNTER
 ****************************************************************/

/**
 * Logs a new rule violation to the 'Violations' sheet.
 * @param {object} violationData - The violation data.
 * @returns {string} Confirmation message.
 */
function logViolation(violationData) {
  const newRow = [
    "V-" + new Date().getTime(), // ViolationID
    new Date(), // Timestamp
    violationData.tradeId,
    violationData.ruleBroken,
    violationData.justification
  ];
  violationsSheet.appendRow(newRow);
  return "Violation logged successfully.";
}


/****************************************************************
 * 4. DATA EXPORTER
 ****************************************************************/

/**
 * Exports a given sheet to a JSON string.
 * @param {string} sheetName - The name of the sheet to export.
 * @returns {string} A JSON string representing the sheet data.
 */
function exportSheetToJson(sheetName) {
  const sheet = SpreadsheetApp.openById(SPREADSHEET_ID).getSheetByName(sheetName);
  if (!sheet) {
    throw new Error(`Sheet "${sheetName}" not found.`);
  }
  const data = sheet.getDataRange().getValues();
  const headers = data.shift();
  const jsonArray = data.map(row => {
    let obj = {};
    headers.forEach((header, index) => {
      obj[header] = row[index];
    });
    return obj;
  });
  return JSON.stringify(jsonArray);
}

/****************************************************************
 * UTILITY FUNCTIONS
 ****************************************************************/

/**
 * Retrieves a prompt template. In a real scenario, this could
 * fetch from another sheet or a dedicated file.
 */
function getPromptTemplate(promptType) {
    // In a real app, you'd fetch these from a "Prompts" sheet or file.
    if (promptType === 'EntryValidation') {
        return `You are my Trading Mentor... (rest of the prompt)`;
    }
    if (promptType === 'EmotionalReflection') {
        return `You are my Trading Psychologist... (rest of the prompt)`;
    }
    // ... etc.
    return '';
}

/**
 * Simple template formatter.
 */
function formatPrompt(template, data) {
    let formatted = template;
    for (const key in data) {
        const regex = new RegExp(`{{${key}}}`, 'g');
        formatted = formatted.replace(regex, data[key]);
    }
    return formatted;
}
