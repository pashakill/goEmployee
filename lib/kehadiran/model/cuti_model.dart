import 'package:intl/intl.dart';

class CutiModel {
  final String jenisCuti;
  final String tanggalMulai;
  final String tanggalSelesai;
  final String alasan;
  final String dokumenUrl;

  CutiModel({
    required this.jenisCuti,
    required this.tanggalMulai,
    required this.tanggalSelesai,
    required this.alasan,
    required this.dokumenUrl,
  });

  /// Hitung lama cuti (dalam hari)
  int get lamaCuti {
    try {
      final start = DateFormat('yyyy-MM-dd').parse(tanggalMulai);
      final end = DateFormat('yyyy-MM-dd').parse(tanggalSelesai);
      return end.difference(start).inDays + 1;
    } catch (e) {
      return 0;
    }
  }
}
