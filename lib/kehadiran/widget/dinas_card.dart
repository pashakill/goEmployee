import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:goemployee/goemployee.dart';
import 'package:intl/intl.dart';

class DinasCard extends StatelessWidget {
  final DinasModel dinasModel;
  const DinasCard({Key? key, required this.dinasModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SvgPicture.asset(
              'assets/icons/ic_maps.svg',
              width: 24,
            ),
            const SizedBox(width: 10),

            // 🔥 WAJIB Expanded biar ga overflow
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Tanggal ---
                  Row(
                    children: [
                      const Icon(Icons.date_range, size: 16, color: Colors.grey),
                      const SizedBox(width: 6),

                      // 🔥 biar teks panjang ga keluar layar
                      Expanded(
                        child: Text(
                          '${DateFormat('dd MMMM yyyy', 'id_ID').format(DateTime.parse(dinasModel.tanggalMulai))} - ${DateFormat('dd MMMM yyyy', 'id_ID').format(DateTime.parse(dinasModel.tanggalSelesai))}',
                          style: const TextStyle(fontSize: 14),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // --- Alamat ---
                  Text(
                    dinasModel.alamat ?? '-',
                    style: const TextStyle(fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 8),

                  // --- Alasan ---
                  Text(
                    dinasModel.alasan ?? '-',
                    style: const TextStyle(fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}