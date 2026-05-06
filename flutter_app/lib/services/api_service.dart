import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _gasUrl = String.fromEnvironment('GAS_URL');
  static const String _apiKey = String.fromEnvironment('API_KEY');

  static Future<dynamic> post(String action, Map<String, dynamic> data) async {
    if (_gasUrl.isEmpty) {
      throw Exception('GAS_URL is not defined. Please build with --dart-define=GAS_URL=...');
    }

    try {
      final response = await http.post(
        Uri.parse(_gasUrl),
        headers: { 'Content-Type': 'application/json' },
        body: jsonEncode({
          'action': action,
          'data': data,
          'apiKey': _apiKey
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 302) {
        final responseBody = jsonDecode(response.body);
        if (responseBody['status'] == 'success') {
          return responseBody['data'];
        } else {
          throw Exception('API Error: ${responseBody['message']}');
        }
      } else {
        throw Exception('Failed to connect to GAS. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('ApiService Error: $e');
      rethrow;
    }
  }
}
