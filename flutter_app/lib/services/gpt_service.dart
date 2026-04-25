import '../services/api_service.dart';

class GptService {
  static Future<dynamic> getValidation(Map<String, dynamic> data) async {
    return ApiService.post('getGptFeedback', {
      'promptType': 'EntryValidation',
      'promptData': data,
      'referenceId': 'VAL-${DateTime.now().millisecondsSinceEpoch}'
    });
  }
}
