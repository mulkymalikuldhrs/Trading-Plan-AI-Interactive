import 'api_service.dart';
import '../models/trade.dart';

class SheetApi {
  /// Log a trade from a Trade model object
  static Future<dynamic> logTrade(Trade trade) {
    return ApiService.post('logTrade', trade.toJson());
  }

  /// Log a trade from a raw map (used by EntryForm)
  static Future<dynamic> logTradeFromMap(Map<String, dynamic> data) {
    return ApiService.post('logTrade', data);
  }

  static Future<dynamic> logViolation(String tradeId, String rule, String justification) {
    return ApiService.post('logViolation', {
      'tradeId': tradeId,
      'ruleBroken': rule,
      'justification': justification,
    });
  }

  static Future<List<Trade>> getJournal() async {
    final List<dynamic> tradesJson = await ApiService.exportSheet('Journal');
    return tradesJson.map((json) => Trade.fromJson(json)).toList();
  }
}
