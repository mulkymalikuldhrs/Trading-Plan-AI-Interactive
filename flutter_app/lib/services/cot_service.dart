import 'api_service.dart';

class CotService {
  static Future<Map<String, dynamic>> getCotSummary(String symbol) async {
    try {
      final response = await ApiService.post('getAiMasterSummary', {'symbol': symbol});
      // Extract numeric institutional data from the GAS response if available
      // The positional_thesis usually contains the textual summary.
      // We look for raw COT data in the response if it was added to the summary.

      return {
        'institutionalLong': response['cot_raw']?['nonCommercialLong'] ?? 0,
        'retailShort': response['cot_raw']?['nonCommercialShort'] ?? 0,
        'netPosition': response['positional_thesis'] ?? 'N/A',
        'bias': response['final_bias'] ?? 'Neutral',
        'divergenceDetected': (response['final_bias'] != 'NEUTRAL'),
      };
    } catch (e) {
      print('CotService Error: $e');
      return {'error': 'Could not fetch COT data.'};
    }
  }
}
