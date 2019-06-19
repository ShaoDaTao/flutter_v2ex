import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:flutter/material.dart';

class ToWeb extends StatelessWidget {
  ToWeb({this.url});
  final String url;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return WebviewScaffold(
      appBar: AppBar(
        title: Text(url),
      ),
      url: url,
    );
  }
}


class ToImage extends StatelessWidget {
  ToImage({this.url});
  final String url;
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text(url),
      ),
      body: Center(child: Image.network(url),),
    );
  }

}