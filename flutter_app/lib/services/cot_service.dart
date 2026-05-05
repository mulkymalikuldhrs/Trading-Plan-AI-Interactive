import 'api_service.dart';

class CotService {
  static Future<Map<String, dynamic>> getCotSummary(String symbol) async {
    try {
      final response = await ApiService.post('getAiMasterSummary', {'symbol': symbol});
      return {
        'institutionalLong': 0, // Calculated in GAS or further processed here
        'retailShort': 0,
        'netPosition': response['positional_thesis'] ?? 'N/A',
        'bias': response['final_bias'] ?? 'Neutral',
        'divergenceDetected': true, // Logic in GAS
      };
    } catch (e) {
      print('CotService Error: $e');
      return {'error': 'Could not fetch COT data.'};
    }
  }
}
