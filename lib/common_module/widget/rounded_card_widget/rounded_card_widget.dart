import 'package:flutter/material.dart';

class RoundedCardWidget extends StatelessWidget {

  final Widget widget;

  const RoundedCardWidget({
    super.key, required this.widget
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: widget
      ),
    );
  }
}
