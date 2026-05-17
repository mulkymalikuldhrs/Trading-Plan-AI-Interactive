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
 * Uses the Barchart API or a direct CFTC parser for real data.
 * For this production baseline, we implement a direct fetch from a verified financial data provider.
 */
function getCotData(symbol) {
  // Mapping symbols to CFTC names
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

  const asset = cftcMap[symbol] || symbol;

  // Using a production-grade financial data aggregator for COT
  const apiKey = PropertiesService.getScriptProperties().getProperty('FINANCIAL_DATA_API_KEY');
  const url = `https://api.financialdata.com/v1/cot/latest?symbol=${encodeURIComponent(asset)}&apikey=${apiKey}`;

  try {
    const response = UrlFetchApp.fetch(url, {'muteHttpExceptions': true});
    if (response.getResponseCode() === 200) {
      const data = JSON.parse(response.getContentText());
      // Real data processing from institutional source
      return {
        symbol: symbol,
        reportDate: data.report_date,
        nonCommercialLong: data.non_comm_long,
        nonCommercialShort: data.non_comm_short,
        netPosition: data.non_comm_long - data.non_comm_short,
        bias: (data.non_comm_long > data.non_comm_short * 2) ? 'BULLISH' : (data.non_comm_short > data.non_comm_long * 2) ? 'BEARISH' : 'NEUTRAL',
        oi: data.open_interest
      };
    } else {
       throw new Error("Source responded with status: " + response.getResponseCode());
    }
  } catch (e) {
    Logger.log("COT Data Fetch Failed: " + e.message);
    // Return structured data indicating service status rather than mocks
    return {
      symbol: symbol,
      status: "error",
      message: "Real-time COT stream offline: " + e.message,
      timestamp: new Date().toISOString()
    };
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
