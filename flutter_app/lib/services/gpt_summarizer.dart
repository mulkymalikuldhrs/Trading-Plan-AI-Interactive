import './api_service.dart';

class GptSummarizer {
  static Future<Map<String, dynamic>> getAiMasterSummary(String symbol) async {
    try {
      final response = await ApiService.post('getAiMasterSummary', {
        'symbol': symbol,
      });
      return response as Map<String, dynamic>;
    } catch (e) {
      return {'error': 'Could not generate AI Master Summary.'};
    }
  }
}
