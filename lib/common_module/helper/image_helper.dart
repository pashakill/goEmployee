import 'dart:io';
import 'dart:convert';
import 'package:image/image.dart' as img;

class ImageHelper {
  /// Compress gambar dan convert ke base64
  static Future<String?> compressAndConvertToBase64(File file, {int quality = 70}) async {
    try {
      final bytes = await file.readAsBytes();

      // Decode image
      img.Image? image = img.decodeImage(bytes);
      if (image == null) return null;

      // Compress ke JPEG
      final compressed = img.encodeJpg(image, quality: quality);

      // Convert ke base64
      return base64Encode(compressed);
    } catch (e) {
      print("Error compressing image: $e");
      return null;
    }
  }
}
