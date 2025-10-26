import 'package:flutter/material.dart';

class AttendanceTimeline extends StatelessWidget {
  final List<Map<String, String>> attendance = [
    {"status": "Check-in", "time": "08:00"},
    {"status": "Check-out", "time": "17:00"},
    {"status": "Terlambat", "time": "08:15"},
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120, // Tinggi untuk menampung title + icon + time
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.all(16),
        itemCount: attendance.length,
        itemBuilder: (context, index) {
          final item = attendance[index];
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title di atas
                  Text(
                    item["status"]!,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Icon
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: item["status"] == "Terlambat"
                          ? Colors.red
                          : Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Jam
                  Text(
                    item["time"]!,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
              // Garis horizontal kecuali item terakhir
              if (index != attendance.length - 1)
                Container(
                  width: 50,
                  height: 2,
                  color: Colors.grey,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                ),
            ],
          );
        },
      ),
    );
  }
}
