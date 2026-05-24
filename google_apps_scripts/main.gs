/****************************************************************
 * Dhaher Trading Plan AI - GOOGLE APPS SCRIPTS (ALL-IN-ONE)
 *
 * This file contains all the core functions for interacting
 * with the Google Sheet database.
 ****************************************************************/

// --- SPREADSHEET & API CONFIGURATION ---
const SPREADSHEET_ID = PropertiesService.getScriptProperties().getProperty('SPREADSHEET_ID') || "1I8uVUlquRPwIc_cMKr-toHZ9qHW38uDom4TYdKexaoE";
const LLM7_API_KEY = PropertiesService.getScriptProperties().getProperty('LLM7_API_KEY');
const LLM7_API_URL = "https://api.llm7.io/v1/chat/completions";
const WHATSAPP_API_URL = PropertiesService.getScriptProperties().getProperty('WHATSAPP_BOT_URL') || "http://localhost:3000/send";

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

  // Security check
  const APP_API_KEY = PropertiesService.getScriptProperties().getProperty('APP_API_KEY');
  if (data.apiKey !== APP_API_KEY) {
     return ContentService.createTextOutput(JSON.stringify({ "status": "error", "message": "Unauthorized access." }))
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
      case "getMarketData":
        result = getComprehensiveMarketData(data.symbol);
        break;
      case "getAiMasterSummary":
        result = getAiMasterSummary(data.symbol);
        break;
      case "getForecast":
        result = getForecast(data);
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
    data.setup, data.mood, data.ai_status, data.result, data.emotion_after, data.gpt_comment, data.pnl
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
    "model": "gpt-4.5-turbo",
    "messages": [{ "role": "user", "content": formattedPrompt }],
    "temperature": 0.8,
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

// --- MODULE 3: WEEKLY ANALYZER ---

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

  const dominantEmotion = Object.keys(emotions).reduce((a, b) => emotions[a] > emotions[b] ? a : b, 'None');

  const analysisPromptData = {
    total_trades: tradeCount,
    win_rate: ((winCount / tradeCount) * 100).toFixed(2),
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

  sendWhatsAppNotification(`🚀 Your weekly summary is ready! Dominant emotion: ${dominantEmotion}. Win Rate: ${analysisPromptData.win_rate}%. Open the app to see the full report.`);

  return weeklyFeedback;
}


// --- MODULE 4: NOTIFICATION SYSTEM ---

function sendWhatsAppNotification(message) {
  const userPhoneNumber = PropertiesService.getScriptProperties().getProperty('USER_PHONE_NUMBER') || "6285322624048";
  if (!userPhoneNumber) return;

  const payload = {
    to: userPhoneNumber,
    message: message
  };

  const options = {
    'method': 'post',
    'contentType': 'application/json',
    'payload': JSON.stringify(payload)
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
        'EntryValidation': `Setup saya:\n- Pair: {{Pair}}\n- Arah: {{Arah}}\n- SL: {{SL}}\n- TP: {{TP}}\n- Mood: {{Mood}}\n- Setup: {{Setup}}\nTolong validasi dan beri saran. Jika saya override, tolong bantu refleksi.`,
        'EmotionalOverride': `Saya override entry. Mood saya {{Mood}}. Kenapa ini bisa terjadi dan bagaimana saya bisa memperbaiki mindset saya?`,
        'WeeklySummary': `Berikut data jurnal saya minggu ini:\n- Total Trades: {{total_trades}}\n- Win Rate: {{win_rate}}%\n- Emosi Dominan: {{dominant_emotion}}\n- Ringkasan: {{journal_summary}}\nTolong beri analisa teknikal, emosi dominan, motivasi, dan saran peningkatan minggu depan.`,
        'MasterTradeAnalyst': `Analisa pasar lengkap untuk {{symbol}}:\nTechnicals: {{technicals}}\nNews: {{news_headlines}}\nCalendar: {{economic_calendar}}\nCOT: {{cot_report}}\nTolong berikan bias akhir, skor keyakinan (1-10), dan signal entry jika ada (JSON format).`,
        'Forecast': `Berikan prakiraan {{days}} hari untuk {{pair}} pada timeframe {{timeframe}}. Gunakan data pasar saat ini. Output JSON: bias, entry_zone, confirmation, stop_loss, take_profit, probability, is_tradeable, chart_spots (list of [x, y] coordinates for a line chart).`
    };
    return prompts[promptType] || '';
}

function formatPrompt(template, data) {
    return template.replace(/{{(\w+)}}/g, (placeholder, key) => data[key] ? (typeof data[key] === 'object' ? JSON.stringify(data[key]) : data[key]) : placeholder);
}

function exportSheetToJson(sheetName) {
  const sheet = ss.getSheetByName(sheetName);
  if (!sheet) throw new Error(`Sheet "${sheetName}" not found.`);
  const [headers, ...rows] = sheet.getDataRange().getValues();
  const jsonArray = rows.map(row =>
    headers.reduce((obj, header, i) => ({...obj, [header]: row[i]}), {})
  );
  return jsonArray; // Return as object, doPost handles JSON stringify
}

// --- MODULE 5: AUTONOMOUS SIGNAL GENERATION ---

function getAiMasterSummary(symbol) {
  const marketData = getComprehensiveMarketData(symbol);
  const analysis = getGptFeedback({
    promptType: 'MasterTradeAnalyst',
    promptData: { ...marketData, symbol: symbol },
    referenceId: 'MASTER-SUMMARY-' + symbol + '-' + new Date().getTime()
  });
  return {
    ...analysis,
    market_data: marketData // Include raw data for the frontend to display
  };
}

function getForecast(data) {
  const marketData = getComprehensiveMarketData(data.pair);
  return getGptFeedback({
    promptType: 'Forecast',
    promptData: { ...marketData, ...data },
    referenceId: 'FORECAST-' + data.pair + '-' + new Date().getTime()
  });
}

function scanForTradeSignals() {
  const tradingPlanSheet = ss.getSheetByName("Trading Plan");
  if (!tradingPlanSheet) return;
  const symbolsToScan = tradingPlanSheet.getDataRange().getValues().slice(1).map(row => row[0]);

  symbolsToScan.forEach(symbol => {
    const analysis = getAiMasterSummary(symbol);

    if (analysis.signal && analysis.signal.active && analysis.signal.confidence_score >= 8) {
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
