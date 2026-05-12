import 'api_service.dart';

class CotService {
  static Future<Map<String, dynamic>> getCotSummary(String symbol) async {
    try {
      final response = await ApiService.post('getAiMasterSummary', {'symbol': symbol});

      // Real data extraction from GAS backend response
      final cotData = response['cot_report'] ?? {};

      return {
        'institutionalLong': cotData['nonCommercialLong'] ?? 0,
        'institutionalShort': cotData['nonCommercialShort'] ?? 0,
        'netPosition': cotData['netPosition']?.toString() ?? response['positional_thesis'] ?? 'N/A',
        'bias': cotData['bias'] ?? response['final_bias'] ?? 'Neutral',
        'divergenceDetected': (cotData['bias'] != response['final_bias']), // Simple divergence logic
        'raw': cotData,
      };
    } catch (e) {
      print('CotService Error: $e');
      return {'error': 'Could not fetch COT data.'};
    }
  }
}
