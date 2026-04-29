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
      child: ListTile(
        contentPadding: const EdgeInsets.all(16.0),
        // 1. ICON (Dinamis berdasarkan Tipe)
        leading: SvgPicture.asset(
          'assets/icons/ic_maps.svg',
          width: 32,
        ),

        // 2. JUDUL (Dinamis berdasarkan Tipe)
        title: Row(
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

        // 3. SUBTITLE (Menampilkan Tanggal dan Alasan)
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            Text(
              dinasModel.alamat ?? '-',
              style: const TextStyle(color: Colors.black54),
            ),
            Text(
              dinasModel.alasan ?? '-',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            Text('Di Ajukan Pada : ${DateFormat('dd MMMM yyyy', 'id_ID').format(DateTime.parse(dinasModel.tanggalPengajuan ?? ''))}', style: TextStyle(fontSize: 12),),
          ],
        ),
        // 4. TRAILING (Dinamis berdasarkan Status)
        isThreeLine: false,
      ),
    );
  }
}