

import 'package:permission_handler/permission_handler.dart';

class PermissionHelper {
  /// Meminta izin kamera
  static Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.status;
    if (status.isGranted) return true;
    final result = await Permission.camera.request();
    return result.isGranted;
  }

  /// Meminta izin storage (untuk menyimpan foto)
  static Future<bool> requestStoragePermission() async {
    final status = await Permission.storage.status;
    if (status.isGranted) return true;
    final result = await Permission.storage.request();
    return result.isGranted;
  }

  /// Meminta dua permission sekaligus
  static Future<bool> requestAll() async {
    final camera = await requestCameraPermission();
    final storage = await requestStoragePermission();
    return camera && storage;
  }
}
