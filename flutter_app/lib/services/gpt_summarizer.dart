import "package:flutter/foundation.dart";
import './api_service.dart';
// import './technical_analysis_service.dart';

class GptSummarizer {

  static Future<Map<String, dynamic>> getAiMasterSummary(String symbol) async {
    // According to AGENTS.md, all intelligent analysis and data aggregation
    // MUST happen in the GAS backend. The frontend simply calls the action.
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
}
