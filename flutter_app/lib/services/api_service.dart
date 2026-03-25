import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Use --dart-define=GAS_URL=your_url --dart-define=API_KEY=your_key
  static const String _googleAppsScriptUrl = String.fromEnvironment('GAS_URL');
  static const String _apiKey = String.fromEnvironment('API_KEY');

  // Reusable POST call handler
  static Future<Map<String, dynamic>> post(String action, Map<String, dynamic> data) async {
    if (_googleAppsScriptUrl.isEmpty) {
      throw Exception('GAS_URL is not defined. Please build with --dart-define=GAS_URL=...');
    }

    try {
      final response = await http.post(
        Uri.parse(_googleAppsScriptUrl),
        headers: { 'Content-Type': 'application/json' },
        body: jsonEncode({
          'action': action,
          'data': data,
          'api_key': _apiKey
        }),
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
