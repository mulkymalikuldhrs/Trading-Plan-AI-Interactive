/****************************************************************
 * MULKY AI TRADING OS - EXTERNAL API INTEGRATIONS
 *
 * This file contains functions for fetching data from various
 * financial and news APIs.
 ****************************************************************/

const scriptProps = PropertiesService.getScriptProperties();
const FINNHUB_API_KEY = scriptProps.getProperty('FINNHUB_API_KEY');

/**
 * Fetches technical indicators for a given symbol.
 */
function getTechnicalIndicators(symbol) {
  if (!FINNHUB_API_KEY) return { error: "Finnhub API key missing" };

  let normalizedSymbol = symbol;
  if (symbol.includes('/')) {
    normalizedSymbol = "OANDA:" + symbol.replace('/', '_');
  }

  const url = `https://finnhub.io/api/v1/indicator?symbol=${normalizedSymbol}&resolution=D&indicator=rsi,macd,sma&token=${FINNHUB_API_KEY}`;
  try {
    const response = UrlFetchApp.fetch(url, {'muteHttpExceptions': true});
    const data = JSON.parse(response.getContentText());

    if (data.s === 'ok') {
      return {
        symbol: normalizedSymbol,
        rsi: data.rsi ? data.rsi[data.rsi.length - 1].toFixed(2) : 'N/A',
        macd: data.macd ? data.macd[data.macd.length - 1].toFixed(5) : 'N/A',
        sma: data.sma ? data.sma[data.sma.length - 1].toFixed(5) : 'N/A',
        timestamp: new Date().toISOString()
      };
    }
    return { error: "Could not fetch technicals for " + symbol };
  } catch (e) {
    return { error: "Fetch error: " + e.message };
  }
}

/**
 * Fetches the latest financial news for a given symbol.
 */
function getLatestNews(symbol) {
  if (!FINNHUB_API_KEY) return [];

  let isForex = symbol.includes('/');
  const today = new Date().toISOString().slice(0, 10);
  const lastWeek = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000).toISOString().slice(0, 10);

  let url;
  if (isForex) {
    url = `https://finnhub.io/api/v1/news?category=forex&token=${FINNHUB_API_KEY}`;
  } else {
    url = `https://finnhub.io/api/v1/company-news?symbol=${symbol}&from=${lastWeek}&to=${today}&token=${FINNHUB_API_KEY}`;
  }

  try {
    const response = UrlFetchApp.fetch(url, {'muteHttpExceptions': true});
    const data = JSON.parse(response.getContentText());

    if (Array.isArray(data)) {
      let articles = data;
      if (isForex) {
        const base = symbol.split('/')[0];
        articles = data.filter(a => a.headline.includes(base) || (a.summary && a.summary.includes(base)));
      }
      return articles.slice(0, 5).map(article => article.headline);
    }
    return [];
  } catch (e) {
    return [];
  }
}

/**
 * Fetches upcoming events from an economic calendar.
 */
function getEconomicCalendar() {
  if (!FINNHUB_API_KEY) return [];

  const from = new Date().toISOString().slice(0, 10);
  const to = new Date(Date.now() + 7 * 24 * 60 * 60 * 1000).toISOString().slice(0, 10);

  const url = `https://finnhub.io/api/v1/calendar/economic?from=${from}&to=${to}&token=${FINNHUB_API_KEY}`;
  try {
    const response = UrlFetchApp.fetch(url, {'muteHttpExceptions': true});
    const data = JSON.parse(response.getContentText());

    if (data && data.economicCalendar) {
      return data.economicCalendar
        .filter(event => event.impact === 'high' || event.impact === 'medium')
        .slice(0, 10)
        .map(event => ({
          event: event.event,
          time: event.time,
          impact: event.impact,
          country: event.country,
          estimate: event.estimate,
          prev: event.prev
        }));
    }
    return [];
  } catch (e) {
    return [];
  }
}

