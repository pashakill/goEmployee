import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// ===============================================================
/// CUTI QUOTA MANAGER
/// ===============================================================
///
/// Mengatur limit cuti secara LOCAL menggunakan FlutterSecureStorage.
///
/// Tidak mengubah database.
///
/// Contoh:
/// Limit 2026 = 12 hari
/// Terpakai    = 5 hari
/// Sisa        = 7 hari
///
/// Yang dihitung sebagai pemakaian hanya cuti APPROVED.
/// ===============================================================

class CutiQuotaManager {
  final FlutterSecureStorage _storage =
  const FlutterSecureStorage();

  /// Limit default cuti per tahun.
  static const int defaultAnnualLimit = 12;

  /// Prefix key penyimpanan.
  static const String _limitPrefix = 'cuti_limit';

  // ===============================================================
  // KEY
  // ===============================================================

  String _limitKey({
    required String userId,
    required int year,
  }) {
    return '${_limitPrefix}_${userId}_$year';
  }

  // ===============================================================
  // GET LIMIT
  // ===============================================================

  /// Mengambil limit cuti user untuk tahun tertentu.
  ///
  /// Jika belum pernah diatur, otomatis menggunakan
  /// [defaultAnnualLimit].
  Future<int> getLimit({
    required String userId,
    int? year,
  }) async {
    final int targetYear = year ?? DateTime.now().year;

    try {
      final String? value = await _storage.read(
        key: _limitKey(
          userId: userId,
          year: targetYear,
        ),
      );

      if (value == null || value.isEmpty) {
        return defaultAnnualLimit;
      }

      final int? limit = int.tryParse(value);

      if (limit == null || limit < 0) {
        return defaultAnnualLimit;
      }

      return limit;
    } catch (e) {
      print(
        'CutiQuotaManager: Gagal mengambil limit cuti: $e',
      );

      return defaultAnnualLimit;
    }
  }

  // ===============================================================
  // SET LIMIT
  // ===============================================================

  /// Mengatur limit cuti secara lokal.
  ///
  /// Contoh:
  ///
  /// await quotaManager.setLimit(
  ///   userId: '123',
  ///   year: 2026,
  ///   limit: 15,
  /// );
  Future<bool> setLimit({
    required String userId,
    required int limit,
    int? year,
  }) async {
    final int targetYear = year ?? DateTime.now().year;

    if (limit < 0) {
      return false;
    }

    try {
      await _storage.write(
        key: _limitKey(
          userId: userId,
          year: targetYear,
        ),
        value: limit.toString(),
      );

      print(
        'CutiQuotaManager: '
            'Limit cuti user $userId tahun $targetYear '
            'diset menjadi $limit hari.',
      );

      return true;
    } catch (e) {
      print(
        'CutiQuotaManager: Gagal menyimpan limit cuti: $e',
      );

      return false;
    }
  }

  // ===============================================================
  // RESET LIMIT
  // ===============================================================

  /// Menghapus limit custom.
  ///
  /// Setelah dihapus, limit kembali ke defaultAnnualLimit.
  Future<void> resetLimit({
    required String userId,
    int? year,
  }) async {
    final int targetYear = year ?? DateTime.now().year;

    try {
      await _storage.delete(
        key: _limitKey(
          userId: userId,
          year: targetYear,
        ),
      );

      print(
        'CutiQuotaManager: '
            'Limit user $userId tahun $targetYear '
            'di-reset ke default.',
      );
    } catch (e) {
      print(
        'CutiQuotaManager: Gagal reset limit cuti: $e',
      );
    }
  }

  // ===============================================================
  // HITUNG SISA
  // ===============================================================

  /// Menghitung sisa cuti.
  int calculateRemaining({
    required int limit,
    required int used,
  }) {
    final int remaining = limit - used;

    return remaining < 0 ? 0 : remaining;
  }

  // ===============================================================
  // CEK BOLEH / TIDAK
  // ===============================================================

  /// Mengecek apakah user masih boleh mengambil cuti sejumlah [days].
  bool canTakeLeave({
    required int limit,
    required int used,
    required int days,
  }) {
    if (days <= 0) {
      return false;
    }

    final int remaining = calculateRemaining(
      limit: limit,
      used: used,
    );

    return days <= remaining;
  }

  // ===============================================================
  // FORMAT
  // ===============================================================

  String formatQuota({
    required int limit,
    required int used,
  }) {
    final remaining = calculateRemaining(
      limit: limit,
      used: used,
    );

    return '$remaining dari $limit hari';
  }
}