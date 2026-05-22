import './api_service.dart';

class CotService {
  static Future<Map<String, dynamic>> getCotSummary(String symbol) async {
    try {
      // Delegate to GAS backend for real data
      final response = await ApiService.post('getMarketData', {
        'symbol': symbol,
        'dataType': 'cot'
      });
      return response;
    } catch (e) {
      print('CotService Error: $e');
      return {'error': 'Could not fetch COT data.'};
    }
  }
}
