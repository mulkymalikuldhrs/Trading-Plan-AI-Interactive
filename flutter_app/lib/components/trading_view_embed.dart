import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:html' as html;
import 'dart:ui' as ui;

class TradingViewEmbed extends StatefulWidget {
  final String symbol;

  const TradingViewEmbed({Key? key, required this.symbol}) : super(key: key);

  @override
  _TradingViewEmbedState createState() => _TradingViewEmbedState();
}

class _TradingViewEmbedState extends State<TradingViewEmbed> {
  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      // Use IFrame for web
      final iframeElement = html.IFrameElement()
        ..src = 'https://s.tradingview.com/widgetembed/?frameElementId=tradingview_12345&symbol=${widget.symbol}&interval=15&theme=dark'
        ..style.border = 'none'
        ..width = '100%'
        ..height = '100%';

      // ignore: undefined_prefixed_name
      ui.platformViewRegistry.registerViewFactory(
        'tradingview-iframe-${widget.symbol}', // Unique ID for each instance
        (int viewId) => iframeElement,
      );

      return HtmlElementView(
        viewType: 'tradingview-iframe-${widget.symbol}',
      );
    } else {
      // Use WebView for mobile (Android/iOS)
      return WebView(
        initialUrl: 'https://s.tradingview.com/widgetembed/?frameElementId=tradingview_12345&symbol=${widget.symbol}&interval=15&theme=dark',
        javascriptMode: JavascriptMode.unrestricted,
      );
    }
  }
}
