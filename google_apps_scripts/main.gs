/****************************************************************
 * Dhaher Trading Plan AI - GOOGLE APPS SCRIPTS (ALL-IN-ONE)
 *
 * This file contains all the core functions for interacting
 * with the Google Sheet database.
 ****************************************************************/

// --- SPREADSHEET & API CONFIGURATION (Using Script Properties) ---
const props = PropertiesService.getScriptProperties();
const SPREADSHEET_ID = props.getProperty("SPREADSHEET_ID") || "1I8uVUlquRPwIc_cMKr-toHZ9qHW38uDom4TYdKexaoE";
const LLM7_API_KEY = props.getProperty("LLM7_API_KEY");
const LLM7_API_URL = props.getProperty("LLM7_API_URL") || "https://api.llm7.io/v1/chat/completions";
const WHATSAPP_API_URL = props.getProperty("WHATSAPP_API_URL");
const BOT_API_KEY = props.getProperty("BOT_API_KEY");
const USER_PHONE_NUMBER = props.getProperty("USER_PHONE_NUMBER") || "6285322624048";

// --- SHEET HANDLERS ---
const ss = SpreadsheetApp.openById(SPREADSHEET_ID);
const journalSheet = ss.getSheetByName("Journal");
const aiFeedbackSheet = ss.getSheetByName("AI Feedback");
const violationsSheet = ss.getSheetByName("Violations");
const weeklySummarySheet = ss.getSheetByName("Weekly Summary");
const settingsSheet = ss.getSheetByName("Settings");


/**
 * Central API endpoint for all requests from the Flutter app.
 */
function doPost(e) {
  try {
    const contents = JSON.parse(e.postData.contents);
    const { action, data } = contents;

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
      case "getAiMasterSummary": // For WhatsApp bot
        result = getAiMasterSummary(data.symbol);
        break;
      case "logForecast":
        result = logForecast(data);
        break;
      case "scanForTradeSignals":
        result = scanForTradeSignals();
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
    data.result,
    data.emotion_after,
    data.gpt_comment
  ]);
  return "Trade logged.";
}

function logViolation(data) {
  violationsSheet.appendRow(["V-" + new Date().getTime(), new Date(), data.tradeId, data.ruleBroken, data.justification]);

  // Emotional Lockout Trigger
  const recentViolations = violationsSheet.getLastRow() > 3 ? violationsSheet.getRange(violationsSheet.getLastRow() - 2, 1, 3, 1).getValues() : [];
  if (recentViolations.length === 3) {
    sendWhatsAppNotification("🚨 You've had 3 consecutive violations. Mandatory break required. Reflect on your psychology.");
  }

  return "Violation logged.";
}

// --- MODULE 2: GPT INTEGRATION ---

