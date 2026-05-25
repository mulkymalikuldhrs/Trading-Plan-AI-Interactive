import 'package:flutter/material.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:ui_web' as ui;
import 'package:web/web.dart' as web;

/// Web implementation using dart:ui_web for iframe embedding.
Widget buildTradingViewWebEmbed(String symbol) {
  final String viewType = 'tradingview-iframe-$symbol';

  ui.platformViewRegistry.registerViewFactory(
    viewType,
    (int viewId) {
      final iframeElement = web.HTMLIFrameElement()
        ..src = 'https://s.tradingview.com/widgetembed/?frameElementId=tradingview_12345&symbol=$symbol&interval=15&theme=dark'
        ..style.border = 'none'
        ..width = '100%'
        ..height = '100%';
      return iframeElement;
    },
  );

  return HtmlElementView(
    viewType: viewType,
  );
}
