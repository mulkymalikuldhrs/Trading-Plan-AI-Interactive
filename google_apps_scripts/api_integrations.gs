/****************************************************************
 * MULKY AI TRADING OS - EXTERNAL API INTEGRATIONS
 *
 * This file contains functions for fetching data from various
 * financial and news APIs.
 ****************************************************************/

// --- API KEYS (Store securely in Script Properties) ---
const FINNHUB_API_KEY = PropertiesService.getScriptProperties().getProperty('FINNHUB_API_KEY');
const NEWS_API_KEY = PropertiesService.getScriptProperties().getProperty('NEWS_API_KEY');

/**
 * Fetches technical indicators for a given symbol.
 * @param {string} symbol - The trading symbol (e.g., 'AAPL', 'EUR/USD').
 * @returns {object} An object containing key technical indicators.
 */
function getTechnicalIndicators(symbol) {
  // For demonstration, we'll use Finnhub.io
  const url = `https://finnhub.io/api/v1/indicator?symbol=${symbol}&indicator=rsi,macd,sma&token=${FINNHUB_API_KEY}`;
  const response = UrlFetchApp.fetch(url, {'muteHttpExceptions': true});
  const data = JSON.parse(response.getContentText());

  // We would parse and return the most recent values here.
  return {
    rsi: data.rsi[data.rsi.length - 1],
    macd: data.macd[data.macd.length - 1],
    sma: data.sma[data.sma.length - 1]
  };
}

/**
 * Fetches the latest financial news for a given query.
 * @param {string} query - The search query (e.g., 'forex', 'inflation').
 * @returns {Array<string>} A list of news headlines.
 */
function getLatestNews(query) {
  // Using NewsAPI.org for this example
  const url = `https://newsapi.org/v2/everything?q=${query}&sortBy=publishedAt&pageSize=5&apiKey=${NEWS_API_KEY}`;
  const response = UrlFetchApp.fetch(url, {'muteHttpExceptions': true});
  const data = JSON.parse(response.getContentText());

  return data.articles.map(article => article.title);
}

/**
 * Fetches upcoming events from an economic calendar.
 * @returns {Array<object>} A list of upcoming economic events.
 */
function getEconomicCalendar() {
  const calSheet = ss.getSheetByName("Economic Calendar");
  if (!calSheet) {
    throw new Error("Economic Calendar sheet is missing. Please ensure it exists in your spreadsheet.");
  }

  const data = calSheet.getDataRange().getValues();
  if (data.length <= 1) return []; // Only headers or empty

  const headers = data.shift();
  return data.map(row => headers.reduce((obj, h, i) => ({...obj, [h.toLowerCase()]: row[i]}), {}));
}

/**
 * Fetches the latest Commitment of Traders data.
 * @returns {object} Parsed COT data for major currencies.
 */
function getCotData() {
  const cotSheet = ss.getSheetByName("COT Data");
  if (!cotSheet) {
    throw new Error("COT Data sheet is missing. Please ensure it exists in your spreadsheet.");
  }

  const data = cotSheet.getDataRange().getValues();
  if (data.length <= 1) return {};

  const headers = data.shift();
  const cotObj = {};
  data.forEach(row => {
    const symbol = row[0];
    cotObj[symbol] = headers.reduce((obj, h, i) => ({...obj, [h.toLowerCase()]: row[i]}), {});
  });
  return cotObj;
}

/**
 * A master function to gather all market data for analysis.
 * @param {string} symbol - The trading symbol.
 * @returns {object} A comprehensive object of all market data.
 */
function getComprehensiveMarketData(symbol) {
    const technicals = getTechnicalIndicators(symbol);
    const news = getLatestNews(symbol); // Or a broader query like 'forex'
    const calendar = getEconomicCalendar();
    const cot = getCotData();

    return {
        technicals: technicals,
        news_headlines: news,
        economic_calendar: calendar,
        cot_report: cot
    };
}
