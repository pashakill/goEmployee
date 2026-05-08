import 'package:geolocator/geolocator.dart';
import 'package:safe_device/safe_device.dart';

class MobileSecurityChecker {

  /// 🔐 DETEKSI ROOT / JAILBREAK
  Future<bool> isRooted() async {
    try {
      return await SafeDevice.isJailBroken;
    } catch (_) {
      return true;
    }
  }

  /// 🔐 DETEKSI MOCK LOCATION
  Future<bool> isMockLocation(Position pos) async {
    try {
      return pos.isMocked;
    } catch (_) {
      return true;
    }
  }

  /// 🔐 AKURASI GPS
  bool isBadAccuracy(Position pos, {double maxAccuracy = 100}) {
    return pos.accuracy > maxAccuracy;
  }

  /// 🔐 FINAL CHECK
  Future<bool> isSafe(Position pos) async {
    final root = await isRooted();
    final mock = await isMockLocation(pos);
    final badAcc = isBadAccuracy(pos);

    return !(root || mock || badAcc);
  }
}