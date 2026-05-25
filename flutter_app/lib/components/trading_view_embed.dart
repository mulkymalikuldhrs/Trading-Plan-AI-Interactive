import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

// Conditional import for web-only platform view registration
import 'trading_view_embed_stub.dart'
    if (dart.library.html) 'trading_view_embed_web.dart'
    if (dart.library.js) 'trading_view_embed_web.dart';

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
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(
          'https://s.tradingview.com/widgetembed/?frameElementId=tradingview_12345&symbol=${widget.symbol}&interval=15&theme=dark'));
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      // On web, use the platform-specific iframe widget
      return buildTradingViewWebEmbed(widget.symbol);
    } else {
      // On mobile, use WebView
      return WebViewWidget(controller: _controller);
    }
  }
}
