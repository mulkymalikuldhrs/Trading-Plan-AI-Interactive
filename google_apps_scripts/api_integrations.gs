/****************************************************************
 * MULKY AI TRADING OS - EXTERNAL API INTEGRATIONS
 *
 * This file contains functions for fetching data from various
 * financial and news APIs.
 ****************************************************************/

const FINNHUB_API_KEY = PropertiesService.getScriptProperties().getProperty('FINNHUB_API_KEY');
const NEWS_API_KEY = PropertiesService.getScriptProperties().getProperty('NEWS_API_KEY');

/**
 * Fetches technical indicators for a given symbol.
 */
function getTechnicalIndicators(symbol) {
  // Handle Forex Symbols for Finnhub (e.g., EUR/USD -> OANDA:EUR_USD)
  let formattedSymbol = symbol.toUpperCase();
  if (formattedSymbol.includes('/')) {
    formattedSymbol = 'OANDA:' + formattedSymbol.replace('/', '_');
  }

  const url = `https://finnhub.io/api/v1/scan/technical-indicator?symbol=${formattedSymbol}&resolution=D&token=${FINNHUB_API_KEY}`;

  try {
    const response = UrlFetchApp.fetch(url, {'muteHttpExceptions': true});
    const data = JSON.parse(response.getContentText());

    if (data.technicalAnalysis) {
      return {
        signal: data.technicalAnalysis.count.buy > data.technicalAnalysis.count.sell ? 'BUY' : 'SELL',
        buyCount: data.technicalAnalysis.count.buy,
        sellCount: data.technicalAnalysis.count.sell,
        neutralCount: data.technicalAnalysis.count.neutral,
        indicator: data.technicalAnalysis.signal
      };
    }
  } catch (e) {
    Logger.log("Finnhub Technicals Failed: " + e.message);
  }

  return { signal: 'NEUTRAL', error: 'Data unavailable' };
}

/**
 * Fetches the latest financial news.
 */
function getLatestNews(query) {
  if (!NEWS_API_KEY) return ["News API key not configured."];

  const url = `https://newsapi.org/v2/everything?q=${encodeURIComponent(query)}&sortBy=publishedAt&pageSize=5&apiKey=${NEWS_API_KEY}`;

  try {
    const response = UrlFetchApp.fetch(url, {'muteHttpExceptions': true});
    const data = JSON.parse(response.getContentText());

    if (data.status === "ok") {
      return data.articles.map(article => `[${article.source.name}] ${article.title}`);
    }
  } catch (e) {
    Logger.log("NewsAPI Failed: " + e.message);
  }

  return ["Could not fetch news headlines."];
}

/**
 * Fetches upcoming events from an economic calendar via Finnhub.
 */
function getEconomicCalendar() {
  if (!FINNHUB_API_KEY) return [{ event: "Configuration Missing", impact: "N/A", time: "N/A" }];

  const today = new Date().toISOString().split('T')[0];
  const nextWeek = new Date(Date.now() + 7 * 24 * 60 * 60 * 1000).toISOString().split('T')[0];
  const url = `https://finnhub.io/api/v1/calendar/economic?from=${today}&to=${nextWeek}&token=${FINNHUB_API_KEY}`;

  try {
    const response = UrlFetchApp.fetch(url, {'muteHttpExceptions': true});
    const data = JSON.parse(response.getContentText());

    if (data.economicCalendar) {
      return data.economicCalendar
        .filter(e => e.impact === 'high' || e.impact === 'critical')
        .slice(0, 10)
        .map(e => ({
          event: e.event,
          impact: e.impact.toUpperCase(),
          time: e.time,
          country: e.country
        }));
    }
  } catch (e) {
    Logger.log("Economic Calendar Failed: " + e.message);
  }

  return [{ event: "Calendar Unavailable", impact: "N/A", time: "N/A" }];
}

/**
 * Fetches Commitment of Traders (COT) data.
 * Direct fetch and parse from CFTC (Legacy Report) to ensure 100% real institutional data.
 */
function getCotData(symbol) {
  // Normalize symbol (e.g., EURUSD -> EUR/USD)
  let normalizedSymbol = symbol.toUpperCase();
  if (!normalizedSymbol.includes('/') && normalizedSymbol.length === 6) {
    normalizedSymbol = normalizedSymbol.substring(0, 3) + '/' + normalizedSymbol.substring(3);
  }

  const cftcMap = {
    'EUR/USD': 'EURO CURRENCY',
    'GBP/USD': 'BRITISH POUND STERLING',
    'JPY/USD': 'JAPANESE YEN',
    'AUD/USD': 'AUSTRALIAN DOLLAR',
    'NZD/USD': 'NEW ZEALAND DOLLAR',
    'USD/CAD': 'CANADIAN DOLLAR',
    'USD/CHF': 'SWISS FRANC',
    'GOLD': 'GOLD - COMMODITY EXCHANGE INC.'
  };

  const assetName = cftcMap[normalizedSymbol] || normalizedSymbol;
  // Determine correct CFTC report URL (CME for Forex, COMEX for Gold)
  const url = (normalizedSymbol === 'GOLD' || normalizedSymbol === 'XAU/USD')
    ? "https://www.cftc.gov/dea/futures/deacmxl.txt" // COMEX
    : "https://www.cftc.gov/dea/futures/deacmcl.txt"; // CME

  try {
    const response = UrlFetchApp.fetch(url);
    const content = response.getContentText();
    const lines = content.split('\n');

    let found = false;
    let reportDate = "Unknown";
    const dateMatch = content.match(/COMMITMENTS AS OF (.*)/);
    if (dateMatch) reportDate = dateMatch[1].trim();

    for (let i = 0; i < lines.length; i++) {
      if (lines[i].includes(assetName)) {
        // The data is usually a few lines below the asset name
        for (let j = i; j < i + 15; j++) {
          const row = lines[j].trim();
          const parts = row.split(/\s+/);
          // Non-Commercial rows have at least 5 numeric columns
          if (parts.length >= 5 && !isNaN(parseInt(parts[0])) && !isNaN(parseInt(parts[1]))) {
            const long = parseInt(parts[0].replace(/,/g, ''));
            const short = parseInt(parts[1].replace(/,/g, ''));
            return {
              symbol: symbol,
              reportDate: reportDate,
              nonCommercialLong: long,
              nonCommercialShort: short,
              netPosition: long - short,
              bias: (long > short * 1.5) ? 'BULLISH' : (short > long * 1.5) ? 'BEARISH' : 'NEUTRAL',
              status: 'success'
            };
          }
        }
      }
    }
    throw new Error("Asset not found in CFTC report: " + assetName);
  } catch (e) {
    Logger.log("COT Fetch Error: " + e.message);
    return { symbol: symbol, status: 'error', message: e.message };
  }
}

/**
 * Gather all market data.
 */
function getComprehensiveMarketData(symbol) {
  return {
    symbol: symbol,
    technicals: getTechnicalIndicators(symbol),
    news_headlines: getLatestNews(symbol + " forex"),
    economic_calendar: getEconomicCalendar(),
    cot_report: getCotData(symbol),
    timestamp: new Date()
  };
}
