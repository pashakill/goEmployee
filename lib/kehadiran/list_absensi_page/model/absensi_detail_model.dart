class AbsensiDetailItem {

  final String tanggal;
  final String jamMasuk;
  final String jamKerja;
  final int lateMinutes;
  final String status;

  AbsensiDetailItem({
    required this.tanggal,
    required this.jamMasuk,
    required this.jamKerja,
    required this.lateMinutes,
    required this.status,
  });

  factory AbsensiDetailItem.fromJson(
      Map<String, dynamic> json) {

    return AbsensiDetailItem(

      tanggal:
      (json['tanggal'] ?? '').toString(),

      jamMasuk:
      (json['jam_masuk'] ?? '-').toString(),

      jamKerja:
      (json['jam_kerja'] ?? '-').toString(),

      lateMinutes:
      int.tryParse(
        json['late_minutes'].toString(),
      ) ?? 0,

      status:
      (json['status'] ?? '').toString(),
    );
  }
}