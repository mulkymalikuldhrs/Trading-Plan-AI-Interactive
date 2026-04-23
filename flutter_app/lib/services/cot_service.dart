import 'api_service.dart';

class CotService {
  static Future<Map<String, dynamic>> getCotSummary(String symbol) async {
    try {
      final data = await ApiService.post('getCotAnalysis', {'symbol': symbol});
      return data;
    } catch (e) {
      print('CotService Error: $e');
      return {
        'error': 'Could not fetch COT data from AI backend.'
      };
    }
  }
}
