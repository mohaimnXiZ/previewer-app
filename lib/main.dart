import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Previewer',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue)),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const String _robotModelUrl =
      'https://cdn.pixabay.com/download/objects3d/2025/12/22/processed_3332__8a1756a876.glb?filename=pixellabs-robot-3332.glb';
  static const String _dartModelUrl =
      'https://cdn.pixabay.com/download/objects3d/2026/03/08/processed_3943__5d256c038d.glb?filename=gustavorezende-dart-3943.glb';
  static const String _treeModelUrl =
      'https://cdn.pixabay.com/download/objects3d/2025/06/30/processed_11__525746f65f.glb?filename=blendertimer-tree-11.glb';

  static Uri _sceneViewerIntentUri({
    required String packageName,
    required String modelUrl,
  }) {
    return Uri.parse(
      'intent://arvr.google.com/scene-viewer/1.0?file=${Uri.encodeComponent(modelUrl)}&mode=ar_preferred#Intent;scheme=https;package=$packageName;action=android.intent.action.VIEW;end;',
    );
  }

  static Uri _sceneViewerHttpsUri({required String modelUrl}) {
    return Uri.parse(
      'https://arvr.google.com/scene-viewer/1.0?file=${Uri.encodeComponent(modelUrl)}&mode=ar_preferred',
    );
  }

  static Future<void> _openArSceneViewer(
    BuildContext context, {
    required String modelUrl,
  }) async {
    final candidates = <(String, Uri)>[
      (
        'Google app Scene Viewer intent',
        _sceneViewerIntentUri(
          packageName: 'com.google.android.googlequicksearchbox',
          modelUrl: modelUrl,
        ),
      ),
      (
        'Chrome Scene Viewer intent',
        _sceneViewerIntentUri(
          packageName: 'com.android.chrome',
          modelUrl: modelUrl,
        ),
      ),
      ('Scene Viewer HTTPS URL', _sceneViewerHttpsUri(modelUrl: modelUrl)),
    ];

    final failureReasons = <String>[];

    for (final candidate in candidates) {
      final label = candidate.$1;
      final uri = candidate.$2;

      try {
        final supported = await canLaunchUrl(uri);
        if (!supported) {
          failureReasons.add('$label: handler not available');
          continue;
        }

        final launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );

        if (launched) {
          return;
        }
        failureReasons.add('$label: launch returned false');
      } catch (e) {
        failureReasons.add('$label: $e');
      }
    }

    if (!context.mounted) {
      return;
    }

    final message = failureReasons.isEmpty
        ? 'AR launch failed for an unknown reason.'
        : 'AR launch failed:\n\n${failureReasons.join('\n')}';

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('AR Launch Failed'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Open 3D Viewer'),
            ),
          ],
        );
      },
    );

    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ModelViewerScreen(modelUrl: modelUrl),
        ),
      );
    }
  }

  Widget _buildModelButton(
    BuildContext context, {
    required String label,
    required String modelUrl,
  }) {
    return SizedBox(
      width: 220,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black87,
          foregroundColor: Colors.white,
        ),
        onPressed: () => _openArSceneViewer(context, modelUrl: modelUrl),
        child: Text(label),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Previewer'),backgroundColor: Colors.white,),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          children: [
             Padding(
               padding: EdgeInsets.only(left: 18),
               child: Text(
                 'WebView Exampless',
                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
               ),
             ),
            const SizedBox(height: 16),
            Center(
              child: Column(
                children: [
              SizedBox(
                width: 220,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const BrowserScreen(title: 'YouTube', url: 'https://www.youtube.com'),
                      ),
                    );
                  },
                  child: const Text('YouTube'),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: 220,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const BrowserScreen(title: 'Wikipedia', url: 'https://www.wikipedia.org'),
                      ),
                    );
                  },
                  child: const Text('Wikipedia'),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: 220,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const BrowserScreen(title: 'Instagram', url: 'https://www.instagram.com'),
                      ),
                    );
                  },
                  child: const Text('Instagram'),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: 220,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const BrowserScreen(title: 'Facebook', url: 'https://www.facebook.com'),
                      ),
                    );
                  },
                  child: const Text('Facebook'),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: 220,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const BrowserScreen(
                          title: 'Google Chrome',
                          url: 'https://www.google.com',
                        ),
                      ),
                    );
                  },
                  child: const Text('Google'),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: 220,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                        const BrowserScreen(title: 'Apple legal', url: 'https://www.apple.com/legal/internet-services/terms/site.html'),
                      ),
                    );
                  },
                  child: const Text('apple'),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: 220,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                        const BrowserScreen(title: 'Shopify', url: 'https://changelog.shopify.com/'),
                      ),
                    );
                  },
                  child: const Text('Shopify'),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: 220,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                        const BrowserScreen(title: 'Payment example', url: 'https://buy.stripe.com/test_3cIaEQ3MQfne2Ct6qj4sE00'),
                      ),
                    );
                  },
                  child: const Text('Payment Example'),
                ),
              ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Center(
              child: Text(
                'AR Examples',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Column(
                children: [
              _buildModelButton(
                context,
                label: 'Show Robot 3D Model',
                modelUrl: _robotModelUrl,
              ),
              const SizedBox(height: 16),
              _buildModelButton(
                context,
                label: 'Show Dart 3D Model',
                modelUrl: _dartModelUrl,
              ),
              const SizedBox(height: 16),
              _buildModelButton(
                context,
                label: 'Show Tree 3D Model',
                modelUrl: _treeModelUrl,
              ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BrowserScreen extends StatefulWidget {
  const BrowserScreen({super.key, required this.title, required this.url});

  final String title;
  final String url;

  @override
  State<BrowserScreen> createState() => _BrowserScreenState();
}

class _BrowserScreenState extends State<BrowserScreen> {
  late final WebViewController _controller;
  bool _showOfflineView = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (!mounted) {
              return;
            }
            setState(() {
              _isLoading = true;
              _showOfflineView = false;
            });
          },
          onPageFinished: (_) {
            if (!mounted) {
              return;
            }
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (error) {
            if (!mounted) {
              return;
            }
            if (_isNetworkError(error)) {
              setState(() {
                _isLoading = false;
                _showOfflineView = true;
              });
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  bool _isNetworkError(WebResourceError error) {
    return error.errorType == WebResourceErrorType.hostLookup ||
        error.errorType == WebResourceErrorType.connect ||
        error.errorType == WebResourceErrorType.timeout;
  }

  void _retry() {
    setState(() {
      _showOfflineView = false;
      _isLoading = true;
    });
    _controller.reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: SafeArea(
        bottom: widget.title == "YouTube" ? false : widget.title == "Instagram" ? false : true,
        child: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_isLoading && !_showOfflineView)
              const Center(child: CircularProgressIndicator()),
            if (_showOfflineView)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.wifi_off, size: 48),
                      const SizedBox(height: 12),
                      const Text(
                        'No internet connection',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Please check your network and try again.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _retry,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

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
