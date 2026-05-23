import './api_service.dart';

class SheetApi {
  static Future<Map<String, dynamic>> logTrade(Map<String, dynamic> tradeData) async {
    return await ApiService.post('logTrade', tradeData);
  }

  static Future<Map<String, dynamic>> logViolation(Map<String, dynamic> violationData) async {
    return await ApiService.post('logViolation', violationData);
  }

  static Future<Map<String, dynamic>> exportSheet(String sheetName) async {
    return await ApiService.post('exportToJson', {'sheetName': sheetName});
  }
}
