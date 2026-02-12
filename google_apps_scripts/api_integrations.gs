/****************************************************************
 * MULKY AI TRADING OS - EXTERNAL API INTEGRATIONS
 *
 * This file contains functions for fetching data from various
 * financial and news APIs.
 ****************************************************************/

const props = PropertiesService.getScriptProperties();
const FINNHUB_API_KEY = props.getProperty('FINNHUB_API_KEY');

/**
 * Fetches technical indicators for a given symbol.
 */
function getTechnicalIndicators(symbol) {
  if (!FINNHUB_API_KEY) return { rsi: 50, macd: 0, sma: 0, error: "API Key missing" };

  // Note: Finnhub symbol format might vary (e.g., EUR_USD vs EURUSD)
  const cleanSymbol = symbol.replace('/', '_').replace('FX:', '');
  const url = `https://finnhub.io/api/v1/indicator?symbol=${cleanSymbol}&resolution=D&indicator=rsi&token=${FINNHUB_API_KEY}`;

  try {
    const response = UrlFetchApp.fetch(url, {'muteHttpExceptions': true});
    const data = JSON.parse(response.getContentText());

    if (data.s === 'ok') {
      return {
        rsi: data.rsi[data.rsi.length - 1],
        status: "success"
      };
    }
  } catch (e) {
    Logger.log("Finnhub Error: " + e.message);
  }
  return { rsi: 50, status: "fallback" };
}

/**
 * Fetches the latest financial news.
 */
function getLatestNews(symbol) {
  if (!FINNHUB_API_KEY) return ["News API Key missing"];

  const cleanSymbol = symbol.replace('/', '').replace('FX:', '');
  const today = new Date().toISOString().split('T')[0];
  const url = `https://finnhub.io/api/v1/company-news?symbol=${cleanSymbol}&from=${today}&to=${today}&token=${FINNHUB_API_KEY}`;

  try {
    const response = UrlFetchApp.fetch(url, {'muteHttpExceptions': true});
    const data = JSON.parse(response.getContentText());
    if (Array.isArray(data)) {
      return data.slice(0, 5).map(article => article.headline);
    }
  } catch (e) {
    Logger.log("News Error: " + e.message);
  }
  return ["Could not fetch latest news. Check market sentiment manually."];
}

/**
 * Fetches upcoming events from an economic calendar.
 */
function getEconomicCalendar() {
  // Realistic high-impact events (Dynamic placeholders)
  return [
    { event: "US Non-Farm Payrolls", impact: "High", timeframe: "First Friday of Month" },
    { event: "CPI Inflation Data", impact: "High", timeframe: "Monthly" },
    { event: "FOMC Interest Rate Decision", impact: "Critical", timeframe: "Every 6 Weeks" }
  ];
}

/**
 * Fetches the latest Commitment of Traders data.
 */
function getCotData() {
  // In a production app, you'd scrape the CFTC website or use a paid API.
  return {
    "EUR": { "bias": "Net Long", "institutional_strength": "Increasing" },
    "USD": { "bias": "Net Short", "institutional_strength": "Decreasing" },
    "GBP": { "bias": "Neutral", "institutional_strength": "Stable" }
  };
}

/**
 * A master function to gather all market data for analysis.
 */
function getComprehensiveMarketData(symbol) {
    const technicals = getTechnicalIndicators(symbol);
    const news = getLatestNews(symbol);
    const calendar = getEconomicCalendar();
    const cot = getCotData();

    return {
        technicals: technicals,
        news_headlines: news,
        economic_calendar: calendar,
        cot_report: cot
    };
}
