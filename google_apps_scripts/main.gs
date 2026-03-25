/****************************************************************
 * Dhaher Trading Plan AI - GOOGLE APPS SCRIPTS (ALL-IN-ONE)
 *
 * This file contains all the core functions for interacting
 * with the Google Sheet database.
 ****************************************************************/

// --- SPREADSHEET & API CONFIGURATION (Using Script Properties) ---
const props = PropertiesService.getScriptProperties();
const SPREADSHEET_ID = props.getProperty('SPREADSHEET_ID');
const LLM7_API_KEY = props.getProperty('LLM7_API_KEY');
const LLM7_API_URL = props.getProperty('LLM7_API_URL') || "https://api.llm7.io/v1/chat/completions";
const WHATSAPP_API_URL = props.getProperty('WHATSAPP_API_URL');
const BOT_API_KEY = props.getProperty('BOT_API_KEY'); // For securing GAS -> Bot and Client -> GAS

// --- SHEET HANDLERS ---
if (!SPREADSHEET_ID) {
  throw new Error("SPREADSHEET_ID not found in Script Properties.");
}
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
  const { action, data, api_key } = contents;

  // --- API KEY VALIDATION ---
  if (!BOT_API_KEY) {
    return ContentService.createTextOutput(JSON.stringify({ "status": "error", "message": "Server Error: BOT_API_KEY not configured in Script Properties" }))
      .setMimeType(ContentService.MimeType.JSON);
  }

  if (api_key !== BOT_API_KEY) {
    return ContentService.createTextOutput(JSON.stringify({ "status": "error", "message": "Unauthorized: Invalid API Key" }))
      .setMimeType(ContentService.MimeType.JSON);
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
      default:
        throw new Error("Invalid action specified.");
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
    "TRADE-" + new Date().getTime(), new Date(), data.pair, data.direction, data.entry, data.sl, data.tp, data.rrr,
    data.setup, data.mood, data.ai_status, data.result, data.emotion_after, data.gpt_comment
  ]);
  return "Trade logged.";
}

function logViolation(data) {
  violationsSheet.appendRow(["V-" + new Date().getTime(), new Date(), data.tradeId, data.ruleBroken, data.justification]);

  // Emotional Lockout Trigger
  const recentViolations = violationsSheet.getLastRow() > 3 ? violationsSheet.getRange(violationsSheet.getLastRow() - 2, 1, 3, 1).getValues() : [];
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
    "model": "gpt-4o", // Using a more standard model name for compatibility
    "messages": [
      { "role": "system", "content": "You are a professional trading analyst. Always respond in valid JSON format." },
      { "role": "user", "content": formattedPrompt }
    ],
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
  if (response.getResponseCode() !== 200) {
    throw new Error("AI API Error: " + response.getContentText());
  }

  const gptResponse = JSON.parse(response.getContentText());
  let gptContent;
  try {
    gptContent = JSON.parse(gptResponse.choices[0].message.content);
  } catch (e) {
    // If not JSON, return as a summary object
    gptContent = { "summary": gptResponse.choices[0].message.content };
  }

  aiFeedbackSheet.appendRow(["AI-F-" + new Date().getTime(), new Date(), referenceId, promptType, JSON.stringify(gptContent)]);

  return gptContent;
}

// --- MODULE 3: WEEKLY ANALYZER ---

