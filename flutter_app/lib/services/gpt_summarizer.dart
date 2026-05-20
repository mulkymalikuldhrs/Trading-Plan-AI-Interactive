import './api_service.dart';

class GptSummarizer {
  static Future<Map<String, dynamic>> getAiMasterSummary(String symbol) async {
    try {
      // Delegate to GAS backend for real intelligence
      final response = await ApiService.post('getAiMasterSummary', {
        'symbol': symbol,
      });
      return response;
    } catch (e) {
      print('GptSummarizer Error: $e');
      return {'error': 'Could not generate AI Master Summary.'};
    }
  }
}
