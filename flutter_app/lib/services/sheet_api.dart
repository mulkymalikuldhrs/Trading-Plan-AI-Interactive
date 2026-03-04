import 'api_service.dart';
import '../models/trade.dart';

class SheetApi {
  static Future<String> logTrade(Trade trade) async {
    final result = await ApiService.post('logTrade', trade.toJson());
    return result.toString();
  }

  static Future<String> logViolation(String tradeId, String rule, String justification) async {
    final result = await ApiService.post('logViolation', {
      'tradeId': tradeId,
      'ruleBroken': rule,
      'justification': justification,
    });
    return result.toString();
  }

  static Future<List<Trade>> getJournal() async {
    final List<dynamic> tradesJson = await ApiService.fetchJournalData();
    return tradesJson.map((json) => Trade.fromJson(json)).toList();
  }
}
