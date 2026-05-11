import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _gasUrl = String.fromEnvironment('GAS_URL');
  static const String _apiKey = String.fromEnvironment('API_KEY');

  static Future<dynamic> post(String action, Map<String, dynamic> data) async {
    if (_gasUrl.isEmpty) {
      throw Exception('GAS_URL is not defined. Please build with --dart-define=GAS_URL=...');
    }

    // Include API Key in data if needed by backend
    final Map<String, dynamic> requestBody = {
      'action': action,
      'data': {
        ...data,
        'apiKey': _apiKey,
      }
    };

    try {
      final response = await http.post(
        Uri.parse(_gasUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200 || response.statusCode == 302) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        if (responseBody['status'] == 'success') {
          return responseBody['data'];
        } else {
          throw Exception('Backend Error: ${responseBody['message']}');
        }
      } else {
        throw Exception('Server Error: ${response.statusCode}');
      }
    } catch (e) {
      print('ApiService Error: $e');
      rethrow;
    }
  }

  static Future<List<dynamic>> exportSheet(String sheetName) async {
    final response = await post('exportToJson', {'sheetName': sheetName});
    if (response is String) {
      return jsonDecode(response);
    }
    return response as List<dynamic>;
  }
}
