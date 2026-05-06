import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ModelViewerScreen extends StatefulWidget {
  const ModelViewerScreen({super.key, required this.modelUrl});

  final String modelUrl;

  @override
  State<ModelViewerScreen> createState() => _ModelViewerScreenState();
}

class _ModelViewerScreenState extends State<ModelViewerScreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    final encodedModelUrl = jsonEncode(widget.modelUrl);
    final html = '''
<!doctype html>
<html>
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <script type="module" src="https://unpkg.com/@google/model-viewer/dist/model-viewer.min.js"></script>
    <style>
      html, body { margin: 0; padding: 0; width: 100%; height: 100%; background: #111; }
      model-viewer { width: 100%; height: 100%; }
    </style>
  </head>
  <body>
    <model-viewer id="viewer" camera-controls touch-action="pan-y" auto-rotate shadow-intensity="1"></model-viewer>
    <script>
      const modelUrl = $encodedModelUrl;
      document.getElementById('viewer').setAttribute('src', modelUrl);
    </script>
  </body>
</html>
''';

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadHtmlString(html);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('3D Model Viewer')),
      body: WebViewWidget(controller: _controller),
    );
  }
}
