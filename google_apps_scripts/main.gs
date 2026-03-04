/****************************************************************
 * Dhaher Trading Plan AI - GOOGLE APPS SCRIPTS (ALL-IN-ONE)
 *
 * This file contains all the core functions for interacting
 * with the Google Sheet database.
 ****************************************************************/

// --- SPREADSHEET & API CONFIGURATION ---
const scriptProperties = PropertiesService.getScriptProperties();
const SPREADSHEET_ID = scriptProperties.getProperty('SPREADSHEET_ID') || "YOUR_SPREADSHEET_ID";
const LLM7_API_KEY = scriptProperties.getProperty('LLM7_API_KEY');
const LLM7_API_URL = scriptProperties.getProperty('LLM7_API_URL') || "https://api.llm7.io/v1/chat/completions";
const WHATSAPP_API_URL = scriptProperties.getProperty('WHATSAPP_API_URL'); // URL to your running WhatsApp bot server/send
const BOT_API_KEY = scriptProperties.getProperty('BOT_API_KEY');
const USER_PHONE_NUMBER = scriptProperties.getProperty('USER_PHONE_NUMBER') || "YOUR_PHONE_NUMBER";

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
  const contents = JSON.parse(e.postData.contents);
  const { action, data } = contents;

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
        result = getForecast(data);
        break;
      case "logForecast":
        result = logForecast(data);
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
  // Order aligned with Trade.fromJson and Dhaher_Trading_Sheet_Template.md
  journalSheet.appendRow([
    "TRADE-" + new Date().getTime(), // 0: TradeID
    new Date(),                      // 1: Timestamp
    data.pair,                       // 2: Pair
    data.direction,                  // 3: Direction
    data.entry,                      // 4: EntryPrice
    "",                              // 5: ExitPrice (empty for new trades)
    data.sl,                         // 6: SL
    data.tp,                         // 7: TP
    data.result,                     // 8: Result
    0,                               // 9: PnL (zero for new trades)
    data.mood,                       // 10: Mood
    data.emotion_after,              // 11: Emotion_After
    data.gpt_comment,                // 12: GPT_Comment
    data.setup,                      // 13: Setup
    data.ai_status,                  // 14: AI_Status
    data.rrr                         // 15: RRR
  ]);
  return "Trade logged.";
}

function logViolation(data) {
  violationsSheet.appendRow(["V-" + new Date().getTime(), new Date(), data.tradeId, data.ruleBroken, data.justification]);

  // Emotional Lockout Trigger
  const lastRows = violationsSheet.getLastRow();
  if (lastRows >= 3) {
      const recentViolations = violationsSheet.getRange(lastRows - 2, 1, 3, 1).getValues();
      if (recentViolations.length === 3) {
        sendWhatsAppNotification("⚠️ You've had 3 consecutive violations. It's time for a mandatory break. Reflect on your actions.");
      }
  }

  return "Violation logged.";
}

// --- MODULE 2: GPT/LLM7 INTEGRATION ---

