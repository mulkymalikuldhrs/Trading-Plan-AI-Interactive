import 'api_service.dart';

class GptService {
  static Future<Map<String, dynamic>> getValidation(Map<String, dynamic> tradeData) {
    return ApiService.post('getGptFeedback', {
      'promptType': 'EntryValidation',
      'referenceId': 'trade-validation',
      'promptData': tradeData,
    });
  }

  static Future<Map<String, dynamic>> getReflection(String mood, String lastAction) {
    return ApiService.post('getGptFeedback', {
      'promptType': 'EmotionalOverride',
      'referenceId': 'reflection',
      'promptData': {
        'Mood': mood,
        'last_action': lastAction,
      },
    });
  }

  static Future<Map<String, dynamic>> getWeeklySummary(Map<String, dynamic> summaryData) {
    return ApiService.post('getGptFeedback', {
      'promptType': 'WeeklySummary',
      'referenceId': 'weekly-summary',
      'promptData': summaryData,
    });
  }
}
