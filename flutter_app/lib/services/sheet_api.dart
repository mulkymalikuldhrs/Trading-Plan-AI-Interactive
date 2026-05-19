import 'api_service.dart';
import '../models/trade.dart';
import 'dart:convert';

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
    final List<dynamic> list = response is String ? jsonDecode(response) : response;
    return list.map((json) => Trade.fromJson(json)).toList();
  }
}
