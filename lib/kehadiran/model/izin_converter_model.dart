
// 1. Definisikan Enum untuk Tipe dan Status
// Ini membuat kode Anda lebih aman dari typo string

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

  IzinConverterModel({
    required this.id,
    required this.tipe,
    required this.status,
    required this.tanggal,
    required this.alasan,
    this.jam,
  });

  // 3. Buat 'factory constructor' untuk parsing JSON dari API
  // Ini adalah bagian terpenting
  factory IzinConverterModel.fromJson(Map<String, dynamic> json) {
    return IzinConverterModel(
      id: json['id'] ?? '',

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
}