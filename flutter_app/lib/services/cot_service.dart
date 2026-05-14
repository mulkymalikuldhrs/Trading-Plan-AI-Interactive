import 'api_service.dart';

class CotService {
  static Future<Map<String, dynamic>> getCotSummary(String symbol) async {
    try {
      final response = await ApiService.post('getMarketData', {'symbol': symbol});
      final cot = response['cot_report'];

      if (cot == null || cot['status'] == 'error') {
        return {
          'institutionalLong': 0,
          'retailShort': 0,
          'netPosition': 'Data unavailable',
          'bias': 'Neutral',
          'divergenceDetected': false,
        };
      }

      return {
        'institutionalLong': cot['nonCommercialLong'] ?? 0,
        'retailShort': cot['nonCommercialShort'] ?? 0,
        'netPosition': cot['netPosition']?.toString() ?? 'N/A',
        'bias': cot['bias'] ?? 'Neutral',
        'divergenceDetected': (cot['netPosition'] ?? 0).abs() > (cot['oi'] ?? 0) * 0.1, // Example dynamic logic
      };
    } catch (e) {
      print('CotService Error: $e');
      return {'error': 'Could not fetch COT data.'};
    }
  }
}
