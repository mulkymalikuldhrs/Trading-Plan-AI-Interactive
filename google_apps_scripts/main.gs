/****************************************************************
 * Dhaher Trading Plan AI - GOOGLE APPS SCRIPTS (ALL-IN-ONE)
 *
 * This file contains all the core functions for interacting
 * with the Google Sheet database.
 ****************************************************************/

// --- SPREADSHEET & API CONFIGURATION ---
const SPREADSHEET_ID = PropertiesService.getScriptProperties().getProperty('SPREADSHEET_ID');
const LLM7_API_KEY = PropertiesService.getScriptProperties().getProperty('LLM7_API_KEY');
const LLM7_API_URL = PropertiesService.getScriptProperties().getProperty('LLM7_API_URL') || "https://api.llm7.io/v1/chat/completions";
const WHATSAPP_API_URL = PropertiesService.getScriptProperties().getProperty('WHATSAPP_API_URL');
const BOT_API_KEY = PropertiesService.getScriptProperties().getProperty('BOT_API_KEY');

/**
 * Central API endpoint for all requests from the Flutter app or WhatsApp Bot.
 */
function doPost(e) {
  try {
    const contents = JSON.parse(e.postData.contents);
    const { action, data, apiKey } = contents;

    // Security Verification
    if (apiKey !== BOT_API_KEY) {
       throw new Error("Unauthorized access: Invalid API Key.");
    }

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
        result = getForecast(data);
        break;
      case "getCotAnalysis":
        result = getCotAnalysis(data.symbol);
        break;
      default:
        throw new Error("Invalid action specified: " + action);
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
  const ss = SpreadsheetApp.openById(SPREADSHEET_ID);
  const journalSheet = ss.getSheetByName("Journal");
  journalSheet.appendRow([
    "TRADE-" + new Date().getTime(), new Date(), data.pair, data.direction, data.entry, data.sl, data.tp, data.rrr,
    data.setup, data.mood, data.ai_status, data.result, data.emotion_after, data.gpt_comment
  ]);
  return "Trade logged.";
}

function logViolation(data) {
  const ss = SpreadsheetApp.openById(SPREADSHEET_ID);
  const violationsSheet = ss.getSheetByName("Violations");
  violationsSheet.appendRow(["V-" + new Date().getTime(), new Date(), data.tradeId, data.ruleBroken, data.justification]);

  // Emotional Lockout Trigger
  const recentViolations = violationsSheet.getLastRow() >= 3 ? violationsSheet.getRange(violationsSheet.getLastRow() - 2, 1, 3, 1).getValues() : [];
  if (recentViolations.length === 3) {
    sendWhatsAppNotification("You've had 3 consecutive violations. It's time for a mandatory break. Reflect on your actions.");
  }

  return "Violation logged.";
}

// --- MODULE 2: GPT/LLM7 INTEGRATION ---

function getGptFeedback(data) {
  const { promptType, promptData, referenceId } = data;
  const promptTemplate = getPromptTemplate(promptType);
  const formattedPrompt = formatPrompt(promptTemplate, promptData);

  const payload = {
    "model": "gpt-4o", // Upgraded to gpt-4o for production
    "messages": [{ "role": "user", "content": formattedPrompt }],
    "temperature": 0.7,
    "response_format": { "type": "json_object" }
  };

  const options = {
    'method': 'post',
    'contentType': 'application/json',
    'headers': { 'Authorization': 'Bearer ' + LLM7_API_KEY },
    'payload': JSON.stringify(payload),
    'muteHttpExceptions': true
  };

  const response = UrlFetchApp.fetch(LLM7_API_URL, options);
  const responseText = response.getContentText();
  const gptResponse = JSON.parse(responseText);

  if (gptResponse.error) {
    throw new Error("GPT API Error: " + gptResponse.error.message);
  }

  const gptContent = JSON.parse(gptResponse.choices[0].message.content);

  const ss = SpreadsheetApp.openById(SPREADSHEET_ID);
  const aiFeedbackSheet = ss.getSheetByName("AI Feedback");
  aiFeedbackSheet.appendRow(["AI-F-" + new Date().getTime(), new Date(), referenceId, promptType, JSON.stringify(gptContent)]);

  return gptContent;
}

// --- MODULE 3: INTELLIGENCE & FORECASTING ---

function getAiMasterSummary(symbol) {
  const marketData = getComprehensiveMarketData(symbol);

  const analysis = getGptFeedback({
    promptType: 'MasterTradeAnalyst',
    promptData: { ...marketData, symbol: symbol },
    referenceId: 'SUMMARY-' + symbol + '-' + new Date().getTime()
  });

  return analysis;
}

function getForecast(data) {
  const { pair, timeframe, days } = data;
  const marketData = getComprehensiveMarketData(pair);

  const forecast = getGptFeedback({
    promptType: 'MarketForecaster',
    promptData: { ...marketData, pair: pair, timeframe: timeframe, days: days },
    referenceId: 'FORECAST-' + pair + '-' + new Date().getTime()
  });

  return forecast;
}

function getCotAnalysis(symbol) {
  const cotData = getCotData(symbol);

  const analysis = getGptFeedback({
    promptType: 'CotAnalyst',
    promptData: { ...cotData, symbol: symbol },
    referenceId: 'COT-' + symbol + '-' + new Date().getTime()
  });

  return {
    ...cotData,
    gptAnalysis: analysis
  };
}

// --- MODULE 4: WEEKLY ANALYZER ---

function analyzeAndSummarizeWeek() {
  const ss = SpreadsheetApp.openById(SPREADSHEET_ID);
  const journalSheet = ss.getSheetByName("Journal");
  const journalData = journalSheet.getDataRange().getValues();
  const headers = journalData.shift();

  if (journalData.length === 0) return "No trades to analyze this week.";

  // Data processing using headers for robustness
  const getIndex = (name) => headers.indexOf(name);

  let winCount = 0;
  let emotions = {};

  journalData.forEach(row => {
    if(row[getIndex('Result')] === 'WIN') winCount++;
    const mood = row[getIndex('Mood')];
    emotions[mood] = (emotions[mood] || 0) + 1;
  });

  const dominantEmotion = Object.keys(emotions).reduce((a, b) => emotions[a] > emotions[b] ? a : b, 'Neutral');

  const analysisPromptData = {
    total_trades: journalData.length,
    win_rate: ((winCount / journalData.length) * 100).toFixed(2),
    dominant_emotion: dominantEmotion,
    journal_summary: JSON.stringify(journalData.slice(-10)) // Send last 10 trades for context
  };

  const weeklyFeedback = getGptFeedback({
    promptType: 'WeeklySummary',
    promptData: analysisPromptData,
    referenceId: 'WEEKLY-' + new Date().toISOString().slice(0, 10)
  });

  const weeklySummarySheet = ss.getSheetByName("Weekly Summary");
  weeklySummarySheet.appendRow([
    'W-' + new Date().getTime(), new Date(),
    analysisPromptData.win_rate, analysisPromptData.total_trades, JSON.stringify(weeklyFeedback)
  ]);

  sendWhatsAppNotification(`🚀 Your weekly summary is ready! Dominant emotion: ${dominantEmotion}. Win Rate: ${analysisPromptData.win_rate}%. Open the app to see the full report.`);

  return weeklyFeedback;
}


// --- MODULE 5: NOTIFICATION SYSTEM ---

function sendWhatsAppNotification(message) {
  const userPhoneNumber = PropertiesService.getScriptProperties().getProperty('USER_PHONE_NUMBER');
  if (!userPhoneNumber || !WHATSAPP_API_URL) return;

  const payload = {
    apiKey: BOT_API_KEY,
    to: userPhoneNumber,
    message: message
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
    Logger.log("Could not send WhatsApp message: " + e.message);
  }
}

// --- UTILITIES ---

function getPromptTemplate(promptType) {
    const prompts = {
        'EntryValidation': `Setup saya:\n- Pair: {{Pair}}\n- Arah: {{Arah}}\n- SL: {{SL}}\n- TP: {{TP}}\n- Mood: {{Mood}}\n- Setup: {{Setup}}\nTolong validasi dan beri saran. Kembalikan dalam format JSON dengan field: validation_score, is_valid_setup, rule_violations, emotional_warning, tough_love_feedback, detailed_explanation.`,
        'WeeklySummary': `Berikut data jurnal saya minggu ini:\n- Total Trades: {{total_trades}}\n- Win Rate: {{win_rate}}%\n- Emosi Dominan: {{dominant_emotion}}\n- Ringkasan: {{journal_summary}}\nTolong beri analisa teknikal, emosi dominan, motivasi, dan saran peningkatan. Kembalikan dalam format JSON.`,
        'MasterTradeAnalyst': `Analisa pasar untuk {{symbol}} berdasarkan data: {{technicals}}, News: {{news_headlines}}, COT: {{cot_report}}. Kembalikan JSON dengan field: final_bias, confidence_score, technical_thesis, fundamental_thesis, positional_thesis, signal: {active, entry, stop_loss, take_profit}.`,
        'MarketForecaster': `Buat prakiraan {{days}} hari untuk {{pair}} ({{timeframe}}). Data: {{technicals}}. Kembalikan JSON dengan field: bias, probability, entry_zone, confirmation, stop_loss, take_profit.`,
        'CotAnalyst': `Analisa data COT untuk {{symbol}}: {{long}} Long, {{short}} Short. Kembalikan JSON dengan bias dan penjelasan singkat.`
    };
    return prompts[promptType] || '';
}

function formatPrompt(template, data) {
    return template.replace(/{{(\w+)}}/g, (placeholder, key) => {
        const val = data[key];
        return (typeof val === 'object') ? JSON.stringify(val) : (val || placeholder);
    });
}

function exportSheetToJson(sheetName) {
  const ss = SpreadsheetApp.openById(SPREADSHEET_ID);
  const sheet = ss.getSheetByName(sheetName);
  if (!sheet) throw new Error(`Sheet "${sheetName}" not found.`);
  const [headers, ...rows] = sheet.getDataRange().getValues();
  const jsonArray = rows.map(row =>
    headers.reduce((obj, header, i) => ({...obj, [header]: row[i]}), {})
  );
  return jsonArray;
}

// --- MODULE 6: AUTONOMOUS SIGNAL GENERATION (RE-IMPLEMENTED) ---

/**
 * Scans for trading opportunities based on user's trading plan.
 * This function is designed to be run on a time-based trigger.
 */
function scanForTradeSignals() {
  const ss = SpreadsheetApp.openById(SPREADSHEET_ID);
  const tradingPlanSheet = ss.getSheetByName("Settings"); // Assumes settings/plan in Settings
  const data = tradingPlanSheet.getDataRange().getValues();

  // Extract symbols from Settings (assuming column 1 has symbols)
  const symbols = data.slice(1).map(row => row[0]).filter(s => s);

  symbols.forEach(symbol => {
    const marketData = getComprehensiveMarketData(symbol);

    const analysis = getGptFeedback({
      promptType: 'MasterTradeAnalyst',
      promptData: { ...marketData, symbol: symbol },
      referenceId: 'AUTO-SIGNAL-' + symbol + '-' + new Date().getTime()
    });

    if (analysis.signal && analysis.signal.active && analysis.confidence_score >= 8) {
      const signalMessage = "🚀 *New High-Conviction Signal* 🚀\n" +
        "*Symbol:* " + symbol + "\n" +
        "*Bias:* " + analysis.final_bias + " (" + analysis.confidence_score + "/10)\n" +
        "*Entry:* " + analysis.signal.entry + "\n" +
        "*SL:* " + analysis.signal.stop_loss + "\n" +
        "*TP:* " + analysis.signal.take_profit + "\n\n" +
        "*Thesis:* " + analysis.technical_thesis;

      sendWhatsAppNotification(signalMessage);
    }
  });
}

function createAutonomousTriggers() {
  ScriptApp.newTrigger('scanForTradeSignals')
      .timeBased()
      .everyHours(4)
      .create();

  ScriptApp.newTrigger('analyzeAndSummarizeWeek')
      .timeBased()
      .onWeekDay(ScriptApp.WeekDay.FRIDAY)
      .atHour(18)
      .create();
}
