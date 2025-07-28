import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // IMPORTANT: REPLACE WITH YOUR ACTUAL DEPLOYED GOOGLE APPS SCRIPT URL
  static const String _googleAppsScriptUrl = "AQ.Ab8RN6Lpynl-lou0SdHQmWWIMuSXzHZmHzZ0Gfvx8snhJsehUA";

  // Reusable POST call handler
  static Future<Map<String, dynamic>> post(String action, Map<String, dynamic> data) async {
    if (_googleAppsScriptUrl.contains("YOUR_DEPLOYMENT_ID")) {
      // This is a dummy response for when the URL is not set.
      // In a real app, this would be a proper error.
      print("DUMMY MODE: Google Apps Script URL not set.");
      if (action == 'getGptFeedback') {
        return {
          "validation_score": 5,
          "is_valid_setup": false,
          "rule_violations": ["Dummy violation"],
          "emotional_warning": "This is a dummy warning.",
          "tough_love_feedback": "This is dummy feedback.",
          "detailed_explanation": "This is a dummy explanation because the API URL is not set."
        };
      }
      return {'status': 'success', 'data': 'Dummy response'};
    }

    try {
      final response = await http.post(
        Uri.parse(_googleAppsScriptUrl),
        headers: { 'Content-Type': 'application/json' },
        body: jsonEncode({ 'action': action, 'data': data }),
      );

      if (response.statusCode == 200 || response.statusCode == 302) { // 302 is a common redirect status from GAS
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
}
