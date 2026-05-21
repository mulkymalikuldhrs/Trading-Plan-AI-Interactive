import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _url = String.fromEnvironment('GAS_URL');
  static const String _apiKey = String.fromEnvironment('API_KEY');

  static Future<dynamic> post(String action, Map<String, dynamic> data) async {
    if (_url.isEmpty) {
      throw Exception('GAS_URL is not defined. Use --dart-define=GAS_URL=...');
    }

    final payload = {
      'action': action,
      'data': {
        ...data,
        'apiKey': _apiKey,
      }
    };

    try {
      final response = await http.post(
        Uri.parse(_url),
        headers: { 'Content-Type': 'application/json' },
        body: jsonEncode(payload),
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
}
