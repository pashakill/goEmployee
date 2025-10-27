import 'package:flutter/material.dart';

class RoundedContainer extends StatelessWidget {
  final Color color;
  final double radius;
  final EdgeInsetsGeometry? margin;
  final WidgetBuilder builder;

  const RoundedContainer({
    Key? key,
    required this.color,
    this.radius = 12,
    this.margin,
    required this.builder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: IntrinsicWidth(
        child: IntrinsicHeight(
          child: builder(context),
        ),
      ),
    );
  }
}
