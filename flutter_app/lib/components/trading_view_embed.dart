import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TradingViewEmbed extends StatefulWidget {
  final String symbol;

  const TradingViewEmbed({Key? key, required this.symbol}) : super(key: key);

  @override
  _TradingViewEmbedState createState() => _TradingViewEmbedState();
}

class _TradingViewEmbedState extends State<TradingViewEmbed> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted);
      _loadChart();
    }
  }

  @override
  void didUpdateWidget(TradingViewEmbed oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!kIsWeb && oldWidget.symbol != widget.symbol) {
      _loadChart();
    }
  }

  void _loadChart() {
    _controller.loadRequest(Uri.parse(
        'https://s.tradingview.com/widgetembed/?frameElementId=tradingview_12345&symbol=${widget.symbol}&interval=15&theme=dark'));
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return Center(
          child: Text(
              "TradingView Chart for ${widget.symbol} (Web version requires manual IFrame registration)"));
    } else {
      // Use WebView for mobile (Android/iOS)
      return WebViewWidget(controller: _controller);
    }
  }
}
