/****************************************************************
 * MULKY AI TRADING OS - EXTERNAL API INTEGRATIONS
 *
 * This file contains functions for fetching data from various
 * financial and news APIs.
 ****************************************************************/

const FINNHUB_API_KEY = PropertiesService.getScriptProperties().getProperty('FINNHUB_API_KEY');

/**
 * Fetches technical indicators for a given symbol from Finnhub.
 */
function getTechnicalIndicators(symbol) {
  // Convert symbol if needed (e.g., EUR/USD to OANDA:EUR_USD or FX:EURUSD)
  const formattedSymbol = symbol.replace("/", "");
  const url = `https://finnhub.io/api/v1/scan/technical-indicator?symbol=${formattedSymbol}&resolution=D&token=${FINNHUB_API_KEY}`;

  try {
    const response = UrlFetchApp.fetch(url, {'muteHttpExceptions': true});
    const data = JSON.parse(response.getContentText());
    return data.technicalAnalysis || { trend: "Neutral", signal: "None" };
  } catch (e) {
    return { error: e.message };
  }
}

/**
 * Fetches the latest financial news Headlines from Finnhub.
 */
function getLatestNews(symbol) {
  const now = new Date();
  const oneWeekAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);
  const fromDate = oneWeekAgo.toISOString().split('T')[0];
  const toDate = now.toISOString().split('T')[0];

  const url = `https://finnhub.io/api/v1/company-news?symbol=${symbol}&from=${fromDate}&to=${toDate}&token=${FINNHUB_API_KEY}`;

  try {
    const response = UrlFetchApp.fetch(url, {'muteHttpExceptions': true});
    const articles = JSON.parse(response.getContentText());
    return articles.slice(0, 5).map(a => a.headline);
  } catch (e) {
    return ["Could not fetch news."];
  }
}

/**
 * Fetches upcoming events from an economic calendar.
 */
function getEconomicCalendar() {
  // Using Finnhub Economic Calendar
  const url = `https://finnhub.io/api/v1/calendar/economic?token=${FINNHUB_API_KEY}`;

  try {
    const response = UrlFetchApp.fetch(url, {'muteHttpExceptions': true});
    const data = JSON.parse(response.getContentText());
    return data.economicCalendar.slice(0, 10).filter(e => e.importance >= 2);
  } catch (e) {
    return [];
  }
}

/**
 * Fetches the latest Commitment of Traders data.
 * Real implementation would parse CFTC CSV or use a dedicated API.
 */
function getCotData() {
  // This is a mapping to real CFTC names for the parser
  const symbolMap = {
    "EUR": "EURO CURRENCY",
    "GBP": "BRITISH POUND",
    "JPY": "JAPANESE YEN",
    "AUD": "AUSTRALIAN DOLLAR",
    "CAD": "CANADIAN DOLLAR",
    "CHF": "SWISS FRANC",
    "NZD": "NEW ZEALAND DOLLAR",
    "GOLD": "GOLD - COMMODITY EXCHANGE INC."
  };

  // Mocking real data structure but intended to be replaced by a parser for:
  // https://www.cftc.gov/dea/futures/deacmesf.htm

  return {
    "EUR": { "long": 210000, "short": 150000, "net": 60000 },
    "JPY": { "long": 45000, "short": 120000, "net": -75000 },
    "GBP": { "long": 85000, "short": 60000, "net": 25000 },
    "GOLD": { "long": 300000, "short": 50000, "net": 250000 }
  };
}

/**
 * A master function to gather all market data for analysis.
 */
function getComprehensiveMarketData(symbol) {
    return {
        technicals: getTechnicalIndicators(symbol),
        news_headlines: getLatestNews(symbol),
        economic_calendar: getEconomicCalendar(),
        cot_report: getCotData()
    };
}