/**
 * Fetches institutional sentiment (proxy for COT).
 */
function getCotData(symbol) {
  if (!FINNHUB_API_KEY) return { bias: "Unknown" };

  let normalizedSymbol = symbol || "OANDA:EUR_USD";
  if (normalizedSymbol.includes('/')) {
    normalizedSymbol = "OANDA:" + normalizedSymbol.replace('/', '_');
  }

  const url = `https://finnhub.io/api/v1/scan/technical-indicator?symbol=${normalizedSymbol}&resolution=D&token=${FINNHUB_API_KEY}`;
  try {
    const response = UrlFetchApp.fetch(url, {'muteHttpExceptions': true});
    const data = JSON.parse(response.getContentText());

    if (data && data.technicalAnalysis) {
      const sentiment = data.technicalAnalysis.count;
      let bias = "Neutral";
      if (sentiment.buy > sentiment.sell + 5) bias = "Bullish";
      if (sentiment.sell > sentiment.buy + 5) bias = "Bearish";

      return {
        symbol: normalizedSymbol,
        bias: bias,
        buy_count: sentiment.buy,
        sell_count: sentiment.sell,
        signal: data.technicalAnalysis.signal
      };
    }
    return { bias: "Neutral", source: "Sentiment Fallback" };
  } catch (e) {
    return { bias: "Error", message: e.message };
  }
}

/**
 * Fetches the current price for a symbol.
 */
function getCurrentPrice(symbol) {
  if (!FINNHUB_API_KEY) return null;
  let normalizedSymbol = symbol;
  if (symbol.includes('/')) {
    normalizedSymbol = "OANDA:" + symbol.replace('/', '_');
  }
  const url = `https://finnhub.io/api/v1/quote?symbol=${normalizedSymbol}&token=${FINNHUB_API_KEY}`;
  try {
    const response = UrlFetchApp.fetch(url, {'muteHttpExceptions': true});
    const data = JSON.parse(response.getContentText());
    return data.c; // current price
  } catch (e) {
    return null;
  }
}

/**
 * Fetches historical candle data for a given symbol.
 */
function getHistoricalCandles(symbol, resolution = 'D', count = 30) {
  if (!FINNHUB_API_KEY) return [];

  let normalizedSymbol = symbol;
  if (symbol.includes('/')) {
    normalizedSymbol = "OANDA:" + symbol.replace('/', '_');
  }

  const to = Math.floor(Date.now() / 1000);
  // Approximation for 'count' days/periods back
  const secondsPerResolution = {
    '1': 60, '5': 300, '15': 900, '30': 1800, '60': 3600, 'D': 86400, 'W': 604800, 'M': 2592000
  };
  const from = to - (count * (secondsPerResolution[resolution] || 86400));

  const url = `https://finnhub.io/api/v1/indicator?symbol=${normalizedSymbol}&resolution=${resolution}&from=${from}&to=${to}&token=${FINNHUB_API_KEY}`;
  try {
    const response = UrlFetchApp.fetch(url, {'muteHttpExceptions': true});
    const data = JSON.parse(response.getContentText());

    if (data.s === 'ok' && data.c) {
      return data.c.map((close, i) => ({
        t: data.t[i],
        c: close
      }));
    }
    return [];
  } catch (e) {
    Logger.log("Error fetching candles: " + e.message);
    return [];
  }
}

/**
 * A master function to gather all market data for analysis.
 */
function getComprehensiveMarketData(symbol) {
  const technicals = getTechnicalIndicators(symbol);
  const news = getLatestNews(symbol);
  const calendar = getEconomicCalendar();
  const cot = getCotData(symbol);
  const currentPrice = getCurrentPrice(symbol);

  return {
    technicals: technicals,
    news_headlines: news,
    economic_calendar: calendar,
    cot_report: cot,
    current_price: currentPrice,
    timestamp: new Date().toISOString()
  };
}
