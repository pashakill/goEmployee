import 'package:flutter/material.dart';
import 'package:goemployee/goemployee.dart'; // Asumsi 'User' ada di sini

class AttendanceTimeline extends StatelessWidget {
  final User user;

  const AttendanceTimeline({ // <-- Tambahkan 'const'
    super.key,
    required this.user,
  });

  // HAPUS: List 'attendance' yang hardcoded

  @override
  Widget build(BuildContext context) {
    // --- 1. AMBIL DATA DINAMIS DARI 'user' ---
    // Beri nilai default '--:--' jika datanya 'null'
    final String timeIn = user.timeCheckin ?? '--:--';
    final String timeOut = user.timeCheckout ?? '--:--';
    final String lateIn = user.lateCheckin ?? '--:--';

    // --- 2. BUAT LIST 'attendance' SECARA DINAMIS ---
    // (List ini sekarang berada di dalam build method)
    final List<Map<String, String>> dynamicAttendance = [
      {"status": "Check-in", "time": timeIn},
      {"status": "Check-out", "time": timeOut},
      {"status": "Terlambat", "time": lateIn},
    ];
    // ----------------------------------------------

    return SizedBox(
      height: 120, // Tinggi untuk menampung title + icon + time
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.all(16),
        // --- 3. GUNAKAN LIST DINAMIS ---
        itemCount: dynamicAttendance.length,
        itemBuilder: (context, index) {
          final item = dynamicAttendance[index]; // Gunakan list dinamis
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
                    style: const TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ],
              ),
              // Garis horizontal kecuali item terakhir
              // --- 4. GUNAKAN LIST DINAMIS ---
              if (index != dynamicAttendance.length - 1)
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