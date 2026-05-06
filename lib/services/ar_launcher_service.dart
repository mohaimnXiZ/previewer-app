import 'dart:io';

import 'package:url_launcher/url_launcher.dart';

class ArLaunchResult {
  const ArLaunchResult._({
    required this.success,
    this.message,
  });

  final bool success;
  final String? message;

  factory ArLaunchResult.success() => const ArLaunchResult._(success: true);

  factory ArLaunchResult.failure(String message) =>
      ArLaunchResult._(success: false, message: message);
}

class ArLauncherService {
  const ArLauncherService();

  Future<ArLaunchResult> launch(String modelUrl) async {
    final preflight = await _preflightModelUrl(modelUrl);
    if (preflight != null) {
      return ArLaunchResult.failure(preflight);
    }

    final sceneUri = _sceneViewerHttpsUri(modelUrl);
    final intentCandidates = <(String, Uri)>[
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
      ('Scene Viewer HTTPS URL', sceneUri),
    ];

    final failures = <String>[];

    for (final candidate in intentCandidates) {
      final label = candidate.$1;
      final uri = candidate.$2;

      try {
        final supported = await canLaunchUrl(uri);
        if (!supported) {
          failures.add('$label: handler not available');
          continue;
        }

        final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (launched) {
          return ArLaunchResult.success();
        }

        failures.add('$label: launch returned false');
      } catch (e) {
        failures.add('$label: $e');
      }
    }

    final details = failures.isEmpty ? 'Unknown launch failure.' : failures.join('\n');
    return ArLaunchResult.failure(
      'AR launch failed after URL preflight passed.\n\n$details',
    );
  }

  Uri _sceneViewerIntentUri({
    required String packageName,
    required String modelUrl,
  }) {
    final separator = modelUrl.contains('?') ? '&' : '?';
    final noCacheUrl = '$modelUrl${separator}_cb=${DateTime.now().millisecondsSinceEpoch}';
    return Uri.parse(
      'intent://arvr.google.com/scene-viewer/1.0?file=${Uri.encodeComponent(noCacheUrl)}&mode=ar_preferred#Intent;scheme=https;package=$packageName;action=android.intent.action.VIEW;end;',
    );
  }

  Uri _sceneViewerHttpsUri(String modelUrl) {
    final separator = modelUrl.contains('?') ? '&' : '?';
    final noCacheUrl = '$modelUrl${separator}_cb=${DateTime.now().millisecondsSinceEpoch}';
    return Uri.parse(
      'https://arvr.google.com/scene-viewer/1.0?file=${Uri.encodeComponent(noCacheUrl)}&mode=ar_preferred',
    );
  }

  Future<String?> _preflightModelUrl(String modelUrl) async {
    final uri = Uri.tryParse(modelUrl);
    if (uri == null) {
      return 'Model URL is invalid.';
    }
    if (uri.scheme != 'https') {
      return 'Model URL must use HTTPS for Scene Viewer.';
    }

    final client = HttpClient()..connectionTimeout = const Duration(seconds: 12);
    try {
      final request = await client.headUrl(uri);
      final response = await request.close();

      if (response.statusCode < 200 || response.statusCode >= 400) {
        return 'Model URL returned HTTP ${response.statusCode}.';
      }

      final contentType = response.headers.contentType;
      final mimeType = contentType?.mimeType.toLowerCase() ?? '';
      if (mimeType.isNotEmpty &&
          mimeType != 'model/gltf-binary' &&
          mimeType != 'application/octet-stream') {
        return 'Model URL content-type is "$mimeType" (expected model/gltf-binary or application/octet-stream).';
      }

      final contentLength = response.contentLength;
      if (contentLength == 0) {
        return 'Model URL returned an empty body.';
      }
    } on SocketException catch (e) {
      return 'Network error while checking model URL: ${e.message}';
    } on HandshakeException {
      return 'TLS/SSL handshake failed for model URL.';
    } on HttpException catch (e) {
      return 'HTTP error while checking model URL: ${e.message}';
    } catch (e) {
      return 'Unexpected preflight error: $e';
    } finally {
      client.close(force: true);
    }

    return null;
  }
}
