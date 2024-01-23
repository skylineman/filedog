
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

enum  WebViewPageType {
  Url,
  File,
  Asset
}

class WebViewPage extends StatefulWidget {
  const WebViewPage({Key? key, required this.url, required this.title, this.type = WebViewPageType.Url }) : super(key: key);

  final String url;
  final String title;
  final WebViewPageType type;

  @override
  _WebViewPageState createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {

  late WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController();

    switch ( widget.type ) {
      case WebViewPageType.Url:
        _controller.loadRequest( Uri.parse( widget.url ) );
        break;
      case WebViewPageType.File:
        _controller.loadFile( widget.url );
        break;
      case WebViewPageType.Asset:
        break;
    }

  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text( widget.title ),
      ),
      body: WebViewWidget(
        controller: _controller,
      )
    );
  }
}