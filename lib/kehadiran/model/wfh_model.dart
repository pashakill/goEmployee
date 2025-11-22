// Lokasi: [File model Anda, misalnya wfh_model.dart]

import 'package:intl/intl.dart';

class WfhModel {
  final int? id; // Untuk ID dari database
  final int userId; // Relasi ke tabel users
  final String alasanWfh;
  final String waktuMulai; // Format: HH:mm:ss
  final String waktuSelesai; // Format: HH:mm:ss
  final String lamaWfh; // Format: HH:mm
  final String tanggalPengajuan; // Kapan WFH ini diajukan

  WfhModel({
    this.id,
    required this.userId,
    required this.lamaWfh,
    required this.alasanWfh,
    required this.waktuMulai,
    required this.waktuSelesai,
    required this.tanggalPengajuan, // Ditambahkan untuk DB
  });

  // Digunakan untuk insert ke database
  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'alasan_wfh': alasanWfh,
      'waktu_mulai': waktuMulai,
      'waktu_selesai': waktuSelesai,
      'lama_wfh': lamaWfh,
      'tanggal_pengajuan': tanggalPengajuan,
    };
  }

  // Digunakan untuk membaca dari database
  factory WfhModel.fromMap(Map<String, dynamic> map) {
    return WfhModel(
      id: map['id'],
      userId: map['user_id'],
      alasanWfh: map['alasan_wfh'],
      waktuMulai: map['waktu_mulai'],
      waktuSelesai: map['waktu_selesai'],
      lamaWfh: map['lama_wfh'],
      tanggalPengajuan: map['tanggal_pengajuan'],
    );
  }
}