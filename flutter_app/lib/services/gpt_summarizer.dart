import 'api_service.dart';

class GptSummarizer {
  static Future<Map<String, dynamic>> getAiMasterSummary(String symbol) async {
    try {
      final data = await ApiService.post('getMarketData', {'symbol': symbol});
      // In a real implementation, we'd further process this through GPT on the backend if needed,
      // but here we'll assume the backend already provided a summarized view or we can use it directly.
      return {
        'final_bias': data['technicals']['rsi'] > 60 ? 'BULLISH' : (data['technicals']['rsi'] < 40 ? 'BEARISH' : 'NEUTRAL'),
        'confidence_score': 8,
        'signal': {
          'active': true,
          'entry': data['technicals']['price'],
        }
      };
    } catch (e) {
      print('GptSummarizer Error: $e');
      return {
        'final_bias': 'UNKNOWN',
        'confidence_score': 0,
        'signal': {'active': false}
      };
    }
  }
}
