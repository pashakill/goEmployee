// Lokasi: [File model Anda, misalnya lembur_model.dart]

import 'package:intl/intl.dart';

class LemburModel {
  final int? id;
  final int userId; // Relasi ke tabel users
  final String catatanLembur;
  final String waktuMulai; // Format: HH:mm:ss
  final String waktuSelesai; // Format: HH:mm:ss
  final String lamaLembur; // Format: HH:mm
  // Hapus: final String tanggalLembur; 

  LemburModel({
    this.id,
    required this.userId,
    required this.lamaLembur,
    required this.catatanLembur,
    required this.waktuMulai,
    required this.waktuSelesai,
    // Hapus required this.tanggalLembur,
  });

  // Digunakan untuk insert ke database
  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'catatan_lembur': catatanLembur,
      'waktu_mulai': waktuMulai,
      'waktu_selesai': waktuSelesai,
      'lama_lembur': lamaLembur,
      // Hapus: 'tanggal_lembur': tanggalLembur,
    };
  }

  // Digunakan untuk membaca dari database
  factory LemburModel.fromMap(Map<String, dynamic> map) {
    return LemburModel(
      id: map['id'],
      userId: map['user_id'],
      catatanLembur: map['catatan_lembur'],
      waktuMulai: map['waktu_mulai'],
      waktuSelesai: map['waktu_selesai'],
      lamaLembur: map['lama_lembur'],
      // Hapus: tanggalLembur: map['tanggal_lembur'],
    );
  }
}