// Lokasi: [File model Anda, misalnya dinas_model.dart]

class DinasModel {
  final int? id; // Untuk ID dari database
  final int userId; // Relasi ke tabel users
  final String tanggalMulai; // Format: yyyy-MM-dd
  final String tanggalSelesai; // Format: yyyy-MM-dd
  final String alamat;
  final String latitude;
  final String longTitude;
  final String radius; // Radius area dinas
  final String alasan;
  final String tanggalPengajuan; // Kapan dinas ini diajukan

  DinasModel({
    this.id,
    required this.userId,
    required this.tanggalMulai,
    required this.tanggalSelesai,
    required this.alamat,
    required this.latitude,
    required this.longTitude,
    required this.radius,
    required this.alasan,
    required this.tanggalPengajuan,
  });

  // Digunakan untuk insert ke database
  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'tanggal_mulai': tanggalMulai,
      'tanggal_selesai': tanggalSelesai,
      'alamat': alamat,
      'latitude': latitude,
      'longTitude': longTitude,
      'radius': radius,
      'alasan': alasan,
      'tanggal_pengajuan': tanggalPengajuan,
    };
  }

  // Digunakan untuk membaca dari database
  factory DinasModel.fromMap(Map<String, dynamic> map) {
    return DinasModel(
      id: map['id'],
      userId: map['user_id'],
      tanggalMulai: map['tanggal_mulai'],
      tanggalSelesai: map['tanggal_selesai'],
      alamat: map['alamat'],
      latitude: map['latitude'],
      longTitude: map['longTitude'],
      radius: map['radius'],
      alasan: map['alasan'],
      tanggalPengajuan: map['tanggal_pengajuan'],
    );
  }
}