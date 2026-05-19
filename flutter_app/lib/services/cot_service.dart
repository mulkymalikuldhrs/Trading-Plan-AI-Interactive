import './api_service.dart';

class CotService {
  static Future<Map<String, dynamic>> getCotSummary(String symbol) async {
    try {
      // Delegate to GAS getMarketData action
      final marketData = await ApiService.post('getMarketData', {'symbol': symbol});
      if (marketData != null && marketData['cot_report'] != null) {
        // Find the currency part of the symbol (e.g., 'EUR' from 'EUR/USD')
        String baseCurrency = symbol.split('/')[0].split('-')[0].toUpperCase();
        if (symbol.contains('GOLD') || symbol.contains('XAU')) baseCurrency = 'USD'; // Gold is often compared to USD index or specific gold COT

        final cotReport = marketData['cot_report'];
        final currencyData = cotReport[baseCurrency];

        if (currencyData != null) {
          return {
            'institutionalLong': currencyData['nonCommercialLong'] ?? 0,
            'institutionalShort': currencyData['nonCommercialShort'] ?? 0,
            'netPosition': currencyData['net'] ?? 0,
            'label': currencyData['label'] ?? baseCurrency,
            'bias': (currencyData['net'] ?? 0) > 0 ? 'Bullish' : 'Bearish',
            'divergenceDetected': false, // Logic could be added here
          };
        }
      }
      throw Exception('Failed to parse COT data from backend');
    } catch (e) {
      print('CotService Error: $e');
      return {
        'error': 'Could not fetch COT data.'
      };
    }
  }
}
