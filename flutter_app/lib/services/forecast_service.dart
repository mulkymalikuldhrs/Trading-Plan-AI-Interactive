import './api_service.dart';
// Other services...

class ForecastService {

  static Future<Map<String, dynamic>> getForecast({
    required String pair,
    required String timeframe,
    required int days,
  }) async {
    // 1. Gather all external data
    // final cotData = await CotService.getCotSummary(pair);
    // final newsData = await NewsFetcher.getTopHeadlines(pair);
    // In a real app, we'd also get technical and fundamental data here.

    // 2. Construct the master prompt
    final promptData = {
      "pair": pair,
      "timeframe": timeframe,
      "days": days,
      "technical_structure": "Bearish", // This would be dynamic
      "current_price": "1.0860", // This would be dynamic
      "supply_area": "1.0880 - 1.0900", // This would be dynamic
      "cot_summary": "Net Short ${pair}", // Simplified from cotData
      "fundamental_summary": "USD CPI this week, Fed dovish", // This would be dynamic
    };

    final prompt = _buildForecastPrompt(promptData);

    // 3. Call the GPT service
    try {
      final response = await ApiService.post('getGptFeedback', {
        'promptType': 'Forecast', // A new prompt type
        'promptData': {
          "full_prompt": prompt // Sending the fully constructed prompt
        },
        'referenceId': 'FORECAST_${pair}'
      });

      // 4. In a real app, we would log this forecast to a 'Forecasts' sheet.
      // SheetApi.logForecast(response);

      return response;

    } catch (e) {
      print('ForecastService Error: $e');
      return {'error': 'Could not generate forecast.'};
    }
  }

  static String _buildForecastPrompt(Map<String, dynamic> data) {
    return '''
Forecast untuk pair: ${data['pair']}
Timeframe: ${data['timeframe']}
Hari: ${data['days']}
Struktur HTF: ${data['technical_structure']}
Harga Saat Ini: ${data['current_price']}
Area Supply: ${data['supply_area']}
COT: ${data['cot_summary']}
Fundamental: ${data['fundamental_summary']}

Tolong analisa:
1. Arah bias (Bullish/Bearish/Neutral)
2. Zona entry yang optimal dan level konfirmasi (e.g., "Tunggu CHoCH di M15 di dalam zona ini")
3. SL dan TP ideal
4. Probabilitas setup ini valid (dalam persentase)
5. Apakah setup ini layak untuk ditradingkan? (Yes/No/Wait for confirmation)

Format output sebagai JSON dengan keys: "bias", "entry_zone", "confirmation", "stop_loss", "take_profit", "probability", "is_tradeable".
''';
  }
}
