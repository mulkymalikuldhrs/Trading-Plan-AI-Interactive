import "package:flutter/foundation.dart";
import './api_service.dart';

class ForecastService {
  /// Fetches a multi-day market forecast from the AI backend.
  /// The backend handles all data aggregation (Technicals, News, COT, Calendar)
  /// and prompt engineering to ensure a high-quality, real-data driven output.
  static Future<Map<String, dynamic>> getForecast({
    required String pair,
    required String timeframe,
    required int days,
  }) async {
    try {
      final response = await ApiService.post('getForecast', {
        'pair': pair,
        'timeframe': timeframe,
        'days': days,
      });

      if (response is Map<String, dynamic>) {
        return response;
      } else {
        debugPrint('ForecastService: Unexpected response format');
        return {'error': 'Invalid response from AI engine.'};
      }
    } catch (e) {
      debugPrint('ForecastService Error: $e');
      return {'error': 'Could not generate forecast. Please check your connection.'};
    }
  }
}
