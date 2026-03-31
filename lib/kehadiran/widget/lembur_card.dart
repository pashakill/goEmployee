import 'package:flutter/material.dart';
import 'package:goemployee/goemployee.dart';

class LemburCard extends StatelessWidget {
  final LemburModel lemburModel;
  const LemburCard({Key? key, required this.lemburModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16.0),
        // 1. ICON (Dinamis berdasarkan Tipe)
        leading: Icon(
          Icons.play_for_work_outlined,
          color: Colors.green,
          size: 40,
        ),

        // 2. JUDUL (Dinamis berdasarkan Tipe)
        title: Text(
          lemburModel.catatanLembur,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),

        // 3. SUBTITLE (Menampilkan Tanggal dan Alasan)
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            Text(
              'Durasi ${lemburModel.lamaLembur}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        trailing: Text(
          '${DateHelper.formatDisplay(DateHelper.fromBackend(lemburModel.waktuMulai))} - ${DateHelper.formatDisplay(DateHelper.fromBackend(lemburModel.waktuSelesai))}',
          style: const TextStyle(color: Colors.black54),
        ),
        // 4. TRAILING (Dinamis berdasarkan Status)
        isThreeLine: true,
      )
    );
  }
}
