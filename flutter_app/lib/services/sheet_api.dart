import 'api_service.dart';
import '../models/trade.dart';

class SheetApi {
  static Future<String> logTrade(Trade trade) {
    return ApiService.post('logTrade', trade.toJson());
  }

  static Future<String> logViolation(String tradeId, String rule, String justification) {
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
