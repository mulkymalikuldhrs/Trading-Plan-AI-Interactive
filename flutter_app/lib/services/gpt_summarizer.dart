import 'package:flutter/foundation.dart';
import './api_service.dart';

class GptSummarizer {

  static Future<Map<String, dynamic>> getAiMasterSummary(String symbol) async {
    try {
      final response = await ApiService.post('getAiMasterSummary', {
        'symbol': symbol,
      });
      return response as Map<String, dynamic>;
    } catch (e) {
      debugPrint('GptSummarizer Error: $e');
      return {'error': 'Could not generate AI Master Summary.'};
    }
  }

  static Future<Map<String, dynamic>> validateTrade({
    required String pair,
    required String direction,
    required String entry,
    required String sl,
    required String tp,
    required String setup,
    required String mood,
  }) async {
    try {
      final response = await ApiService.post('getGptFeedback', {
        'promptType': 'EntryValidation',
        'promptData': {
          'Pair': pair,
          'Arah': direction,
          'SL': sl,
          'TP': tp,
          'Setup': setup,
          'Mood': mood,
        },
        'referenceId': 'ENTRY-${DateTime.now().millisecondsSinceEpoch}',
      });
      return response as Map<String, dynamic>;
    } catch (e) {
      debugPrint('GptSummarizer Error: $e');
      return {'analysis': 'Could not validate trade.'};
    }
  }
}
