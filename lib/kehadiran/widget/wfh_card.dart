import 'package:flutter/material.dart';
import 'package:goemployee/goemployee.dart';

class WfhCard extends StatelessWidget {
  final WfhModel wfhModel;
  const WfhCard({Key? key, required this.wfhModel}) : super(key: key);

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
            const SizedBox(height: 8),

            // Tanggal mulai & selesai
            Row(
              children: [
                const Icon(Icons.date_range, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Text(
                  '${wfhModel.waktuMulai} - ${wfhModel.waktuSelesai}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),
            Text(
              wfhModel.alasanWfh,
              style: const TextStyle(fontSize: 14),
            ),
            Text(
              'Durasi ${wfhModel.lamaWfh} hari',
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
