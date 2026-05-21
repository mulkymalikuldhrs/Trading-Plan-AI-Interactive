import './api_service.dart';

class ForecastService {
  static Future<Map<String, dynamic>> getForecast({
    required String pair,
    required String timeframe,
    required int days,
  }) async {
    try {
      // Delegate to GAS backend for real intelligence
      final response = await ApiService.post('getGptFeedback', {
        'promptType': 'Forecast',
        'promptData': {
          'pair': pair,
          'timeframe': timeframe,
          'days': days,
        },
        'referenceId': 'FORECAST_${pair}_${DateTime.now().millisecondsSinceEpoch}'
      });
      return response;
    } catch (e) {
      print('ForecastService Error: $e');
      return {'error': 'Could not generate forecast.'};
    }
  }
}