function getGptFeedback(data) {
  const { promptType, promptData, referenceId } = data;
  const promptTemplate = getPromptTemplate(promptType);
  const formattedPrompt = formatPrompt(promptTemplate, promptData);

  const payload = {
    "model": "gpt-4.5-turbo",
    "messages": [{ "role": "user", "content": formattedPrompt }],
    "temperature": 0.7,
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

  if (response.getResponseCode() !== 200) {
      throw new Error("LLM API Error: " + responseText);
  }

  const gptResponse = JSON.parse(responseText);
  let gptContent;
  try {
      gptContent = JSON.parse(gptResponse.choices[0].message.content);
  } catch (e) {
      gptContent = gptResponse.choices[0].message.content; // Fallback to raw string
  }

  aiFeedbackSheet.appendRow(["AI-F-" + new Date().getTime(), new Date(), referenceId, promptType, JSON.stringify(gptContent)]);

  return gptContent;
}

// --- MODULE 3: WEEKLY ANALYZER ---

function analyzeAndSummarizeWeek() {
  const journalData = journalSheet.getDataRange().getValues();
  const headers = journalData.shift();

  if (journalData.length === 0) return { message: "No trades to analyze this week." };

  let winCount = 0;
  let tradeCount = journalData.length;
  let emotions = {};

  journalData.forEach(row => {
    // Indices based on aligned logTrade order
    if(row[8] === 'WIN') winCount++;
    const mood = row[10];
    emotions[mood] = (emotions[mood] || 0) + 1;
  });

  const dominantEmotion = Object.keys(emotions).reduce((a, b) => emotions[a] > emotions[b] ? a : b, 'None');

  const analysisPromptData = {
    total_trades: tradeCount,
    win_rate: ((winCount / tradeCount) * 100).toFixed(2),
    dominant_emotion: dominantEmotion,
    journal_summary: `User completed ${tradeCount} trades with a ${((winCount / tradeCount) * 100).toFixed(2)}% win rate.`
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

  sendWhatsAppNotification(`🚀 Your weekly summary is ready! Dominant emotion: ${dominantEmotion}. Win Rate: ${analysisPromptData.win_rate}%. Open the app to see the full report.`);

  return weeklyFeedback;
}


// --- MODULE 4: NOTIFICATION SYSTEM ---

function sendWhatsAppNotification(message) {
  if (!USER_PHONE_NUMBER || !WHATSAPP_API_URL) {
      Logger.log("WhatsApp configuration missing.");
      return;
  }

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
    const response = UrlFetchApp.fetch(WHATSAPP_API_URL, options);
    if (response.getResponseCode() !== 200) {
        Logger.log("WhatsApp Bot API Error: " + response.getContentText());
    }
  } catch (e) {
    Logger.log("Could not send WhatsApp message: " + e.message);
  }
}

// --- UTILITIES ---

function getPromptTemplate(promptType) {
    const prompts = {
        'EntryValidation': `Setup saya:\n- Pair: {{Pair}}\n- Arah: {{Arah}}\n- SL: {{SL}}\n- TP: {{TP}}\n- Mood: {{Mood}}\n- Setup: {{Setup}}\nTolong validasi dan beri saran. Jika saya override, tolong bantu refleksi. Return JSON: {"validation_score": 1-10, "is_valid_setup": bool, "rule_violations": [], "emotional_warning": "", "tough_love_feedback": "", "detailed_explanation": ""}`,
        'EmotionalOverride': `Saya override entry. Mood saya {{Mood}}. Kenapa ini bisa terjadi dan bagaimana saya bisa memperbaiki mindset saya? Return JSON: {"analysis": "", "coaching_tip": ""}`,
        'WeeklySummary': `Berikut data jurnal saya minggu ini:\n- Total Trades: {{total_trades}}\n- Win Rate: {{win_rate}}%\n- Emosi Dominan: {{dominant_emotion}}\n- Ringkasan: {{journal_summary}}\nTolong beri analisa teknikal, emosi dominan, motivasi, dan saran peningkatan minggu depan. Return JSON: {"technical_analysis": "", "emotional_insight": "", "motivation": "", "action_plan": []}`,
        'MasterTradeAnalyst': `Analyze market for {{symbol}} using technicals: {{technicals}}, news: {{news_headlines}}, COT: {{cot_report}}, and calendar: {{economic_calendar}}. Return JSON: {"final_bias": "Bullish/Bearish/Neutral", "confidence_score": 1-10, "technical_thesis": "", "fundamental_thesis": "", "positional_thesis": "", "signal": {"active": bool, "entry": float, "stop_loss": float, "take_profit": float}}`,
        'Forecast': `Generate a {{days}}-day forecast for {{pair}} on {{timeframe}} timeframe. Return JSON: {"bias": "Bullish/Bearish", "probability": 0-100, "entry_zone": "", "confirmation": "", "stop_loss": float, "take_profit": float, "analysis": ""}`
    };
    return prompts[promptType] || '';
}

function formatPrompt(template, data) {
    return template.replace(/{{(\w+)}}/g, (placeholder, key) => {
        let val = data[key];
        if (typeof val === 'object') return JSON.stringify(val);
        return val || placeholder;
    });
}

function exportSheetToJson(sheetName) {
  const sheet = ss.getSheetByName(sheetName);
  if (!sheet) throw new Error(`Sheet "${sheetName}" not found.`);
  const [headers, ...rows] = sheet.getDataRange().getValues();
  const jsonArray = rows.map(row =>
    headers.reduce((obj, header, i) => ({...obj, [header]: row[i]}), {})
  );
  return JSON.stringify(jsonArray);
}

// --- INTELLIGENCE ACTIONS ---

function getAiMasterSummary(symbol) {
    const marketData = getComprehensiveMarketData(symbol);
    const analysis = getGptFeedback({
      promptType: 'MasterTradeAnalyst',
      promptData: { ...marketData, symbol: symbol },
      referenceId: 'SUMMARY-' + symbol + '-' + new Date().getTime()
    });

    // Unify: return BOTH analysis and the data used for the analysis.
    return {
      ...analysis,
      rawData: marketData
    };
}

function getForecast(data) {
    const { pair, timeframe, days } = data;
    const marketData = getComprehensiveMarketData(pair);
    return getGptFeedback({
      promptType: 'Forecast',
      promptData: { ...marketData, pair: pair, timeframe: timeframe, days: days },
      referenceId: 'FORECAST-' + pair + '-' + new Date().getTime()
    });
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
    sendWhatsAppNotification("🔔 London Killzone is approaching. Prepare your mind and your charts. Stay disciplined.");
}

function scanForTradeSignals() {
  const tradingPlanSheet = ss.getSheetByName("Trading Plan");
  if (!tradingPlanSheet) return;

  const tradingPlan = tradingPlanSheet.getDataRange().getValues();
  const symbolsToScan = tradingPlan.slice(1).map(row => row[0]);

  symbolsToScan.forEach(symbol => {
    const analysis = getAiMasterSummary(symbol);

    if (analysis.signal && analysis.signal.active && analysis.signal.confidence_score >= 8) {
      const signalMessage = `
🚀 **High-Conviction Signal: ${symbol}** 🚀
**Bias:** ${analysis.final_bias} (Confidence: ${analysis.confidence_score}/10)
**Entry:** ${analysis.signal.entry}
**Stop Loss:** ${analysis.signal.stop_loss}
**Take Profit:** ${analysis.signal.take_profit}

*Thesis:*
- Tech: ${analysis.technical_thesis.substring(0, 100)}...
- Funda: ${analysis.fundamental_thesis.substring(0, 100)}...
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
