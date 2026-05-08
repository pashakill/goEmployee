class StatusKehadiranModel {
  final bool checkin;
  final bool checkout;
  final String? jamMasuk;
  final String? jamKeluar;

  StatusKehadiranModel({
    required this.checkin,
    required this.checkout,
    this.jamMasuk,
    this.jamKeluar,
  });

  factory StatusKehadiranModel.fromJson(Map<String, dynamic> json) {
    return StatusKehadiranModel(
      checkin: json['checkin'],
      checkout: json['checkout'],
      jamMasuk: json['jam_masuk'],
      jamKeluar: json['jam_keluar'],
    );
  }
}