import './api_service.dart';

class GptSummarizer {
  static Future<Map<String, dynamic>> getAiMasterSummary(String symbol) async {
    try {
      // Delegate intelligence entirely to the Google Apps Script backend
      final response = await ApiService.post('getAiMasterSummary', {
        'symbol': symbol
      });
      return response;
    } catch (e) {
      print('GptSummarizer Error: $e');
      return {'error': 'Could not generate AI Master Summary.'};
    }
  }
}
