import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import '../models/quick_link.dart';
import '../services/ar_launcher_service.dart';
import 'browser_screen.dart';
import 'model_viewer_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const ArLauncherService _arLauncher = ArLauncherService();

  static Future<void> _openArSceneViewer(BuildContext context) async {
    final result = await _arLauncher.launch(AppConstants.arModelUrl);
    if (result.success || !context.mounted) {
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('AR Launch Failed'),
          content: Text(result.message ?? 'Unknown failure'),
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
          builder: (_) => const ModelViewerScreen(modelUrl: AppConstants.arModelUrl),
        ),
      );
    }
  }

  void _openQuickLink(BuildContext context, QuickLink link) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BrowserScreen(title: link.title, url: link.url),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final link in AppConstants.quickLinks) ...[
                SizedBox(
                  width: 220,
                  child: ElevatedButton(
                    onPressed: () => _openQuickLink(context, link),
                    child: Text(link.label),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              // SizedBox(
              //   width: 220,
              //   child: ElevatedButton(
              //     onPressed: () => _openArSceneViewer(context),
              //     child: const Text('Show AR model'),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
