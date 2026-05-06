import 'api_service.dart';

class CotService {
  static Future<Map<String, dynamic>> getCotSummary(String symbol) async {
    try {
      final data = await ApiService.post('getMarketData', {'symbol': symbol});
      return data['cot_report'] ?? {};
    } catch (e) {
      print('CotService Error: $e');
      return {'error': 'Could not fetch COT data.'};
    }
  }
}
