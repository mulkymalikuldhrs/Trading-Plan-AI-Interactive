import './api_service.dart';

class ForecastService {
  static Future<Map<String, dynamic>> getForecast({
    required String pair,
    required String timeframe,
    required int days,
  }) async {
    try {
      // Delegate intelligence entirely to the Google Apps Script backend
      final response = await ApiService.post('getForecast', {
        'pair': pair,
        'timeframe': timeframe,
        'days': days
      });
      return response;
    } catch (e) {
      print('ForecastService Error: $e');
      return {'error': 'Could not generate forecast.'};
    }
  }
}
