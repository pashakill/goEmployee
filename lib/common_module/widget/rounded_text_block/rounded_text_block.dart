import 'package:flutter/material.dart';

class RoundedTextBlock extends StatelessWidget {
  final String title;
  final double textSize;
  final Color textColor;
  final Color bgColor;

  const RoundedTextBlock({super.key,
    required this.title,
    required this.textSize, required this.textColor, required this.bgColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: textColor,
          fontSize: textSize,
        ),
      ),
    );
  }
}
