import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Configured via --dart-define=GAS_URL=... during build/run
  static const String _googleAppsScriptUrl = String.fromEnvironment(
    'GAS_URL',
    defaultValue: "YOUR_DEPLOYED_GOOGLE_APPS_SCRIPT_URL",
  );

  // Reusable POST call handler
  static Future<Map<String, dynamic>> post(String action, Map<String, dynamic> data) async {
    if (_googleAppsScriptUrl == "YOUR_DEPLOYED_GOOGLE_APPS_SCRIPT_URL") {
      print("DUMMY MODE: Google Apps Script URL not set.");
      if (action == 'getGptFeedback') {
        return {
          "validation_score": 7,
          "is_valid_setup": true,
          "rule_violations": [],
          "emotional_warning": "You seem calm. Stay focused.",
          "tough_love_feedback": "Stick to your plan, don't let greed take over.",
          "detailed_explanation": "Technical setup looks solid based on your criteria."
        };
      }
      if (action == 'exportToJson') {
        return {
          'status': 'success',
          'data': jsonEncode([
            {'Trade ID': 'T1', 'Date': '2026-02-01', 'Result': 'WIN', 'Mood': 'Focused', 'Setup': 'Breakout', 'Entry': 1.0850, 'TP': 1.0900},
            {'Trade ID': 'T2', 'Date': '2026-02-02', 'Result': 'LOSS', 'Mood': 'Anxious', 'Setup': 'Retest', 'Entry': 1.0860, 'SL': 1.0840},
          ])
        };
      }
      return {'status': 'success', 'data': 'Dummy response for $action'};
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
      throw Exception('An error occurred while communicating with the server.');
    }
  }

  // Bridging method for GPT feedback
  static Future<Map<String, dynamic>> getGptFeedback(String promptType, String referenceId, Map<String, dynamic> promptData) async {
    return post('getGptFeedback', {
      'promptType': promptType,
      'promptData': promptData,
      'referenceId': referenceId,
    });
  }

  static Future<List<dynamic>> fetchJournalData() async {
    final response = await post('exportToJson', {'sheetName': 'Journal'});
    // GAS returns a JSON string in the 'data' field when using exportSheetToJson
    if (response is String) {
        return jsonDecode(response);
    }
    // If it's already a list or map (depending on how GAS is called)
    return response is String ? jsonDecode(response) : response;
  }
}
