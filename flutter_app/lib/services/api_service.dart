import "package:flutter/foundation.dart";
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  /// The Google Apps Script URL must be provided at build time using the following flag:
  /// --dart-define=GAS_URL=https://script.google.com/macros/s/YOUR_DEPLOYMENT_ID/exec
  static const String _googleAppsScriptUrl = String.fromEnvironment('GAS_URL');
  static const String _apiKey = String.fromEnvironment('API_KEY');

  // Reusable POST call handler
  static Future<dynamic> post(String action, Map<String, dynamic> data) async {
    if (_googleAppsScriptUrl.isEmpty) {
      throw Exception(
        "Google Apps Script URL (GAS_URL) is not defined. "
        "Please provide it during build/run using: --dart-define=GAS_URL=your_deployed_url"
      );
    }

    try {
      final response = await http.post(
        Uri.parse(_googleAppsScriptUrl),
        headers: { 'Content-Type': 'application/json' },
        body: jsonEncode({ 'action': action, 'data': data, 'api_key': _apiKey }),
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
      debugPrint('ApiService Error: $e');
      throw Exception('An error occurred while communicating with the server.');
    }
  }

  // Bridging method for GPT feedback
  static Future<Map<String, dynamic>> getGptFeedback(String promptType, String referenceId, Map<String, dynamic> promptData) async {
    final result = await post('getGptFeedback', {
      'promptType': promptType,
      'promptData': promptData,
      'referenceId': referenceId,
    });
    return result as Map<String, dynamic>;
  }

  static Future<List<dynamic>> fetchJournalData() async {
    final response = await post('exportToJson', {'sheetName': 'Journal'});
    // GAS returns a JSON string in the 'data' field when using exportSheetToJson
    if (response is String) {
      return jsonDecode(response);
    }
    return response as List<dynamic>;
  }
}
