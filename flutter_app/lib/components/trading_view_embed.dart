import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'dart:ui' as ui;

class TradingViewEmbed extends StatefulWidget {
  final String symbol;

  const TradingViewEmbed({Key? key, required this.symbol}) : super(key: key);

  @override
  _TradingViewEmbedState createState() => _TradingViewEmbedState();
}

class _TradingViewEmbedState extends State<TradingViewEmbed> {
  late html.IFrameElement _iframeElement;

  @override
  void initState() {
    super.initState();
    _iframeElement = html.IFrameElement()
      ..src = 'https://s.tradingview.com/widgetembed/?frameElementId=tradingview_12345&symbol=${widget.symbol}&interval=15&theme=dark'
      ..style.border = 'none'
      ..width = '100%'
      ..height = '100%';

    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(
      'tradingview-iframe',
      (int viewId) => _iframeElement,
    );
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(
      viewType: 'tradingview-iframe',
    );
  }
}
