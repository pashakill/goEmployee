
class AbsensiDetailItem {
  final String tanggal;
  final String jamMasuk;
  final String jamKerja;
  final int lateMinutes;

  AbsensiDetailItem({
    required this.tanggal,
    required this.jamMasuk,
    required this.jamKerja,
    required this.lateMinutes,
  });

  factory AbsensiDetailItem.fromJson(Map<String, dynamic> json) {
    return AbsensiDetailItem(
      tanggal: (json['tanggal'] ?? '').toString(),
      jamMasuk: (json['jam_masuk'] ?? '-').toString(),
      jamKerja: (json['jam_kerja'] ?? '00:00').toString(),
      lateMinutes: (json['late_minutes'] ?? 0) as int,
    );
  }
}