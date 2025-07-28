import 'dart:convert';
import 'package:http/http.dart' as http;

class NewsFetcher {
  // In a real app, this would be stored securely
  static const String _apiKey = "YOUR_NEWS_API_KEY";

  static Future<List<Map<String, String>>> getTopHeadlines(String query) async {
    final url = "https://newsapi.org/v2/everything?q=${query}&sortBy=publishedAt&pageSize=5&apiKey=${_apiKey}";

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final articles = data['articles'] as List;
        return articles.map((article) => {
          'title': article['title'] as String,
          'source': article['source']['name'] as String,
        }).toList();
      } else {
        throw Exception('Failed to load news');
      }
    } catch (e) {
      print('NewsFetcher Error: $e');
      return [{'title': 'Error: Could not fetch news.', 'source': ''}];
    }
  }
}
