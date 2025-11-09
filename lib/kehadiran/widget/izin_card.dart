import 'package:flutter/material.dart';
import 'package:goemployee/goemployee.dart';
import 'package:intl/intl.dart';

class IzinCard extends StatelessWidget {
  final IzinConverterModel izinConverter;

  const IzinCard({super.key, required this.izinConverter});

  // Helper untuk mendapatkan Judul berdasarkan Tipe Izin
  String _getTitle(IzinTipe tipe) {
    switch (tipe) {
      case IzinTipe.telatMasuk:
        return 'Izin Telat Masuk';
      case IzinTipe.pulangAwal:
        return 'Izin Pulang Awal';
      case IzinTipe.tidakMasuk:
        return 'Izin Tidak Masuk';
      default:
        return 'Izin Tidak Dikenal';
    }
  }

  // Helper untuk mendapatkan Icon berdasarkan Tipe Izin
  IconData _getIcon(IzinTipe tipe) {
    switch (tipe) {
      case IzinTipe.telatMasuk:
        return Icons.login;
      case IzinTipe.pulangAwal:
        return Icons.logout;
      case IzinTipe.tidakMasuk:
        return Icons.block;
      default:
        return Icons.help_outline;
    }
  }

  // Helper untuk membuat Status Chip berdasarkan Status Izin
  Widget _buildStatusChip(IzinStatus status) {
    Color color;
    String label;

    switch (status) {
      case IzinStatus.approved:
        color = Colors.green;
        label = 'Disetujui';
        break;
      case IzinStatus.pending:
        color = Colors.orange;
        label = 'Pending';
        break;
      case IzinStatus.rejected:
        color = Colors.red;
        label = 'Ditolak';
        break;
      default:
        color = Colors.grey;
        label = 'Unknown';
    }

    return Chip(
      label: Text(
        label,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 0),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16.0),

        // 1. ICON (Dinamis berdasarkan Tipe)
        leading: Icon(
          _getIcon(izinConverter.tipe),
          color: Colors.green,
          size: 40,
        ),

        // 2. JUDUL (Dinamis berdasarkan Tipe)
        title: Text(
          _getTitle(izinConverter.tipe),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),

        // 3. SUBTITLE (Menampilkan Tanggal dan Alasan)
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            // Format tanggal (dd MMMM yyyy)
            Text(
              DateFormat('dd MMMM yyyy', 'id_ID').format(izinConverter.tanggal),
              style: const TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 6),
            Text(
              izinConverter.alasan,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),

        // 4. TRAILING (Dinamis berdasarkan Status)
        trailing: _buildStatusChip(izinConverter.status),
        isThreeLine: true,
      ),
    );
  }
}