import 'api_service.dart';

class GptService {
  static Future<Map<String, dynamic>> getValidation(Map<String, dynamic> tradeData) {
    return ApiService.post('getGptFeedback', {
      'promptType': 'EntryValidation',
      'promptData': tradeData,
      'referenceId': 'trade-validation'
    });
  }

  static Future<Map<String, dynamic>> getReflection(String mood, String lastAction) {
    return ApiService.post('getGptFeedback', {
      'promptType': 'EmotionalOverride',
      'promptData': {
        'Mood': mood,
        'last_action': lastAction,
      },
      'referenceId': 'reflection'
    });
  }

  static Future<Map<String, dynamic>> getWeeklySummary(Map<String, dynamic> summaryData) {
    return ApiService.post('getGptFeedback', {
      'promptType': 'WeeklySummary',
      'promptData': summaryData,
      'referenceId': 'weekly-summary'
    });
  }
}
