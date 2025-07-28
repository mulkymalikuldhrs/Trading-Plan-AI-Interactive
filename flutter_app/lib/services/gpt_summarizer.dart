import './api_service.dart';
import './cot_service.dart';
import './news_fetcher.dart';
// Assume a technical analysis service exists
// import './technical_analysis_service.dart';

class GptSummarizer {

  static Future<Map<String, dynamic>> getAiMasterSummary(String symbol) async {
    // 1. Gather all data
    final cotData = await CotService.getCotSummary(symbol);
    final newsData = await NewsFetcher.getTopHeadlines(symbol);
    // final technicalData = await TechnicalAnalysisService.getIndicators(symbol);

    // 2. Format the data for the prompt
    final promptData = {
      "symbol": symbol,
      "technicals": { "rsi": 65, "macd": 0.5, "sma": 1.1234 }, // Dummy data
      "news_headlines": newsData.map((e) => e['title']).toList(),
      "economic_calendar": [
        { "event": "US CPI (MoM)", "impact": "High" },
      ],
      "cot_report": {
        "EUR": { "net": cotData['netPosition'] }
      }
    };

    // 3. Call the GPT service with the master prompt
    try {
      final response = await ApiService.post('getGptFeedback', {
        'promptType': 'MasterTradeAnalyst',
        'promptData': promptData,
        'referenceId': 'MASTER_SUMMARY_${symbol}'
      });
      return response;
    } catch (e) {
      print('GptSummarizer Error: $e');
      return {'error': 'Could not generate AI Master Summary.'};
    }
  }
}
