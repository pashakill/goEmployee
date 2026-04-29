import '../../common_module/repo/pengajuan_response.dart';

class PresensiBackdateModel {
  final int? id;
  final int userId;
  final String tanggal;
  final String? jamMasuk;
  final String? jamKeluar;
  final String alasan;
  final String? tanggalPengajuan;
  final String? dokumenUrl;


  PresensiBackdateModel({
    this.id,
    required this.userId,
    required this.tanggal,
    required this.jamMasuk,
    required this.jamKeluar,
    required this.alasan,
    this.dokumenUrl,
    this.tanggalPengajuan,
  });

  factory PresensiBackdateModel.fromJson(Map<String, dynamic> json) {
    return PresensiBackdateModel(
      id: json['id'],
      userId: json['user_id'],
      tanggal: json['tanggal'] ?? json['tanggal_mulai'],
      jamMasuk: json['jam_masuk'] ?? json['jam_mulai'],
      jamKeluar: json['jam_keluar'] ?? json['jam_selesai'],
      alasan: json['alasan'] ?? '',
      dokumenUrl: json['dokumen_url'] ?? '',
      tanggalPengajuan: json['tanggal_pengajuan'] ?? '',
    );
  }

  factory PresensiBackdateModel.fromApi(PengajuanData pengajuanData, String userId) {
    return PresensiBackdateModel(
        userId: int.parse(userId),
        id: pengajuanData.id,
        tanggal: pengajuanData.tanggal_mulai,
        jamMasuk: pengajuanData.jam_mulai,
        jamKeluar: pengajuanData.jam_selesai,
        alasan: pengajuanData.alasan,
        tanggalPengajuan: pengajuanData.tanggal_pengajuan,
        dokumenUrl: pengajuanData.berkas.isNotEmpty ? pengajuanData.berkas : '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'tanggal': tanggal,
      'jam_masuk': jamMasuk,
      'jam_keluar': jamKeluar,
      'alasan': alasan,
      'tanggal_pengajuan': tanggalPengajuan,
    };
  }

  String get terlambat {
    if (jamMasuk == null) return "-";
    final parts = jamMasuk!.split(":");
    final jam = int.parse(parts[0]);
    final menit = int.parse(parts[1]);
    final masuk = Duration(hours: jam, minutes: menit);
    final normal = const Duration(hours: 9);
    if (masuk <= normal) return "0 menit";
    final diff = masuk - normal;
    return "${diff.inHours} jam ${diff.inMinutes % 60} menit";
  }

  factory PresensiBackdateModel.fromMap(Map<String, dynamic> map) {
    return PresensiBackdateModel(
      id: map['id'],
      userId: map['user_id'],
      tanggal: map['tanggal'],
      jamMasuk: map['jam_masuk'],
      jamKeluar: map['jam_keluar'],
      alasan: map['alasan'],
      dokumenUrl: map['dokumen_url'] ?? '',
      tanggalPengajuan: map['tanggal_pengajuan'],
    );
  }
}