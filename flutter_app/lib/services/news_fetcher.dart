import 'package:flutter/foundation.dart';
import 'api_service.dart';

class NewsFetcher {
  static Future<List<Map<String, String>>> getTopHeadlines(String query) async {
    try {
      final response = await ApiService.post('getAiMasterSummary', {'symbol': query});
      final List<dynamic> headlines = response['news_headlines'] ?? [];

      return headlines.map((h) => {
        'title': h.toString(),
        'source': h.toString().contains('[') ? h.toString().split(']')[0].replaceAll('[', '') : 'News',
      }).toList();
    } catch (e) {
      debugPrint('NewsFetcher Error: $e');
      return [{'title': 'Error: Could not fetch news.', 'source': ''}];
    }
  }
}
