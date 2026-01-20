import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

class ForceUpdateService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> checkForUpdate(BuildContext context) async {
    try {
      // Fetch remote config (min_version) from Firestore
      final doc = await _firestore
          .collection('app_config')
          .doc('version')
          .get();
      if (!doc.exists) return;

      final data = doc.data();
      if (data == null) return;

      final String minVersion = data['min_version'] ?? '0.0.0';
      final String storeUrl = Platform.isIOS
          ? (data['app_store_url'] ?? '')
          : (data['play_store_url'] ?? '');

      // Get current app version
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      if (_isUpdateRequired(currentVersion, minVersion)) {
        if (context.mounted) {
          _showForceUpdateDialog(context, storeUrl);
        }
      }
    } catch (e) {
      debugPrint('Error checking for update: $e');
    }
  }

  bool _isUpdateRequired(String current, String min) {
    List<int> c = current.split('.').map(int.parse).toList();
    List<int> m = min.split('.').map(int.parse).toList();

    // Normalize lengths (e.g., 1.0 vs 1.0.1)
    while (c.length < 3) c.add(0);
    while (m.length < 3) m.add(0);

    for (int i = 0; i < 3; i++) {
      if (c[i] < m[i]) return true;
      if (c[i] > m[i]) return false;
    }
    return false;
  }

  void _showForceUpdateDialog(BuildContext context, String url) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent closing by tapping outside
      builder: (BuildContext context) {
        // WillPopScope is deprecated, use PopScope
        return PopScope(
          canPop: false, // Prevent back button
          child: AlertDialog(
            title: const Text('Update Required'),
            content: const Text(
              'A new version of ThoughtVault is available. Please update the app to continue using it.',
            ),
            actions: [
              TextButton(
                child: const Text('Update Now'),
                onPressed: () async {
                  final uri = Uri.parse(url);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
