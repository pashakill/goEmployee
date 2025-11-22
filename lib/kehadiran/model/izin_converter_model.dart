
// 1. Definisikan Enum untuk Tipe dan Status
// Ini membuat kode Anda lebih aman dari typo string

import 'package:intl/intl.dart';

enum IzinTipe {
  telatMasuk,
  pulangAwal,
  tidakMasuk,
  unknown // Untuk data yang tidak dikenal
}

enum IzinStatus {
  pending,
  approved,
  rejected,
  unknown
}

// 2. Buat Model Izin Terpadu
class IzinConverterModel {
  final String id;
  final IzinTipe tipe;
  final IzinStatus status;
  final DateTime tanggal; // Bisa jadi tanggal izin_page atau tanggal pengajuan
  final String alasan;
  final DateTime? jam; // Opsional, hanya untuk telat/pulang awal
  final int? userId; // Diperlukan untuk FOREIGN KEY ke tabel users
  final String tanggalPengajuan; // Format: YYYY-MM-DD (Kapan pengajuan dilakukan)

  IzinConverterModel({
    required this.id,
    required this.tipe,
    required this.status,
    required this.tanggal,
    required this.alasan,
    this.jam,
    this.userId, // Waji
    required this.tanggalPengajuan
  });

  // 3. Buat 'factory constructor' untuk parsing JSON dari API
  // Ini adalah bagian terpenting
  factory IzinConverterModel.fromJson(Map<String, dynamic> json) {
    // Ambil user_id jika ada (biasanya dari database/API list)
    final int? parsedUserId = json['user_id'] is int ? json['user_id'] : null;

    return IzinConverterModel(
      id: json['id'] ?? '',
      userId: parsedUserId, // <-- TAMBAHAN: Ambil user_id dari JSON
      tanggalPengajuan: json['tanggal_pengajuan'] as String? ?? DateFormat('yyyy-MM-dd').format(DateTime.now()), // Pastikan String

      // Mengubah string dari API menjadi Enum
      tipe: _parseTipe(json['tipe']),
      status: _parseStatus(json['status']),

      // Mengubah string tanggal ISO menjadi DateTime
      tanggal: DateTime.parse(json['tanggal']),

      alasan: json['alasan'] ?? 'Tidak ada alasan',

      // Cek jika field 'jam' ada, lalu parse
      jam: json['jam'] != null ? DateTime.parse(json['jam']) : null,
    );
  }

  IzinConverterModel copyWith({
    String? id,
    IzinTipe? tipe,
    IzinStatus? status,
    DateTime? tanggal,
    String? alasan,
    DateTime? jam,
    int? userId,
    String? tanggalPengajuan,
  }) {
    return IzinConverterModel(
      // Gunakan nilai baru jika disediakan, jika tidak gunakan nilai lama (this.)
      id: id ?? this.id,
      tipe: tipe ?? this.tipe,
      status: status ?? this.status,
      tanggal: tanggal ?? this.tanggal,
      alasan: alasan ?? this.alasan,
      jam: jam ?? this.jam,
      userId: userId ?? this.userId,
      tanggalPengajuan: tanggalPengajuan ?? this.tanggalPengajuan,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      // Pastikan user_id di-handle sebagai int
      'user_id': userId,
      // Konversi Enum kembali ke string untuk DB
      'tipe': _tipeToString(tipe),
      'status': _statusToString(status),
      // Konversi DateTime ke String YYYY-MM-DD
      'tanggal_efektif': DateFormat('yyyy-MM-dd').format(tanggal),
      'tanggal_pengajuan': tanggalPengajuan, // Sudah dalam format string YYYY-MM-DD

      'alasan': alasan,

      // Konversi DateTime jam? ke String HH:mm:ss
      // Field jam di IzinConverterModel adalah DateTime?, jadi kita harus format jam-nya
      'jam_efektif': jam != null
          ? DateFormat('HH:mm:ss').format(jam!)
          : null,
    };
  }

  // --- Helper untuk Parsing Enum ---

  static IzinTipe _parseTipe(String? tipe) {
    switch (tipe) {
      case 'TELAT_MASUK':
        return IzinTipe.telatMasuk;
      case 'PULANG_AWAL':
        return IzinTipe.pulangAwal;
      case 'TIDAK_MASUK':
        return IzinTipe.tidakMasuk;
      default:
        return IzinTipe.unknown;
    }
  }

  static IzinStatus _parseStatus(String? status) {
    switch (status) {
      case 'PENDING':
        return IzinStatus.pending;
      case 'APPROVED':
        return IzinStatus.approved;
      case 'REJECTED':
        return IzinStatus.rejected;
      default:
        return IzinStatus.unknown;
    }
  }

  static String _tipeToString(IzinTipe tipe) {
    switch (tipe) {
      case IzinTipe.telatMasuk:
        return 'TELAT_MASUK';
      case IzinTipe.pulangAwal:
        return 'PULANG_AWAL';
      case IzinTipe.tidakMasuk:
        return 'TIDAK_MASUK';
      default:
        return 'UNKNOWN';
    }
  }

  static String _statusToString(IzinStatus status) {
    switch (status) {
      case IzinStatus.pending:
        return 'PENDING';
      case IzinStatus.approved:
        return 'APPROVED';
      case IzinStatus.rejected:
        return 'REJECTED';
      default:
        return 'UNKNOWN';
    }
  }
}