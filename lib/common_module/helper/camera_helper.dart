import 'dart:convert';
import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'permission_helper.dart';

class CameraHelper {
  static final ImagePicker _picker = ImagePicker();

  /// Ambil foto dari kamera + kompres + convert ke Base64
  static Future<String?> pickFromCamera({int quality = 70}) async {
    try {
      final allowed = await PermissionHelper.requestCameraPermission();
      if (!allowed) return null;
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
      if (photo == null) return null;
      return await _compressAndConvert(photo.path, quality);
    } catch (e) {
      print("Error ambil foto kamera: $e");
      return null;
    }
  }

  /// Ambil gambar dari galeri + kompres + Base64
  static Future<String?> pickFromGallery({int quality = 70}) async {
    try {
      final allowed = await PermissionHelper.requestStoragePermission();
      if (!allowed) return null;

      final XFile? photo = await _picker.pickImage(source: ImageSource.gallery);
      if (photo == null) return null;

      return await _compressAndConvert(photo.path, quality);
    } catch (e) {
      print("Error ambil foto galeri: $e");
      return null;
    }
  }

  /// Helper kompres + convert
  static Future<String> _compressAndConvert(String path, int quality) async {
    final bytes = await File(path).readAsBytes();
    img.Image? image = img.decodeImage(bytes);
    if (image == null) throw Exception("Gagal decode image");

    // Resize jika terlalu besar (opsional)
    if (image.width > 1080) {
      image = img.copyResize(image, width: 1080);
    }

    // Encode ke JPEG dengan kualitas tertentu
    final jpg = img.encodeJpg(image, quality: quality);

    // Convert ke Base64
    return base64Encode(jpg);
  }
}
