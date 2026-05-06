import 'api_service.dart';

class NewsFetcher {
  static Future<List<dynamic>> getTopHeadlines(String symbol) async {
    try {
      final data = await ApiService.post('getMarketData', {'symbol': symbol});
      return data['news_headlines'] ?? [];
    } catch (e) {
      print('NewsFetcher Error: $e');
      return ['Error: Could not fetch news.'];
    }
  }
}
