import 'api_service.dart';

class ForecastService {
  static Future<Map<String, dynamic>> getForecast(String symbol) async {
    try {
      final data = await ApiService.post('generateForecast', {'symbol': symbol});
      return data;
    } catch (e) {
      print('ForecastService Error: $e');
      return {'error': 'Could not generate forecast.'};
    }
  }
}
