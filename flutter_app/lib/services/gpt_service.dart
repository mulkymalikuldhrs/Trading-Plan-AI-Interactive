import 'api_service.dart';

class GptService {
  static Future<Map<String, dynamic>> getValidation(Map<String, dynamic> tradeData) {
    return ApiService.getGptFeedback('EntryValidation', 'trade-validation', tradeData);
  }

  static Future<Map<String, dynamic>> getReflection(String mood, String lastAction) {
    return ApiService.getGptFeedback('EmotionalOverride', 'reflection', {
      'Mood': mood,
      'last_action': lastAction,
    });
  }

  static Future<Map<String, dynamic>> getWeeklySummary(Map<String, dynamic> summaryData) {
    return ApiService.getGptFeedback('WeeklySummary', 'weekly-summary', summaryData);
  }
}
