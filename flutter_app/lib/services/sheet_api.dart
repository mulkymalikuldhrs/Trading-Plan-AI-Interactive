import 'api_service.dart';
import '../models/trade.dart';

class SheetApi {
  static Future<Map<String, dynamic>> logTrade(Trade trade) {
    return ApiService.post('logTrade', trade.toJson());
  }

  static Future<Map<String, dynamic>> logViolation(String tradeId, String rule, String justification) {
    return ApiService.post('logViolation', {
      'tradeId': tradeId,
      'ruleBroken': rule,
      'justification': justification,
    });
  }

  static Future<List<Trade>> getJournal() async {
    final dynamic response = await ApiService.post('exportToJson', {'sheetName': 'Journal'});
    if (response is List) {
       final List<Trade> trades = [];
       for (var item in response) {
         if (item is Map<String, dynamic>) {
           trades.add(Trade.fromJson(item));
         }
       }
       return trades;
    }
    return [];
  }
}
