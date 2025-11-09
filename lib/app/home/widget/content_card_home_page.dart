import 'package:flutter/material.dart';
import 'package:goemployee/goemployee.dart'; // Asumsi 'User' ada di sini

class ContentCardHomePage extends StatelessWidget {
  final User user;

  const ContentCardHomePage({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasPhoto = user.photo != null && user.photo!.isNotEmpty;
    String initials = '?'; // Default jika nama kosong
    if (user.nama.isNotEmpty) {
      initials = user.nama[0].toUpperCase();
    }
    // ----------------------------------------

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Expanded untuk mencegah overflow
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RoundedTextBlock(
                    title: user.companyName, // Langsung pakai user.companyName
                    textSize: 15,
                    textColor: Colors.white,
                    bgColor: Colors.green,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user.nama, // Langsung pakai user.nama
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user.role, // <-- 2. PERBAIKI TYPO DI SINI
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 16), // jarak antara text dan image

            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: 80,
                height: 80,
                color: Colors.green.shade700,
                child: hasPhoto
                    ? Image.network(
                  user.photo!, // Gunakan user.photo
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Text(
                        initials,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                )
                // JIKA TIDAK ADA FOTO
                    : Center(
                  // --- 5. GUNAKAN 'initials' ---
                  child: Text(
                    initials, // Gunakan 'initials'
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
        SizedBox(
          height: 16,
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: RoundedTextBlock(
            title: '26 Oktober 2025', // Ganti dengan data dinamis jika perlu
            textSize: 15,
            textColor: Colors.white,
            bgColor: Colors.green,
          ),
        ),
        AttendanceTimeline()
      ],
    );
  }
}