import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

class Base64ImageWidget extends StatelessWidget {
  final String base64String;

  const Base64ImageWidget({super.key, required this.base64String});

  @override
  Widget build(BuildContext context) {
    try {
      // Decode Base64 menjadi Uint8List
      Uint8List bytes = base64Decode(base64String);
      return SizedBox(
        width: 120,
        height: 120,
        child: Image.memory(
          bytes,
          fit: BoxFit.cover, // bisa disesuaikan
        ),
      );
    } catch (e) {
      return const Center(child: Text('Gagal menampilkan gambar'));
    }
  }
}
