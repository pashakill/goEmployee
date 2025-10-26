import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // gunakan package flutter_svg yang benar

class SvgImageWithColor extends StatelessWidget {
  final Color color;
  final String path;
  final double width;

  const SvgImageWithColor({
    super.key,
    required this.width,
    required this.path,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      path,
      width: width,
      colorFilter: ColorFilter.mode(
        color,
        BlendMode.srcIn,
      ),
    );
  }
}
