import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Use --dart-define=GAS_URL=https://... to set this at build/run time
  static const String _googleAppsScriptUrl = String.fromEnvironment(
    'GAS_URL',
    defaultValue: 'YOUR_GOOGLE_APPS_SCRIPT_WEB_APP_URL',
  );

  static Future<Map<String, dynamic>> post(String action, Map<String, dynamic> data) async {
    if (_googleAppsScriptUrl == 'YOUR_GOOGLE_APPS_SCRIPT_WEB_APP_URL') {
      throw Exception('GAS_URL is not configured. Please use --dart-define=GAS_URL=your_url');
    }

    try {
      final response = await http.post(
        Uri.parse(_googleAppsScriptUrl),
        headers: { 'Content-Type': 'application/json' },
        body: jsonEncode({ 'action': action, 'data': data }),
      );

      if (response.statusCode == 200 || response.statusCode == 302) {
        final responseBody = jsonDecode(response.body);
        if (responseBody['status'] == 'success') {
          return responseBody['data'];
        } else {
          throw Exception('API Error: ${responseBody['message']}');
        }
      } else {
        throw Exception('Failed to connect to the server. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('ApiService Error: $e');
      rethrow;
    }
  }

  // Helper for fetching journal data (used in multiple places)
  static Future<List<dynamic>> fetchJournalData() async {
    final response = await post('exportToJson', {'sheetName': 'Journal'});
    if (response is String) {
        return jsonDecode(response);
    }
    return response as List<dynamic>;
  }
}
