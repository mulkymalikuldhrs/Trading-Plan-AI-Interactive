/****************************************************************
 * Dhaher Trading Plan AI - GOOGLE APPS SCRIPTS (ALL-IN-ONE)
 *
 * This file contains all the core functions for interacting
 * with the Google Sheet database.
 ****************************************************************/

// --- SPREADSHEET & API CONFIGURATION ---
const SPREADSHEET_ID = PropertiesService.getScriptProperties().getProperty('SPREADSHEET_ID');
const LLM7_API_KEY = PropertiesService.getScriptProperties().getProperty('LLM7_API_KEY');
const LLM7_API_URL = PropertiesService.getScriptProperties().getProperty('LLM7_API_URL') || "https://api.openai.com/v1/chat/completions";
const WHATSAPP_API_URL = PropertiesService.getScriptProperties().getProperty('WHATSAPP_API_URL');
const BOT_API_KEY = PropertiesService.getScriptProperties().getProperty('BOT_API_KEY');

// --- SHEET HANDLERS ---
const ss = SpreadsheetApp.openById(SPREADSHEET_ID);
const journalSheet = ss.getSheetByName("Journal");
const aiFeedbackSheet = ss.getSheetByName("AI Feedback");
const violationsSheet = ss.getSheetByName("Violations");
const weeklySummarySheet = ss.getSheetByName("Weekly Summary");
const settingsSheet = ss.getSheetByName("Settings");

/**
 * Central API endpoint for all requests.
 */
function doPost(e) {
  const contents = JSON.parse(e.postData.contents);
  const { action, data } = contents;

  // Security Check: Enforce BOT_API_KEY for ALL production actions
  if (!BOT_API_KEY || data.apiKey !== BOT_API_KEY) {
    throw new Error("Unauthorized: Invalid or missing API Key for " + action);
  }

  try {
    let result;
    switch (action) {
      case "logTrade":
        result = logTrade(data);
        break;
      case "getGptFeedback":
        result = getGptFeedback(data);
        break;
      case "logViolation":
        result = logViolation(data);
        break;
      case "triggerWeeklyAnalysis":
        result = analyzeAndSummarizeWeek();
        break;
      case "exportToJson":
        result = exportSheetToJson(data.sheetName);
        break;
      case "getAiMasterSummary":
        result = getAiMasterSummary(data.symbol);
        break;
      case "getForecast":
        result = generateForecast(data.pair, data.timeframe, data.days);
        break;
      case "getMarketData":
        result = getComprehensiveMarketData(data.symbol);
        break;
      default:
        throw new Error("Invalid action: " + action);
    }
    return ContentService.createTextOutput(JSON.stringify({ "status": "success", "data": result }))
      .setMimeType(ContentService.MimeType.JSON);
  } catch (error) {
    Logger.log(error);
    return ContentService.createTextOutput(JSON.stringify({ "status": "error", "message": error.message }))
      .setMimeType(ContentService.MimeType.JSON);
  }
}

// --- MODULE 1: JOURNAL & VIOLATION LOGGING ---

function logTrade(data) {
  journalSheet.appendRow([
    "TRADE-" + new Date().getTime(),
    new Date(),
    data.pair,
    data.direction,
    data.entry,
    data.sl,
    data.tp,
    data.rrr,
    data.setup,
    data.mood,
    data.ai_status,
    data.result || 'PENDING',
    data.emotion_after || '',
    data.gpt_comment || ''
  ]);
  return "Trade logged.";
}

function logViolation(data) {
  violationsSheet.appendRow(["V-" + new Date().getTime(), new Date(), data.tradeId, data.ruleBroken, data.justification]);

  // Emotional Lockout Trigger
  const lastRow = violationsSheet.getLastRow();
  if (lastRow >= 3) {
    const recentViolations = violationsSheet.getRange(lastRow - 2, 1, 3, 1).getValues();
    if (recentViolations.length === 3) {
      sendWhatsAppNotification("⚠️ MANDATORY BREAK: You've had 3 consecutive violations. Emotional lockout activated. Reflect on your process.");
    }
  }

  return "Violation logged.";
}

// --- MODULE 2: GPT/LLM INTEGRATION ---

function getGptFeedback(data) {
  const { promptType, promptData, referenceId } = data;
  let prompt;

  if (data.full_prompt) {
    prompt = data.full_prompt;
  } else {
    const promptTemplate = getPromptTemplate(promptType);
    prompt = formatPrompt(promptTemplate, promptData);
  }

  const payload = {
    "model": "gpt-4o",
    "messages": [{ "role": "user", "content": prompt }],
    "temperature": 0.7,
    "response_format": { "type": "json_object" }
  };

  const options = {
    'method': 'post',
    'contentType': 'application/json',
    'headers': { 'Authorization': 'Bearer ' + LLM7_API_KEY },
    'payload': JSON.stringify(payload)
  };

  const response = UrlFetchApp.fetch(LLM7_API_URL, options);
  const gptResponse = JSON.parse(response.getContentText());
  const gptContent = JSON.parse(gptResponse.choices[0].message.content);

  aiFeedbackSheet.appendRow(["AI-F-" + new Date().getTime(), new Date(), referenceId, promptType, JSON.stringify(gptContent)]);

  return gptContent;
}

