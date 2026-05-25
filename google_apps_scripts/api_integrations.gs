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
  const cftcMap = {
    'EUR/USD': { name: 'EURO CURRENCY', report: 'CME' },
    'GBP/USD': { name: 'BRITISH POUND STERLING', report: 'CME' },
    'JPY/USD': { name: 'JAPANESE YEN', report: 'CME' },
    'AUD/USD': { name: 'AUSTRALIAN DOLLAR', report: 'CME' },
    'NZD/USD': { name: 'NEW ZEALAND DOLLAR', report: 'CME' },
    'USD/CAD': { name: 'CANADIAN DOLLAR', report: 'CME' },
    'USD/CHF': { name: 'SWISS FRANC', report: 'CME' },
    'GOLD': { name: 'GOLD - COMMODITY EXCHANGE INC.', report: 'COMEX' }
  };

  const asset = cftcMap[symbol];
  if (!asset) return { symbol: symbol, status: "error", message: "Asset not mapped for COT" };

  const reportUrls = {
    'CME': 'https://www.cftc.gov/dea/futures/deacmesf.htm',
    'COMEX': 'https://www.cftc.gov/dea/futures/deacmx.htm'
  };

  const url = reportUrls[asset.report];

  try {
    const response = UrlFetchApp.fetch(url, {'muteHttpExceptions': true});
    if (response.getResponseCode() !== 200) throw new Error("CFTC site unavailable");

    const content = response.getContentText();
    const startIndex = content.toUpperCase().indexOf(asset.name.toUpperCase());
    if (startIndex === -1) throw new Error("Asset not found in report");

    // Find the report date globally first, as it's often at the top of the file
    let reportDate = new Date().toLocaleDateString();
    const globalDateMatch = content.match(/COMMITMENTS AS OF\s+(\d{2}\/\d{2}\/\d{2})/);
    if (globalDateMatch) reportDate = globalDateMatch[1];

    // Extract enough content to find the data row
    const section = content.substring(startIndex, startIndex + 1500);
    const lines = section.split('\n');

    let dataLine = "";

    for (let i = 0; i < lines.length; i++) {
      // The numbers are usually in a row that has at least 5-7 columns of numbers
      const cleanLine = lines[i].trim();
      const numbers = cleanLine.split(/\s+/).filter(n => /^-?\d{1,3}(,\d{3})*$/.test(n));
      if (numbers.length >= 5) {
         dataLine = cleanLine;
         break;
      }
    }

    if (!dataLine) throw new Error("Data line not found in section");

    const numbers = dataLine.trim().split(/\s+/).filter(n => /^-?\d{1,3}(,\d{3})*$/.test(n)).map(n => parseInt(n.replace(/,/g, '')));

    // Non-Commercial: Long is index 0, Short is index 1
    const long = numbers[0];
    const short = numbers[1];

    return {
      symbol: symbol,
      reportDate: reportDate,
      nonCommercialLong: long,
      nonCommercialShort: short,
      netPosition: long - short,
      bias: (long > short * 1.5) ? 'BULLISH' : (short > long * 1.5) ? 'BEARISH' : 'NEUTRAL',
      status: "success"
    };
  } catch (e) {
    Logger.log("COT Fetch Error: " + e.message);
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
