import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

class Base64ImageWidget extends StatelessWidget {
  final String base64String;

  const Base64ImageWidget({
    super.key,
    required this.base64String,
  });

  @override
  Widget build(BuildContext context) {
    try {
      String cleaned = base64String;

      if (cleaned.contains(',')) {
        cleaned = cleaned.split(',').last;
      }

      final bytes = base64Decode(cleaned);

      return Image.memory(
        height: 120,
        width: 120,
        bytes,
        fit: BoxFit.contain,
      );
    } catch (e) {
      return Container(
        height: 120,
        alignment: Alignment.center,
        child: const Icon(Icons.broken_image),
      );
    }
  }
}