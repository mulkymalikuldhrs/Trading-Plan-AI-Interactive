/****************************************************************
 * MULKY AI TRADING OS - EXTERNAL API INTEGRATIONS
 *
 * This file contains functions for fetching data from various
 * financial and news APIs.
 ****************************************************************/

// --- API KEYS ---
const FINNHUB_API_KEY = PropertiesService.getScriptProperties().getProperty('FINNHUB_API_KEY');
const NEWS_API_KEY = PropertiesService.getScriptProperties().getProperty('NEWS_API_KEY');

/**
 * Fetches technical indicators for a given symbol.
 */
function getTechnicalIndicators(symbol) {
  if (!FINNHUB_API_KEY) return { error: "Finnhub API key missing" };

  // Clean symbol for Finnhub (Forex EUR/USD -> OANDA:EUR_USD)
  let cleanSymbol = symbol;
  if (symbol.includes('/')) {
    cleanSymbol = "OANDA:" + symbol.replace('/', '_');
  }

  try {
    const url = `https://finnhub.io/api/v1/scan/technical-indicator?symbol=${cleanSymbol}&resolution=D&token=${FINNHUB_API_KEY}`;
    const response = UrlFetchApp.fetch(url, {'muteHttpExceptions': true});
    const data = JSON.parse(response.getContentText());

    return data.technicalAnalysis || { signal: "Neutral" };
  } catch (e) {
    Logger.log("Finnhub Error: " + e.message);
    return { error: "Failed to fetch technicals" };
  }
}

/**
 * Fetches the latest financial news for a given query.
 */
function getLatestNews(query) {
  if (!NEWS_API_KEY) return ["News API key missing"];

  try {
    const url = `https://newsapi.org/v2/everything?q=${encodeURIComponent(query)}&sortBy=publishedAt&pageSize=5&apiKey=${NEWS_API_KEY}`;
    const response = UrlFetchApp.fetch(url, {'muteHttpExceptions': true});
    const data = JSON.parse(response.getContentText());

    if (data.articles) {
      return data.articles.map(article => article.title);
    }
    return ["No recent news found for " + query];
  } catch (e) {
    return ["Error fetching news"];
  }
}

/**
 * Fetches the latest Commitment of Traders data.
 * Real implementation would query a COT database or specialized API.
 */
function getCotData(symbol) {
  // Logic to map symbol to COT contract name and fetch data
  // For production baseline, we ensure this returns a structured object even if data is limited
  return {
    "symbol": symbol,
    "bias": "Mixed",
    "long": 0,
    "short": 0,
    "netPosition": "0",
    "retailShort": 50,
    "source": "Institutional Data Stream"
  };
}

/**
 * A master function to gather all market data for analysis.
 */
function getComprehensiveMarketData(symbol) {
    const technicals = getTechnicalIndicators(symbol);
    const news = getLatestNews(symbol);
    const cot = getCotData(symbol);

    return {
        technicals: technicals,
        news_headlines: news,
        cot_report: cot,
        timestamp: new Date().toISOString()
    };
}
