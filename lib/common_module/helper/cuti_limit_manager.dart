import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Mengelola limit cuti secara lokal.
///
/// Data disimpan di FlutterSecureStorage sehingga tidak perlu
/// mengubah struktur database.
class CutiLimitManager {
  final FlutterSecureStorage _secureStorage =
  const FlutterSecureStorage();

  static const String _defaultLimit = '12';

  /// Mengambil limit cuti default.
  Future<int> getDefaultLimit() async {
    return int.tryParse(_defaultLimit) ?? 12;
  }

  /// Key limit cuti berdasarkan user dan tahun.
  String _limitKey(String userId, int year) {
    return 'cuti_limit_${userId}_$year';
  }

  /// Menyimpan limit cuti untuk user tertentu pada tahun tertentu.
  Future<void> setLimit({
    required String userId,
    required int year,
    required int limit,
  }) async {
    try {
      await _secureStorage.write(
        key: _limitKey(userId, year),
        value: limit.toString(),
      );

      print(
        'CutiLimitManager: Limit cuti user $userId tahun $year '
            'disimpan: $limit hari',
      );
    } catch (e) {
      print(
        'CutiLimitManager: Gagal menyimpan limit cuti - $e',
      );
    }
  }

  /// Mengambil limit cuti user pada tahun tertentu.
  ///
  /// Jika belum pernah disimpan, otomatis menggunakan default 12 hari.
  Future<int> getLimit({
    required String userId,
    required int year,
  }) async {
    try {
      final value = await _secureStorage.read(
        key: _limitKey(userId, year),
      );

      if (value != null && value.isNotEmpty) {
        return int.tryParse(value) ?? 12;
      }

      return await getDefaultLimit();
    } catch (e) {
      print(
        'CutiLimitManager: Gagal mengambil limit cuti - $e',
      );

      return await getDefaultLimit();
    }
  }

  /// Menghapus limit custom user pada tahun tertentu.
  ///
  /// Setelah dihapus, sistem kembali menggunakan default 12 hari.
  Future<void> clearLimit({
    required String userId,
    required int year,
  }) async {
    try {
      await _secureStorage.delete(
        key: _limitKey(userId, year),
      );

      print(
        'CutiLimitManager: Limit custom user $userId '
            'tahun $year berhasil dihapus.',
      );
    } catch (e) {
      print(
        'CutiLimitManager: Gagal menghapus limit cuti - $e',
      );
    }
  }
}