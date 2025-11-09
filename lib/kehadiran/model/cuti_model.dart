import 'package:intl/intl.dart';

class CutiModel {
  // Tambahkan field dari database
  final int? id;
  final int? userId;
  final String jenisCuti;
  final String tanggalMulai;
  final String tanggalSelesai;
  final String alasan;
  final String dokumenUrl;
  final String? status;
  final String? tanggalPengajuan;

  CutiModel({
    this.id,
    this.userId,
    required this.jenisCuti,
    required this.tanggalMulai,
    required this.tanggalSelesai,
    required this.alasan,
    required this.dokumenUrl,
    this.status,
    this.tanggalPengajuan,
  });

  /// Hitung lama cuti_page (dalam hari)
  int get lamaCuti {
    try {
      final start = DateFormat('yyyy-MM-dd').parse(tanggalMulai);
      final end = DateFormat('yyyy-MM-dd').parse(tanggalSelesai);
      // +1 agar 20-10-2025 s/d 20-10-2025 dihitung 1 hari
      return end.difference(start).inDays + 1;
    } catch (e) {
      return 0;
    }
  }

  /// Factory constructor untuk membuat CutiModel dari Map (hasil database)
  factory CutiModel.fromMap(Map<String, dynamic> map) {
    return CutiModel(
      id: map['id'],
      userId: map['user_id'],
      jenisCuti: map['jenis_cuti'],
      tanggalMulai: map['tanggal_mulai'],
      tanggalSelesai: map['tanggal_selesai'],
      alasan: map['alasan'],
      dokumenUrl: map['dokumen_url'] ?? '',
      status: map['status'],
      tanggalPengajuan: map['tanggal_pengajuan'],
    );
  }
}