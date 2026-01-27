import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:package_info_plus/package_info_plus.dart';

enum UpdateStatus { latest, optionalUpdate, updateRequired }

class ForceUpdateService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Singleton pattern
  static final ForceUpdateService _instance = ForceUpdateService._internal();
  factory ForceUpdateService() => _instance;
  ForceUpdateService._internal();

  Future<UpdateStatus> checkVersion() async {
    try {
      // 1. Get current app version
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersionStr = packageInfo.version;

      // 2. Fetch version config from Firestore
      final doc = await _firestore
          .collection('version_control')
          .doc('config')
          .get();

      if (!doc.exists) {
        // If no config exists, assume we are safe
        return UpdateStatus.latest;
      }

      final data = doc.data()!;
      final minVersionStr = data['min_required_version'] as String? ?? '0.0.0';
      final latestVersionStr = data['latest_version'] as String? ?? '0.0.0';

      // 3. Compare versions
      final currentVersion = _parseVersion(currentVersionStr);
      final minVersion = _parseVersion(minVersionStr);
      final latestVersion = _parseVersion(latestVersionStr);

      if (currentVersion < minVersion) {
        return UpdateStatus.updateRequired;
      }

      if (currentVersion < latestVersion) {
        return UpdateStatus.optionalUpdate;
      }

      return UpdateStatus.latest;
    } catch (e) {
      // If error (e.g. offline), default to allowing access
      return UpdateStatus.latest;
    }
  }

  // Helper to parse "1.0.0" into an integer like 10000 for comparison
  int _parseVersion(String version) {
    try {
      // Remove any build numbers (e.g. "+37")
      final cleanVersion = version.split('+').first;
      final parts = cleanVersion.split('.').map((e) => int.parse(e)).toList();

      // Pad with zeros if needed
      while (parts.length < 3) {
        parts.add(0);
      }

      // Formula: Major * 10000 + Minor * 100 + Patch
      return parts[0] * 10000 + parts[1] * 100 + parts[2];
    } catch (e) {
      return 0;
    }
  }
}
