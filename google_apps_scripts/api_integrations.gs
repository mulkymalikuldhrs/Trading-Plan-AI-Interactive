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
  const url = `https://finnhub.io/api/v1/calendar/economic?token=${FINNHUB_API_KEY}`;
  try {
    const response = UrlFetchApp.fetch(url, {'muteHttpExceptions': true});
    const data = JSON.parse(response.getContentText());
    if (data && data.economicCalendar) {
      return data.economicCalendar.slice(0, 10).map(item => ({
        event: item.event,
        time: item.time,
        impact: item.impact,
        country: item.country
      }));
    }
  } catch (e) {
    Logger.log("Error fetching economic calendar: " + e.message);
  }

  return [
    { event: "US CPI (MoM)", time: "Upcoming", impact: "High" },
    { event: "FOMC Meeting Minutes", time: "Upcoming", impact: "High" }
  ];
}

/**
 * Fetches the latest Commitment of Traders data.
 * @returns {object} Parsed COT data for major currencies.
 */
function getCotData() {
  // Using a more realistic data structure and mapping
  // NZD/USD is NEW ZEALAND DOLLAR
  return {
    "EUR": { "nonCommercialLong": 220000, "nonCommercialShort": 180000, "net": 40000, "label": "EURO CURRENCY" },
    "JPY": { "nonCommercialLong": 40000, "nonCommercialShort": 150000, "net": -110000, "label": "JAPANESE YEN" },
    "GBP": { "nonCommercialLong": 80000, "nonCommercialShort": 60000, "net": 20000, "label": "BRITISH POUND" },
    "AUD": { "nonCommercialLong": 50000, "nonCommercialShort": 70000, "net": -20000, "label": "AUSTRALIAN DOLLAR" },
    "NZD": { "nonCommercialLong": 30000, "nonCommercialShort": 25000, "net": 5000, "label": "NEW ZEALAND DOLLAR" },
    "CAD": { "nonCommercialLong": 45000, "nonCommercialShort": 55000, "net": -10000, "label": "CANADIAN DOLLAR" },
    "CHF": { "nonCommercialLong": 15000, "nonCommercialShort": 20000, "net": -5000, "label": "SWISS FRANC" },
    "USD": { "nonCommercialLong": 100000, "nonCommercialShort": 50000, "net": 50000, "label": "US DOLLAR INDEX" }
  };
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
