import 'package:flutter/material.dart';
import 'package:goemployee/goemployee.dart';
import 'package:intl/intl.dart';

class PresensiBackdateCard extends StatelessWidget {
  final PresensiBackdateModel presensiBackdateModel;
  const PresensiBackdateCard({Key? key, required this.presensiBackdateModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        title: Text(
          'Tanggal ${DateFormat('dd MMMM yyyy', 'id_ID').format(DateTime.parse(presensiBackdateModel.tanggal))}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),

            // 🔥 JAM MASUK & KELUAR
            Row(
              children: [
                const Icon(Icons.login, size: 16, color: Colors.green),
                const SizedBox(width: 4),
                Expanded(child: Text("Masuk: ${DateHelper.formatJam(presensiBackdateModel.jamMasuk ?? "-")}"),),
                const SizedBox(width: 16),
                const Icon(Icons.logout, size: 16, color: Colors.red),
                const SizedBox(width: 4),
                Expanded(child: Text("Keluar: ${DateHelper.formatJam(presensiBackdateModel.jamKeluar ?? "-")}"),)
              ],
            ),

            const SizedBox(height: 6),

            // 🔥 ALASAN
            Text('Alasan : ${presensiBackdateModel.alasan}'),
            Text('Di Ajukan Pada : ${DateFormat('dd MMMM yyyy', 'id_ID').format(DateTime.parse(presensiBackdateModel.tanggalPengajuan ?? ''))}', style: TextStyle(fontSize: 12)),
          ],
        ),
    ));
  }
}
