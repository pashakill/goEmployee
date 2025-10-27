import 'package:flutter/material.dart';

class LinePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final bool isDashed;

  LinePainter({this.color = Colors.black, this.strokeWidth = 2.0, this.isDashed = false});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    if (!isDashed) {
      // garis horizontal full
      canvas.drawLine(Offset(0, size.height / 2), Offset(size.width, size.height / 2), paint);
    } else {
      // contoh dashed line horizontal
      const dashWidth = 8.0;
      const dashSpace = 6.0;
      double startX = 0;
      while (startX < size.width) {
        canvas.drawLine(Offset(startX, size.height / 2), Offset(startX + dashWidth, size.height / 2), paint);
        startX += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant LinePainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth || oldDelegate.isDashed != isDashed;
  }
}
