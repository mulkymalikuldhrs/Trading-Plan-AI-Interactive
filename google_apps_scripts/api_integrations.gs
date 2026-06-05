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
 * Fetches Commitment of Traders (COT) data via direct CFTC scraping.
 * Eliminates reliance on 3rd party aggregators.
 */
function getCotData(symbol) {
  // Normalize symbol (e.g., EURUSD -> EUR/USD)
  let normalizedSymbol = symbol.toUpperCase();
  if (normalizedSymbol.length === 6 && !normalizedSymbol.includes('/')) {
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
    'GOLD': 'GOLD - COMMODITY EXCHANGE INC.',
    'XAU/USD': 'GOLD - COMMODITY EXCHANGE INC.'
  };

  const asset = cftcMap[normalizedSymbol] || normalizedSymbol;

  // Select URL: CME for Forex, COMEX for Gold
  const url = (asset.includes('GOLD'))
    ? 'https://www.cftc.gov/dea/futures/deacmxl.txt'
    : 'https://www.cftc.gov/dea/futures/deacmcl.txt';

  try {
    const response = UrlFetchApp.fetch(url, {'muteHttpExceptions': true});
    if (response.getResponseCode() !== 200) throw new Error("CFTC Server unresponsive");

    const content = response.getContentText();
    const reports = content.split('-----------------------------------------------------------------------');

    const report = reports.find(r => r.includes(asset));
    if (!report) throw new Error("Asset not found in report");

    const dateMatch = content.match(/COMMITMENTS AS OF\s+(\d{2}\/\d{2}\/\d{2})/);
    const reportDate = dateMatch ? dateMatch[1] : "Unknown";

    const lines = report.split('\n');
    let nonCommLong = 0, nonCommShort = 0;

    for (let i = 0; i < lines.length; i++) {
      if (lines[i].includes("NON-COMMERCIAL")) {
        for (let j = i; j < i + 5; j++) {
          const matches = lines[j].match(/(\d{1,3}(,\d{3})*)/g);
          if (matches && matches.length >= 5) {
            nonCommLong = parseInt(matches[0].replace(/,/g, ''));
            nonCommShort = parseInt(matches[1].replace(/,/g, ''));
            break;
          }
        }
        break;
      }
    }

    return {
      symbol: normalizedSymbol,
      reportDate: reportDate,
      nonCommercialLong: nonCommLong,
      nonCommercialShort: nonCommShort,
      netPosition: nonCommLong - nonCommShort,
      bias: (nonCommLong > nonCommShort * 1.5) ? 'BULLISH' : (nonCommShort > nonCommLong * 1.5) ? 'BEARISH' : 'NEUTRAL',
      oi: 'N/A'
    };
  } catch (e) {
    Logger.log("COT Scraping Failed: " + e.message);
    return { symbol: normalizedSymbol, status: "error", message: e.message };
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
