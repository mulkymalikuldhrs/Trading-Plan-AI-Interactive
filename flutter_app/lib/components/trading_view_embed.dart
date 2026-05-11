import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:ui_web' as ui;
import 'package:web/web.dart' as web;

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
  Widget build(BuildContext context) {
    if (kIsWeb) {
      final String viewType = 'tradingview-iframe-${widget.symbol}';

      ui.platformViewRegistry.registerViewFactory(
        viewType,
        (int viewId) {
          final iframeElement = web.HTMLIFrameElement()
            ..src = 'https://s.tradingview.com/widgetembed/?frameElementId=tradingview_12345&symbol=${widget.symbol}&interval=15&theme=dark'
            ..style.border = 'none'
            ..width = '100%'
            ..height = '100%';
          return iframeElement;
        },
      );

      return HtmlElementView(
        viewType: viewType,
      );
    } else {
      return WebViewWidget(controller: _controller);
    }
  }
}
