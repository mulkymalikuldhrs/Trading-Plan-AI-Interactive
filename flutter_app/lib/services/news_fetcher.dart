import 'api_service.dart';

class NewsFetcher {
  static Future<List<Map<String, String>>> getTopHeadlines(String query) async {
    try {
      final data = await ApiService.post('getAiMasterSummary', {'symbol': query});

      // The backend returns a list of news headlines in the master summary
      if (data.containsKey('news_headlines')) {
        List headlines = data['news_headlines'];
        return headlines.map((h) => {
          'title': h.toString(),
          'source': 'AI Market Intel'
        }).toList();
      }
      return [{'title': 'No recent news found for $query', 'source': 'System'}];
    } catch (e) {
      print('NewsFetcher Error: $e');
      return [{'title': 'Error: Could not fetch news from backend.', 'source': 'System'}];
    }
  }
}