// --- MODULE 3: INTELLIGENCE ENGINE ---

function getAiMasterSummary(symbol) {
  const marketData = getComprehensiveMarketData(symbol);

  const prompt = `
    Analyze ${symbol} based on the following data and provide a JSON response.
    TECHNICALS: ${JSON.stringify(marketData.technicals)}
    NEWS: ${JSON.stringify(marketData.news_headlines)}
    CALENDAR: ${JSON.stringify(marketData.economic_calendar)}
    COT: ${JSON.stringify(marketData.cot_report)}

    Return JSON with: final_bias, confidence_score (1-10), technical_thesis, fundamental_thesis, positional_thesis, signal (object with active, entry, stop_loss, take_profit).
  `;

  return getGptFeedback({
    promptType: 'MasterSummary',
    full_prompt: prompt,
    referenceId: 'SUMMARY-' + symbol + '-' + new Date().getTime()
  });
}

function generateForecast(pair, timeframe, days) {
  const marketData = getComprehensiveMarketData(pair);

  const prompt = `
    Generate a ${days}-day forecast for ${pair} (${timeframe}).
    DATA: ${JSON.stringify(marketData)}

    Return JSON with: bias, entry_zone, confirmation, stop_loss, take_profit, probability (%), is_tradeable (boolean).
  `;

  const forecast = getGptFeedback({
    promptType: 'Forecast',
    full_prompt: prompt,
    referenceId: 'FORECAST-' + pair + '-' + new Date().getTime()
  });

  logForecast({
    pair: pair,
    timeframe: timeframe,
    summary: forecast.bias,
    entry: forecast.entry_zone,
    sl: forecast.stop_loss,
    tp: forecast.take_profit,
    probability: forecast.probability,
    gptAnalysis: forecast
  });

  return forecast;
}

// --- MODULE 4: NOTIFICATION SYSTEM ---

function sendWhatsAppNotification(message) {
  const userPhoneNumber = PropertiesService.getScriptProperties().getProperty('USER_PHONE_NUMBER');
  if (!userPhoneNumber || !WHATSAPP_API_URL) return;

  const payload = {
    to: userPhoneNumber,
    message: message,
    apiKey: BOT_API_KEY
  };

  const options = {
    'method': 'post',
    'contentType': 'application/json',
    'payload': JSON.stringify(payload),
    'muteHttpExceptions': true
  };

  try {
    UrlFetchApp.fetch(WHATSAPP_API_URL, options);
  } catch (e) {
    Logger.log("WhatsApp Notification Failed: " + e.message);
  }
}

// --- UTILITIES ---

function getPromptTemplate(promptType) {
    const prompts = {
        'EntryValidation': `Setup: {{Pair}} {{Arah}}. SL: {{SL}}, TP: {{TP}}. Mood: {{Mood}}. Setup: {{Setup}}. Validate this setup. Return JSON.`,
        'WeeklySummary': `Weekly Data: WinRate: {{win_rate}}%, Trades: {{total_trades}}, Emotion: {{dominant_emotion}}. Analyze performance. Return JSON.`
    };
    return prompts[promptType] || 'Analyze this data and return JSON.';
}

function formatPrompt(template, data) {
    return template.replace(/{{(\w+)}}/g, (placeholder, key) => (typeof data[key] === 'object' ? JSON.stringify(data[key]) : data[key]) || placeholder);
}

function exportSheetToJson(sheetName) {
  const sheet = ss.getSheetByName(sheetName);
  if (!sheet) return [];
  const data = sheet.getDataRange().getValues();
  const headers = data.shift();
  return data.map(row => headers.reduce((obj, header, i) => ({...obj, [header]: row[i]}), {}));
}

function logForecast(f) {
  const sheet = ss.getSheetByName("Forecasts") || ss.insertSheet("Forecasts");
  if (sheet.getLastRow() === 0) {
    sheet.appendRow(["Timestamp", "Pair", "Timeframe", "Bias", "Entry", "SL", "TP", "Probability", "FullAnalysis"]);
  }
  sheet.appendRow([new Date(), f.pair, f.timeframe, f.summary, f.entry, f.sl, f.tp, f.probability, JSON.stringify(f.gptAnalysis)]);
}
