import './api_service.dart';

class ForecastService {

  static Future<Map<String, dynamic>> getForecast({
    required String pair,
    required String timeframe,
    required int days,
  }) async {
    // According to AGENTS.md, all intelligent analysis and data aggregation
    // MUST happen in the GAS backend. The frontend simply calls the action.
    try {
      final response = await ApiService.post('getForecast', {
        'pair': pair,
        'timeframe': timeframe,
        'days': days,
      });

      return response as Map<String, dynamic>;

    } catch (e) {
      print('ForecastService Error: $e');
      return {'error': 'Could not generate forecast.'};
    }
  }

  static Future<List<dynamic>> getRecentForecasts() async {
    try {
      final response = await ApiService.post('exportToJson', {
        'sheetName': 'Forecasts',
      });
      return response as List<dynamic>;
    } catch (e) {
      print('ForecastService Error: $e');
      return [];
    }
  }

}
