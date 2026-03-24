import './api_service.dart';
import './cot_service.dart';
import './news_fetcher.dart';
// Other services...

class ForecastService {

  static Future<Map<String, dynamic>> getForecast({
    required String pair,
    required String timeframe,
    required int days,
  }) async {
    // The GAS backend now gathers all market data (Technicals, News, COT, Economic Calendar)
    // and calls the LLM for a unified forecast.
    try {
      final response = await ApiService.post('getGptFeedback', {
        'promptType': 'Forecast',
        'promptData': {
          "pair": pair,
          "timeframe": timeframe,
          "days": days,
          "full_prompt": "Analyze market context for $pair on $timeframe for $days-day outlook."
        },
        'referenceId': 'FORECAST_${pair}_${DateTime.now().millisecondsSinceEpoch}'
      });

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
