import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _googleAppsScriptUrl = "YOUR_GOOGLE_APPS_SCRIPT_WEB_APP_URL";

  // Reusable POST call handler
  static Future<Map<String, dynamic>> post(String action, Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse(_googleAppsScriptUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'action': action,
          'data': data,
        }),
      );

      if (response.statusCode == 200) {
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
      // In a real app, you'd want more robust error handling (e.g., logging)
      print('ApiService Error: $e');
      throw Exception('An error occurred while communicating with the server.');
    }
  }

  // Specific function for getting GPT feedback
  static Future<Map<String, dynamic>> getGptFeedback(String promptType, String referenceId, Map<String, dynamic> promptData) {
    return post('getGptFeedback', {
      'promptType': promptType,
      'referenceId': referenceId,
      'data': promptData,
    });
  }

  // Specific function for logging a trade
  static Future<String> logTrade(Map<String, dynamic> tradeData) async {
    final response = await post('logTrade', tradeData);
    return response.toString();
  }

  // Specific function for logging a violation
  static Future<String> logViolation(Map<String, dynamic> violationData) async {
    final response = await post('logViolation', violationData);
    return response.toString();
  }

  // Specific function for exporting a sheet to JSON
  static Future<List<dynamic>> exportSheet(String sheetName) async {
    final response = await post('exportToJson', {'sheetName': sheetName});
    return jsonDecode(response);
  }
}
