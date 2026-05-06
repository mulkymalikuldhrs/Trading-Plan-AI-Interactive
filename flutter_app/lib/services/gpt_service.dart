import 'api_service.dart';

class GptService {
  static Future<Map<String, dynamic>> getValidation(Map<String, dynamic> tradeData) async {
    final result = await ApiService.post('getGptFeedback', {
      'promptType': 'EntryValidation',
      'promptData': tradeData,
      'referenceId': 'VAL-' + DateTime.now().millisecondsSinceEpoch.toString()
    });
    return result as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> getReflection(String mood, String lastAction) async {
    final result = await ApiService.post('getGptFeedback', {
      'promptType': 'EmotionalOverride',
      'promptData': {
        'Mood': mood,
        'last_action': lastAction,
      },
      'referenceId': 'REFL-' + DateTime.now().millisecondsSinceEpoch.toString()
    });
    return result as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> getWeeklySummary(Map<String, dynamic> summaryData) async {
    final result = await ApiService.post('triggerWeeklyAnalysis', summaryData);
    return result as Map<String, dynamic>;
  }
}
