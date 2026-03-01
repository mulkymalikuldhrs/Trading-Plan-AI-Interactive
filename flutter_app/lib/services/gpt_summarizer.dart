import './api_service.dart';
// Assume a technical analysis service exists
// import './technical_analysis_service.dart';

class GptSummarizer {

  static Future<Map<String, dynamic>> getAiMasterSummary(String symbol) async {
    // Delegate to GAS which gathers real-time data from Finnhub
    try {
      final response = await ApiService.post('getAiMasterSummary', {
        'symbol': symbol
      });
      // response is { analysis: { ... }, rawData: { ... } }
      return response as Map<String, dynamic>;
    } catch (e) {
      print('GptSummarizer Error: $e');
      return {'error': 'Could not generate AI Master Summary.'};
    }
  }
}
