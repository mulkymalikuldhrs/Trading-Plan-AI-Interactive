import './api_service.dart';

class GptService {
  static Future<Map<String, dynamic>> getGptFeedback(Map<String, dynamic> data) async {
    final response = await ApiService.post('getGptFeedback', data);
    return response;
  }

  static Future<Map<String, dynamic>> validateEntry(Map<String, dynamic> entryData) async {
    return await getGptFeedback({
      'promptType': 'EntryValidation',
      'promptData': entryData,
      'referenceId': 'ENTRY_${DateTime.now().millisecondsSinceEpoch}'
    });
  }

  static Future<Map<String, dynamic>> getEmotionalReflection(String mood) async {
    return await getGptFeedback({
      'promptType': 'EmotionalOverride',
      'promptData': {'Mood': mood},
      'referenceId': 'EMOTION_${DateTime.now().millisecondsSinceEpoch}'
    });
  }
}
