import 'package:flutter/material.dart';
import 'package:goemployee/goemployee.dart';
import 'package:intl/intl.dart'; // Asumsi 'User' ada di sini

class ContentCardHomePage extends StatelessWidget {
  final User user;

  const ContentCardHomePage({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final today = DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(DateTime.now());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Hari Ini",
          style: TextStyle(
            color:
            Colors.green.withOpacity(0.75),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          today,
          style: const TextStyle(
            color: Colors.green,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        SizedBox(
          height: 8,
        ),
        AttendanceTimeline(user: user,)
      ],
    );
  }
}