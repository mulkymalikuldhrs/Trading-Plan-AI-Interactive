import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // IMPORTANT: REPLACE WITH YOUR ACTUAL DEPLOYED GOOGLE APPS SCRIPT URL
  static const String _googleAppsScriptUrl = String.fromEnvironment('GAS_URL', defaultValue: "https://script.google.com/macros/s/AKfycbz_REPLACE_WITH_REAL_ID/exec");
  static const String _apiKey = String.fromEnvironment('API_KEY', defaultValue: "");

  // Reusable POST call handler
  static Future<Map<String, dynamic>> post(String action, Map<String, dynamic> data) async {
    if (_googleAppsScriptUrl.contains("REPLACE_WITH_REAL_ID")) {
      print("CRITICAL: Google Apps Script URL not set.");
      throw Exception('Backend URL not configured.');
    }

    try {
      // Encapsulate API_KEY within the data nested object of the JSON request body
      final payload = {
        'action': action,
        'data': {
          ...data,
          'apiKey': _apiKey,
        }
      };

      final response = await http.post(
        Uri.parse(_googleAppsScriptUrl),
        headers: { 'Content-Type': 'application/json' },
        body: jsonEncode(payload),
      );

      // Handle redirects (status code 302) which are common in Google Apps Script
      if (response.statusCode == 302) {
        final newUrl = response.headers['location'];
        if (newUrl != null) {
          final redirectedResponse = await http.post(
            Uri.parse(newUrl),
            headers: { 'Content-Type': 'application/json' },
            body: jsonEncode(payload),
          );
          return _handleResponse(redirectedResponse);
        }
      }

      return _handleResponse(response);
    } catch (e) {
      print('ApiService Error: $e');
      throw Exception('An error occurred while communicating with the server.');
    }
  }

  static Map<String, dynamic> _handleResponse(http.Response response) {
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
  }
}
