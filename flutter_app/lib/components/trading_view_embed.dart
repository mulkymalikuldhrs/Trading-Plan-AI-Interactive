import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'trading_view_web.dart' if (dart.library.io) 'trading_view_stub.dart';

class TradingViewEmbed extends StatefulWidget {
  final String symbol;

  const TradingViewEmbed({super.key, required this.symbol});

  @override
  State<TradingViewEmbed> createState() => _TradingViewEmbedState();
}

class _TradingViewEmbedState extends State<TradingViewEmbed> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..loadRequest(Uri.parse(
            'https://s.tradingview.com/widgetembed/?frameElementId=tradingview_12345&symbol=${widget.symbol}&interval=15&theme=dark'));
    }
  }

  @override
  void didUpdateWidget(TradingViewEmbed oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!kIsWeb && oldWidget.symbol != widget.symbol) {
      _controller.loadRequest(Uri.parse(
          'https://s.tradingview.com/widgetembed/?frameElementId=tradingview_12345&symbol=${widget.symbol}&interval=15&theme=dark'));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return getWebTradingView(widget.symbol);
    } else {
      return WebViewWidget(controller: _controller);
    }
  }
}
