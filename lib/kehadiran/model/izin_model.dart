// File: izin_models.dart

import 'package:flutter/material.dart'; // Dibutuhkan untuk TimeOfDay

/// Model untuk "Izin Telat Masuk"
class IzinTelatRequest {
  final String tipe = 'TELAT_MASUK';
  final DateTime tanggal;
  final TimeOfDay jam;
  final String alasan;

  IzinTelatRequest({
    required this.tanggal,
    required this.jam,
    required this.alasan,
  });

  /// Mengonversi model Dart menjadi Map JSON
  Map<String, dynamic> toJson() {
    // Gabungkan tanggal dan jam menjadi satu string DateTime lengkap
    final DateTime tanggalLengkap = DateTime(
      tanggal.year,
      tanggal.month,
      tanggal.day,
      jam.hour,
      jam.minute,
    );

    return {
      // API biasanya lebih suka satu field timestamp
      'tanggal': tanggalLengkap.toIso8601String(), // "2025-11-09T09:30:00.000"
      'alasan': alasan,
    };
  }
}

// ---

/// Model untuk "Izin Pulang Awal"
class IzinPulangAwalRequest {
  final String tipe = 'PULANG_AWAL';
  final DateTime tanggal;
  final TimeOfDay jam;
  final String alasan;

  IzinPulangAwalRequest({
    required this.tanggal,
    required this.jam,
    required this.alasan,
  });

  /// Mengonversi model Dart menjadi Map JSON
  Map<String, dynamic> toJson() {
    // Gabungkan tanggal dan jam
    final DateTime tanggalLengkap = DateTime(
      tanggal.year,
      tanggal.month,
      tanggal.day,
      jam.hour,
      jam.minute,
    );

    return {
      'tanggal': tanggalLengkap.toIso8601String(), // "2025-11-09T16:00:00.000"
      'alasan': alasan,
    };
  }
}

// ---

/// Model untuk "Izin Tidak Masuk"
class IzinTidakMasukRequest {
  final String tipe = 'TIDAK_MASUK';
  final DateTime tanggal;
  final String alasan;

  IzinTidakMasukRequest({
    required this.tanggal,
    required this.alasan,
  });

  /// Mengonversi model Dart menjadi Map JSON
  Map<String, dynamic> toJson() {
    return {
      // Di sini tidak perlu jam, jadi kirim tanggalnya saja
      'tanggal': tanggal.toIso8601String().split('T')[0], // "2025-11-09"
      'alasan': alasan,
    };
  }
}
