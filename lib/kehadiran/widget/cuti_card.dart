import 'package:flutter/material.dart';
import 'package:goemployee/goemployee.dart';

class CutiCard extends StatelessWidget {
  final CutiModel cuti;
  const CutiCard({Key? key, required this.cuti}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Jenis Cuti
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  cuti.jenisCuti,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const Icon(Icons.event_note, color: Colors.green),
              ],
            ),
            const SizedBox(height: 8),

            // Tanggal mulai & selesai
            Row(
              children: [
                const Icon(Icons.date_range, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Text(
                  '${cuti.tanggalMulai} → ${cuti.tanggalSelesai}',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),

            // Lama cuti
            Padding(
              padding: const EdgeInsets.only(left: 22, top: 4),
              child: Text(
                'Lama cuti_page: ${cuti.lamaCuti} hari',
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Alasan
            Text(
              'Alasan: ${cuti.alasan}',
              style: const TextStyle(fontSize: 14),
            ),

            const SizedBox(height: 8),

            // Dokumen
            Row(
              children: [
                const Icon(Icons.attach_file, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    cuti.dokumenUrl.isNotEmpty
                        ? cuti.dokumenUrl
                        : 'Belum ada dokumen',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
