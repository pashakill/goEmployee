
class SlipGajiModel {
  final int id;
  final String bulan;
  final String tahun;
  final String fileBase64;

  SlipGajiModel({
    required this.id,
    required this.bulan,
    required this.tahun,
    required this.fileBase64,
  });

  factory SlipGajiModel.fromJson(Map<String, dynamic> json) {
    return SlipGajiModel(
      id: json['id'],
      bulan: json['bulan'],
      tahun: json['tahun'],
      fileBase64: json['file'],
    );
  }
}