function getGptFeedback(data) {
  const { promptType, promptData, referenceId } = data;
  const promptTemplate = getPromptTemplate(promptType);
  const formattedPrompt = formatPrompt(promptTemplate, promptData);

  const payload = {
    "model": "gpt-4.5-turbo",
    "messages": [{ "role": "user", "content": formattedPrompt }],
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

// --- MODULE 3: MASTER SUMMARY (AUTONOMOUS) ---

function getAiMasterSummary(symbol) {
  const marketData = getComprehensiveMarketData(symbol);

  const analysis = getGptFeedback({
    promptType: 'MasterTradeAnalyst',
    promptData: {
      ...marketData,
      symbol: symbol,
      technical_json: JSON.stringify(marketData.technicals),
      news_json: JSON.stringify(marketData.news_headlines)
    },
    referenceId: 'SUMMARY-' + symbol + '-' + new Date().getTime()
  });

  return analysis;
}

// ... rest of the file (AnalyzeAndSummarizeWeek, etc.) remains similar but using props ...

function analyzeAndSummarizeWeek() {
  const journalData = journalSheet.getDataRange().getValues();
  const headers = journalData.shift();

  let winCount = 0;
  let tradeCount = journalData.length;
  let emotions = {};

  journalData.forEach(row => {
    let trade = headers.reduce((obj, header, i) => ({...obj, [header]: row[i]}), {});
    if(trade.Result === 'WIN') winCount++;
    emotions[trade.Mood] = (emotions[trade.Mood] || 0) + 1;
  });

  const dominantEmotion = Object.keys(emotions).reduce((a, b) => (emotions[a] > (emotions[b] || 0)) ? a : b, 'None');

  const analysisPromptData = {
    total_trades: tradeCount,
    win_rate: tradeCount > 0 ? ((winCount / tradeCount) * 100).toFixed(2) : 0,
    dominant_emotion: dominantEmotion,
    journal_summary: "User traded " + tradeCount + " times."
  };

  const weeklyFeedback = getGptFeedback({
    promptType: 'WeeklySummary',
    promptData: analysisPromptData,
    referenceId: 'WEEKLY-' + new Date().toISOString().slice(0, 10)
  });

  weeklySummarySheet.appendRow([
    'W-' + new Date().getTime(), new Date(), new Date(),
    analysisPromptData.win_rate, analysisPromptData.total_trades, JSON.stringify(weeklyFeedback)
  ]);

  sendWhatsAppNotification(`🚀 Your weekly summary is ready! Win Rate: ${analysisPromptData.win_rate}%. Open the app to see the full report.`);

  return weeklyFeedback;
}

function sendWhatsAppNotification(message) {
  if (!WHATSAPP_API_URL) return;

  const payload = {
    to: USER_PHONE_NUMBER,
    message: message,
    api_key: BOT_API_KEY
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

function getPromptTemplate(promptType) {
    const prompts = {
        'EntryValidation': `Setup saya:\n- Pair: {{Pair}}\n- Arah: {{Arah}}\n- SL: {{SL}}\n- TP: {{TP}}\n- Mood: {{Mood}}\n- Setup: {{Setup}}\nTolong validasi dan beri saran. Format JSON: {"validation_score": number, "is_valid_setup": boolean, "rule_violations": [], "emotional_warning": "", "tough_love_feedback": "", "detailed_explanation": ""}`,
        'EmotionalOverride': `Saya override entry. Mood saya {{Mood}}. Kenapa ini bisa terjadi? Format JSON: {"analysis": "", "advice": ""}`,
        'WeeklySummary': `Berikut data jurnal saya minggu ini:\n- Total Trades: {{total_trades}}\n- Win Rate: {{win_rate}}%\n- Emosi Dominan: {{dominant_emotion}}\nTolong beri analisa. Format JSON: {"technical_analysis": "", "emotional_analysis": "", "motivation": "", "suggestions": []}`,
        'MasterTradeAnalyst': `Analisislah data pasar berikut untuk {{symbol}}:\nTechnicals: {{technical_json}}\nNews: {{news_json}}\nCOT: {{cot_report}}\nEconomic Calendar: {{economic_calendar}}\nBeri bias, confidence score (1-10), dan signal (entry, sl, tp). Format JSON: {"final_bias": "", "confidence_score": 0, "technical_thesis": "", "fundamental_thesis": "", "positional_thesis": "", "signal": {"active": boolean, "entry": "", "stop_loss": "", "take_profit": ""}}`
    };
    return prompts[promptType] || '';
}

function formatPrompt(template, data) {
    return template.replace(/{{(\w+)}}/g, (placeholder, key) => data[key] || placeholder);
}

function exportSheetToJson(sheetName) {
  const sheet = ss.getSheetByName(sheetName);
  if (!sheet) throw new Error(`Sheet "${sheetName}" not found.`);
  const data = sheet.getDataRange().getValues();
  if (data.length < 1) return JSON.stringify([]);
  const headers = data[0];
  const rows = data.slice(1);
  const jsonArray = rows.map(row =>
    headers.reduce((obj, header, i) => ({...obj, [header]: row[i]}), {})
  );
  return JSON.stringify(jsonArray);
}

// --- TRIGGERS ---
function createWeeklyAnalysisTrigger() {
  ScriptApp.newTrigger('analyzeAndSummarizeWeek')
      .timeBased()
      .onWeekDay(ScriptApp.WeekDay.FRIDAY)
      .atHour(18)
      .create();
}

function createKillzoneReminderTrigger() {
    ScriptApp.newTrigger('sendKillzoneReminder')
      .timeBased()
      .everyDays(1)
      .atHour(8)
      .create();
}

function sendKillzoneReminder() {
    sendWhatsAppNotification("London Killzone is approaching. Prepare your mind and your charts. Stay disciplined.");
}

// --- MODULE 4: AUTONOMOUS SIGNAL GENERATION ---

function scanForTradeSignals() {
  const tradingPlanSheet = ss.getSheetByName("Trading Plan");
  if (!tradingPlanSheet) return;
  const tradingPlan = tradingPlanSheet.getDataRange().getValues();
  const symbolsToScan = tradingPlan.slice(1).map(row => row[0]);

  symbolsToScan.forEach(symbol => {
    const analysis = getAiMasterSummary(symbol);

    if (analysis.signal && analysis.signal.active && analysis.confidence_score >= 7) {
      const signalMessage = `
🚀 **New High-Conviction Trade Signal for ${symbol}** 🚀
**Bias:** ${analysis.final_bias} (Confidence: ${analysis.confidence_score}/10)
**Entry:** ${analysis.signal.entry}
**Stop Loss:** ${analysis.signal.stop_loss}
**Take Profit:** ${analysis.signal.take_profit}

*Thesis:*
- *Tech:* ${analysis.technical_thesis}
- *Funda:* ${analysis.fundamental_thesis}
- *COT:* ${analysis.positional_thesis}
      `;
      sendWhatsAppNotification(signalMessage);
    }
  });
}

function logForecast(forecastData) {
  const forecastSheet = ss.getSheetByName("Forecasts");
  if (!forecastSheet) return "Forecast sheet not found.";
  forecastSheet.appendRow([
    new Date(),
    forecastData.pair,
    forecastData.timeframe,
    forecastData.summary,
    forecastData.entry,
    forecastData.sl,
    forecastData.tp,
    forecastData.probability,
    JSON.stringify(forecastData.gptAnalysis)
  ]);
  return "Forecast logged successfully.";
}