function analyzeAndSummarizeWeek() {
  const journalData = journalSheet.getDataRange().getValues();
  const headers = journalData.shift();

  // Simple analysis (can be expanded)
  let winCount = 0;
  let tradeCount = journalData.length;
  let emotions = {};

  journalData.forEach(row => {
    let trade = headers.reduce((obj, header, i) => ({...obj, [header]: row[i]}), {});
    if(trade.Result === 'WIN') winCount++;
    emotions[trade.Mood] = (emotions[trade.Mood] || 0) + 1;
  });

  const dominantEmotion = Object.keys(emotions).reduce((a, b) => emotions[a] > emotions[b] ? a : b, 'None');

  const analysisPromptData = {
    total_trades: tradeCount,
    win_rate: ((winCount / tradeCount) * 100).toFixed(2),
    dominant_emotion: dominantEmotion,
    journal_summary: "User traded " + tradeCount + " times." // Simple summary
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
  const userPhoneNumber = props.getProperty('USER_PHONE_NUMBER');
  if (!userPhoneNumber || !WHATSAPP_API_URL) return;

  const payload = {
    to: userPhoneNumber,
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

// --- UTILITIES ---

function getPromptTemplate(promptType) {
    // In a production app, this would fetch from a dedicated "Prompts" sheet.
    const prompts = {
        'EntryValidation': `Setup saya:\n- Pair: {{Pair}}\n- Arah: {{Arah}}\n- SL: {{SL}}\n- TP: {{TP}}\n- Mood: {{Mood}}\n- Setup: {{Setup}}\nTolong validasi dan beri saran. Jika saya override, tolong bantu refleksi.`,
        'EmotionalOverride': `Saya override entry. Mood saya {{Mood}}. Kenapa ini bisa terjadi dan bagaimana saya bisa memperbaiki mindset saya?`,
        'WeeklySummary': `Berikut data jurnal saya minggu ini:\n- Total Trades: {{total_trades}}\n- Win Rate: {{win_rate}}%\n- Emosi Dominan: {{dominant_emotion}}\n- Ringkasan: {{journal_summary}}\nTolong beri analisa teknikal, emosi dominan, motivasi, dan saran peningkatan minggu depan.`,
        'MasterTradeAnalyst': `Analisa pasar lengkap untuk {{symbol}}:\nTechnical: {{technicals}}\nNews: {{news_headlines}}\nCalendar: {{economic_calendar}}\nCOT: {{cot_report}}\n\nTolong berikan:\n1. Final bias (Bullish/Bearish/Neutral)\n2. Confidence score (1-10)\n3. Technical thesis\n4. Fundamental thesis\n5. Positional (COT) thesis\n6. Signal (active: true/false, entry, stop_loss, take_profit)\n\nFormat sebagai JSON.`,
        'Forecast': `Generate a detailed multi-day forecast for {{pair}} (Timeframe: {{timeframe}}, Horizon: {{days}} days). Use context: {{full_prompt}}. Format output as JSON with keys: bias, entry_zone, confirmation, stop_loss, take_profit, probability, is_tradeable.`
    };
    return prompts[promptType] || '';
}

function formatPrompt(template, data) {
    return template.replace(/{{(\w+)}}/g, (placeholder, key) => data[key] || placeholder);
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

// --- TRIGGERS ---
// Manually create time-based triggers in Apps Script UI to run these.
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
      .atHour(8) // e.g., 8 AM for London Killzone
      .create();
}

function sendKillzoneReminder() {
    sendWhatsAppNotification("London Killzone is approaching. Prepare your mind and your charts. Stay disciplined.");
}

// --- MODULE 5: AUTONOMOUS SIGNAL GENERATION ---

/**
 * Scans for trading opportunities based on user's trading plan.
 * This function is designed to be run on a time-based trigger (e.g., every hour).
 */
function scanForTradeSignals() {
  // 1. Get user's trading plan (e.g., preferred symbols) from Settings sheet
  const tradingPlan = ss.getSheetByName("Trading Plan").getDataRange().getValues();
  const symbolsToScan = tradingPlan.slice(1).map(row => row[0]); // Assumes symbol is in the first column

  symbolsToScan.forEach(symbol => {
    // 2. Gather all market data
    const marketData = getComprehensiveMarketData(symbol);

    // 3. Get analysis from AI
    const analysis = getGptFeedback({
      promptType: 'MasterTradeAnalyst',
      promptData: { ...marketData, symbol: symbol },
      referenceId: 'SIGNAL-' + symbol + '-' + new Date().getTime()
    });

    // 4. If a high-confidence signal is generated, send it
    if (analysis.signal && analysis.signal.active && analysis.signal.confidence_score >= 7) {
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

        (This is not financial advice. Always do your own research.)
      `;

      // Send via WhatsApp
      sendWhatsAppNotification(signalMessage);

      // We would also push this to a 'Signals' table/sheet to be displayed in the app
    }
  });
}

function logForecast(forecastData) {
  const forecastSheet = ss.getSheetByName("Forecasts");
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
