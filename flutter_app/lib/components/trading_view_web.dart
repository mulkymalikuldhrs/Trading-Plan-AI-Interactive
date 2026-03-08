// ignore_for_file: avoid_web_libraries_in_flutter

import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'dart:ui_web' as ui;

Widget getWebTradingView(String symbol) {
  final iframeElement = html.IFrameElement()
    ..src =
        'https://s.tradingview.com/widgetembed/?frameElementId=tradingview_12345&symbol=$symbol&interval=15&theme=dark'
    ..style.border = 'none'
    ..width = '100%'
    ..height = '100%';

  // ignore: undefined_prefixed_name
  ui.platformViewRegistry.registerViewFactory(
    'tradingview-iframe-$symbol',
    (int viewId) => iframeElement,
  );

  return HtmlElementView(
    viewType: 'tradingview-iframe-$symbol',
  );
}
