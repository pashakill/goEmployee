class AbsensiModel {
  final String id;
  final String userId;
  final String nama;
  final String tanggal;
  final String jamMasuk;
  final String jamPulang;
  final String status;
  final String division;
  final String source;

  AbsensiModel({
    required this.source,
    required this.id,
    required this.userId,
    required this.nama,
    required this.tanggal,
    required this.jamMasuk,
    required this.jamPulang,
    required this.status,
    required this.division
  });

  factory AbsensiModel.fromJson(Map<String, dynamic> json) {
    return AbsensiModel(
      source: json['source'] ?? '',
      id: json['id'].toString(),
      userId: json['user_id'].toString(),
      nama: json['nama'] ?? '',
      tanggal: json['tanggal'] ?? '',
      jamMasuk: json['jam_masuk'] ?? '-',
      jamPulang: json['jam_pulang'] ?? '-',
      status: json['status'] ?? '-',
        division: json['division'] ?? '-'
    );
  }
}