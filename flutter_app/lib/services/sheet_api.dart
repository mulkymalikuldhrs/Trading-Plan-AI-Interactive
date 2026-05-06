import 'api_service.dart';

class SheetApi {
  static Future<dynamic> logTrade(Map<String, dynamic> data) async {
    return ApiService.post('logTrade', data);
  }

  static Future<dynamic> logViolation(Map<String, dynamic> data) async {
    return ApiService.post('logViolation', data);
  }

  static Future<List<dynamic>> fetchJournal() async {
    final data = await ApiService.post('exportToJson', {'sheetName': 'Journal'});
    return data as List<dynamic>;
  }
}
